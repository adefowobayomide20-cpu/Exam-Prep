import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import TeacherView from "@/components/teacher/TeacherView";

export const metadata: Metadata = {
  title: "AI Teacher",
  description:
    "A structured, curriculum-aware daily lesson through your class topics — Premium feature.",
  alternates: { canonical: "/teacher" },
  robots: { index: false, follow: true },
};

export default function TeacherPage() {
  return (
    <RequireAuth>
      <TeacherView />
    </RequireAuth>
  );
}
