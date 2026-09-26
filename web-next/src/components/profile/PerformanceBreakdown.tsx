"use client";

import { computeSubjectStats, useProfileAttempts } from "@/components/profile/useProfileInsights";
import CollapsibleSection from "@/components/profile/CollapsibleSection";

/** "Performance" card — per-subject accuracy % with a simple width-percentage
 * bar, same visual pattern as GamificationProgress.tsx's level-progress bar.
 * Aggregated from the same recent quizAttempts sample as the rest of the
 * Profile insights cards (see useProfileInsights.ts). Collapsed by default —
 * see TodaysProgress.tsx's doc comment for why. */
export default function PerformanceBreakdown() {
  const { attempts, loading } = useProfileAttempts();
  if (loading) return null;

  const stats = computeSubjectStats(attempts ?? []);
  if (stats.length === 0) return null;

  return (
    <CollapsibleSection title="Performance">
      <ul className="space-y-3">
        {stats.map((s) => (
          <li key={s.subjectName}>
            <div className="flex items-center justify-between text-sm">
              <span className="text-[var(--color-primary)]">{s.subjectName}</span>
              <span className="font-semibold text-[var(--color-primary)]">{s.accuracyPct}%</span>
            </div>
            <div className="mt-1 h-2 w-full overflow-hidden rounded-full bg-[var(--color-border)]">
              <div
                className="h-full rounded-full bg-gold transition-all duration-300"
                style={{ width: `${s.accuracyPct}%` }}
              />
            </div>
          </li>
        ))}
      </ul>
    </CollapsibleSection>
  );
}
