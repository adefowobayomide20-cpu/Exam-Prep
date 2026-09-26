import fs from "node:fs";
import path from "node:path";

/**
 * Content-layer helpers for the exam/subject landing pages and quiz session.
 *
 * Source of truth for "what subjects exist" is the JSON files actually
 * present under src/content/questions/<dir>/*.json (see that folder's
 * README.md) — NOT the full subject list from the Flutter app, since not
 * every (subject, examCategory) pair has been migrated yet.
 */

export type CategorySlug = "waec" | "neco" | "jamb" | "post-utme";

export interface CategoryInfo {
  /** URL-facing slug, e.g. "post-utme". */
  slug: CategorySlug;
  /** Folder name under src/content/questions, e.g. "post-jamb". */
  dir: string;
  /** Full display name, matches the Flutter app's ExamTypeInfo.name. */
  name: string;
  /** Short label, matches ExamTypeInfo.shortLabel. */
  shortLabel: string;
  /** SEO-friendly blurb for the category landing page. */
  description: string;
}

export const CATEGORIES: Record<CategorySlug, CategoryInfo> = {
  waec: {
    slug: "waec",
    dir: "waec",
    name: "WAEC & WAEC GCE",
    shortLabel: "WAEC",
    description:
      "Practice free WAEC and WAEC GCE past questions across every subject. Each timed objective test mirrors the real West African Senior School Certificate Examination format, with instant scoring and worked explanations.",
  },
  neco: {
    slug: "neco",
    dir: "neco",
    name: "NECO & NECO GCE",
    shortLabel: "NECO",
    description:
      "Practice free NECO and NECO GCE past questions across every subject. Each timed objective test mirrors the real National Examinations Council format, with instant scoring and worked explanations.",
  },
  jamb: {
    slug: "jamb",
    dir: "jamb",
    name: "JAMB",
    shortLabel: "JAMB",
    description:
      "Practice free JAMB UTME past questions across every subject on the syllabus, including the compulsory Use of English paper. Each timed CBT-style test mirrors the real JAMB exam format, with instant scoring and worked explanations.",
  },
  "post-utme": {
    slug: "post-utme",
    dir: "post-jamb",
    name: "Post-UTME",
    shortLabel: "Post-UTME",
    description:
      "Practice free Post-UTME (Post-JAMB) screening past questions for the subjects Nigerian universities test most. Each timed objective test gives instant scoring and worked explanations to help you prepare for your school's screening exercise.",
  },
};

const CATEGORY_SLUGS = Object.keys(CATEGORIES) as CategorySlug[];

/**
 * Categories that still use the flat "/[category]/[subject]" list-of-subjects
 * flow. Post-UTME moved to a school-first flow (see post-utme-content.ts and
 * src/app/post-utme/**) — students pick a university before a subject,
 * matching the Flutter app — so it's intentionally excluded here even though
 * `CATEGORIES` (used for e.g. the /exam hub cards) still has an entry for it.
 */
const FLAT_CATEGORY_SLUGS: CategorySlug[] = ["waec", "neco", "jamb"];

// Lives under public/ (not src/) so it's actually present at runtime in the
// deployed Cloud Function — Firebase's Next.js Hosting integration bundles
// public/ in full, but does NOT respect outputFileTracingIncludes for
// arbitrary src/ files (confirmed by inspecting the deployed function
// package: files matched only by a trace-includes glob never made it into
// .firebase/<site>/functions/, while public/** always does, same as how
// icons/manifest/logo already load correctly on every route). Moving here
// was the actual fix after a next.config.ts outputFileTracingIncludes
// attempt silently did nothing in production despite working in `next build`'s
// own trace output — that mismatch is worth remembering if this ever needs
// revisiting.
const CONTENT_ROOT = path.join(process.cwd(), "public", "content", "questions");

export interface QuizQuestionData {
  subject: string;
  text: string;
  options: string[];
  correctIndex: number;
  explanation: string | null;
}

export interface SubjectQuestionFile {
  subject: string;
  examCategory: string;
  questions: QuizQuestionData[];
}

/** Category slugs that use the flat "/[category]/[subject]" flow — see FLAT_CATEGORY_SLUGS. */
export function getCategorySlugs(): CategorySlug[] {
  return FLAT_CATEGORY_SLUGS;
}

export function isCategorySlug(value: string): value is CategorySlug {
  return (CATEGORY_SLUGS as string[]).includes(value);
}

export function getCategoryInfo(slug: string): CategoryInfo | undefined {
  return isCategorySlug(slug) ? CATEGORIES[slug] : undefined;
}

/** Subject slugs (JSON filenames minus extension) available for a category, sorted A-Z. */
export function getSubjectSlugsForCategory(categorySlug: CategorySlug): string[] {
  const dirPath = path.join(CONTENT_ROOT, CATEGORIES[categorySlug].dir);
  if (!fs.existsSync(dirPath)) return [];
  return fs
    .readdirSync(dirPath)
    .filter((file) => file.endsWith(".json"))
    .map((file) => file.replace(/\.json$/, ""))
    .sort((a, b) => a.localeCompare(b));
}

