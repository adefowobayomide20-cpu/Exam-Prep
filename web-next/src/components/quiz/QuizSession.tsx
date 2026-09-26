"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { addDoc, collection, serverTimestamp } from "firebase/firestore";
import type { QuizQuestionData } from "@/lib/exam-content";
import { useAuth } from "@/lib/auth-context";
import { db } from "@/lib/firebase";
import { awardMcqCompletionXp } from "@/lib/gamification";
import {
  applyLifelineElimination,
  buildHintText,
  canApplyLifeline,
  consumeQuizLifelineUse,
  MAX_FIFTY_FIFTY_USES_PER_DAY,
  MAX_FIFTY_FIFTY_USES_PER_SESSION,
  MAX_HINT_USES_PER_DAY,
  MAX_HINT_USES_PER_SESSION,
  useQuizLifelineUsage,
} from "@/lib/lifelines";
import LifelineControls from "./LifelineControls";
import QuizResult, { scoreFor } from "./QuizResult";

interface Props {
  title: string;
  backHref: string;
  questions: QuizQuestionData[];
  sessionSize: number;
  durationMinutes: number;
  /** Category/subject slugs + display name, used only to record a quiz
   * attempt for signed-in users (see the write effect below) — not required
   * for the quiz mechanics themselves. */
  categorySlug?: string;
  subjectSlug?: string;
  subjectName?: string;
}

