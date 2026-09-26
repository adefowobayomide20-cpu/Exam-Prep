import { notFound } from "next/navigation";
import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import QuizSession from "@/components/quiz/QuizSession";
import { getDurationMinutes, QUESTIONS_PER_SESSION } from "@/lib/exam-content";
import {
  getAllSchoolSubjectPairs,
  getSchoolBySlug,
  loadSchoolSubjectFile,
} from "@/lib/post-utme-content";

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

  const title = `${file.subject} Practice Test — ${school.shortName} Post-UTME`;
  return {
    title,
    description: `Take a free timed ${school.shortName} Post-UTME ${file.subject} practice test with instant scoring.`,
    alternates: { canonical: `/post-utme/${schoolSlug}/${subjectSlug}/practice` },
    robots: { index: false, follow: true },
  };
}

export default async function SchoolPracticePage({ params }: Props) {
  const { school: schoolSlug, subject: subjectSlug } = await params;
  const school = getSchoolBySlug(schoolSlug);
  if (!school) notFound();
  const file = loadSchoolSubjectFile(schoolSlug, subjectSlug);
  if (!file) notFound();

  return (
    <RequireAuth>
      <QuizSession
        title={`${school.shortName} · ${file.subject}`}
        backHref={`/post-utme/${schoolSlug}/${subjectSlug}`}
        questions={file.questions}
        sessionSize={QUESTIONS_PER_SESSION}
        durationMinutes={getDurationMinutes("post-utme")}
        categorySlug="post-utme"
        subjectSlug={`${schoolSlug}-${subjectSlug}`}
        subjectName={`${school.shortName} ${file.subject}`}
      />
    </RequireAuth>
  );
}
