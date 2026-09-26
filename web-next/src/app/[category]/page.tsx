import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import {
  getCategoryInfo,
  getCategorySlugs,
  getSubjectSummariesForCategory,
} from "@/lib/exam-content";
import SearchableList from "@/components/SearchableList";
import AdminQuestionCount from "@/components/AdminQuestionCount";

export function generateStaticParams() {
  return getCategorySlugs().map((category) => ({ category }));
}

type Props = {
  params: Promise<{ category: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { category } = await params;
  const info = getCategoryInfo(category);
  if (!info) return {};

  const title = `${info.name} Past Questions & Practice Tests`;
  return {
    title,
    description: info.description,
    alternates: { canonical: `/${info.slug}` },
    openGraph: {
      title,
      description: info.description,
      url: `/${info.slug}`,
    },
  };
}

export default async function CategoryPage({ params }: Props) {
  const { category } = await params;
  const info = getCategoryInfo(category);
  if (!info) notFound();

  const subjects = getSubjectSummariesForCategory(info.slug);

  return (
    <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6">
      <p className="text-sm font-semibold uppercase tracking-wide text-gold">
        {info.shortLabel} Exam Prep
      </p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        {info.name} Past Questions
      </h1>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--color-primary)]/80">
        {info.description}
      </p>
      <p className="mt-2 text-sm text-[var(--color-primary)]/60">
        {subjects.length} subject{subjects.length === 1 ? "" : "s"} available
        for free practice — pick one below to start a timed test.
      </p>

      {info.slug === "jamb" && (
        <div className="mt-6 rounded-2xl border border-gold bg-gold/10 p-6">
          <p className="text-xs font-semibold uppercase tracking-wide text-gold">
            Recommended
          </p>
          <h2 className="mt-1 text-xl font-bold text-[var(--color-primary)]">
            Take the Real JAMB CBT Exam
          </h2>
          <p className="mt-2 max-w-2xl text-sm leading-relaxed text-[var(--color-primary)]/80">
            The real JAMB UTME is one combined, timed session covering 4
            subjects — Use of English (compulsory) plus 3 electives of your
            choice — not one subject at a time. Practice that exact format
            in a single sitting.
          </p>
          <Link
            href="/jamb/combined"
            className="mt-4 inline-flex items-center rounded-full bg-gold px-6 py-3 text-sm font-semibold text-navy transition-colors hover:brightness-105"
          >
            Take the Real JAMB CBT Exam (4 subjects combined)
          </Link>
        </div>
      )}

      {subjects.length === 0 ? (
        <p className="mt-10 text-[var(--color-primary)]/70">
          Subjects for {info.shortLabel} are coming soon. Check back shortly.
        </p>
      ) : (
        <SearchableList
          items={subjects.map((subject) => ({
            key: subject.slug,
            searchText: subject.name,
            node: (
              <Link
                href={`/${info.slug}/${subject.slug}`}
                className="flex items-center justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 transition-colors hover:border-gold"
              >
                <span className="font-medium text-[var(--color-primary)]">
                  {subject.name}
                </span>
                <AdminQuestionCount count={subject.questionCount} />
              </Link>
            ),
          }))}
          placeholder="Search subjects…"
          ariaLabel="Search subjects"
          listClassName="mt-8 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3"
        />
      )}
    </div>
  );
}
