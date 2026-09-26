import { notFound } from "next/navigation";
import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import TheorySession from "@/components/theory/TheorySession";
import { getTheorySubject, getTheorySubjectSlugs } from "@/lib/theory-content";

export function generateStaticParams() {
  return getTheorySubjectSlugs().map((subject) => ({ subject }));
}

type Props = {
  params: Promise<{ subject: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { subject: slug } = await params;
  const subject = getTheorySubject(slug);
  if (!subject) return {};

  const title = `${subject.name} Theory Practice — AI-Marked`;
  const description = `Answer AI-generated ${subject.name} theory questions and get instant, step-by-step marking. Sign in to start.`;
  return {
    title,
    description,
    alternates: { canonical: `/theory/${subject.slug}` },
    robots: { index: false, follow: true },
    openGraph: { title, description, url: `/theory/${subject.slug}` },
  };
}

export default async function TheorySubjectPage({ params }: Props) {
  const { subject: slug } = await params;
  const subject = getTheorySubject(slug);
  if (!subject) notFound();

  return (
    <RequireAuth>
      <TheorySession subject={subject.name} subjectSlug={subject.slug} backHref="/theory" />
    </RequireAuth>
  );
}
