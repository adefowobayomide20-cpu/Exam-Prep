import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import {
  JAMB_COMPULSORY_SUBJECT_SLUG,
  POST_UTME_COMBINED_DURATION_MINUTES,
  getSubjectSummariesForCategory,
} from "@/lib/exam-content";
import {
  POST_UTME_COMPULSORY_SUBJECT_SLUG,
  getSchoolBySlug,
  getSchoolSlugs,
  getSubjectSummariesForSchool,
} from "@/lib/post-utme-content";
import SearchableList from "@/components/SearchableList";
import PostUtmeCombinedFlow from "@/components/post-utme/PostUtmeCombinedFlow";
import AdminQuestionCount from "@/components/AdminQuestionCount";

export function generateStaticParams() {
  return getSchoolSlugs().map((school) => ({ school }));
}

type Props = {
  params: Promise<{ school: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { school: schoolSlug } = await params;
  const school = getSchoolBySlug(schoolSlug);
  if (!school) return {};

  const title = `${school.shortName} Post-UTME Screening Test — General Paper + 4 Subjects`;
  const description = `Practice the full ${school.shortName} Post-UTME screening test: General Paper (compulsory) plus 4 elective subjects of your choice, in one 20-minute timed session with instant scoring.`;
  return {
    title,
    description,
    alternates: { canonical: `/post-utme/${school.slug}` },
    openGraph: { title, description, url: `/post-utme/${school.slug}` },
  };
}

/**
 * Landing page for a single Post-UTME school. Per the user's requested
 * flow, the FIRST thing shown after picking a school is the combined
 * screening-test picker (General Paper + 3 JAMB electives), not a flat list
 * of individual subjects — that flat list still exists further down the
 * page (and its own pages still exist at [school]/[subject] for anyone who
 * wants untimed single-subject practice, plus SEO), but it's secondary now.
 */
export default async function SchoolPage({ params }: Props) {
  const { school: schoolSlug } = await params;
  const school = getSchoolBySlug(schoolSlug);
  if (!school) notFound();

  const subjects = getSubjectSummariesForSchool(schoolSlug);
  const compulsorySubject = subjects.find(
    (s) => s.slug === POST_UTME_COMPULSORY_SUBJECT_SLUG,
  );
  // Mathematics and Use of English are excluded — every school's own
  // General Paper (General Knowledge) already covers that ground, so the 4
  // free picks are JAMB's other subjects only.
  const electiveSubjects = getSubjectSummariesForCategory("jamb").filter(
    (s) => s.slug !== JAMB_COMPULSORY_SUBJECT_SLUG && s.slug !== "mathematics",
  );

  return (
    <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6">
      <p className="text-sm">
        <Link href="/post-utme" className="text-gold hover:underline">
          Post-UTME · Choose Your School
        </Link>
      </p>
      <p className="mt-2 text-sm font-semibold uppercase tracking-wide text-gold">
        {school.shortName} · {school.type} University
      </p>
      <h1 className="mt-1 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        {school.name} Post-UTME Screening Test
      </h1>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--color-primary)]/80">
        {school.blurb}
      </p>
      <p className="mt-3 max-w-3xl rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-3 text-sm leading-relaxed text-[var(--color-primary)]/70">
        Post-UTME screening formats vary by institution and can change from
        year to year — for the most up-to-date subjects and format, visit{" "}
        {school.shortName}&apos;s official website ({school.website}). For
        practice purposes here, General Paper is required, along with every
        other subject you&apos;d take in your JAMB exam. For a more
        interactive way to prepare, you can also{" "}
        <Link href="/duel" className="text-gold hover:underline">
          challenge a friend — or anyone online — to a duel
        </Link>
        .
      </p>

      {compulsorySubject ? (
        <>
          <PostUtmeCombinedFlow
            schoolSlug={school.slug}
            schoolShortName={school.shortName}
            compulsorySubject={compulsorySubject}
            electiveSubjects={electiveSubjects}
            durationMinutes={POST_UTME_COMBINED_DURATION_MINUTES}
          />
        </>
      ) : (
        <p className="mt-6 max-w-3xl rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-3 text-sm text-[var(--color-primary)]/70">
          The {school.shortName} screening test is temporarily unavailable.
          Please check back shortly.
        </p>
      )}

      {subjects.length > 0 && (
        <details className="mt-12">
          <summary className="cursor-pointer text-sm font-semibold text-[var(--color-primary)]/70 hover:text-gold">
            Prefer to practice one subject at a time instead?
          </summary>
          <SearchableList
            items={subjects.map((subject) => ({
              key: subject.slug,
              searchText: subject.name,
              node: (
                <Link
                  href={`/post-utme/${school.slug}/${subject.slug}`}
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
            listClassName="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3"
          />
        </details>
      )}
    </div>
  );
}
