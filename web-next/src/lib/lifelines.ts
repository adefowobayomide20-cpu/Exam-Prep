"use client";

import { doc, onSnapshot, runTransaction } from "firebase/firestore";
import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { dateKey, nowInLagos } from "@/lib/gamification";

/**
 * Shared lifeline mechanics for exam-taking sessions — built for regular
 * (single-subject + combined) quiz practice, but deliberately generic so a
 * follow-up task can reuse it for duel-specific lifelines (Freeze /
 * Ask-a-Friend / Ask-Computer) without any MCQ-session-specific assumptions
 * baked in here. Nothing in this file references QuizSession/
 * CombinedQuizSession/DuelSession directly.
 *
 * Two independent caps:
 *  - PER-SESSION: at most `MAX_LIFELINE_USES_PER_SESSION` uses (Hint +
 *    50/50 combined) in one quiz-taking session. Purely local component
 *    state (a plain counter that resets when a new session mounts) — no
 *    Firestore involvement, so it isn't exported from here.
 *  - PER-DAY: at most `MAX_LIFELINE_USES_PER_DAY` uses across ALL sessions,
 *    for a signed-in user, per Africa/Lagos calendar day (same convention
 *    as gamification.ts's streak logic — `dateKey`/`nowInLagos` are
 *    imported from there rather than reimplemented). Persisted at
 *    `users/{uid}.lifelineUsage = { date: "YYYY-MM-DD", count: number }`.
 *
 * CLIENT-TRUST LIMITATION (same deliberate, documented decision as the rest
 * of this system's gamification fields — see gamification.ts): `lifelineUsage`
 * is a plain field on `users/{uid}`, writable by the owning user under the
 * existing generic firestore.rules write rule (only `premium`/`aiUsage`/
 * `bonusUses` are server-only). No server-side validation is added here.
 *
 * Lifelines are only ever offered to signed-in users (the daily cap needs a
 * uid to track against) — callers should gate all of this on `useAuth()`'s
 * `user` being non-null and simply not render lifeline UI otherwise.
 */

/** Max Hint+50/50 uses combined, per single quiz-taking session. Enforced
 * entirely client-side via local component state — see module doc above.
 * Still used as-is by DuelSession.tsx (all 5 duel lifeline kinds share one
 * combined session/day cap, per the user's explicit "2x per exam taking, 3x
 * per daily exam" spec for duels). Regular quiz practice (QuizSession.tsx /
 * CombinedQuizSession.tsx) does NOT use this anymore — see
 * MAX_HINT_USES_PER_SESSION / MAX_FIFTY_FIFTY_USES_PER_SESSION below, which
 * track Hint and 50/50 as two independent allowances instead of one shared
 * pool of 2. */
export const MAX_LIFELINE_USES_PER_SESSION = 2;

/** Max Hint+50/50 uses combined, per signed-in user, per Africa/Lagos
 * calendar day, across every session. Enforced via `consumeDailyLifelineUse`
 * below. Still used as-is by DuelSession.tsx; regular quiz practice uses
 * MAX_HINT_USES_PER_DAY / MAX_FIFTY_FIFTY_USES_PER_DAY instead — see below. */
export const MAX_LIFELINE_USES_PER_DAY = 3;

/**
 * Regular-quiz-practice lifeline caps (QuizSession.tsx / CombinedQuizSession.tsx
 * only — NOT used by duels, which keep the combined MAX_LIFELINE_USES_PER_*
 * pool above). Per the user's correction: "in a quiz question, i can use the
 * hint 2x, and 50/50 2x" per session, "allowed for just 3x in a day" per
 * kind — i.e. Hint and 50/50 are two fully independent allowances (2 uses
 * each per session, 3 uses each per day = 6 total lifeline uses/day), not one
 * shared pool of 2/3 like the original (incorrect) implementation.
 */
export const MAX_HINT_USES_PER_SESSION = 2;
export const MAX_FIFTY_FIFTY_USES_PER_SESSION = 2;
export const MAX_HINT_USES_PER_DAY = 3;
export const MAX_FIFTY_FIFTY_USES_PER_DAY = 3;

interface LifelineUsageDoc {
  date: string;
  count: number;
}

function usedCountForToday(usage: LifelineUsageDoc | null): number {
  if (!usage) return 0;
  const today = dateKey(nowInLagos());
  return usage.date === today ? usage.count : 0;
}

/**
 * Live-reads the signed-in user's daily lifeline usage count, auto-resetting
 * to 0 (in the returned value, not by writing) whenever the stored date
 * isn't today. Mirrors use-gamification.ts's onSnapshot pattern.
 *
 * `uid` is `null` for signed-out users — no subscription is created and
 * `used` stays 0 with `loading: false` (callers should be hiding lifeline UI
 * entirely for signed-out users anyway, per this feature's scope; `used: 0`
 * here is just a safe default, not a claim that signed-out users have a
 * daily allowance).
 */
