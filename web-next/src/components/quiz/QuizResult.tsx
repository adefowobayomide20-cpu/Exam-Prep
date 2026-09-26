import Link from "next/link";
import type { QuizQuestionData } from "@/lib/exam-content";
import ReportQuestionButton from "./ReportQuestionButton";

interface Props {
  title: string;
  backHref: string;
  questions: QuizQuestionData[];
  answers: Record<number, number>;
}

export function scoreFor(questions: QuizQuestionData[], answers: Record<number, number>) {
  return questions.reduce(
    (score, question, index) => (answers[index] === question.correctIndex ? score + 1 : score),
    0,
  );
}

export default function QuizResult({ title, backHref, questions, answers }: Props) {
  const score = scoreFor(questions, answers);
  const total = questions.length;
  const percent = total === 0 ? 0 : Math.round((score / total) * 100);

  return (
    <div className="mx-auto max-w-2xl px-4 py-8 sm:px-6">
      <h1 className="text-lg font-semibold text-[var(--color-primary)]">{title} · Result</h1>

      <div className="mt-4 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6 text-center">
        <p className="text-sm text-[var(--color-primary)]/60">Your Score</p>
        <p className="mt-2 text-4xl font-bold text-[var(--color-primary)]">
          {score} <span className="text-xl font-medium text-[var(--color-primary)]/50">/ {total}</span>
        </p>
        <p className="mt-1 text-sm text-[var(--color-primary)]/60">{percent}% correct</p>
      </div>

      <h2 className="mt-8 text-base font-semibold text-[var(--color-primary)]">Review Answers</h2>
      <ul className="mt-3 space-y-2">
        {questions.map((question, index) => {
          const selectedIndex = answers[index];
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
                  <p
                    className={`font-semibold ${isCorrect ? "text-teal" : "text-red-600"}`}
                  >
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

      <Link
        href={backHref}
        className="mt-8 block rounded-full bg-navy px-4 py-3 text-center text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
      >
        Done
      </Link>
    </div>
  );
}
