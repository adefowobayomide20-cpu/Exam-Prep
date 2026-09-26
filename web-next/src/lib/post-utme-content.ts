import fs from "node:fs";
import path from "node:path";
import type { SubjectQuestionFile, SubjectSummary } from "./exam-content";

/**
 * Content-layer helpers for the school-first Post-UTME flow: pick a
 * university, then a subject, matching how the Flutter app's
 * post_utme_subject_picker_page.dart / post_jamb_school_detail_page.dart
 * already work (see lib/features/exam/post_jamb_schools.dart, read-only
 * reference — do not import from it directly, this file is the Next.js
 * port).
 *
 * Content reality: only 8 of these schools have real per-school curated
 * question banks in the Flutter app (exported to
 * src/content/questions/post-utme-schools/<slug>/*.json by
 * tool/export_post_utme_schools.dart at the repo root). The remaining
 * schools are still fully selectable and functional, but fall back to
 * general-purpose practice content — the shared Post-UTME common pool
 * (English Language / General Knowledge, exported to the `_common/`
 * folder) plus the existing generic Post-JAMB bank (Mathematics / Further
 * Mathematics / Biology, in src/content/questions/post-jamb/). This is the
 * same honesty pattern the Flutter app already uses for its own
 * placeholder fallbacks — see question_bank_registry.dart's doc comments —
 * and the UI must label fallback content as general practice questions,
 * not implied to be official past questions for that specific school.
 */

export interface PostUtmeSchool {
  /** URL-facing slug, e.g. "unilag". */
  slug: string;
  name: string;
  shortName: string;
  type: "Federal" | "State";
  /** Bare domain for the institution's official website (source of truth for cut-offs/dates, which change every session). */
  website: string;
  /** True for the 8 schools with a real curated question bank; false for schools that fall back to general practice content. */
  hasDedicatedContent: boolean;
  blurb: string;
}

