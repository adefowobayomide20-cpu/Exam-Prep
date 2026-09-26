"use client";

import { usePathname } from "next/navigation";
import HomeTopBar from "@/components/HomeTopBar";

// Mobile-only slim title bar, replacing Header on small viewports so the
// PWA feels like a native app (no logo/nav-links/auth-controls — just the
// current page's title). Desktop keeps the full Header (see layout.tsx).
// Home ("/") is the one exception: it gets branding + notification/profile
// icons instead of a generic title, via HomeTopBar below.
const ROUTE_TITLES: Record<string, string> = {
  "/": "Home",
  "/exam": "Exam",
  "/waec": "WAEC",
  "/neco": "NECO",
  "/jamb": "JAMB",
  "/post-utme": "Post-UTME",
  "/news": "News",
  "/services": "Services",
  "/profile": "Profile",
  "/notifications": "Notifications",
  "/premium": "Premium",
  "/tutor": "AI Tutor",
  "/theory": "Theory",
  "/duel": "Duel",
  "/sign-in": "Sign in",
  "/sign-up": "Sign up",
  "/reset-password": "Reset password",
  "/account-deletion-request": "Account Deletion Request",
  "/privacy": "Privacy Policy",
  "/terms": "Terms of Service",
  "/refund-policy": "Refund Policy",
  "/about": "About Us",
  "/faq": "FAQ",
};

function humanize(segment: string): string {
  return segment
    .split("-")
    .filter(Boolean)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

function titleForPath(pathname: string): string {
  if (ROUTE_TITLES[pathname]) return ROUTE_TITLES[pathname];

  const segments = pathname.split("/").filter(Boolean);
  if (segments.length === 0) return "Home";

  // Prefix match against known top-level routes (e.g. "/waec/mathematics"
  // falls back to a humanized last segment rather than "Exam Coach").
  const lastSegment = segments[segments.length - 1];
  const humanized = humanize(lastSegment);

  // If the last segment looks like an opaque id/code (e.g. duel room codes
  // like "ABC123", Firestore doc ids), humanizing it produces noise —
  // fall back to the site name instead. Ordinary word-based slugs (e.g.
  // "mathematics", "further-maths") are all-lowercase and pass through.
  const looksLikeId = /[A-Z]/.test(lastSegment) && /[0-9]/.test(lastSegment);
  if (looksLikeId) return "Exam Coach";

  return humanized || "Exam Coach";
}

export default function MobileTopBar() {
  const pathname = usePathname();

  if (pathname === "/") return <HomeTopBar />;

  const title = titleForPath(pathname);

  return (
    <header className="fixed inset-x-0 top-0 z-40 flex h-12 items-center justify-center border-b border-[var(--color-border)] bg-navy pt-[env(safe-area-inset-top)] md:hidden">
      <h1 className="truncate px-4 text-sm font-semibold text-cream">{title}</h1>
    </header>
  );
}
