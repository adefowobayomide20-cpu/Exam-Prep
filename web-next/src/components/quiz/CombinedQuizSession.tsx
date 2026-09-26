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
import CombinedQuizResult from "./CombinedQuizResult";

export interface CombinedSubjectQuestions {
  slug: string;
  name: string;
  questions: QuizQuestionData[];
}

interface FlatQuestion {
  subjectIndex: number;
  question: QuizQuestionData;
}

interface Props {
  subjects: CombinedSubjectQuestions[];
  durationMinutes: number;
  /** Heading shown above the timer. Defaults to the original JAMB combined
   * copy so the existing `JambCombinedFlow` usage is unaffected. */
  title?: string;
  /** Heading shown on the result screen (`CombinedQuizResult`). */
  resultTitle?: string;
  /** "Leave exam" / "Done" link target. Defaults to `/jamb/combined`. */
  backHref?: string;
  /** `quizAttempts` doc `category` field. Defaults to "jamb" (unchanged
   * behavior for the existing JAMB combined flow). Post-UTME's combined flow
   * passes "post-utme" so these attempts group with the school's other
   * post-utme attempts for profile/weak-subject aggregation. */
  category?: string;
}

/**
 * The JAMB combined (4-subject) practice session: ONE shared countdown
 * timer across all subjects, questions presented back-to-back grouped by
 * subject with a clear "Subject X of 4" header, one answer track keyed by
 * the flattened question index. Modeled closely on QuizSession.tsx's timer
 * / answer-tracking / submit internals (that component is left untouched —
 * this is a separate component for the multi-subject flow).
 *
 * Question sampling already happened server-side (see
 * /api/jamb-combined/route.ts) before this component is mounted, so —
 * unlike QuizSession.tsx — there's no "Start Test" gesture here; the timer
 * starts as soon as this component renders its first question.
 */
