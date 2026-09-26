import Link from "next/link";
import type { Metadata } from "next";
import { THEORY_SUBJECTS } from "@/lib/theory-content";
import SearchableList from "@/components/SearchableList";

const TITLE = "Theory Practice — AI-Marked Essay & Calculation Questions";
const DESCRIPTION =
  "Practice WAEC-style theory (essay and calculation) questions with instant, step-by-step AI marking. Pick a subject, answer in your own words, and get detailed feedback when you get it wrong.";

export const metadata: Metadata = {
  title: TITLE,
  description: DESCRIPTION,
  alternates: { canonical: "/theory" },
  openGraph: {
    title: TITLE,
    description: DESCRIPTION,
    url: "/theory",
  },
};

export default function TheorySubjectPickerPage() {
  return (
    <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6">
      <p className="text-sm font-semibold uppercase tracking-wide text-gold">
        Theory Practice
      </p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Practice Theory Questions, Marked by AI
      </h1>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--color-primary)]/80">
        {DESCRIPTION}
      </p>
      <p className="mt-2 text-sm text-[var(--color-primary)]/60">
        Sign-in is required to start a session — pick a subject to begin.
      </p>

      <SearchableList
        items={THEORY_SUBJECTS.map((subject) => ({
          key: subject.slug,
          searchText: subject.name,
          node: (
            <Link
              href={`/theory/${subject.slug}`}
              className="flex items-center justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 transition-colors hover:border-gold"
            >
              <span className="font-medium text-[var(--color-primary)]">
                {subject.name}
              </span>
              <span className="text-xs text-[var(--color-primary)]/60">
                Theory
              </span>
            </Link>
          ),
        }))}
        placeholder="Search subjects…"
        ariaLabel="Search subjects"
        listClassName="mt-8 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3"
      />
    </div>
  );
}