export function useDailyLifelineUsage(uid: string | null): { used: number; loading: boolean } {
  const [usage, setUsage] = useState<LifelineUsageDoc | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!uid) {
      return;
    }
    return onSnapshot(doc(db, "users", uid), (snapshot) => {
      const data = snapshot.data();
      const raw = data?.lifelineUsage as Partial<LifelineUsageDoc> | undefined;
      setUsage(
        raw && typeof raw.date === "string" && typeof raw.count === "number"
          ? { date: raw.date, count: raw.count }
          : null,
      );
      setLoading(false);
    });
  }, [uid]);

  if (!uid) return { used: 0, loading: false };
  return { used: usedCountForToday(usage), loading };
}

/**
 * Attempts to record one lifeline use against the signed-in user's daily
 * cap. Callers MUST already have checked the per-session cap client-side
 * (cheap, local) before calling this, so the Firestore round trip only
 * happens when a use might actually be allowed.
 *
 * Uses a transaction (same pattern as gamification.ts's `applyActivity`) so
 * concurrent uses (e.g. two tabs) can't both squeeze through past the cap.
 * Returns `{ ok: false, used }` without writing anything if the day's cap is
 * already reached; `{ ok: true, used }` with the incremented count once the
 * write commits.
 */
export async function consumeDailyLifelineUse(uid: string): Promise<{ ok: boolean; used: number }> {
  const userRef = doc(db, "users", uid);
  return runTransaction(db, async (transaction) => {
    const snapshot = await transaction.get(userRef);
    const data = snapshot.data() ?? {};
    const raw = data.lifelineUsage as Partial<LifelineUsageDoc> | undefined;
    const stored: LifelineUsageDoc | null =
      raw && typeof raw.date === "string" && typeof raw.count === "number"
        ? { date: raw.date, count: raw.count }
        : null;
    const today = dateKey(nowInLagos());
    const currentUsed = stored && stored.date === today ? stored.count : 0;

    if (currentUsed >= MAX_LIFELINE_USES_PER_DAY) {
      return { ok: false, used: currentUsed };
    }

    const nextUsed = currentUsed + 1;
    transaction.set(
      userRef,
      { lifelineUsage: { date: today, count: nextUsed } satisfies LifelineUsageDoc },
      { merge: true },
    );
    return { ok: true, used: nextUsed };
  });
}

// ---------------------------------------------------------------------------
// Regular-quiz-practice per-kind daily usage (Hint and 50/50 tracked
// separately — see MAX_HINT_USES_PER_DAY / MAX_FIFTY_FIFTY_USES_PER_DAY
// above). Stored at `users/{uid}.quizLifelineUsage`, a SEPARATE Firestore
// field from `lifelineUsage` (which stays exclusively the duel's combined
// counter, untouched) so fixing the quiz cap model can't affect duels.
// ---------------------------------------------------------------------------

interface QuizLifelineUsageDoc {
  date: string;
  hintCount: number;
  fiftyFiftyCount: number;
}

function quizUsedCountForToday(
  usage: QuizLifelineUsageDoc | null,
): { hintUsed: number; fiftyFiftyUsed: number } {
  if (!usage) return { hintUsed: 0, fiftyFiftyUsed: 0 };
  const today = dateKey(nowInLagos());
  if (usage.date !== today) return { hintUsed: 0, fiftyFiftyUsed: 0 };
  return { hintUsed: usage.hintCount, fiftyFiftyUsed: usage.fiftyFiftyCount };
}

/** Live-reads the signed-in user's daily Hint/50-50 usage, same
 * auto-resets-to-0-on-a-new-day semantics as useDailyLifelineUsage above. */
export function useQuizLifelineUsage(
  uid: string | null,
): { hintUsed: number; fiftyFiftyUsed: number; loading: boolean } {
  const [usage, setUsage] = useState<QuizLifelineUsageDoc | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!uid) {
      return;
    }
    return onSnapshot(doc(db, "users", uid), (snapshot) => {
      const data = snapshot.data();
      const raw = data?.quizLifelineUsage as Partial<QuizLifelineUsageDoc> | undefined;
      setUsage(
        raw &&
          typeof raw.date === "string" &&
          typeof raw.hintCount === "number" &&
          typeof raw.fiftyFiftyCount === "number"
          ? { date: raw.date, hintCount: raw.hintCount, fiftyFiftyCount: raw.fiftyFiftyCount }
          : null,
      );
      setLoading(false);
    });
  }, [uid]);

  if (!uid) return { hintUsed: 0, fiftyFiftyUsed: 0, loading: false };
  const { hintUsed, fiftyFiftyUsed } = quizUsedCountForToday(usage);
  return { hintUsed, fiftyFiftyUsed, loading };
}

/** Attempts to record one Hint or 50/50 use against its OWN daily cap (not
 * the combined duel pool). Same transaction-safety rationale as
 * consumeDailyLifelineUse. */
