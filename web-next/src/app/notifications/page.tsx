import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import NotificationsView from "@/components/notifications/NotificationsView";

export const metadata: Metadata = {
  title: "Notifications",
  description: "Your Exam Coach notifications — news alerts, reminders, and updates.",
  alternates: { canonical: "/notifications" },
  robots: { index: false, follow: true },
};

export default function NotificationsPage() {
  return (
    <RequireAuth>
      <NotificationsView />
    </RequireAuth>
  );
}
