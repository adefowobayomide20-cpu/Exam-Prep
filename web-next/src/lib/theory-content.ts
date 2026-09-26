/**
 * Subjects available for Theory practice mode. Unlike the MCQ subject list
 * (Phase 3/4 — driven by src/content/questions, ~35 WAEC subjects), Theory
 * questions are always AI-generated on demand via the `generateTheoryQuestion`
 * Cloud Function rather than served from a static bank, so in principle any
 * subject string works. This is a deliberately curated, smaller list — the
 * WAEC subjects that actually have a written (essay/calculation) theory
 * paper, matching lib/features/exam/theory/theory_questions.dart's
 * ready-made bank (Mathematics, English Language, Chemistry, Physics,
 * Agricultural Science) plus the other core WAEC subjects whose theory
 * papers are free-text/calculation-based and so grade well with an LLM.
 * Deliberately excludes practical/trade subjects (e.g. Basic Electricity,
 * Woodwork, Visual Arts, Home Management) and script-heavy languages (e.g.
 * Yoruba, Hausa, Igbo, French, Arabic) — a text-based AI grader isn't a good
 * fit for those without native-script/handwriting support.
 */
export interface TheorySubject {
  slug: string;
  name: string;
}

export const THEORY_SUBJECTS: TheorySubject[] = [
  { slug: "mathematics", name: "Mathematics" },
  { slug: "english-language", name: "English Language" },
  { slug: "physics", name: "Physics" },
  { slug: "chemistry", name: "Chemistry" },
  { slug: "biology", name: "Biology" },
  { slug: "agricultural-science", name: "Agricultural Science" },
  { slug: "economics", name: "Economics" },
  { slug: "government", name: "Government" },
  { slug: "geography", name: "Geography" },
  { slug: "commerce", name: "Commerce" },
  { slug: "financial-accounting", name: "Financial Accounting" },
  { slug: "christian-religious-studies", name: "Christian Religious Studies" },
  { slug: "civic-education", name: "Civic Education" },
  { slug: "literature-in-english", name: "Literature in English" },
];

export function getTheorySubjectSlugs(): string[] {
  return THEORY_SUBJECTS.map((subject) => subject.slug);
}

export function getTheorySubject(slug: string): TheorySubject | undefined {
  return THEORY_SUBJECTS.find((subject) => subject.slug === slug);
}
