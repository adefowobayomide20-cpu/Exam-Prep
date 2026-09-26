"use client";

import { useEffect, useState } from "react";
import { collection, getDocs, limit, orderBy, query } from "firebase/firestore";
import { useAuth } from "@/lib/auth-context";
import { db } from "@/lib/firebase";

/** Mirrors the doc shape written by QuizSession.tsx's attempt-recording
 * effect at users/{uid}/quizAttempts/{autoId}. `completedAt` is a Firestore
 * server timestamp — not read here since the query already orders by it. */
export interface QuizAttempt {
  category: string;
  subject: string;
  subjectName: string;
  score: number;
  totalQuestions: number;
}

// Reasonable-limit sample for a simple client-side aggregate (average score,
// most-practiced subject) — no server-side rollup / Cloud Function needed
// for a home-page summary.
const RECENT_ATTEMPTS_LIMIT = 20;

/**
 * Fetches the current user's most recent quiz attempts for the home page's
 * "continue practicing" CTA and performance track record. `attempts` is
 * `null` while signed out or before the first fetch resolves, and `[]` if
 * the user has never completed a practice test (or the read fails).
 */
export function useQuizAttempts() {
  const { user } = useAuth();
  const [attempts, setAttempts] = useState<QuizAttempt[] | null>(null);

  useEffect(() => {
    if (!user) return;
    let cancelled = false;
    const attemptsQuery = query(
      collection(db, "users", user.uid, "quizAttempts"),
      orderBy("completedAt", "desc"),
      limit(RECENT_ATTEMPTS_LIMIT),
    );
    getDocs(attemptsQuery)
      .then((snapshot) => {
        if (cancelled) return;
        setAttempts(snapshot.docs.map((doc) => doc.data() as QuizAttempt));
      })
      .catch(() => {
        if (!cancelled) setAttempts([]);
      });
    return () => {
      cancelled = true;
    };
  }, [user]);

  // Ignore any stale fetch result from a previous signed-in user once
  // they've signed out, without needing to reset state synchronously inside
  // the effect above (which react-hooks/set-state-in-effect disallows).
  const resolvedAttempts = user ? attempts : null;
  return { attempts: resolvedAttempts, loading: !!user && resolvedAttempts === null };
}
