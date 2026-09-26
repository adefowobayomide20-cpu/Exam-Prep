"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { doc, onSnapshot } from "firebase/firestore";
import { httpsCallable } from "firebase/functions";
import { db, functions } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { functionsErrorMessage } from "@/lib/functions-errors";
import {
  generatePracticeSetFromOutline,
  type GeneratePracticeSetResponse,
} from "@/lib/practice-generator";
import QuizSession from "@/components/quiz/QuizSession";

const ALLOWED_MIME_TYPES = ["image/jpeg", "image/png", "image/webp"];
// Mirrors MAX_BASE64_LENGTH in functions/practice-generator.js (~6MB raw image).
const MAX_BASE64_LENGTH = 8_000_000;

type InputMode = "text" | "image";
type Stage = "form" | "generating" | "error" | "theory" | "mcq";

interface PendingImage {
  base64: string;
  mimeType: string;
  previewUrl: string;
}

interface GradeAnswerResponse {
  correct: boolean;
  feedback: string;
}

type TheoryStage = "answering" | "grading" | "result";

const describeError = functionsErrorMessage;

/**
 * "Snap your syllabus" — generate a full practice test (30 MCQs + 5 theory
 * questions) from a student's own course outline/topic list, Premium-only.
 *
 * The real premium gate is server-side in generatePracticeSetFromOutline
 * (hard HttpsError('permission-denied') for non-Premium, no free uses at
 * all) — the live `users/{uid}.premium` read here is only so a non-Premium
 * visitor sees a clean upgrade prompt instead of filling out the form and
 * having the submit fail.
 *
 * Flow: theory questions first, then the 30 MCQs via the existing
 * QuizSession component last — QuizSession owns its own full result screen
 * with no "and then do this next" hook, so handing off to it as the final
 * step reads cleaner than trying to resume this page's own UI after it.
 */
