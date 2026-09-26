import type { Metadata } from "next";
import { POST_UTME_SCHOOLS } from "@/lib/post-utme-content";
import PostUtmeSchoolSearch from "@/components/PostUtmeSchoolSearch";

// Post-UTME is school-first (pick a university, then a subject), matching
// how the Flutter app already works — see lib/features/exam/post_jamb_schools.dart
// and post_utme_subject_picker_page.dart (read-only reference). This file
// is a literal "post-utme" route segment, which Next.js always prefers over
// the sibling dynamic "/[category]" route for this exact path, so it fully
// replaces the old flat 3-subject list without touching the WAEC/NECO/JAMB
// flow in src/app/[category]/**.
export const metadata: Metadata = {
  title: "Post-UTME Past Questions — Pick Your School",
  description:
    "Practice free Post-UTME screening past questions for Nigerian universities. Pick your school first to get subjects matched to its actual screening format.",
  alternates: { canonical: "/post-utme" },
};

export default function PostUtmeSchoolsPage() {
  return (
    <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6">
      <p className="text-sm font-semibold uppercase tracking-wide text-gold">
        Post-UTME Exam Prep
      </p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Choose Your School
      </h1>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--color-primary)]/80">
        Post-UTME screening tests vary by university — different subjects,
        different formats. Pick your school below to see the subjects it
        tests and start free, timed practice with instant scoring.
      </p>
      <p className="mt-2 text-sm text-[var(--color-primary)]/60">
        {POST_UTME_SCHOOLS.length} schools available with curated question banks.
      </p>

      <PostUtmeSchoolSearch schools={POST_UTME_SCHOOLS} />
    </div>
  );
}
