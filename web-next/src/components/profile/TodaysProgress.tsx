"use client";

import { computeTodayStats, useProfileAttempts } from "@/components/profile/useProfileInsights";
import CollapsibleSection from "@/components/profile/CollapsibleSection";

/** "Today's Progress" card — questions answered, accuracy, and an
 * *estimated* study time (see useProfileInsights.ts's
 * ESTIMATED_SECONDS_PER_QUESTION doc comment: no real per-session timer
 * exists yet, so this is a documented approximation, not measured time).
 * Collapsed by default (see CollapsibleSection) so this card — one of four
 * sharing a horizontal carousel row — is the same short height as its
 * siblings until tapped open. */
export default function TodaysProgress() {
  const { attempts, loading } = useProfileAttempts();
  if (loading) return null;

  const stats = computeTodayStats(attempts ?? []);

  return (
    <CollapsibleSection title="Today's Progress">
      <dl className="grid grid-cols-3 gap-3 text-center">
        <div>
          <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
            Questions
          </dt>
          <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
            {stats.questionsAnswered}
          </dd>
        </div>
        <div>
          <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
            Accuracy
          </dt>
          <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
            {stats.accuracyPct !== null ? `${stats.accuracyPct}%` : "—"}
          </dd>
        </div>
        <div>
          <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
            Study time*
          </dt>
          <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
            {stats.studyMinutesEstimate} min{stats.studyMinutesEstimate === 1 ? "" : "s"}
          </dd>
        </div>
      </dl>
      <p className="mt-3 text-[10px] leading-tight text-[var(--color-primary)]/50">
        *Estimated from questions answered today (~20s/question) — not a measured timer.
      </p>
    </CollapsibleSection>
  );
}