// The 8 schools with real, curated per-school Post-UTME question banks
// (see lib/features/exam/quiz/question_bank/post_utme_school_subject_banks.dart,
// unilag_post_utme_bank.dart, unilorin_post_utme_bank.dart), plus 8 more
// well-known Nigerian federal/state universities that run a Post-UTME
// screening but don't have dedicated question content yet. The user asked
// for 15 schools; the 8 named "no dedicated content" schools below bring
// the total to 16 — see the export-script report for why (the named list
// itself has 8 entries, one more than the "7" summary count).
export const POST_UTME_SCHOOLS: PostUtmeSchool[] = [
  {
    slug: "unilag",
    name: "University of Lagos",
    shortName: "UNILAG",
    type: "Federal",
    website: "unilag.edu.ng",
    hasDedicatedContent: true,
    blurb:
      "Practice with UNILAG's own curated Post-UTME question pool covering English Language, Mathematics, and General Knowledge.",
  },
  {
    slug: "unilorin",
    name: "University of Ilorin",
    shortName: "UNILORIN",
    type: "Federal",
    website: "unilorin.edu.ng",
    hasDedicatedContent: true,
    blurb:
      "Practice with UNILORIN's own curated Post-UTME question pool covering English Language, Mathematics, and General Knowledge.",
  },
  {
    slug: "ui",
    name: "University of Ibadan",
    shortName: "UI",
    type: "Federal",
    website: "ui.edu.ng",
    hasDedicatedContent: true,
    blurb:
      "Practice with UI's own curated Post-UTME questions across English Language, Mathematics, General Knowledge, and a wide range of electives.",
  },
  {
    slug: "oau",
    name: "Obafemi Awolowo University",
    shortName: "OAU",
    type: "Federal",
    website: "oauife.edu.ng",
    hasDedicatedContent: true,
    blurb:
      "Practice with OAU's own curated Post-UTME questions across English Language, Mathematics, General Knowledge, and a wide range of electives.",
  },
  {
    slug: "uniben",
    name: "University of Benin",
    shortName: "UNIBEN",
    type: "Federal",
    website: "uniben.edu",
    hasDedicatedContent: true,
    blurb:
      "Practice with UNIBEN's own curated Post-UTME question pool covering English Language, Mathematics, and General Knowledge.",
  },
  {
    slug: "unn",
    name: "University of Nigeria, Nsukka",
    shortName: "UNN",
    type: "Federal",
    website: "unn.edu.ng",
    hasDedicatedContent: true,
    blurb:
      "Practice with UNN's own curated Post-UTME question pool covering English Language, Mathematics, and General Knowledge.",
  },
  {
    slug: "futa",
    name: "Federal University of Technology, Akure",
    shortName: "FUTA",
    type: "Federal",
    website: "futa.edu.ng",
    hasDedicatedContent: true,
    blurb:
      "Practice with FUTA's own curated Post-UTME question pool covering English Language, Mathematics, and General Knowledge.",
  },
  {
    slug: "lautech",
    name: "Ladoke Akintola University of Technology",
    shortName: "LAUTECH",
    type: "State",
    website: "lautech.edu.ng",
    hasDedicatedContent: true,
    blurb:
      "Practice with LAUTECH's own curated Post-UTME question pool covering English Language, Mathematics, and General Knowledge.",
  },
  {
    slug: "abu",
    name: "Ahmadu Bello University",
    shortName: "ABU",
    type: "Federal",
    website: "abu.edu.ng",
    hasDedicatedContent: false,
    blurb:
      "General Post-UTME practice questions for ABU applicants — always confirm the exact subjects and format on ABU's own screening portal.",
  },
  {
    slug: "uniport",
    name: "University of Port Harcourt",
    shortName: "UNIPORT",
    type: "Federal",
    website: "uniport.edu.ng",
    hasDedicatedContent: false,
    blurb:
      "General Post-UTME practice questions for UNIPORT applicants — always confirm the exact subjects and format on UNIPORT's own screening portal.",
  },
  {
    slug: "unical",
    name: "University of Calabar",
    shortName: "UNICAL",
    type: "Federal",
    website: "unical.edu.ng",
    hasDedicatedContent: false,
    blurb:
      "General Post-UTME practice questions for UNICAL applicants — always confirm the exact subjects and format on UNICAL's own screening portal.",
  },
  {
    slug: "futo",
    name: "Federal University of Technology, Owerri",
    shortName: "FUTO",
    type: "Federal",
    website: "futo.edu.ng",
    hasDedicatedContent: false,
    blurb:
      "General Post-UTME practice questions for FUTO applicants — always confirm the exact subjects and format on FUTO's own screening portal.",
  },
  {
    slug: "unizik",
    name: "Nnamdi Azikiwe University",
    shortName: "UNIZIK",
    type: "Federal",
    website: "unizik.edu.ng",
    hasDedicatedContent: false,
    blurb:
      "General Post-UTME practice questions for UNIZIK applicants — always confirm the exact subjects and format on UNIZIK's own screening portal.",
  },
  {
    slug: "buk",
    name: "Bayero University, Kano",
    shortName: "BUK",
    type: "Federal",
    website: "buk.edu.ng",
    hasDedicatedContent: false,
    blurb:
      "General Post-UTME practice questions for BUK applicants — always confirm the exact subjects and format on BUK's own screening portal.",
  },
  {
    slug: "uniuyo",
    name: "University of Uyo",
    shortName: "UNIUYO",
    type: "Federal",
    website: "uniuyo.edu.ng",
    hasDedicatedContent: false,
    blurb:
      "General Post-UTME practice questions for UNIUYO applicants — always confirm the exact subjects and format on UNIUYO's own screening portal.",
  },
  {
    slug: "unijos",
    name: "University of Jos",
    shortName: "UNIJOS",
    type: "Federal",
    website: "unijos.edu.ng",
    hasDedicatedContent: false,
    blurb:
      "General Post-UTME practice questions for UNIJOS applicants — always confirm the exact subjects and format on UNIJOS's own screening portal.",
  },
];

// See the matching comment on exam-content.ts's CONTENT_ROOT — moved under
// public/ because that's the only directory Firebase's Next.js Hosting
// integration reliably bundles into the deployed Cloud Function at runtime;
// outputFileTracingIncludes in next.config.ts does not work with this
// integration despite appearing correctly in Next's own build trace output.
const SCHOOL_CONTENT_ROOT = path.join(
  process.cwd(),
  "public",
  "content",
  "questions",
  "post-utme-schools",
);
const POST_JAMB_ROOT = path.join(process.cwd(), "public", "content", "questions", "post-jamb");

/** Subjects served as general practice content for any school without its own dedicated bank. */
const FALLBACK_SUBJECT_SLUGS = [
  "english-language",
  "mathematics",
  "further-mathematics",
  "biology",
  "general-knowledge",
];

