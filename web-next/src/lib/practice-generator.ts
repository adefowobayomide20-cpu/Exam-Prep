import { httpsCallable } from "firebase/functions";
import { functions } from "@/lib/firebase";
import type { QuizQuestionData } from "@/lib/exam-content";

/**
 * Thin wrapper around the `generatePracticeSetFromOutline` Cloud Function
 * (functions/practice-generator.js) — mirrors how solveQuestion/
 * generateTheoryQuestion are called from TutorChat.tsx/TheorySession.tsx.
 * Premium-only server-side; this file has no gating logic of its own, the
 * caller (see src/app/tutor/generate) is responsible for the client-side
 * "nice UX" gate, the Cloud Function enforces the real one.
 */

export interface GeneratePracticeSetRequest {
  subject: string;
  /** Typed topic list/course outline — mutually exclusive-ish with imageBase64
   * (either works, at least one is required by the backend). Preferred over
   * a photo: identical text input hits the server-side cache, so it's both
   * faster and cheaper to regenerate. */
  topicText?: string;
  imageBase64?: string;
  mimeType?: string;
}

export interface GeneratedTheoryQuestion {
  question: string;
  topic: string;
}

export interface GeneratePracticeSetResponse {
  mcqs: QuizQuestionData[];
  theoryQuestions: GeneratedTheoryQuestion[];
}

export async function generatePracticeSetFromOutline(
  request: GeneratePracticeSetRequest,
): Promise<GeneratePracticeSetResponse> {
  const callable = httpsCallable<GeneratePracticeSetRequest, GeneratePracticeSetResponse>(
    functions,
    "generatePracticeSetFromOutline",
  );
  const { data } = await callable(request);
  return data;
}
