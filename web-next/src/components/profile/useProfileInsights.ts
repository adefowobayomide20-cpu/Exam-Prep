"use client";

import { useEffect, useState } from "react";
import { collection, getDocs, limit, orderBy, query, Timestamp } from "firebase/firestore";
import { useAuth } from "@/lib/auth-context";
import { db } from "@/lib/firebase";

/** Mirrors the doc shape written by QuizSession.tsx/TheorySession.tsx's
 * attempt-recording effects at users/{uid}/quizAttempts/{autoId} — same
 * fields as use-quiz-attempts.ts's QuizAttempt, PLUS `completedAt`, which
 * that hook's type omits. Kept as a standalone local fetch (same query
 * shape/limit as use-quiz-attempts.ts) rather than extending that hook,
 * because this task is scoped to components/profile/** only and
 * src/lib/use-quiz-attempts.ts is outside that scope. */
export interface AttemptWithTime {
  category: string;
  subject: string;
  subjectName: string;
  score: number;
  totalQuestions: number;
  completedAt: Timestamp | null;
}

// Same recent-sample size as use-quiz-attempts.ts and gamification.ts's
// subject-mastery badge check — not a full-history rollup.
const RECENT_ATTEMPTS_LIMIT = 20;

const TIMEZONE = "Africa/Lagos";

/** yyyy-MM-dd in Africa/Lagos, matching the calendar-day convention used by
 * gamification.ts's streak logic (en-CA locale formats as ISO YYYY-MM-DD
 * directly, so no manual padding/parsing needed here). */
function lagosDateKey(date: Date): string {
  return date.toLocaleDateString("en-CA", { timeZone: TIMEZONE });
}

/**
 * Fetches the current user's recent quiz/theory attempts (including
 * `completedAt`) for the Profile page's "Today's Progress", "Performance",
 * and "Weak Topics" cards. `attempts` is `null` while signed out or before
 * the first fetch resolves, `[]` if the user has no tracked attempts yet.
 */
export function useProfileAttempts() {
  const { user } = useAuth();
  const [attempts, setAttempts] = useState<AttemptWithTime[] | null>(null);

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
        setAttempts(
          snapshot.docs.map((docSnap) => {
            const data = docSnap.data();
            return {
              category: typeof data.category === "string" ? data.category : "",
              subject: typeof data.subject === "string" ? data.subject : "",
              subjectName: typeof data.subjectName === "string" ? data.subjectName : (data.subject ?? ""),
              score: typeof data.score === "number" ? data.score : 0,
              totalQuestions: typeof data.totalQuestions === "number" ? data.totalQuestions : 0,
              completedAt: data.completedAt instanceof Timestamp ? data.completedAt : null,
            } satisfies AttemptWithTime;
          }),
        );
      })
      .catch(() => {
        if (!cancelled) setAttempts([]);
      });
    return () => {
      cancelled = true;
    };
  }, [user]);

  // Ignore any stale fetch result from a previous signed-in user once
  // they've signed out — same pattern as use-quiz-attempts.ts.
  const resolvedAttempts = user ? attempts : null;
  return { attempts: resolvedAttempts, loading: !!user && resolvedAttempts === null };
}

export interface TodayStats {
  questionsAnswered: number;
  accuracyPct: number | null;
  studyMinutesEstimate: number;
}

/**
 * ~20s/question average pacing — a documented ESTIMATE, not measured
 * wall-clock time. Real per-session timing would require instrumenting
 * QuizSession.tsx/TheorySession.tsx to persist a `durationSeconds` field,
 * which is deliberately NOT done in this task (too invasive / risk of
 * breaking a working, already-shipped flow). This constant is a reasonable
 * stand-in given the practice-test pacing already assumed elsewhere in this
 * codebase, not a precise measurement — follow-up work, not built here.
 */
const ESTIMATED_SECONDS_PER_QUESTION = 20;

/** Aggregates today's (Africa/Lagos calendar day) attempts: total questions
 * answered (summed totalQuestions, not doc count, so a 20-question MCQ test
 * counts as 20), accuracy across those questions, and an estimated study
 * time (see ESTIMATED_SECONDS_PER_QUESTION above). */
export function computeTodayStats(attempts: AttemptWithTime[]): TodayStats {
  const todayKey = lagosDateKey(new Date());
  const todays = attempts.filter(
    (a) => a.completedAt && lagosDateKey(a.completedAt.toDate()) === todayKey,
  );
  const questionsAnswered = todays.reduce((sum, a) => sum + a.totalQuestions, 0);
  const correct = todays.reduce((sum, a) => sum + a.score, 0);
  const accuracyPct = questionsAnswered === 0 ? null : Math.round((correct / questionsAnswered) * 100);
  const studyMinutesEstimate = Math.round((questionsAnswered * ESTIMATED_SECONDS_PER_QUESTION) / 60);
  return { questionsAnswered, accuracyPct, studyMinutesEstimate };
}

export interface SubjectStat {
  subjectName: string;
  correct: number;
  total: number;
  accuracyPct: number;
}

/** Per-subject accuracy across the recent-attempts sample, sorted best-first
 * for the "Performance" card. */
export function computeSubjectStats(attempts: AttemptWithTime[]): SubjectStat[] {
  const bySubject = new Map<string, { correct: number; total: number }>();
  for (const a of attempts) {
    if (!a.subjectName) continue;
    const entry = bySubject.get(a.subjectName) ?? { correct: 0, total: 0 };
    entry.correct += a.score;
    entry.total += a.totalQuestions;
    bySubject.set(a.subjectName, entry);
  }
  const stats: SubjectStat[] = [];
  for (const [subjectName, { correct, total }] of bySubject) {
    if (total === 0) continue;
    stats.push({ subjectName, correct, total, accuracyPct: Math.round((correct / total) * 100) });
  }
  return stats.sort((a, b) => b.accuracyPct - a.accuracyPct);
}

const WEAK_SUBJECT_THRESHOLD = 70;
const WEAK_SUBJECT_MAX = 3;

/**
 * Bottom N subjects below a "weak" accuracy threshold, for the "Weak
 * Topics" card. NOTE (scoping simplification): this surfaces weak SUBJECTS
 * (e.g. "Mathematics"), not weak TOPICS within a subject (e.g.
 * "Probability", "Logarithms") — quizAttempts only records subject-level
 * score/totalQuestions per attempt, with no per-question topic tag in the
 * current content schema, so genuine topic-level weakness detection isn't
 * possible with existing data. Adding per-question topic tagging is out of
 * scope for this task.
 */
export function computeWeakSubjects(stats: SubjectStat[]): SubjectStat[] {
  return [...stats]
    .filter((s) => s.accuracyPct < WEAK_SUBJECT_THRESHOLD)
    .sort((a, b) => a.accuracyPct - b.accuracyPct)
    .slice(0, WEAK_SUBJECT_MAX);
}
