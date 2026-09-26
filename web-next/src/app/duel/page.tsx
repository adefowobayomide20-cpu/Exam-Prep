import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import DuelHome from "@/components/duel/DuelHome";
import { getSubjectSummariesForCategory } from "@/lib/exam-content";

export const metadata: Metadata = {
  title: "Duel",
  description: "Challenge other students, invite a friend, or play vs computer in a live 1v1 JAMB quiz duel.",
  alternates: { canonical: "/duel" },
  robots: { index: false, follow: true },
};

export default function DuelPage() {
  // Duels always run over JAMB's question banks (see duel-types.ts) — no
  // exam-category picker, matching the Flutter app's lobby after its
  // category picker was removed this session.
  const subjects = getSubjectSummariesForCategory("jamb");

  return (
    <RequireAuth>
      <DuelHome subjects={subjects} />
    </RequireAuth>
  );
}
