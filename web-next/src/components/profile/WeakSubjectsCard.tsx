"use client";

import {
  computeSubjectStats,
  computeWeakSubjects,
  useProfileAttempts,
} from "@/components/profile/useProfileInsights";
import CollapsibleSection from "@/components/profile/CollapsibleSection";

/**
 * "Weak Topics" card — scoped down to weak SUBJECTS, not per-topic
 * granularity (e.g. "Probability", "Logarithms", "Organic Chemistry" from
 * the design mock). quizAttempts records one score/totalQuestions pair per
 * whole attempt at the SUBJECT level (see QuizSession.tsx/TheorySession.tsx)
 * — there's no per-question topic tag anywhere in the current content
 * schema, so true topic-level weakness detection isn't possible with
 * existing data. Showing weak subjects instead is an honest, clearly-labeled
 * simplification; adding per-question topic tagging is out of scope here.
 * Collapsed by default — see TodaysProgress.tsx's doc comment for why.
 */
export default function WeakSubjectsCard() {
  const { attempts, loading } = useProfileAttempts();
  if (loading) return null;

  const weak = computeWeakSubjects(computeSubjectStats(attempts ?? []));
  if (weak.length === 0) return null;

  return (
    <CollapsibleSection title="Weak Subjects">
      <p className="text-xs text-[var(--color-primary)]/60">
        Subjects under 70% accuracy in your recent practice — real per-topic
        breakdowns (e.g. specific weak chapters) aren&apos;t tracked yet.
      </p>
      <ul className="mt-3 space-y-2">
        {weak.map((s) => (
          <li
            key={s.subjectName}
            className="flex items-center justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-2"
          >
            <span className="text-sm text-[var(--color-primary)]">{s.subjectName}</span>
            <span className="text-sm font-semibold text-red-600">{s.accuracyPct}%</span>
          </li>
        ))}
      </ul>
    </CollapsibleSection>
  );
}
