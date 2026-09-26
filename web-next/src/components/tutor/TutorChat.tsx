"use client";

import Image from "next/image";
import Link from "next/link";
import { useRef, useState } from "react";
import { httpsCallable, FunctionsError } from "firebase/functions";
import { functions } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { awardTutorUsageXp } from "@/lib/gamification";
import { functionsErrorMessage } from "@/lib/functions-errors";

const ALLOWED_MIME_TYPES = ["image/jpeg", "image/png", "image/webp"];
// Mirrors MAX_BASE64_LENGTH in functions/tutor.js (~6MB raw image).
const MAX_BASE64_LENGTH = 8_000_000;

type Status = "idle" | "sending" | "limitReached" | "error";

interface ChatMessage {
  role: "user" | "assistant";
  text: string;
  imagePreviewUrl?: string;
  truncated?: boolean;
}

interface PendingImage {
  base64: string;
  mimeType: string;
  previewUrl: string;
}

interface SolveQuestionRequest {
  imageBase64?: string;
  mimeType?: string;
  question?: string;
  history: { role: "user" | "assistant"; text: string }[];
}

interface SolveQuestionResponse {
  text: string;
  truncated?: boolean;
}

const describeError = functionsErrorMessage;

function isLimitReached(error: unknown): boolean {
  return error instanceof FunctionsError && error.code === "functions/resource-exhausted";
}

/**
 * AI Tutor ("Snap & Solve") chat: upload a photo of a question, optionally
 * add a text note, and get an AI explanation via the `solveQuestion` Cloud
 * Function — mirrors lib/features/tutor/tutor_chat_page.dart minus Firestore
 * persistence (chat history here is local component state only, cleared on
 * refresh, which keeps this phase focused on the core ask/answer loop).
 *
 * Follows the same stage-driven pattern as TheorySession: no bare-useEffect
 * setState, a pending image/question is only cleared once the call
 * succeeds so a failed request can be retried without re-uploading.
 */
