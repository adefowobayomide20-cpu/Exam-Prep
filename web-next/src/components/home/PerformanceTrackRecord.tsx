"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import { useQuizAttempts } from "@/lib/use-quiz-attempts";

function mostPracticedSubject(attempts: { subjectName: string }[]): string | null {
  if (attempts.length === 0) return null;
  const counts = new Map<string, number>();
  for (const attempt of attempts) {
    counts.set(attempt.subjectName, (counts.get(attempt.subjectName) ?? 0) + 1);
  }
  let best: string | null = null;
  let bestCount = 0;
  for (const [subject, count] of counts) {
    if (count > bestCount) {
      best = subject;
      bestCount = count;
    }
  }
  return best;
}

/** Summary stats from the same users/{uid}/quizAttempts subcollection the
 * "continue practicing" card reads — a simple client-side reduce over the
 * last 20 attempts, not a server-side rollup. */
export default function PerformanceTrackRecord() {
  const { user, loading: authLoading } = useAuth();
  const { attempts } = useQuizAttempts();

  if (!authLoading && !user) {
    return (
      <section className="rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
        <p className="text-xs font-semibold uppercase tracking-wide text-gold">
          Your progress
        </p>
        <h2 className="mt-1 text-xl font-bold text-[var(--color-primary)]">
          Sign in to track your progress
        </h2>
        <p className="mt-2 text-sm text-[var(--color-primary)]/70">
          Create a free account to save your quiz scores and see your
          performance over time.
        </p>
        <Link
          href="/sign-in"
          className="mt-4 inline-flex items-center rounded-full bg-navy px-5 py-2 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
        >
          Sign in
        </Link>
      </section>
    );
  }

  const list = attempts ?? [];
  const totalAttempts = list.length;
  const averageScore =
    totalAttempts === 0
      ? 0
      : Math.round(
          (list.reduce(
            (sum, a) => sum + (a.totalQuestions === 0 ? 0 : a.score / a.totalQuestions),
            0,
          ) /
            totalAttempts) *
            100,
        );
  const topSubject = mostPracticedSubject(list);

  return (
    <section className="rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6">
      <p className="text-xs font-semibold uppercase tracking-wide text-gold">
        Your progress
      </p>
      <h2 className="mt-1 text-xl font-bold text-[var(--color-primary)]">
        Performance track record
      </h2>
      {totalAttempts === 0 ? (
        <p className="mt-2 text-sm text-[var(--color-primary)]/70">
          Complete a practice test to start building your track record.
        </p>
      ) : (
        <dl className="mt-4 grid grid-cols-2 gap-4 sm:grid-cols-3">
          <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-4">
            <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
              Attempts tracked
            </dt>
            <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
              {totalAttempts}
            </dd>
          </div>
          <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-4">
            <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
              Average score
            </dt>
            <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
              {averageScore}%
            </dd>
          </div>
          {topSubject && (
            <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-4">
              <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
                Most practiced
              </dt>
              <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
                {topSubject}
              </dd>
            </div>
          )}
        </dl>
      )}
    </section>
  );
}