export function loadSubjectFile(
  categorySlug: CategorySlug,
  subjectSlug: string,
): SubjectQuestionFile | null {
  const info = CATEGORIES[categorySlug];
  if (!info) return null;
  const filePath = path.join(CONTENT_ROOT, info.dir, `${subjectSlug}.json`);
  if (!fs.existsSync(filePath)) return null;
  const raw = fs.readFileSync(filePath, "utf8");
  return JSON.parse(raw) as SubjectQuestionFile;
}

export interface SubjectSummary {
  slug: string;
  name: string;
  questionCount: number;
}

/** Lightweight (name, count) summary for every subject in a category — used on the category landing page. */
export function getSubjectSummariesForCategory(categorySlug: CategorySlug): SubjectSummary[] {
  return getSubjectSlugsForCategory(categorySlug).map((slug) => {
    const file = loadSubjectFile(categorySlug, slug);
    return {
      slug,
      name: file?.subject ?? slug,
      questionCount: file?.questions.length ?? 0,
    };
  });
}

/** All (category, subject) slug pairs that have content — for generateStaticParams. */
export function getAllCategorySubjectPairs(): { category: CategorySlug; subject: string }[] {
  return FLAT_CATEGORY_SLUGS.flatMap((category) =>
    getSubjectSlugsForCategory(category).map((subject) => ({ category, subject })),
  );
}

/**
 * Practice-test duration in minutes for a category, matching the Flutter
 * app's per-subject timing (WAEC/NECO/Post-UTME: 15 min; JAMB: 15 min per
 * subject, since the app's 60-minute JAMB timer covers a 4-subject combined
 * test and this web version quizzes one subject at a time).
 */
export function getDurationMinutes(categorySlug: CategorySlug): number {
  void categorySlug;
  return 15;
}

/** Matches the Flutter app's _questionsPerSubject sample size. */
export const QUESTIONS_PER_SESSION = 20;

// ---------------------------------------------------------------------------
// JAMB combined (4-subject, single-session) mode — additive helpers only;
// none of the above single-subject exports are changed by these.
// ---------------------------------------------------------------------------

/** Subject slug for JAMB's compulsory "Use of English" paper (matches the
 * filename under src/content/questions/jamb, confirmed against the JSON's
 * `subject` field). Every combined session includes this subject plus 3
 * student-chosen electives, matching the real JAMB UTME format. */
export const JAMB_COMPULSORY_SUBJECT_SLUG = "use-of-english";

/** Sample size per subject for the combined 4-subject session. Real JAMB
 * gives ~40-60 questions per subject; 10/subject (40 total) keeps a single
 * combined session a reasonable length for a web practice tool while still
 * covering all 4 subjects and every question in the flow. */
export const COMBINED_QUESTIONS_PER_SUBJECT = 10;

/** Single shared countdown for the whole 4-subject combined session, in
 * minutes. Reuses the same 15-minutes-per-subject convention already
 * established by `getDurationMinutes` for JAMB (see its comment: the
 * Flutter app's real combined JAMB timer is treated as 60 minutes total for
 * a 4-subject test) rather than inventing a new proportional-scaling rule —
 * 4 subjects x 15 minutes = 60 minutes total. */
export const COMBINED_DURATION_MINUTES = 60;

// ---------------------------------------------------------------------------
// Post-UTME combined (General Paper + 4 JAMB electives, single-session) mode
// — additive helpers only; none of the JAMB combined exports above are
// changed by these. See src/app/post-utme/[school]/combined/page.tsx and
// src/app/api/post-utme-combined/route.ts.
// ---------------------------------------------------------------------------

/** Sample size per subject for the Post-UTME combined session. Real Post-UTME
 * screening tests run far shorter than JAMB's; the user asked for a single
 * 20-minute combined session across 5 subjects (General Paper + 4
 * electives, bumped up from 3 electives per a later revision). 5
 * questions/subject = 25 questions total, i.e. 48 seconds per question on
 * average across the shared 20-minute timer — enough time to read and
 * answer an objective question without leaving so much slack that the timer
 * never matters, while still touching every one of the 5 chosen subjects in
 * one sitting. */
export const POST_UTME_COMBINED_QUESTIONS_PER_SUBJECT = 5;

/** Single shared countdown for the whole Post-UTME combined session, in
 * minutes. Intentionally much shorter than `COMBINED_DURATION_MINUTES`
 * (JAMB's 60-minute, 4-subject combined test) — the user specified 20
 * minutes total for this shorter Post-UTME screening format (raised from an
 * initial 15 minutes once the elective count went from 3 to 4). */
export const POST_UTME_COMBINED_DURATION_MINUTES = 20;

/** Deterministic Fisher-Yates shuffle-and-take, shared by the combined-mode
 * API route (server-side sampling) — factored out so it isn't duplicated
 * from QuizSession.tsx's local `shuffled` helper (that component is left
 * untouched; this is a fresh export for the new flow only). */
export function shuffledSample<T>(items: T[], size: number): T[] {
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy.slice(0, size);
}