export default function GeneratePracticeView() {
  const { user } = useAuth();
  const [premiumActive, setPremiumActive] = useState(false);
  const [premiumLoaded, setPremiumLoaded] = useState(false);

  const [subject, setSubject] = useState("");
  const [inputMode, setInputMode] = useState<InputMode>("text");
  const [topicText, setTopicText] = useState("");
  const [pendingImage, setPendingImage] = useState<PendingImage | null>(null);
  const [fileError, setFileError] = useState<string | null>(null);

  const [stage, setStage] = useState<Stage>("form");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [practiceSet, setPracticeSet] = useState<GeneratePracticeSetResponse | null>(null);

  const [theoryIndex, setTheoryIndex] = useState(0);
  const [theoryStage, setTheoryStage] = useState<TheoryStage>("answering");
  const [theoryAnswer, setTheoryAnswer] = useState("");
  const [theoryResult, setTheoryResult] = useState<GradeAnswerResponse | null>(null);
  const [theoryError, setTheoryError] = useState<string | null>(null);

  useEffect(() => {
    if (!user) return;
    return onSnapshot(doc(db, "users", user.uid), (snapshot) => {
      setPremiumActive(Boolean(snapshot.data()?.premium?.active));
      setPremiumLoaded(true);
    });
  }, [user]);

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    setFileError(null);

    if (!ALLOWED_MIME_TYPES.includes(file.type)) {
      setFileError("Please choose a JPEG, PNG, or WebP image.");
      event.target.value = "";
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      const dataUrl = reader.result as string;
      const commaIndex = dataUrl.indexOf(",");
      const base64 = commaIndex >= 0 ? dataUrl.slice(commaIndex + 1) : dataUrl;

      if (base64.length > MAX_BASE64_LENGTH) {
        setFileError("That image is too large. Try a smaller photo or screenshot.");
        event.target.value = "";
        return;
      }

      setPendingImage({ base64, mimeType: file.type, previewUrl: dataUrl });
    };
    reader.onerror = () => {
      setFileError("Couldn't read that image. Please try again.");
      event.target.value = "";
    };
    reader.readAsDataURL(file);
  };

  const canSubmit =
    subject.trim().length > 0 &&
    (inputMode === "text" ? topicText.trim().length > 0 : pendingImage !== null);

  const submit = async () => {
    if (!canSubmit) return;
    setStage("generating");
    setErrorMessage(null);
    try {
      const data = await generatePracticeSetFromOutline(
        inputMode === "text"
          ? { subject: subject.trim(), topicText: topicText.trim() }
          : {
              subject: subject.trim(),
              imageBase64: pendingImage!.base64,
              mimeType: pendingImage!.mimeType,
            },
      );
      setPracticeSet(data);
      setTheoryIndex(0);
      setTheoryStage("answering");
      setTheoryAnswer("");
      setTheoryResult(null);
      setStage("theory");
    } catch (error) {
      setErrorMessage(describeError(error));
      setStage("error");
    }
  };

  const submitTheoryAnswer = async () => {
    if (!practiceSet || theoryAnswer.trim().length === 0) return;
    const current = practiceSet.theoryQuestions[theoryIndex];
    setTheoryStage("grading");
    setTheoryError(null);
    try {
      const gradeTheoryAnswer = httpsCallable<
        { subject: string; question: string; answerText: string },
        GradeAnswerResponse
      >(functions, "gradeTheoryAnswer");
      const { data } = await gradeTheoryAnswer({
        subject: subject.trim(),
        question: current.question,
        answerText: theoryAnswer.trim(),
      });
      setTheoryResult(data);
      setTheoryStage("result");
    } catch (error) {
      setTheoryError(describeError(error));
      setTheoryStage("answering");
    }
  };

  const nextTheoryQuestion = () => {
    if (!practiceSet) return;
    if (theoryIndex + 1 >= practiceSet.theoryQuestions.length) {
      setStage("mcq");
      return;
    }
    setTheoryIndex((i) => i + 1);
    setTheoryStage("answering");
    setTheoryAnswer("");
    setTheoryResult(null);
  };

  if (!premiumLoaded) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <p className="text-[var(--color-primary)]/70">Checking your Premium status…</p>
      </div>
    );
  }

  if (!premiumActive) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-gold/15 text-3xl">
          🔒
        </div>
        <h1 className="mt-4 text-2xl font-bold text-[var(--color-primary)] sm:text-3xl">
          This is a Premium feature
        </h1>
        <p className="mt-3 text-[var(--color-primary)]/80">
          Snap a photo of your course outline or type a topic list, and get a full 30-question
          practice test plus 5 AI-graded theory questions covering that material. Upgrade to
          Premium to generate practice tests from your own notes.
        </p>
        <Link
          href="/premium"
          className="mt-6 inline-block rounded-full bg-gold px-6 py-2.5 font-semibold text-navy transition-colors hover:opacity-90"
        >
          See Premium
        </Link>
      </div>
    );
  }

  if (stage === "mcq" && practiceSet) {
    return (
      <QuizSession
        title={`${subject.trim()} · Practice Test`}
        backHref="/tutor/generate"
        questions={practiceSet.mcqs}
        sessionSize={30}
        durationMinutes={30}
      />
    );
  }

  if (stage === "theory" && practiceSet) {
    const current = practiceSet.theoryQuestions[theoryIndex];
    const total = practiceSet.theoryQuestions.length;
    return (
      <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
        <h1 className="text-2xl font-bold tracking-tight text-[var(--color-primary)] sm:text-3xl">
          {subject.trim()} · Theory
        </h1>
        <p className="mt-2 text-sm text-[var(--color-primary)]/60">
          Question {theoryIndex + 1} of {total} · then a 30-question practice test
        </p>

        <div className="mt-6 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-gold">
            {current.topic}
          </p>
          <p className="mt-2 whitespace-pre-wrap text-[var(--color-primary)]">
            {current.question}
          </p>
        </div>

        {theoryStage !== "result" && (
          <div className="mt-4 flex flex-col gap-3">
            <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
              Your answer
              <textarea
                value={theoryAnswer}
                onChange={(event) => setTheoryAnswer(event.target.value)}
                disabled={theoryStage === "grading"}
                rows={8}
                placeholder="Write your answer or working here…"
                className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold disabled:opacity-60"
              />
            </label>

            {theoryError && <p className="text-sm text-red-600">{theoryError}</p>}

            <button
              type="button"
              onClick={submitTheoryAnswer}
              disabled={theoryStage === "grading" || theoryAnswer.trim().length === 0}
              className="rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
            >
              {theoryStage === "grading" ? "Grading…" : "Submit answer"}
            </button>
          </div>
        )}

        {theoryStage === "result" && theoryResult && (
          <div className="mt-4 flex flex-col gap-4">
            <p
              className={`text-lg font-bold ${theoryResult.correct ? "text-green-600" : "text-red-600"}`}
            >
              {theoryResult.correct ? "Well done — correct!" : "Let's go through it"}
            </p>
            <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
              <p className="text-xs font-semibold uppercase tracking-wide text-gold">
                Explanation
              </p>
              <p className="mt-2 whitespace-pre-wrap text-[var(--color-primary)]">
                {theoryResult.feedback}
              </p>
            </div>
            <button
              type="button"
              onClick={nextTheoryQuestion}
              className="rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light"
            >
              {theoryIndex + 1 >= total ? "Continue to the 30 MCQs" : "Next question"}
            </button>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
      <h1 className="text-2xl font-bold tracking-tight text-[var(--color-primary)] sm:text-3xl">
        Generate a Practice Test
      </h1>
      <p className="mt-2 text-[var(--color-primary)]/70">
        Snap a photo of your course outline or topic list — or just type it out — and get 30
        auto-graded questions plus 5 AI-graded theory questions covering that material.
      </p>

      {stage === "error" && (
        <div className="mt-6 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
          <p className="text-[var(--color-primary)]">{errorMessage}</p>
        </div>
      )}

      {stage === "generating" ? (
        <div className="mt-8 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
          <p className="text-[var(--color-primary)]">
            Generating your practice test — this can take up to a minute…
          </p>
        </div>
      ) : (
        <div className="mt-8 flex flex-col gap-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
          <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
            Subject
            <input
              type="text"
              value={subject}
              onChange={(event) => setSubject(event.target.value)}
              placeholder="e.g. Chemistry"
              className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold"
            />
          </label>

          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => setInputMode("text")}
              className={`rounded-full px-4 py-2 text-sm font-semibold transition-colors ${
                inputMode === "text"
                  ? "bg-navy text-cream"
                  : "border border-[var(--color-border)] text-[var(--color-primary)] hover:border-gold"
              }`}
            >
              Type topics
            </button>
            <button
              type="button"
              onClick={() => setInputMode("image")}
              className={`rounded-full px-4 py-2 text-sm font-semibold transition-colors ${
                inputMode === "image"
                  ? "bg-navy text-cream"
                  : "border border-[var(--color-border)] text-[var(--color-primary)] hover:border-gold"
              }`}
            >
              Upload a photo
            </button>
          </div>

          {inputMode === "text" ? (
            <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
              Topic list / course outline
              <textarea
                value={topicText}
                onChange={(event) => setTopicText(event.target.value)}
                rows={6}
                placeholder={"e.g. Atomic structure, chemical bonding, periodic table trends, acids and bases…"}
                className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold"
              />
              <span className="text-xs font-normal text-[var(--color-primary)]/60">
                Tip: typing your topic instead of a photo means we can serve you faster next time.
              </span>
            </label>
          ) : (
            <div className="flex flex-col gap-2">
              {pendingImage ? (
                <div className="flex items-start gap-3">
                  <Image
                    src={pendingImage.previewUrl}
                    alt="Selected course outline"
                    width={96}
                    height={96}
                    unoptimized
                    className="h-24 w-24 rounded-lg object-cover"
                  />
                  <button
                    type="button"
                    onClick={() => setPendingImage(null)}
                    className="rounded-full border border-[var(--color-border)] px-3 py-1 text-sm text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold"
                  >
                    Remove photo
                  </button>
                </div>
              ) : (
                <label className="cursor-pointer self-start rounded-full bg-navy px-4 py-2 text-sm font-semibold text-cream transition-colors hover:bg-navy-light">
                  Upload a photo
                  <input
                    type="file"
                    accept="image/jpeg,image/png,image/webp"
                    onChange={handleFileChange}
                    className="hidden"
                  />
                </label>
              )}
              {fileError && <p className="text-sm text-red-600">{fileError}</p>}
              <span className="text-xs font-normal text-[var(--color-primary)]/60">
                Tip: typing your topic instead of a photo means we can serve you faster next time.
              </span>
            </div>
          )}

          <button
            type="button"
            onClick={submit}
            disabled={!canSubmit}
            className="rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
          >
            Generate practice test
          </button>
        </div>
      )}
    </div>
  );
}
