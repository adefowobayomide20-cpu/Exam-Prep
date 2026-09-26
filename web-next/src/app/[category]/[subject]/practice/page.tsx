import { notFound } from "next/navigation";
import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import QuizSession from "@/components/quiz/QuizSession";
import {
  getAllCategorySubjectPairs,
  getCategoryInfo,
  getDurationMinutes,
  loadSubjectFile,
  QUESTIONS_PER_SESSION,
} from "@/lib/exam-content";

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

  const title = `${file.subject} Practice Test — ${info.shortLabel}`;
  return {
    title,
    description: `Take a free timed ${info.shortLabel} ${file.subject} practice test with instant scoring.`,
    alternates: { canonical: `/${info.slug}/${subject}/practice` },
    robots: { index: false, follow: true },
  };
}

export default async function PracticePage({ params }: Props) {
  const { category, subject } = await params;
  const info = getCategoryInfo(category);
  if (!info) notFound();
  const file = loadSubjectFile(info.slug, subject);
  if (!file) notFound();

  return (
    <RequireAuth>
      <QuizSession
        title={`${info.shortLabel} · ${file.subject}`}
        backHref={`/${info.slug}/${subject}`}
        questions={file.questions}
        sessionSize={QUESTIONS_PER_SESSION}
        durationMinutes={getDurationMinutes(info.slug)}
        categorySlug={info.slug}
        subjectSlug={subject}
        subjectName={file.subject}
      />
    </RequireAuth>
  );
}