export default function CombinedQuizSession({
  subjects,
  durationMinutes,
  title = "JAMB Combined Exam",
  resultTitle,
  backHref = "/jamb/combined",
  category = "jamb",
}: Props) {
  const { user } = useAuth();
  const flat: FlatQuestion[] = subjects.flatMap((subject, subjectIndex) =>
    subject.questions.map((question) => ({ subjectIndex, question })),
  );

  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [remainingSeconds, setRemainingSeconds] = useState(durationMinutes * 60);
  const [submitted, setSubmitted] = useState(false);
  const attemptRecorded = useRef(false);

  // Lifelines (Hint / 50/50) — see src/lib/lifelines.ts. Hint and 50/50 are
  // two fully independent allowances (2 uses each per session, 3 uses each
  // per day). Session caps are local state that naturally reset on each
  // fresh mount of this component (no "Start Test" gesture here to hook a
  // reset into, unlike QuizSession.tsx — a new combined session is always a
  // new mount). Daily caps are read live from Firestore; controls are hidden
  // entirely for signed-out users.
  const quizUsage = useQuizLifelineUsage(user?.uid ?? null);
  const [hintSessionUses, setHintSessionUses] = useState(0);
  const [fiftyFiftySessionUses, setFiftyFiftySessionUses] = useState(0);
  const [eliminatedByQuestion, setEliminatedByQuestion] = useState<Record<number, Set<number>>>({});
  const [hintTextByQuestion, setHintTextByQuestion] = useState<Record<number, string>>({});
  const currentEliminated = eliminatedByQuestion[currentIndex] ?? new Set<number>();

  const triggerHint = async () => {
    if (!user) return;
    if (hintSessionUses >= MAX_HINT_USES_PER_SESSION) return;
    if (hintTextByQuestion[currentIndex]) return;
    const current = flat[currentIndex];
    const result = await consumeQuizLifelineUse(user.uid, "hint").catch(() => ({ ok: false, used: quizUsage.hintUsed }));
    if (!result.ok) return;
    setHintSessionUses((n) => n + 1);
    setHintTextByQuestion((prev) => ({
      ...prev,
      [currentIndex]: buildHintText(current.question.options, current.question.correctIndex),
    }));
  };

  const triggerFiftyFifty = async () => {
    if (!user) return;
    if (fiftyFiftySessionUses >= MAX_FIFTY_FIFTY_USES_PER_SESSION) return;
    const current = flat[currentIndex];
    if (!canApplyLifeline(current.question.options.length, currentEliminated)) return;
    const result = await consumeQuizLifelineUse(user.uid, "fiftyFifty").catch(() => ({ ok: false, used: quizUsage.fiftyFiftyUsed }));
    if (!result.ok) return;
    setFiftyFiftySessionUses((n) => n + 1);
    setEliminatedByQuestion((prev) => ({
      ...prev,
      [currentIndex]: applyLifelineElimination(
        "fiftyFifty",
        current.question.options.length,
        current.question.correctIndex,
        currentEliminated,
      ),
    }));
  };

  useEffect(() => {
    if (submitted) return;
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
  }, [submitted]);

  // Persist one quizAttempts doc per subject (sharing a sessionId) and award
  // MCQ XP once per subject. This matches the existing single-subject
  // quizAttempts doc shape exactly (see QuizSession.tsx / use-quiz-attempts.ts
  // / PerformanceTrackRecord.tsx / gamification.ts's subject-mastery badge
  // check, all of which assume one doc = one subject's score) rather than
  // inventing a new "combined" doc shape those readers wouldn't understand.
  // awardMcqCompletionXp's streak/daily-login logic only fires once per
  // Lagos calendar day regardless of how many times it's called (see
  // gamification.ts's `countsForStreak` check against `lastActivityDate`),
  // so calling it 4x here is safe — it just adds each subject's own
  // accuracy-scaled XP, the same as if the student had practiced all 4
  // subjects separately.
  useEffect(() => {
    if (!submitted || attemptRecorded.current) return;
    if (!user) return;
    attemptRecorded.current = true;
    const sessionId = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
    let offset = 0;
    for (const subject of subjects) {
      const subjectAnswers: Record<number, number> = {};
      subject.questions.forEach((_, i) => {
        if (answers[offset + i] !== undefined) subjectAnswers[i] = answers[offset + i];
      });
      const score = subject.questions.reduce(
        (s, q, i) => (subjectAnswers[i] === q.correctIndex ? s + 1 : s),
        0,
      );
      addDoc(collection(db, "users", user.uid, "quizAttempts"), {
        category,
        subject: subject.slug,
        subjectName: subject.name,
        score,
        totalQuestions: subject.questions.length,
        completedAt: serverTimestamp(),
        sessionId,
        combined: true,
      }).catch(() => {});
      awardMcqCompletionXp(user.uid, score, subject.questions.length).catch(() => {});
      offset += subject.questions.length;
    }
  }, [submitted, subjects, answers, user, category]);

  if (submitted) {
    return (
      <CombinedQuizResult
        subjects={subjects}
        answers={answers}
        title={resultTitle ?? `${title} · Result`}
        backHref={backHref}
      />
    );
  }

  const current = flat[currentIndex];
  const subject = subjects[current.subjectIndex];
  const questionIndexInSubject =
    currentIndex - subjects.slice(0, current.subjectIndex).reduce((n, s) => n + s.questions.length, 0);
  const isLast = currentIndex === flat.length - 1;
  const clamped = Math.max(0, remainingSeconds);
  const minutes = String(Math.floor(clamped / 60)).padStart(2, "0");
  const seconds = String(clamped % 60).padStart(2, "0");
  const isLowTime = clamped <= 300;

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
          style={{ width: `${((currentIndex + 1) / flat.length) * 100}%` }}
        />
      </div>
      <p className="mt-2 text-xs font-semibold uppercase tracking-wide text-gold">
        Subject {current.subjectIndex + 1} of {subjects.length}: {subject.name} (Q
        {questionIndexInSubject + 1}/{subject.questions.length})
      </p>
      <p className="mt-1 text-xs text-[var(--color-primary)]/60">
        Overall question {currentIndex + 1} of {flat.length}
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
            !canApplyLifeline(current.question.options.length, currentEliminated)
          }
          hintUsesRemaining={Math.max(0, MAX_HINT_USES_PER_DAY - quizUsage.hintUsed)}
          fiftyFiftyUsesRemaining={Math.max(0, MAX_FIFTY_FIFTY_USES_PER_DAY - quizUsage.fiftyFiftyUsed)}
          hintText={hintTextByQuestion[currentIndex]}
        />
      )}

      <div className="mt-6">
        <p className="text-base font-medium text-[var(--color-primary)]">
          {current.question.text}
        </p>
        <div className="mt-4 space-y-2">
          {current.question.options.map((option, optionIndex) => {
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
        Leave exam (progress will be lost)
      </Link>
    </div>
  );
}
