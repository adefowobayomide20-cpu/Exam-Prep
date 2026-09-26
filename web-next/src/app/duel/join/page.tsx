import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import JoinDuelForm from "@/components/duel/JoinDuelForm";

export const metadata: Metadata = {
  title: "Join a Duel",
  description: "Enter a duel code to join a friend's live 1v1 quiz duel.",
  alternates: { canonical: "/duel/join" },
  robots: { index: false, follow: true },
};

export default function DuelJoinPage() {
  return (
    <RequireAuth>
      <JoinDuelForm />
    </RequireAuth>
  );
}
