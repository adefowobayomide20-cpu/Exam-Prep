import { NextResponse } from "next/server";
import {
  COMBINED_QUESTIONS_PER_SUBJECT,
  getSubjectSlugsForCategory,
  loadSubjectFile,
  shuffledSample,
} from "@/lib/exam-content";

/**
 * Server-side question sampling for the JAMB combined (4-subject) session.
 * `exam-content.ts` reads JSON off disk with `node:fs`, so it can't be
 * imported into the client-side subject-selection/session components —
 * this route is the client-safe bridge, matching the existing
 * `/api/duel/questions` pattern (see that route). Unlike the duel route,
 * this one accepts multiple subjects at once (exactly 4, one combined
 * session) and samples `COMBINED_QUESTIONS_PER_SUBJECT` questions from each.
 */
export async function GET(request: Request) {
  const subjectsParam = new URL(request.url).searchParams.get("subjects");
  if (!subjectsParam) {
    return NextResponse.json({ error: "Missing subjects" }, { status: 400 });
  }
  const requested = subjectsParam.split(",").map((s) => s.trim()).filter(Boolean);
  const uniqueRequested = Array.from(new Set(requested));
  if (uniqueRequested.length !== 4) {
    return NextResponse.json(
      { error: "Exactly 4 subjects are required (Use of English + 3 electives)" },
      { status: 400 },
    );
  }

  const validSlugs = new Set(getSubjectSlugsForCategory("jamb"));
  if (!uniqueRequested.every((slug) => validSlugs.has(slug))) {
    return NextResponse.json({ error: "Unknown subject slug" }, { status: 404 });
  }

  const subjects = uniqueRequested.map((slug) => {
    const file = loadSubjectFile("jamb", slug)!;
    const sampled = shuffledSample(file.questions, COMBINED_QUESTIONS_PER_SUBJECT);
    return { slug, name: file.subject, questions: sampled };
  });

  return NextResponse.json({ subjects });
}
