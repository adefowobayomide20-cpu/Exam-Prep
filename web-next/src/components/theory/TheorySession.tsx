"use client";

import Link from "next/link";
import { useState } from "react";
import { httpsCallable, FunctionsError } from "firebase/functions";
import { addDoc, collection, serverTimestamp } from "firebase/firestore";
import { functions, db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { awardTheoryCompletionXp } from "@/lib/gamification";
import { functionsErrorMessage } from "@/lib/functions-errors";

interface Props {
  subject: string;
  /** Stable slug for the quizAttempts `subject` field (see
   * lib/theory-content.ts); falls back to `subject` (the display name) if a
   * caller doesn't pass one, so this stays optional/non-breaking. */
  subjectSlug?: string;
  backHref: string;
}

type Stage = "idle" | "loadingQuestion" | "answering" | "grading" | "result" | "limitReached" | "error";

interface GenerateQuestionResponse {
  question: string;
  topic: string;
}

interface GradeAnswerResponse {
  correct: boolean;
  feedback: string;
}

const describeError = functionsErrorMessage;

function isLimitReached(error: unknown): boolean {
  return error instanceof FunctionsError && error.code === "functions/resource-exhausted";
}

/**
 * Theory practice session for one subject: generate a WAEC-style theory
 * question via the `generateTheoryQuestion` Cloud Function, let the student
 * type an answer, grade it via `gradeTheoryAnswer`, show correctness +
 * step-by-step feedback, and let them request another question (a loop, not
 * an auto-fetch) — mirrors lib/features/exam/theory/theory_session_page.dart
 * minus the photo-answer option, which is out of scope for this phase.
 *
 * The initial question fetch is triggered by a user click ("Get a
 * question"), not a bare useEffect on mount — same reasoning as
 * QuizSession's "Start Test" button: React's set-state-in-effect rule
 * disallows synchronous setState in effects, and starting from a user
 * gesture keeps this component effect-free entirely.
 */
export default function TheorySession({ subject, subjectSlug, backHref }: Props) {
  const { user } = useAuth();
  const [stage, setStage] = useState<Stage>("idle");
  const [question, setQuestion] = useState<string | null>(null);
  const [topic, setTopic] = useState<string | null>(null);
  const [answerText, setAnswerText] = useState("");
  const [result, setResult] = useState<GradeAnswerResponse | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const loadQuestion = async () => {
    setStage("loadingQuestion");
    setErrorMessage(null);
    try {
      const generateTheoryQuestion = httpsCallable<{ subject: string }, GenerateQuestionResponse>(
        functions,
        "generateTheoryQuestion",
      );
      const { data } = await generateTheoryQuestion({ subject });
      setQuestion(data.question);
      setTopic(data.topic);
      setAnswerText("");
      setResult(null);
      setStage("answering");
    } catch (error) {
      if (isLimitReached(error)) {
        setStage("limitReached");
        return;
      }
      setErrorMessage(describeError(error));
      setStage("error");
    }
  };

  const submitAnswer = async () => {
    if (!question || answerText.trim().length === 0) return;
    setStage("grading");
    setErrorMessage(null);
    try {
      const gradeTheoryAnswer = httpsCallable<
        { subject: string; question: string; answerText: string },
        GradeAnswerResponse
      >(functions, "gradeTheoryAnswer");
      const { data } = await gradeTheoryAnswer({
        subject,
        question,
        answerText: answerText.trim(),
      });
      setResult(data);
      setStage("result");
      // Daily Streak + XP (see src/lib/gamification.ts) — awarded once per
      // graded answer (this component is always RequireAuth-wrapped, but
      // guard on `user` anyway, mirroring QuizSession's `if (user)` guard,
      // and to stay safe for signed-out edge cases like a stale session).
      if (user) {
        awardTheoryCompletionXp(user.uid).catch(() => {});
        // Record a quizAttempts-compatible doc so Theory practice shows up
        // in the same home/profile "performance track record" as MCQ
        // practice (see use-quiz-attempts.ts / PerformanceTrackRecord.tsx).
        // Theory is graded correct/incorrect per question rather than
        // scored out of N like an MCQ test, so each graded answer is its
        // own 1-question attempt (score 1 or 0 of 1) — same per-answer
        // granularity as the XP award above, just best-effort like
        // QuizSession's write.
        addDoc(collection(db, "users", user.uid, "quizAttempts"), {
          category: "theory",
          subject: subjectSlug ?? subject,
          subjectName: subject,
          score: data.correct ? 1 : 0,
          totalQuestions: 1,
          completedAt: serverTimestamp(),
        }).catch(() => {});
      }
    } catch (error) {
      if (isLimitReached(error)) {
        setStage("limitReached");
        return;
      }
      setErrorMessage(describeError(error));
      setStage("error");
    }
  };

  return (
    <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
      <div className="flex items-center justify-between">
        <Link href={backHref} className="text-sm font-medium text-gold hover:underline">
          &larr; Back to subjects
        </Link>
      </div>
      <h1 className="mt-4 text-2xl font-bold tracking-tight text-[var(--color-primary)] sm:text-3xl">
        {subject} · Theory
      </h1>

      {stage === "idle" && (
        <div className="mt-8 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
          <p className="text-[var(--color-primary)]/80">
            You&apos;ll get one AI-generated {subject} theory question at a time. Type your
            answer or working, submit it, and get instant, step-by-step marking.
          </p>
          <button
            type="button"
            onClick={loadQuestion}
            className="mt-6 rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light"
          >
            Get a question
          </button>
        </div>
      )}

      {stage === "loadingQuestion" && (
        <div className="mt-8 text-center text-[var(--color-primary)]/70">
          Generating your question…
        </div>
      )}

      {stage === "limitReached" && (
        <div className="mt-8 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
          <p className="font-semibold text-[var(--color-primary)]">
            You&apos;ve reached today&apos;s free Theory limit.
          </p>
          <p className="mt-2 text-[var(--color-primary)]/70">
            Come back tomorrow for more free questions, or upgrade for unlimited AI-marked
            practice.
          </p>
          <Link
            href="/premium"
            className="mt-6 inline-block rounded-full bg-gold px-6 py-2.5 font-semibold text-navy transition-colors hover:opacity-90"
          >
            See Premium
          </Link>
        </div>
      )}

      {stage === "error" && (
        <div className="mt-8 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
          <p className="text-[var(--color-primary)]">{errorMessage}</p>
          <button
            type="button"
            onClick={loadQuestion}
            className="mt-6 rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light"
          >
            Try again
          </button>
        </div>
      )}

      {(stage === "answering" || stage === "grading") && question && (
        <div className="mt-8 flex flex-col gap-4">
          <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
            {topic && (
              <p className="text-xs font-semibold uppercase tracking-wide text-gold">{topic}</p>
            )}
            <p className="mt-2 whitespace-pre-wrap text-[var(--color-primary)]">{question}</p>
          </div>

          <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
            Your answer
            <textarea
              value={answerText}
              onChange={(event) => setAnswerText(event.target.value)}
              disabled={stage === "grading"}
              rows={8}
              placeholder="Write your answer or working here…"
              className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold disabled:opacity-60"
            />
          </label>

          <button
            type="button"
            onClick={submitAnswer}
            disabled={stage === "grading" || answerText.trim().length === 0}
            className="rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
          >
            {stage === "grading" ? "Grading…" : "Submit answer"}
          </button>
        </div>
      )}

      {stage === "result" && question && result && (
        <div className="mt-8 flex flex-col gap-4">
          <p
            className={`text-lg font-bold ${result.correct ? "text-green-600" : "text-red-600"}`}
          >
            {result.correct ? "Well done — correct!" : "Let's go through it"}
          </p>

          <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
            <p className="text-xs font-semibold uppercase tracking-wide text-gold">Question</p>
            <p className="mt-2 whitespace-pre-wrap text-[var(--color-primary)]">{question}</p>
          </div>

          <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
            <p className="text-xs font-semibold uppercase tracking-wide text-gold">Explanation</p>
            <p className="mt-2 whitespace-pre-wrap text-[var(--color-primary)]">{result.feedback}</p>
          </div>

          <button
            type="button"
            onClick={loadQuestion}
            className="rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light"
          >
            Try another question
          </button>
        </div>
      )}
    </div>
  );
}
