import { NextResponse } from "next/server";
import {
  JAMB_COMPULSORY_SUBJECT_SLUG,
  POST_UTME_COMBINED_QUESTIONS_PER_SUBJECT,
  getSubjectSlugsForCategory,
  loadSubjectFile,
  shuffledSample,
} from "@/lib/exam-content";
import {
  POST_UTME_COMPULSORY_SUBJECT_SLUG,
  getSchoolBySlug,
  loadSchoolSubjectFile,
} from "@/lib/post-utme-content";

const REQUIRED_ELECTIVES = 4;

/**
 * Server-side question sampling for the Post-UTME combined (General Paper +
 * 4 JAMB electives) session. Mirrors /api/jamb-combined/route.ts's pattern —
 * `exam-content.ts` / `post-utme-content.ts` read JSON off disk with
 * `node:fs`, so they can't be imported into the client-side flow components,
 * this route is the client-safe bridge.
 *
 * Unlike jamb-combined, the compulsory subject here always comes from the
 * SCHOOL's own General Knowledge content (dedicated bank or the shared
 * `_common` fallback — see loadSchoolSubjectFile), while the 4 electives are
 * sampled from JAMB's subject bank per the user's requirement to reuse
 * JAMB's broader elective pool rather than each school's own limited
 * elective set. "Use of English" and "Mathematics" are excluded from the
 * elective pool since every school already has its own English
 * Language/Mathematics subject/content elsewhere on the site (see
 * /post-utme/[school]/english-language and /post-utme/[school]/mathematics)
 * and including them again here would be redundant — the combined exam is
 * General Paper (compulsory) plus 4 picks from JAMB's remaining subjects.
 */
export async function GET(request: Request) {
  const url = new URL(request.url);
  const schoolSlug = url.searchParams.get("school");
  const subjectsParam = url.searchParams.get("subjects");

  if (!schoolSlug) {
    return NextResponse.json({ error: "Missing school" }, { status: 400 });
  }
  const school = getSchoolBySlug(schoolSlug);
  if (!school) {
    return NextResponse.json({ error: "Unknown school" }, { status: 404 });
  }

  if (!subjectsParam) {
    return NextResponse.json({ error: "Missing subjects" }, { status: 400 });
  }
  const requested = subjectsParam.split(",").map((s) => s.trim()).filter(Boolean);
  const uniqueRequested = Array.from(new Set(requested));
  if (uniqueRequested.length !== REQUIRED_ELECTIVES) {
    return NextResponse.json(
      { error: `Exactly ${REQUIRED_ELECTIVES} elective subjects are required` },
      { status: 400 },
    );
  }

  // Mathematics is also excluded (alongside Use of English above) — the
  // combined exam is General Paper + 4 JAMB electives, not Math/English.
  const validElectiveSlugs = new Set(
    getSubjectSlugsForCategory("jamb").filter(
      (slug) => slug !== JAMB_COMPULSORY_SUBJECT_SLUG && slug !== "mathematics",
    ),
  );
  if (!uniqueRequested.every((slug) => validElectiveSlugs.has(slug))) {
    return NextResponse.json({ error: "Unknown elective subject slug" }, { status: 404 });
  }

  const compulsoryFile = loadSchoolSubjectFile(schoolSlug, POST_UTME_COMPULSORY_SUBJECT_SLUG);
  if (!compulsoryFile) {
    return NextResponse.json(
      { error: "General Paper content is unavailable for this school" },
      { status: 404 },
    );
  }

  const compulsory = {
    slug: `${schoolSlug}-${POST_UTME_COMPULSORY_SUBJECT_SLUG}`,
    name: `${school.shortName} General Paper`,
    questions: shuffledSample(compulsoryFile.questions, POST_UTME_COMBINED_QUESTIONS_PER_SUBJECT),
  };

  const electives = uniqueRequested.map((slug) => {
    const file = loadSubjectFile("jamb", slug)!;
    return {
      slug: `${schoolSlug}-jamb-${slug}`,
      name: `${file.subject} (JAMB)`,
      questions: shuffledSample(file.questions, POST_UTME_COMBINED_QUESTIONS_PER_SUBJECT),
    };
  });

  return NextResponse.json({ subjects: [compulsory, ...electives] });
}
