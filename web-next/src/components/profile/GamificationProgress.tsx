"use client";

import { useGamification } from "@/lib/use-gamification";
import { BADGES, levelProgress } from "@/lib/gamification";
import CollapsibleSection from "@/components/profile/CollapsibleSection";

/**
 * "Achievements" card for the Profile page (level progress + streak detail
 * + earned-badges grid) — the fuller companion to the compact
 * level/streak/XP/coins line shown in ProfileView's top summary card.
 * Design choice: unearned badges are shown grayed-out with their
 * requirement text (rather than omitted) so the full badge set is
 * discoverable — a simple locked/unlocked treatment, no separate
 * "browse all badges" surface needed for this MVP. Collapsed by default —
 * see TodaysProgress.tsx's doc comment for why.
 */
export default function GamificationProgress() {
  const state = useGamification();
  if (!state) return null;

  const { level, tierName, nextLevelXp, progress } = levelProgress(state.xp);

  return (
    <CollapsibleSection title="Achievements">
      <div>
        <p className="text-lg font-bold text-[var(--color-primary)]">
          Level {level} · {tierName}
        </p>
        <p className="mt-1 text-sm text-[var(--color-primary)]/70">
          {state.xp.toLocaleString()} XP
          {nextLevelXp !== null
            ? ` · ${(nextLevelXp - state.xp).toLocaleString()} XP to Level ${level + 1}`
            : " · Max level reached"}
        </p>
        <div className="mt-3 h-2 w-full overflow-hidden rounded-full bg-[var(--color-border)]">
          <div
            className="h-full rounded-full bg-gold transition-all duration-300"
            style={{ width: `${Math.round(progress * 100)}%` }}
          />
        </div>
      </div>

      <dl className="mt-6 grid grid-cols-2 gap-4">
        <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
          <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
            Current streak
          </dt>
          <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
            🔥 {state.streakCount} day{state.streakCount === 1 ? "" : "s"}
          </dd>
        </div>
        <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
          <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
            Longest streak
          </dt>
          <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
            🏅 {state.longestStreak} day{state.longestStreak === 1 ? "" : "s"}
          </dd>
        </div>
      </dl>

      <div className="mt-6">
        <p className="text-sm font-semibold text-[var(--color-primary)]">Badges</p>
        <ul className="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-3">
          {BADGES.map((badge) => {
            const earned = state.badges.includes(badge.id);
            return (
              <li
                key={badge.id}
                className={`rounded-xl border p-3 text-center ${
                  earned
                    ? "border-gold bg-gold/10"
                    : "border-[var(--color-border)] bg-[var(--color-surface-alt)] opacity-50"
                }`}
              >
                <p className="text-2xl" aria-hidden="true">
                  {badge.icon}
                </p>
                <p className="mt-1 text-xs font-semibold text-[var(--color-primary)]">{badge.name}</p>
                {!earned && (
                  <p className="mt-1 text-[10px] leading-tight text-[var(--color-primary)]/60">
                    {badge.description}
                  </p>
                )}
              </li>
            );
          })}
        </ul>
      </div>
    </CollapsibleSection>
  );
}
