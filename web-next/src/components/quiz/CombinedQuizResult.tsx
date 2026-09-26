import Link from "next/link";
import type { CombinedSubjectQuestions } from "./CombinedQuizSession";
import ReportQuestionButton from "./ReportQuestionButton";

interface Props {
  subjects: CombinedSubjectQuestions[];
  /** Answers keyed by the FLATTENED (overall) question index, same as
   * CombinedQuizSession's `answers` state. */
  answers: Record<number, number>;
  /** Heading shown at the top of the result screen. Defaults to the
   * original JAMB combined copy. */
  title?: string;
  /** "Done" link target. Defaults to `/jamb/combined`. */
  backHref?: string;
}

/**
 * Results screen for the JAMB combined session — modeled on
 * QuizResult.tsx's visual style (score card + collapsible review list) but
 * extended for 4 subjects: one overall score card, a per-subject breakdown
 * grid, then one review section per subject. QuizResult.tsx itself is left
 * untouched since its props (a single flat question/answer array) don't fit
 * a per-subject grouping without reshaping the data anyway.
 */
export default function CombinedQuizResult({
  subjects,
  answers,
  title = "JAMB Combined Exam · Result",
  backHref = "/jamb/combined",
}: Props) {
  // Prefix-sum the per-subject question counts so each subject's slice of
  // the flattened `answers` map can be located without mutating a shared
  // counter across the .map below (react-hooks/immutability disallows
  // reassigning an outer-scope variable during render).
  const offsets = subjects.reduce<number[]>((acc, subject, i) => {
    acc.push(i === 0 ? 0 : acc[i - 1] + subjects[i - 1].questions.length);
    return acc;
  }, []);

  const perSubject = subjects.map((subject, subjectIndex) => {
    const offset = offsets[subjectIndex];
    const subjectAnswers: Record<number, number> = {};
    subject.questions.forEach((_, i) => {
      if (answers[offset + i] !== undefined) subjectAnswers[i] = answers[offset + i];
    });
    const score = subject.questions.reduce(
      (s, q, i) => (subjectAnswers[i] === q.correctIndex ? s + 1 : s),
      0,
    );
    return { subject, subjectAnswers, score, total: subject.questions.length };
  });

  const overallScore = perSubject.reduce((s, r) => s + r.score, 0);
  const overallTotal = perSubject.reduce((s, r) => s + r.total, 0);
  const overallPercent = overallTotal === 0 ? 0 : Math.round((overallScore / overallTotal) * 100);

  return (
    <div className="mx-auto max-w-2xl px-4 py-8 sm:px-6">
      <h1 className="text-lg font-semibold text-[var(--color-primary)]">{title}</h1>

      <div className="mt-4 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
        <p className="text-sm text-[var(--color-primary)]/60">Overall Score</p>
        <p className="mt-2 text-4xl font-bold text-[var(--color-primary)]">
          {overallScore}{" "}
          <span className="text-xl font-medium text-[var(--color-primary)]/50">
            / {overallTotal}
          </span>
        </p>
        <p className="mt-1 text-sm text-[var(--color-primary)]/60">
          {overallPercent}% correct
        </p>
      </div>

      <h2 className="mt-8 text-base font-semibold text-[var(--color-primary)]">
        Per-subject breakdown
      </h2>
      <dl className="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
        {perSubject.map(({ subject, score, total }) => (
          <div
            key={subject.slug}
            className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-3"
          >
            <dt className="text-xs text-[var(--color-primary)]/60">{subject.name}</dt>
            <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
              {score}/{total}
            </dd>
          </div>
        ))}
      </dl>
      <p className="mt-3 text-sm text-[var(--color-primary)]/70">
        {perSubject.map((r) => `${r.subject.name}: ${r.score}/${r.total}`).join(", ")} — Total:{" "}
        {overallScore}/{overallTotal}
      </p>

      {perSubject.map(({ subject, subjectAnswers }) => (
        <div key={subject.slug} className="mt-8">
          <h2 className="text-base font-semibold text-[var(--color-primary)]">
            {subject.name} · Review Answers
          </h2>
          <ul className="mt-3 space-y-2">
            {subject.questions.map((question, index) => {
              const selectedIndex = subjectAnswers[index];
              const isCorrect = selectedIndex === question.correctIndex;
              return (
                <li
                  key={index}
                  className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)]"
                >
                  <details className="group">
                    <summary className="flex cursor-pointer list-none items-center gap-3 px-4 py-3">
                      <span
                        aria-hidden
                        className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-full text-xs font-bold text-white ${
                          isCorrect ? "bg-teal" : "bg-red-600"
                        }`}
                      >
                        {isCorrect ? "✓" : "✕"}
                      </span>
                      <span className="flex-1 text-sm text-[var(--color-primary)]">
                        <span className="font-semibold">Question {index + 1}.</span>{" "}
                        <span className="text-[var(--color-primary)]/80">{question.text}</span>
                      </span>
                    </summary>
                    <div className="border-t border-[var(--color-border)] px-4 py-3 text-sm">
                      <p className={`font-semibold ${isCorrect ? "text-teal" : "text-red-600"}`}>
                        Your answer:{" "}
                        {selectedIndex === undefined
                          ? "(not answered)"
                          : question.options[selectedIndex]}
                      </p>
                      {!isCorrect && (
                        <p className="mt-1 font-semibold text-teal">
                          Correct answer: {question.options[question.correctIndex]}
                        </p>
                      )}
                      <p className="mt-2 text-[var(--color-primary)]/70">
                        {question.explanation ?? "No explanation available for this question."}
                      </p>
                      <ReportQuestionButton question={question} />
                    </div>
                  </details>
                </li>
              );
            })}
          </ul>
        </div>
      ))}

      <Link
        href={backHref}
        className="mt-8 block rounded-full bg-navy px-4 py-3 text-center text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
      >
        Done
      </Link>
    </div>
  );
}
