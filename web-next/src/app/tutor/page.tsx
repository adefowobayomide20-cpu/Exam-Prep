import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import TutorChat from "@/components/tutor/TutorChat";

export const metadata: Metadata = {
  title: "AI Tutor — Snap & Solve",
  description:
    "Snap a photo of any question and get an instant, step-by-step AI explanation. Sign in to start.",
  alternates: { canonical: "/tutor" },
  robots: { index: false, follow: true },
  openGraph: {
    title: "AI Tutor — Snap & Solve",
    description:
      "Snap a photo of any question and get an instant, step-by-step AI explanation. Sign in to start.",
    url: "/tutor",
  },
};

export default function TutorPage() {
  return (
    <RequireAuth>
      <TutorChat />
    </RequireAuth>
  );
}