export async function consumeQuizLifelineUse(
  uid: string,
  kind: "hint" | "fiftyFifty",
): Promise<{ ok: boolean; used: number }> {
  const userRef = doc(db, "users", uid);
  return runTransaction(db, async (transaction) => {
    const snapshot = await transaction.get(userRef);
    const data = snapshot.data() ?? {};
    const raw = data.quizLifelineUsage as Partial<QuizLifelineUsageDoc> | undefined;
    const stored: QuizLifelineUsageDoc | null =
      raw &&
      typeof raw.date === "string" &&
      typeof raw.hintCount === "number" &&
      typeof raw.fiftyFiftyCount === "number"
        ? { date: raw.date, hintCount: raw.hintCount, fiftyFiftyCount: raw.fiftyFiftyCount }
        : null;
    const today = dateKey(nowInLagos());
    const current =
      stored && stored.date === today
        ? stored
        : { date: today, hintCount: 0, fiftyFiftyCount: 0 };

    const currentUsed = kind === "hint" ? current.hintCount : current.fiftyFiftyCount;
    const cap = kind === "hint" ? MAX_HINT_USES_PER_DAY : MAX_FIFTY_FIFTY_USES_PER_DAY;
    if (currentUsed >= cap) {
      return { ok: false, used: currentUsed };
    }

    const next: QuizLifelineUsageDoc = {
      date: today,
      hintCount: kind === "hint" ? current.hintCount + 1 : current.hintCount,
      fiftyFiftyCount: kind === "fiftyFifty" ? current.fiftyFiftyCount + 1 : current.fiftyFiftyCount,
    };
    transaction.set(userRef, { quizLifelineUsage: next }, { merge: true });
    return { ok: true, used: kind === "hint" ? next.hintCount : next.fiftyFiftyCount };
  });
}

/**
 * Builds a textual clue for the Hint lifeline — a real "guess-it" clue (first
 * letter + character count of the correct option), NOT an elimination. Per
 * the user's correction: "if u say hint, then it should mean, giving an
 * answer clue for one to guess right, not cancelling a option from a
 * question" — that's 50/50's job (see applyLifelineElimination below), which
 * Hint no longer touches at all for regular quiz practice.
 */
export function buildHintText(options: string[], correctIndex: number): string {
  const answer = (options[correctIndex] ?? "").trim();
  if (!answer) return "No hint available for this question.";
  const firstChar = answer.charAt(0).toUpperCase();
  return `The correct answer starts with "${firstChar}" and has ${answer.length} character${answer.length === 1 ? "" : "s"}.`;
}

// ---------------------------------------------------------------------------
// Elimination mechanics — pure, data-only (no React, no Firestore). Works off
// any multiple-choice question shape with an `optionCount` and
// `correctIndex`, so it's equally usable for duel questions later.
// ---------------------------------------------------------------------------

export type LifelineKind = "hint" | "fiftyFifty";

/** How many WRONG options each lifeline kind eliminates, at most (fewer if
 * there aren't enough non-correct, non-already-eliminated options left). */
const ELIMINATE_COUNT: Record<LifelineKind, number> = {
  hint: 1,
  fiftyFifty: 2,
};

/**
 * Returns a NEW Set of option indices to treat as eliminated (hidden/disabled)
 * for a question, given what's already eliminated for it. Guarantees:
 *  - `correctIndex` is never included.
 *  - At least 2 options are ever left un-eliminated (never eliminates down to
 *    only the correct answer standing alone).
 *  - Purely additive: previously-eliminated indices are preserved, so
 *    applying Hint then 50/50 to the same question (2 session uses) ends up
 *    eliminating 2 total wrong options, not up to 3.
 *  - Random choice among eligible wrong options, so repeated hints across
 *    different questions don't always eliminate "the same-looking" option.
 */
export function applyLifelineElimination(
  kind: LifelineKind,
  optionCount: number,
  correctIndex: number,
  alreadyEliminated: ReadonlySet<number>,
): Set<number> {
  const result = new Set(alreadyEliminated);
  const maxEliminable = Math.max(0, optionCount - 2);
  const candidates: number[] = [];
  for (let i = 0; i < optionCount; i += 1) {
    if (i === correctIndex || result.has(i)) continue;
    candidates.push(i);
  }
  // Shuffle candidates so elimination choice isn't always index-ascending.
  for (let i = candidates.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [candidates[i], candidates[j]] = [candidates[j], candidates[i]];
  }

  const slotsLeft = maxEliminable - result.size;
  const toEliminate = Math.max(0, Math.min(ELIMINATE_COUNT[kind], slotsLeft, candidates.length));
  for (let i = 0; i < toEliminate; i += 1) {
    result.add(candidates[i]);
  }
  return result;
}

/** Whether a given lifeline kind could eliminate at least one more option for
 * a question in its current state — use this (combined with the session/day
 * caps) to disable a lifeline button once it would have no effect. */
export function canApplyLifeline(optionCount: number, alreadyEliminated: ReadonlySet<number>): boolean {
  const maxEliminable = Math.max(0, optionCount - 2);
  return alreadyEliminated.size < maxEliminable;
}