function shuffled<T>(items: T[]): T[] {
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

/**
 * Client-side timed MCQ session, modeled on the Flutter app's
 * QuizSessionPage: a time-limit notice before starting (matches
 * showTimeLimitNotice), one question at a time, answer-locking via
 * selection, countdown auto-submits, Previous/Next navigation, submit
 * shows results.
 *
 * Simplification vs. the Flutter app: the 50-50 / hint lifelines are not
 * ported (out of scope for this SEO-focused phase — they're a nice-to-have
 * mobile-app engagement feature, not core to crawlable content or scoring).
 * The question sample is chosen client-side when the student presses
 * "Start Test" (not during SSG, and not in a useEffect — React's
 * set-state-in-effect rule disallows synchronous setState in effects, and
 * starting from a user gesture also avoids any server/client hydration
 * mismatch from random content), matching the app's
 * `questionsForSubject(sampleSize: ...)` shuffle-and-take behavior.
 */
export default function QuizSession({
  title,
  backHref,
  questions,
  sessionSize,
  durationMinutes,
  categorySlug,
  subjectSlug,
  subjectName,
}: Props) {
  const { user } = useAuth();
  const [sessionQuestions, setSessionQuestions] = useState<QuizQuestionData[] | null>(null);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [remainingSeconds, setRemainingSeconds] = useState(durationMinutes * 60);
  const [submitted, setSubmitted] = useState(false);
  const attemptRecorded = useRef(false);

  // Lifelines (Hint / 50/50) — see src/lib/lifelines.ts for the cap logic.
  // Hint and 50/50 are two fully INDEPENDENT allowances (2 uses each per
  // session, 3 uses each per day = 6 total/day), not one shared pool — see
  // the module doc on MAX_HINT_USES_PER_SESSION etc. Session caps are plain
  // local state that resets whenever a new session starts (`startTest`).
  // Daily caps are read live from Firestore; only signed-in users see the
  // controls at all (daily cap needs a uid to track against).
  const quizUsage = useQuizLifelineUsage(user?.uid ?? null);
  const [hintSessionUses, setHintSessionUses] = useState(0);
  const [fiftyFiftySessionUses, setFiftyFiftySessionUses] = useState(0);
  const [eliminatedByQuestion, setEliminatedByQuestion] = useState<Record<number, Set<number>>>({});
  const [hintTextByQuestion, setHintTextByQuestion] = useState<Record<number, string>>({});

  useEffect(() => {
    if (!sessionQuestions || submitted) return;
    const interval = setInterval(() => {
      setRemainingSeconds((seconds) => {
        if (seconds <= 1) {
          clearInterval(interval);
          setSubmitted(true);
          return 0;
        }
        return seconds - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, [sessionQuestions, submitted]);

  // Persist a lightweight attempt record for signed-in users once a test is
  // submitted, so the home page can show "continue practicing" + a
  // performance track record (see users/{uid}/quizAttempts in
  // firestore.rules — already covered by the generic per-user subcollection
  // rule, no rules change needed). Signed-out users are skipped entirely; no
  // mid-session state is recorded, only the final score.
  useEffect(() => {
    if (!submitted || !sessionQuestions || attemptRecorded.current) return;
    if (!user || !categorySlug || !subjectSlug) return;
    attemptRecorded.current = true;
    const score = scoreFor(sessionQuestions, answers);
    addDoc(collection(db, "users", user.uid, "quizAttempts"), {
      category: categorySlug,
      subject: subjectSlug,
      subjectName: subjectName ?? subjectSlug,
      score,
      totalQuestions: sessionQuestions.length,
      completedAt: serverTimestamp(),
    }).catch(() => {
      // Best-effort — a failed write shouldn't block the student from
      // seeing their result.
    });
    // Daily Streak + XP (see src/lib/gamification.ts) — same best-effort,
    // never-block-the-result handling as the attempt write above.
    awardMcqCompletionXp(user.uid, score, sessionQuestions.length).catch(() => {});
  }, [submitted, sessionQuestions, answers, user, categorySlug, subjectSlug, subjectName]);

  const startTest = () => {
    setSessionQuestions(shuffled(questions).slice(0, sessionSize));
    setRemainingSeconds(durationMinutes * 60);
    setHintSessionUses(0);
    setFiftyFiftySessionUses(0);
    setEliminatedByQuestion({});
    setHintTextByQuestion({});
  };

  const currentEliminated = eliminatedByQuestion[currentIndex] ?? new Set<number>();

  const triggerHint = async () => {
    if (!user || !sessionQuestions) return;
    if (hintSessionUses >= MAX_HINT_USES_PER_SESSION) return;
    if (hintTextByQuestion[currentIndex]) return;
    const result = await consumeQuizLifelineUse(user.uid, "hint").catch(() => ({ ok: false, used: quizUsage.hintUsed }));
    if (!result.ok) return;
    setHintSessionUses((n) => n + 1);
    const question = sessionQuestions[currentIndex];
    setHintTextByQuestion((prev) => ({
      ...prev,
      [currentIndex]: buildHintText(question.options, question.correctIndex),
    }));
  };

  const triggerFiftyFifty = async () => {
    if (!user || !sessionQuestions) return;
    if (fiftyFiftySessionUses >= MAX_FIFTY_FIFTY_USES_PER_SESSION) return;
    if (!canApplyLifeline(sessionQuestions[currentIndex].options.length, currentEliminated)) return;
    const result = await consumeQuizLifelineUse(user.uid, "fiftyFifty").catch(() => ({ ok: false, used: quizUsage.fiftyFiftyUsed }));
    if (!result.ok) return;
    setFiftyFiftySessionUses((n) => n + 1);
    setEliminatedByQuestion((prev) => ({
      ...prev,
      [currentIndex]: applyLifelineElimination(
        "fiftyFifty",
        sessionQuestions[currentIndex].options.length,
        sessionQuestions[currentIndex].correctIndex,
        currentEliminated,
      ),
    }));
  };

  if (submitted && sessionQuestions) {
    return (
      <QuizResult title={title} backHref={backHref} questions={sessionQuestions} answers={answers} />
    );
  }

  if (!sessionQuestions) {
    const actualSize = Math.min(sessionSize, questions.length);
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <h1 className="text-2xl font-bold text-[var(--color-primary)]">{title}</h1>
        <p className="mt-4 text-[var(--color-primary)]/80">
          You will have <strong>{durationMinutes} minutes</strong> to answer{" "}
          <strong>{actualSize} questions</strong>. The timer starts as soon as
          you press Start — answer at your own pace and submit before time
          runs out.
        </p>
        <button
          type="button"
          onClick={startTest}
          className="mt-8 inline-flex items-center rounded-full bg-gold px-6 py-3 text-sm font-semibold text-navy transition-colors hover:brightness-105"
        >
          Start Test
        </button>
        <Link
          href={backHref}
          className="mt-6 block text-center text-xs text-[var(--color-primary)]/50 hover:underline"
        >
          Cancel
        </Link>
      </div>
    );
  }

  const question = sessionQuestions[currentIndex];
  const isLast = currentIndex === sessionQuestions.length - 1;
  const clamped = Math.max(0, remainingSeconds);
  const minutes = String(Math.floor(clamped / 60)).padStart(2, "0");
  const seconds = String(clamped % 60).padStart(2, "0");
  const isLowTime = clamped <= 60;

  return (
    <div className="mx-auto max-w-2xl px-4 py-8 sm:px-6">
      <div className="flex items-center justify-between">
        <h1 className="text-lg font-semibold text-[var(--color-primary)]">{title}</h1>
        <span
          className={`rounded-full px-3 py-1 text-sm font-bold tabular-nums ${
            isLowTime
              ? "bg-[var(--color-danger-bg)] text-[var(--color-danger-text)]"
              : "bg-[var(--color-surface-alt)] text-[var(--color-primary)]"
          }`}
        >
          {minutes}:{seconds}
        </span>
      </div>

      <div className="mt-4 h-1.5 w-full overflow-hidden rounded-full bg-[var(--color-border)]">
        <div
          className="h-full rounded-full bg-gold transition-all duration-300"
          style={{ width: `${((currentIndex + 1) / sessionQuestions.length) * 100}%` }}
        />
      </div>
      <p className="mt-2 text-xs text-[var(--color-primary)]/60">
        Question {currentIndex + 1} of {sessionQuestions.length} · {question.subject}
      </p>

      {user && (
        <LifelineControls
          onHint={() => void triggerHint()}
          onFiftyFifty={() => void triggerFiftyFifty()}
          hintDisabled={
            hintSessionUses >= MAX_HINT_USES_PER_SESSION ||
            quizUsage.hintUsed >= MAX_HINT_USES_PER_DAY ||
            Boolean(hintTextByQuestion[currentIndex])
          }
          fiftyFiftyDisabled={
            fiftyFiftySessionUses >= MAX_FIFTY_FIFTY_USES_PER_SESSION ||
            quizUsage.fiftyFiftyUsed >= MAX_FIFTY_FIFTY_USES_PER_DAY ||
            !canApplyLifeline(question.options.length, currentEliminated)
          }
          hintUsesRemaining={Math.max(0, MAX_HINT_USES_PER_DAY - quizUsage.hintUsed)}
          fiftyFiftyUsesRemaining={Math.max(0, MAX_FIFTY_FIFTY_USES_PER_DAY - quizUsage.fiftyFiftyUsed)}
          hintText={hintTextByQuestion[currentIndex]}
        />
      )}

      <div className="mt-6">
        <p className="text-base font-medium text-[var(--color-primary)]">{question.text}</p>
        <div className="mt-4 space-y-2">
          {question.options.map((option, optionIndex) => {
            const selected = answers[currentIndex] === optionIndex;
            const eliminated = currentEliminated.has(optionIndex);
            return (
              <button
                key={optionIndex}
                type="button"
                disabled={eliminated}
                onClick={() =>
                  setAnswers((prev) => ({ ...prev, [currentIndex]: optionIndex }))
                }
                className={`flex w-full items-center gap-3 rounded-xl border px-4 py-3 text-left transition-colors ${
                  eliminated
                    ? "cursor-not-allowed border-[var(--color-border)] bg-[var(--color-surface-alt)] opacity-40 line-through"
                    : selected
                    ? "border-gold bg-gold/10"
                    : "border-[var(--color-border)] bg-[var(--color-surface-alt)] hover:border-gold/50"
                }`}
              >
                <span
                  className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-full border text-xs font-semibold ${
                    selected
                      ? "border-gold bg-gold text-navy"
                      : "border-[var(--color-border)] text-[var(--color-primary)]/60"
                  }`}
                >
                  {String.fromCharCode(65 + optionIndex)}
                </span>
                <span className="text-sm text-[var(--color-primary)]">{option}</span>
              </button>
            );
          })}
        </div>
      </div>

      <div className="mt-8 flex items-center gap-3">
        {currentIndex > 0 && (
          <button
            type="button"
            onClick={() => setCurrentIndex((i) => i - 1)}
            className="flex-1 rounded-full border border-[var(--color-border)] px-4 py-3 text-sm font-semibold text-[var(--color-primary)]"
          >
            Previous
          </button>
        )}
        <button
          type="button"
          onClick={isLast ? () => setSubmitted(true) : () => setCurrentIndex((i) => i + 1)}
          className="flex-1 rounded-full bg-navy px-4 py-3 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
        >
          {isLast ? "Submit" : "Next"}
        </button>
      </div>

      <Link
        href={backHref}
        className="mt-6 block text-center text-xs text-[var(--color-primary)]/50 hover:underline"
      >
        Leave test (progress will be lost)
      </Link>
    </div>
  );
}
