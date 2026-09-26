import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import PremiumView from "@/components/premium/PremiumView";

export const metadata: Metadata = {
  title: "Go Premium",
  description:
    "Upgrade to Exam Coach Premium for unlimited Snap & Solve and Theory AI help, an ad-free experience, and to support Exam Coach.",
  alternates: { canonical: "/premium" },
  robots: { index: false, follow: true },
};

export default function PremiumPage() {
  return (
    <RequireAuth>
      <PremiumView />
    </RequireAuth>
  );
}
