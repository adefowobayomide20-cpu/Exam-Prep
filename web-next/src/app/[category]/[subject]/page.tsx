import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import {
  getAllCategorySubjectPairs,
  getCategoryInfo,
  getDurationMinutes,
  loadSubjectFile,
  QUESTIONS_PER_SESSION,
} from "@/lib/exam-content";
import { AdminOnly } from "@/components/AdminQuestionCount";

export function generateStaticParams() {
  return getAllCategorySubjectPairs();
}

type Props = {
  params: Promise<{ category: string; subject: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { category, subject } = await params;
  const info = getCategoryInfo(category);
  const file = info ? loadSubjectFile(info.slug, subject) : null;
  if (!info || !file) return {};

  const title = `${file.subject} — ${info.shortLabel} Past Questions & Practice Test`;
  const description = `Practice free ${info.shortLabel} ${file.subject} past questions. ${file.questions.length} questions available, with a timed CBT-style test and instant scoring plus explanations.`;

  return {
    title,
    description,
    alternates: { canonical: `/${info.slug}/${subject}` },
    openGraph: { title, description, url: `/${info.slug}/${subject}` },
  };
}

export default async function SubjectPage({ params }: Props) {
  const { category, subject } = await params;
  const info = getCategoryInfo(category);
  if (!info) notFound();
  const file = loadSubjectFile(info.slug, subject);
  if (!file) notFound();

  const duration = getDurationMinutes(info.slug);
  const sessionSize = Math.min(QUESTIONS_PER_SESSION, file.questions.length);

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "LearningResource",
    name: `${file.subject} — ${info.shortLabel} Past Questions & Practice Test`,
    description: `Practice free ${info.shortLabel} ${file.subject} past questions with a timed CBT-style test and instant scoring plus explanations.`,
    url: `https://www.examcoach.com.ng/${info.slug}/${subject}`,
    learningResourceType: "Practice test",
    educationalUse: "practice",
    about: file.subject,
    isAccessibleForFree: true,
    provider: {
      "@type": "EducationalOrganization",
      name: "Exam Coach",
      url: "https://www.examcoach.com.ng",
    },
  };

  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
        }}
      />
      <p className="text-sm">
        <Link href={`/${info.slug}`} className="text-gold hover:underline">
          {info.name}
        </Link>
      </p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        {file.subject} Past Questions
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
        Practice {info.shortLabel} {file.subject} with a free bank of
        objective past questions. Start a timed,
        {` ${sessionSize}-question`} practice test built from this bank —
        get your score instantly along with explanations for every answer.
      </p>

      <dl className="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-3">
        <AdminOnly>
          <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
            <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
              Question bank
            </dt>
            <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
              {file.questions.length} questions
            </dd>
          </div>
        </AdminOnly>
        <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
          <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
            Practice test
          </dt>
          <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
            {sessionSize} questions
          </dd>
        </div>
        <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
          <dt className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
            Time limit
          </dt>
          <dd className="mt-1 text-lg font-semibold text-[var(--color-primary)]">
            {duration} minutes
          </dd>
        </div>
      </dl>

      <Link
        href={`/${info.slug}/${subject}/practice`}
        className="mt-8 inline-flex items-center rounded-full bg-gold px-6 py-3 text-sm font-semibold text-navy transition-colors hover:brightness-105"
      >
        Start Practice Test
      </Link>
    </div>
  );
}