export default function TutorChat() {
  const { user } = useAuth();
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [pendingImage, setPendingImage] = useState<PendingImage | null>(null);
  const [questionText, setQuestionText] = useState("");
  const [status, setStatus] = useState<Status>("idle");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [fileError, setFileError] = useState<string | null>(null);
  const [writeMode, setWriteMode] = useState(false);
  const [speakingIndex, setSpeakingIndex] = useState<number | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const cameraInputRef = useRef<HTMLInputElement>(null);

  const resetFileInput = () => {
    if (fileInputRef.current) fileInputRef.current.value = "";
    if (cameraInputRef.current) cameraInputRef.current.value = "";
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setFileError(null);

    if (!ALLOWED_MIME_TYPES.includes(file.type)) {
      setFileError("Please choose a JPEG, PNG, or WebP image.");
      resetFileInput();
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      const dataUrl = reader.result as string;
      const commaIndex = dataUrl.indexOf(",");
      const base64 = commaIndex >= 0 ? dataUrl.slice(commaIndex + 1) : dataUrl;

      if (base64.length > MAX_BASE64_LENGTH) {
        setFileError("That image is too large. Try a smaller photo or screenshot.");
        resetFileInput();
        return;
      }

      setPendingImage({ base64, mimeType: file.type, previewUrl: dataUrl });
    };
    reader.onerror = () => {
      setFileError("Couldn't read that image. Please try again.");
      resetFileInput();
    };
    reader.readAsDataURL(file);
  };

  const removeImage = () => {
    setPendingImage(null);
    resetFileInput();
  };

  // Toggles playback of an assistant reply via the browser's built-in
  // SpeechSynthesis API — purely client-side, no backend involved. Only
  // ever invoked from a click handler (never during render), so it's safe
  // to touch `window.speechSynthesis` directly here.
  const toggleSpeak = (text: string, index: number) => {
    if (typeof window === "undefined" || !window.speechSynthesis) return;
    window.speechSynthesis.cancel();
    if (speakingIndex === index) {
      setSpeakingIndex(null);
      return;
    }
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.onend = () => setSpeakingIndex(null);
    utterance.onerror = () => setSpeakingIndex(null);
    setSpeakingIndex(index);
    window.speechSynthesis.speak(utterance);
  };

  const submit = async () => {
    if (status === "sending") return;
    const trimmedQuestion = questionText.trim();
    if (!pendingImage && !(writeMode && trimmedQuestion)) return;

    setStatus("sending");
    setErrorMessage(null);

    const history = messages.map((message) => ({ role: message.role, text: message.text }));

    try {
      const solveQuestion = httpsCallable<SolveQuestionRequest, SolveQuestionResponse>(
        functions,
        "solveQuestion",
      );
      // Write mode has no image at all: omit imageBase64/mimeType entirely
      // rather than sending them as null/blank, matching the backend's
      // "no image" code path in functions/tutor.js.
      const { data } = await solveQuestion(
        pendingImage
          ? {
              imageBase64: pendingImage.base64,
              mimeType: pendingImage.mimeType,
              question: trimmedQuestion || undefined,
              history,
            }
          : { question: trimmedQuestion, history },
      );

      setMessages((prev) => [
        ...prev,
        {
          role: "user",
          text: trimmedQuestion || "Please solve and explain this question.",
          imagePreviewUrl: pendingImage?.previewUrl,
        },
        { role: "assistant", text: data.text, truncated: data.truncated },
      ]);
      setPendingImage(null);
      setQuestionText("");
      setWriteMode(false);
      resetFileInput();
      setStatus("idle");
      // Small flat XP per successful AI Tutor response (see
      // src/lib/gamification.ts) — this component is always
      // RequireAuth-wrapped, but guard on `user` anyway.
      if (user) {
        awardTutorUsageXp(user.uid).catch(() => {});
      }
    } catch (error) {
      if (isLimitReached(error)) {
        setStatus("limitReached");
        return;
      }
      setErrorMessage(describeError(error));
      setStatus("error");
    }
  };

  return (
    <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
      <h1 className="text-2xl font-bold tracking-tight text-[var(--color-primary)] sm:text-3xl">
        AI Tutor
      </h1>
      <p className="mt-2 text-[var(--color-primary)]/70">
        Snap or upload a photo of a question, or type it out, and get an instant, step-by-step
        explanation — read it, or tap Listen to hear it aloud.
      </p>
      <Link
        href="/teacher"
        className="mt-3 inline-block text-sm font-semibold text-gold hover:underline"
      >
        Want a structured lesson instead? Try AI Teacher →
      </Link>

      {messages.length === 0 && status === "idle" && !pendingImage && !writeMode && (
        <div className="mt-8 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
          <p className="text-[var(--color-primary)]/80">
            Snap a photo with your camera, upload one from your device — a textbook page, a
            past question, your own handwriting — or just type the question out, and the AI
            tutor will walk you through the solution.
          </p>
        </div>
      )}

      {messages.length > 0 && (
        <div className="mt-8 flex flex-col gap-4">
          {messages.map((message, index) => (
            <div
              key={index}
              className={`flex ${message.role === "user" ? "justify-end" : "justify-start"}`}
            >
              <div
                className={`max-w-[85%] rounded-xl p-4 ${
                  message.role === "user"
                    ? "bg-navy text-cream"
                    : "border border-[var(--color-border)] bg-[var(--color-surface-alt)] text-[var(--color-primary)]"
                }`}
              >
                {message.imagePreviewUrl && (
                  <Image
                    src={message.imagePreviewUrl}
                    alt="Uploaded question"
                    width={200}
                    height={200}
                    unoptimized
                    className="mb-2 h-auto max-h-48 w-auto rounded-lg object-contain"
                  />
                )}
                <p className="whitespace-pre-wrap">{message.text}</p>
                {message.truncated && (
                  <p className="mt-2 text-xs italic opacity-70">
                    (Response was cut short — ask a follow-up if you need more.)
                  </p>
                )}
                {message.role === "assistant" &&
                  typeof window !== "undefined" &&
                  !!window.speechSynthesis && (
                    <button
                      type="button"
                      onClick={() => toggleSpeak(message.text, index)}
                      className="mt-2 inline-flex items-center gap-1 rounded-full border border-[var(--color-border)] px-3 py-1 text-xs font-semibold text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold"
                    >
                      {speakingIndex === index ? "⏹ Stop" : "🔊 Listen"}
                    </button>
                  )}
              </div>
            </div>
          ))}
        </div>
      )}

      {status === "sending" && (
        <div className="mt-4 text-center text-[var(--color-primary)]/70">
          Reading and solving&hellip;
        </div>
      )}

      {status === "limitReached" && (
        <div className="mt-8 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
          <p className="font-semibold text-[var(--color-primary)]">
            You&apos;ve reached today&apos;s free Tutor limit.
          </p>
          <p className="mt-2 text-[var(--color-primary)]/70">
            Come back tomorrow for more free questions, or upgrade for unlimited AI tutoring.
          </p>
          <Link
            href="/premium"
            className="mt-6 inline-block rounded-full bg-gold px-6 py-2.5 font-semibold text-navy transition-colors hover:opacity-90"
          >
            See Premium
          </Link>
        </div>
      )}

      {status === "error" && (
        <div className="mt-8 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
          <p className="text-[var(--color-primary)]">{errorMessage}</p>
          <button
            type="button"
            onClick={submit}
            className="mt-6 rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light"
          >
            Try again
          </button>
        </div>
      )}

      {status !== "limitReached" && (
        <div className="mt-8 flex flex-col gap-3 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
          {pendingImage ? (
            <div className="flex items-start gap-3">
              <Image
                src={pendingImage.previewUrl}
                alt="Selected question"
                width={96}
                height={96}
                unoptimized
                className="h-24 w-24 rounded-lg object-cover"
              />
              <button
                type="button"
                onClick={removeImage}
                disabled={status === "sending"}
                className="rounded-full border border-[var(--color-border)] px-3 py-1 text-sm text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold disabled:opacity-60"
              >
                Remove photo
              </button>
            </div>
          ) : writeMode ? (
            <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
              Type your question
              <textarea
                value={questionText}
                onChange={(event) => setQuestionText(event.target.value)}
                disabled={status === "sending"}
                rows={4}
                placeholder="e.g. Solve for x: 2x + 5 = 17"
                className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold disabled:opacity-60"
              />
              <button
                type="button"
                onClick={() => {
                  setWriteMode(false);
                  setQuestionText("");
                }}
                disabled={status === "sending"}
                className="self-start text-sm font-normal text-[var(--color-primary)]/70 underline decoration-dotted transition-colors hover:text-gold disabled:opacity-60"
              >
                Use a photo instead
              </button>
            </label>
          ) : (
            <div className="flex flex-col gap-2">
              <span className="text-sm font-medium text-[var(--color-primary)]">
                Ask a question
              </span>
              <div className="flex flex-wrap gap-2">
                <label className="cursor-pointer rounded-full bg-navy px-4 py-2 text-sm font-semibold text-cream transition-colors hover:bg-navy-light">
                  Upload a photo
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/jpeg,image/png,image/webp"
                    onChange={handleFileChange}
                    className="hidden"
                  />
                </label>
                <label className="cursor-pointer rounded-full border border-[var(--color-border)] px-4 py-2 text-sm font-semibold text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold">
                  Snap a photo
                  <input
                    ref={cameraInputRef}
                    type="file"
                    accept="image/jpeg,image/png,image/webp"
                    capture="environment"
                    onChange={handleFileChange}
                    className="hidden"
                  />
                </label>
                <button
                  type="button"
                  onClick={() => setWriteMode(true)}
                  className="rounded-full border border-[var(--color-border)] px-4 py-2 text-sm font-semibold text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold"
                >
                  Write a question
                </button>
              </div>
            </div>
          )}

          {fileError && <p className="text-sm text-red-600">{fileError}</p>}

          {pendingImage && (
            <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
              Add a note (optional)
              <input
                type="text"
                value={questionText}
                onChange={(event) => setQuestionText(event.target.value)}
                disabled={status === "sending"}
                placeholder="e.g. I don't understand step 2"
                className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold disabled:opacity-60"
              />
            </label>
          )}

          <button
            type="button"
            onClick={submit}
            disabled={
              status === "sending" || !(pendingImage || (writeMode && questionText.trim()))
            }
            className="rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
          >
            {status === "sending" ? "Asking…" : "Ask the tutor"}
          </button>
        </div>
      )}
    </div>
  );
}
