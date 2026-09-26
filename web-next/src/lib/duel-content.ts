import type { QuizQuestionData } from "@/lib/exam-content";

function shuffled<T>(items: T[]): T[] {
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

/**
 * Client-side fetch + sample of a JAMB subject's question bank, via the
 * `/api/duel/questions` route handler (see that file for why a route
 * handler is needed instead of importing exam-content.ts directly).
 * Mirrors the Flutter app's `questionsForSubject(subject, sampleSize: ...)`.
 */
export async function fetchDuelQuestions(
  subjectSlug: string,
  sampleSize: number,
): Promise<{ subjectName: string; questions: QuizQuestionData[] }> {
  const response = await fetch(`/api/duel/questions?subject=${encodeURIComponent(subjectSlug)}`);
  if (!response.ok) {
    throw new Error("Could not load questions for that subject.");
  }
  const data = (await response.json()) as { subject: string; questions: QuizQuestionData[] };
  return { subjectName: data.subject, questions: shuffled(data.questions).slice(0, sampleSize) };
}
