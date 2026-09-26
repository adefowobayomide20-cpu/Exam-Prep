import Link from "next/link";
import type { Metadata } from "next";
import {
  COMBINED_DURATION_MINUTES,
  COMBINED_QUESTIONS_PER_SUBJECT,
  JAMB_COMPULSORY_SUBJECT_SLUG,
  getSubjectSummariesForCategory,
} from "@/lib/exam-content";
import JambCombinedFlow from "@/components/jamb/JambCombinedFlow";

const TITLE = "JAMB Combined CBT Exam — 4 Subjects, One Timed Session";
const DESCRIPTION =
  "Practice the real JAMB UTME format: Use of English (compulsory) plus 3 elective subjects of your choice, all in one combined, timed CBT-style session with instant scoring and a per-subject breakdown.";

export const metadata: Metadata = {
  title: TITLE,
  description: DESCRIPTION,
  alternates: { canonical: "/jamb/combined" },
  openGraph: { title: TITLE, description: DESCRIPTION, url: "/jamb/combined" },
};

/**
 * Static route (NOT under the shared `[category]/[subject]` dynamic
 * template) for JAMB's real combined exam format: English + 3 electives in
 * one timed session. Next.js resolves the static `/jamb/combined` segment
 * ahead of the sibling `/[category]` dynamic route at the same level, so
 * this coexists safely with `/jamb` (see
 * node_modules/next/dist/docs/01-app/01-getting-started/05-linking-and-navigating.mdx
 * and the routing docs on static-vs-dynamic segment priority) without any
 * changes to `[category]/page.tsx` or `[category]/[subject]/**`.
 */
export default function JambCombinedPage() {
  const allSubjects = getSubjectSummariesForCategory("jamb");
  const compulsorySubject = allSubjects.find((s) => s.slug === JAMB_COMPULSORY_SUBJECT_SLUG);
  const electiveSubjects = allSubjects.filter((s) => s.slug !== JAMB_COMPULSORY_SUBJECT_SLUG);

  if (!compulsorySubject) {
    // Content bank issue, not a routing 404 — surface plainly rather than
    // silently rendering a broken picker.
    return (
      <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
        <p className="text-[var(--color-primary)]/70">
          The JAMB combined exam is temporarily unavailable. Please check back shortly.
        </p>
      </div>
    );
  }

  const totalQuestions = COMBINED_QUESTIONS_PER_SUBJECT * 4;

  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
      <p className="text-sm">
        <Link href="/jamb" className="text-gold hover:underline">
          JAMB
        </Link>
      </p>
      <p className="mt-2 text-sm font-semibold uppercase tracking-wide text-gold">
        Real JAMB UTME Format
      </p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        JAMB Combined CBT Exam
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
        Every JAMB UTME candidate sits ONE combined, timed Computer-Based
        Test covering 4 subjects: the compulsory Use of English paper plus 3
        elective subjects the candidate chooses based on their intended
        course of study. This combined practice test mirrors that real
        format — pick your 3 electives below, and you&apos;ll get one
        single timed session covering all 4 subjects back-to-back, with
        clear subject headers, instant scoring, and a per-subject
        breakdown at the end.
      </p>
      <p className="mt-3 max-w-2xl text-sm leading-relaxed text-[var(--color-primary)]/70">
        This practice session samples {COMBINED_QUESTIONS_PER_SUBJECT} questions
        from each of your 4 subjects ({totalQuestions} questions total) with a
        shared {COMBINED_DURATION_MINUTES}-minute countdown for the whole
        exam — a scaled-down version of the real JAMB CBT (which runs ~180
        questions over 2 hours) sized for a focused practice sitting while
        keeping the same 4-subjects-in-one-sitting structure.
      </p>
      <p className="mt-3 max-w-2xl text-sm leading-relaxed text-[var(--color-primary)]/70">
        Prefer to practice one subject at a time instead? Visit the{" "}
        <Link href="/jamb" className="text-gold hover:underline">
          JAMB subject list
        </Link>{" "}
        for untimed-pace, single-subject practice tests.
      </p>

      <JambCombinedFlow
        compulsorySlug={JAMB_COMPULSORY_SUBJECT_SLUG}
        compulsorySubject={compulsorySubject}
        electiveSubjects={electiveSubjects}
        durationMinutes={COMBINED_DURATION_MINUTES}
        questionsPerSubject={COMBINED_QUESTIONS_PER_SUBJECT}
      />
    </div>
  );
}
