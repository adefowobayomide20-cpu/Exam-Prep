"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import { useGamification } from "@/lib/use-gamification";
import { levelProgress } from "@/lib/gamification";

/**
 * Compact at-a-glance streak/level/XP line for the top of the home page
 * body, e.g. "🔥 12-day streak · Level 5 Scholar · 1,240 XP". Reads live
 * from `users/{uid}` via useGamification (see src/lib/gamification.ts for
 * the XP/level design). Renders nothing while signed out — the existing
 * PerformanceTrackRecord section below already carries the "sign in to
 * track your progress" CTA, so this stays uncluttered rather than
 * duplicating that prompt.
 */
export default function GamificationSummary() {
  const { user, loading } = useAuth();
  const state = useGamification();

  if (loading || !user || !state) return null;

  const { level, tierName, progress } = levelProgress(state.xp);

  return (
    <section className="mt-8 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-5 py-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm font-semibold text-[var(--color-primary)]">
          🔥 {state.streakCount}-day streak · Level {level} {tierName} ·{" "}
          {state.xp.toLocaleString()} XP
        </p>
        <Link href="/profile" className="shrink-0 text-xs font-semibold text-gold hover:underline">
          View progress →
        </Link>
      </div>
      <div className="mt-3 h-1.5 w-full overflow-hidden rounded-full bg-[var(--color-border)]">
        <div
          className="h-full rounded-full bg-gold transition-all duration-300"
          style={{ width: `${Math.round(progress * 100)}%` }}
        />
      </div>
    </section>
  );
}
