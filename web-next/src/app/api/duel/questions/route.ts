import { NextResponse } from "next/server";
import { loadSubjectFile } from "@/lib/exam-content";

/**
 * Server-side question lookup for duels. `exam-content.ts` reads JSON off
 * disk with `node:fs`, so it can't be imported into the client components
 * that create/accept duels (the lobby page, the incoming-challenge
 * listener, the join-by-code page) — this tiny route handler is the
 * client-safe bridge. Duels always draw from the JAMB bank (see
 * duel-types.ts), so the exam category isn't a request parameter.
 */
export async function GET(request: Request) {
  const subject = new URL(request.url).searchParams.get("subject");
  if (!subject) {
    return NextResponse.json({ error: "Missing subject" }, { status: 400 });
  }
  const file = loadSubjectFile("jamb", subject);
  if (!file) {
    return NextResponse.json({ error: "Unknown subject" }, { status: 404 });
  }
  return NextResponse.json({ subject: file.subject, questions: file.questions });
}
