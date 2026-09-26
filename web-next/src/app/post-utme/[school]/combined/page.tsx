import { redirect } from "next/navigation";
import { getSchoolSlugs } from "@/lib/post-utme-content";

export function generateStaticParams() {
  return getSchoolSlugs().map((school) => ({ school }));
}

type Props = {
  params: Promise<{ school: string }>;
};

/**
 * The combined screening-test picker now lives directly on
 * /post-utme/[school] (per user request: school pick -> straight into the
 * General Paper + JAMB elective picker, no intermediate subject-list page).
 * This route is kept as a permanent redirect rather than deleted, since it
 * may already be linked/bookmarked/indexed.
 */
export default async function PostUtmeCombinedRedirectPage({ params }: Props) {
  const { school } = await params;
  redirect(`/post-utme/${school}`);
}
