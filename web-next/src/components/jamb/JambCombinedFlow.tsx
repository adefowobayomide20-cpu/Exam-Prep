"use client";

import { useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import type { SubjectSummary } from "@/lib/exam-content";
import { useAuth } from "@/lib/auth-context";
import CombinedQuizSession, {
  type CombinedSubjectQuestions,
} from "@/components/quiz/CombinedQuizSession";
import AdminQuestionCount from "@/components/AdminQuestionCount";

interface Props {
  compulsorySlug: string;
  compulsorySubject: SubjectSummary;
  electiveSubjects: SubjectSummary[];
  durationMinutes: number;
  questionsPerSubject: number;
}

const REQUIRED_ELECTIVES = 3;

/**
 * Client-side flow for the JAMB combined (4-subject) practice test:
 * subject selection (Use of English locked in + exactly 3 electives) ->
 * fetch a sampled question set for all 4 subjects from `/api/jamb-combined`
 * -> render the single combined session. Modeled on QuizSession.tsx's
 * "pick a sample on a user gesture, not in an effect" approach, extended
 * with a subject-selection step before that gesture.
 */
export default function JambCombinedFlow({
  compulsorySlug,
  compulsorySubject,
  electiveSubjects,
  durationMinutes,
  questionsPerSubject,
}: Props) {
  const { user } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [selected, setSelected] = useState<string[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [sessionData, setSessionData] = useState<CombinedSubjectQuestions[] | null>(null);

  const toggleElective = (slug: string) => {
    setError(null);
    setSelected((prev) => {
      if (prev.includes(slug)) return prev.filter((s) => s !== slug);
      if (prev.length >= REQUIRED_ELECTIVES) {
        setError(
          `You can only pick ${REQUIRED_ELECTIVES} elective subjects. Unselect one before choosing another.`,
        );
        return prev;
      }
      return [...prev, slug];
    });
  };

  const startExam = async () => {
    if (selected.length !== REQUIRED_ELECTIVES) {
      setError(`Pick exactly ${REQUIRED_ELECTIVES} elective subjects to continue.`);
      return;
    }
    if (!user) {
      router.push(`/sign-in?redirect=${encodeURIComponent(pathname)}`);
      return;
    }
    setError(null);
    setLoading(true);
    try {
      const subjects = [compulsorySlug, ...selected];
      const response = await fetch(
        `/api/jamb-combined?subjects=${encodeURIComponent(subjects.join(","))}`,
      );
      if (!response.ok) throw new Error("Failed to load questions");
      const data = (await response.json()) as { subjects: CombinedSubjectQuestions[] };
      setSessionData(data.subjects);
    } catch {
      setError("Could not load questions for your selected subjects. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  if (sessionData) {
    return <CombinedQuizSession subjects={sessionData} durationMinutes={durationMinutes} />;
  }

  return (
    <div className="mt-8">
      <h2 className="text-xl font-semibold text-[var(--color-primary)]">
        Choose your 3 elective subjects
      </h2>
      <p className="mt-2 text-sm text-[var(--color-primary)]/70">
        {compulsorySubject.name} is compulsory for every JAMB candidate and is
        already locked in below. Pick exactly {REQUIRED_ELECTIVES} more
        subjects to match the real JAMB UTME combination — this practice test
        will sample {questionsPerSubject} questions from each of your 4
        chosen subjects.
      </p>

      <ul className="mt-4 grid grid-cols-1 gap-2 sm:grid-cols-2">
        <li>
          <label className="flex cursor-not-allowed items-center justify-between rounded-xl border border-gold bg-gold/10 px-4 py-3 opacity-90">
            <span className="flex items-center gap-3">
              <input type="checkbox" checked disabled className="h-4 w-4 accent-gold" />
              <span className="font-medium text-[var(--color-primary)]">
                {compulsorySubject.name}
              </span>
            </span>
            <span className="text-xs font-semibold uppercase tracking-wide text-gold">
              Compulsory
            </span>
          </label>
        </li>
        {electiveSubjects.map((subject) => {
          const checked = selected.includes(subject.slug);
          return (
            <li key={subject.slug}>
              <label
                className={`flex cursor-pointer items-center justify-between rounded-xl border px-4 py-3 transition-colors ${
                  checked
                    ? "border-gold bg-gold/10"
                    : "border-[var(--color-border)] bg-[var(--color-surface-alt)] hover:border-gold/50"
                }`}
              >
                <span className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={checked}
                    onChange={() => toggleElective(subject.slug)}
                    className="h-4 w-4 accent-gold"
                  />
                  <span className="font-medium text-[var(--color-primary)]">
                    {subject.name}
                  </span>
                </span>
                <AdminQuestionCount count={subject.questionCount} />
              </label>
            </li>
          );
        })}
      </ul>

      {error && <p className="mt-4 text-sm font-semibold text-red-600">{error}</p>}

      {/* Spacer so the sticky bar below never covers the last few electives
          in the list above — matches PostUtmeCombinedFlow.tsx's pattern. */}
      <div className="h-24" aria-hidden="true" />

      {/* Sticky "Start Exam" bar — always visible without scrolling past a
          long elective checklist, sitting just above the mobile bottom tab
          bar (bottom-16 ≈ its height) and flush to the bottom on desktop
          (no bottom tab bar there). */}
      <div className="fixed inset-x-0 bottom-16 z-30 border-t border-[var(--color-border)] bg-[var(--color-surface)] px-4 py-3 shadow-[0_-2px_8px_rgba(0,0,0,0.06)] sm:px-6 md:bottom-0">
        <div className="mx-auto flex max-w-3xl items-center justify-between gap-4">
          <p className="text-sm font-medium text-[var(--color-primary)]/80">
            {selected.length} / {REQUIRED_ELECTIVES} electives selected
          </p>
          <button
            type="button"
            onClick={startExam}
            disabled={selected.length !== REQUIRED_ELECTIVES || loading}
            className="inline-flex shrink-0 items-center rounded-full bg-gold px-6 py-3 text-sm font-semibold text-navy transition-colors hover:brightness-105 disabled:cursor-not-allowed disabled:opacity-50"
          >
            {loading ? "Loading questions…" : "Start Exam"}
          </button>
        </div>
      </div>
    </div>
  );
}
