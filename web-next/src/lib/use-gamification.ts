"use client";

import { doc, onSnapshot } from "firebase/firestore";
import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";

export interface GamificationState {
  xp: number;
  streakCount: number;
  longestStreak: number;
  badges: string[];
}

const DEFAULT_STATE: GamificationState = { xp: 0, streakCount: 0, longestStreak: 0, badges: [] };

/**
 * Live-reads the gamification fields on `users/{uid}` (xp, streakCount,
 * longestStreak, badges) written by src/lib/gamification.ts's `award*Xp`
 * functions — same onSnapshot pattern as use-avatar-url.ts. `level` and
 * tier name are intentionally NOT read here: they're derived from `xp` at
 * render time via `levelForXp`/`tierNameForLevel` in gamification.ts, never
 * stored, so they can't drift out of sync.
 *
 * Returns `null` while signed out or before the first Firestore read
 * resolves; returns `DEFAULT_STATE` (all zeros) for a signed-in user who
 * hasn't triggered any gamification write yet (e.g. a brand-new account, or
 * one whose users/{uid} doc predates this feature).
 */
export function useGamification(): GamificationState | null {
  const { user } = useAuth();
  const [state, setState] = useState<GamificationState | null>(null);

  useEffect(() => {
    if (!user) return;
    return onSnapshot(doc(db, "users", user.uid), (snapshot) => {
      const data = snapshot.data();
      setState({
        xp: typeof data?.xp === "number" ? data.xp : 0,
        streakCount: typeof data?.streakCount === "number" ? data.streakCount : 0,
        longestStreak: typeof data?.longestStreak === "number" ? data.longestStreak : 0,
        badges: Array.isArray(data?.badges) ? (data.badges as string[]) : [],
      });
    });
  }, [user]);

  // Ignore any stale snapshot from a previous session once signed out,
  // rather than resetting state synchronously inside the effect above (same
  // pattern as use-avatar-url.ts / use-quiz-attempts.ts).
  if (!user) return null;
  return state ?? DEFAULT_STATE;
}