// ---------------------------------------------------------------------------
// Post-UTME combined (General Paper + 3 JAMB electives) mode — additive only.
// ---------------------------------------------------------------------------

/** Subject slug for the compulsory "General Paper" slot in the Post-UTME
 * combined flow. This codebase's existing field for the same content is
 * "General Knowledge" (`general-knowledge.json`, present for every school —
 * either the school's own dedicated bank or the shared `_common` fallback,
 * see `FALLBACK_SUBJECT_SLUGS` above), which the user's "General Paper"
 * terminology refers to. There's no separate JAMB-style shared "General
 * Paper" subject in this codebase, and Post-UTME's existing single-subject
 * pages already treat General Knowledge as the school's own screening-style
 * general paper, so reusing it per-school (rather than inventing new
 * content) is the correct source — only the combined-flow UI label changes
 * to "General Paper (compulsory)" to match the user's wording; the
 * single-subject "General Knowledge" pages elsewhere are untouched. */
export const POST_UTME_COMPULSORY_SUBJECT_SLUG = "general-knowledge";

export function getSchoolSlugs(): string[] {
  return POST_UTME_SCHOOLS.map((s) => s.slug);
}

export function getSchoolBySlug(slug: string): PostUtmeSchool | undefined {
  return POST_UTME_SCHOOLS.find((s) => s.slug === slug);
}

/** Subject slugs available for a school, sorted with the core three first. */
export function getSubjectSlugsForSchool(schoolSlug: string): string[] {
  const school = getSchoolBySlug(schoolSlug);
  if (!school) return [];

  if (!school.hasDedicatedContent) {
    return FALLBACK_SUBJECT_SLUGS;
  }

  const dirPath = path.join(SCHOOL_CONTENT_ROOT, schoolSlug);
  if (!fs.existsSync(dirPath)) return [];
  const slugs = fs
    .readdirSync(dirPath)
    .filter((file) => file.endsWith(".json"))
    .map((file) => file.replace(/\.json$/, ""));

  const core = ["english-language", "mathematics", "general-knowledge"];
  const electives = slugs.filter((s) => !core.includes(s)).sort((a, b) => a.localeCompare(b));
  return [...core.filter((s) => slugs.includes(s)), ...electives];
}

function readJsonFile(filePath: string): SubjectQuestionFile | null {
  if (!fs.existsSync(filePath)) return null;
  const raw = fs.readFileSync(filePath, "utf8");
  return JSON.parse(raw) as SubjectQuestionFile;
}

/**
 * Loads question content for a (school, subject) pair. For the 8 schools
 * with dedicated content this reads their own JSON file directly. For every
 * other school it falls back to: the shared common pool for English
 * Language / General Knowledge, and the existing generic Post-JAMB bank for
 * Mathematics / Further Mathematics / Biology.
 */
export function loadSchoolSubjectFile(
  schoolSlug: string,
  subjectSlug: string,
): SubjectQuestionFile | null {
  const school = getSchoolBySlug(schoolSlug);
  if (!school) return null;

  if (school.hasDedicatedContent) {
    return readJsonFile(path.join(SCHOOL_CONTENT_ROOT, schoolSlug, `${subjectSlug}.json`));
  }

  if (!FALLBACK_SUBJECT_SLUGS.includes(subjectSlug)) return null;

  if (subjectSlug === "english-language" || subjectSlug === "general-knowledge") {
    return readJsonFile(path.join(SCHOOL_CONTENT_ROOT, "_common", `${subjectSlug}.json`));
  }

  // mathematics / further-mathematics / biology
  return readJsonFile(path.join(POST_JAMB_ROOT, `${subjectSlug}.json`));
}

/** Lightweight (slug, name, count) summary for every subject a school offers — used on the school landing page. */
export function getSubjectSummariesForSchool(schoolSlug: string): SubjectSummary[] {
  return getSubjectSlugsForSchool(schoolSlug).map((slug) => {
    const file = loadSchoolSubjectFile(schoolSlug, slug);
    return {
      slug,
      name: file?.subject ?? slug,
      questionCount: file?.questions.length ?? 0,
    };
  });
}

/** All (school, subject) slug pairs that have content — for generateStaticParams. */
export function getAllSchoolSubjectPairs(): { school: string; subject: string }[] {
  return getSchoolSlugs().flatMap((school) =>
    getSubjectSlugsForSchool(school).map((subject) => ({ school, subject })),
  );
}
