"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import { useQuizAttempts } from "@/lib/use-quiz-attempts";

/**
 * "Continue practicing" is a shortcut back to the last-practiced subject's
 * landing page, not a mid-quiz resume — QuizSession.tsx doesn't persist
 * per-question state, only the final score once a test is submitted. That's
 * a deliberate scope simplification.
 */
export default function ContinueQuizCard() {
  const { user, loading: authLoading } = useAuth();
  const { attempts } = useQuizAttempts();

  const latest =
    !authLoading && user && attempts && attempts.length > 0 ? attempts[0] : null;
  const loadingProgress = !authLoading && user && attempts === null;

  return (
    <section className="rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6">
      <p className="text-xs font-semibold uppercase tracking-wide text-gold">
        Practice
      </p>

      {loadingProgress ? (
        <p className="mt-3 text-sm text-[var(--color-primary)]/70">
          Fetching your last practice session…
        </p>
      ) : (
        // Single row, two columns side-by-side once there's a "continue"
        // card to show alongside "take a new quiz" — falls back to one
        // column (via the grid's natural single-item behavior) when there's
        // nothing to continue yet.
        <div className={`mt-3 grid grid-cols-1 gap-4 ${latest ? "sm:grid-cols-2" : ""}`}>
          {latest && (
            <div>
              <h2 className="text-lg font-bold text-[var(--color-primary)]">
                Continue practicing {latest.subjectName}
              </h2>
              <p className="mt-1 text-sm text-[var(--color-primary)]/70">
                You last scored {latest.score}/{latest.totalQuestions} in{" "}
                {latest.subjectName}. Pick up where you left off with a fresh
                timed test.
              </p>
              <Link
                href={`/${latest.category}/${latest.subject}`}
                className="mt-3 inline-flex items-center rounded-full bg-gold px-5 py-2 text-sm font-semibold text-navy transition-colors hover:opacity-90"
              >
                Continue with {latest.subjectName}
              </Link>
            </div>
          )}

          <div className={latest ? "border-t border-[var(--color-border)] pt-4 sm:border-t-0 sm:border-l sm:pt-0 sm:pl-4" : ""}>
            <h2 className="text-lg font-bold text-[var(--color-primary)]">
              {latest ? "Or take a new quiz" : "Take a new quiz"}
            </h2>
            <p className="mt-1 text-sm text-[var(--color-primary)]/70">
              Jump into free WAEC, NECO, JAMB, or Post-UTME past questions in
              any subject.
            </p>
            <Link
              href="/exam"
              className={`mt-3 inline-flex items-center rounded-full px-5 py-2 text-sm font-semibold transition-colors ${
                latest
                  ? "border border-gold text-gold hover:bg-gold/10"
                  : "bg-gold text-navy hover:opacity-90"
              }`}
            >
              Take a new quiz
            </Link>
          </div>
        </div>
      )}
    </section>
  );
}
