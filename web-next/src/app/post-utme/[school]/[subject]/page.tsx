import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { getDurationMinutes, QUESTIONS_PER_SESSION } from "@/lib/exam-content";
import {
  getAllSchoolSubjectPairs,
  getSchoolBySlug,
  loadSchoolSubjectFile,
} from "@/lib/post-utme-content";
import { AdminOnly } from "@/components/AdminQuestionCount";

export function generateStaticParams() {
  return getAllSchoolSubjectPairs();
}

type Props = {
  params: Promise<{ school: string; subject: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { school: schoolSlug, subject: subjectSlug } = await params;
  const school = getSchoolBySlug(schoolSlug);
  const file = school ? loadSchoolSubjectFile(schoolSlug, subjectSlug) : null;
  if (!school || !file) return {};

  const title = `${file.subject} — ${school.shortName} Post-UTME Past Questions & Practice Test`;
  const description = `Practice free ${school.shortName} Post-UTME ${file.subject} past questions. ${file.questions.length} questions available, with a timed CBT-style test and instant scoring plus explanations.`;

  return {
    title,
    description,
    alternates: { canonical: `/post-utme/${schoolSlug}/${subjectSlug}` },
    openGraph: { title, description, url: `/post-utme/${schoolSlug}/${subjectSlug}` },
  };
}

export default async function SchoolSubjectPage({ params }: Props) {
  const { school: schoolSlug, subject: subjectSlug } = await params;
  const school = getSchoolBySlug(schoolSlug);
  if (!school) notFound();
  const file = loadSchoolSubjectFile(schoolSlug, subjectSlug);
  if (!file) notFound();

  const duration = getDurationMinutes("post-utme");
  const sessionSize = Math.min(QUESTIONS_PER_SESSION, file.questions.length);

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "LearningResource",
    name: `${file.subject} — ${school.shortName} Post-UTME Past Questions & Practice Test`,
    description: `Practice free ${school.shortName} Post-UTME ${file.subject} past questions with a timed CBT-style test and instant scoring plus explanations.`,
    url: `https://www.examcoach.com.ng/post-utme/${schoolSlug}/${subjectSlug}`,
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
        <Link href="/post-utme" className="text-gold hover:underline">
          Post-UTME
        </Link>{" "}
        <span className="text-[var(--color-primary)]/40">/</span>{" "}
        <Link href={`/post-utme/${schoolSlug}`} className="text-gold hover:underline">
          {school.shortName}
        </Link>
      </p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        {file.subject} Past Questions
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
        Practice {school.shortName} Post-UTME {file.subject} with a free bank
        of objective past questions. Start a timed,
        {` ${sessionSize}-question`} practice test built from this bank — get
        your score instantly along with explanations for every answer.
      </p>
      {!school.hasDedicatedContent && (
        <p className="mt-3 max-w-2xl rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-3 text-sm text-[var(--color-primary)]/70">
          These are general practice questions, not official {school.shortName}{" "}
          past questions — always confirm the exact subjects and format on{" "}
          {school.shortName}&apos;s own screening portal.
        </p>
      )}

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
        href={`/post-utme/${schoolSlug}/${subjectSlug}/practice`}
        className="mt-8 inline-flex items-center rounded-full bg-gold px-6 py-3 text-sm font-semibold text-navy transition-colors hover:brightness-105"
      >
        Start Practice Test
      </Link>
    </div>
  );
}
