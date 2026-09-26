"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { useAvatarUrl } from "@/lib/use-avatar-url";

// Mobile-only bottom tab bar, mirroring the Flutter app's MainNavShell
// (Home / Exam / News / Services / Profile). Hidden at md: and above where
// Header's top nav takes over. No icon library is a dependency yet (see
// package.json), so these are small hand-rolled inline SVGs.
const ICONS = {
  home: (
    <path d="M3 11.5 12 4l9 7.5M5 10v9a1 1 0 0 0 1 1h4v-6h4v6h4a1 1 0 0 0 1-1v-9" />
  ),
  exam: (
    <path d="M6 3h9l3 3v15H6zM15 3v3h3M9 12h6M9 15h6M9 9h3" />
  ),
  news: (
    <path d="M4 5h13a2 2 0 0 1 2 2v12H6a2 2 0 0 1-2-2zM8 9h7M8 12h7M8 15h4M19 8v10a1 1 0 0 1-1 1" />
  ),
  services: (
    <path d="M12 3 4 7v5c0 4.5 3.4 7.7 8 9 4.6-1.3 8-4.5 8-9V7z" />
  ),
  profile: (
    <path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM5 20a7 7 0 0 1 14 0" />
  ),
};

function TabIcon({ name }: { name: keyof typeof ICONS }) {
  return (
    <svg
      viewBox="0 0 24 24"
      width={22}
      height={22}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.8}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {ICONS[name]}
    </svg>
  );
}

export default function BottomNav() {
  const pathname = usePathname();
  const { user } = useAuth();
  const avatarUrl = useAvatarUrl();

  const tabs: { href: string; label: string; icon: keyof typeof ICONS }[] = [
    { href: "/", label: "Home", icon: "home" },
    { href: "/exam", label: "Exam", icon: "exam" },
    { href: "/news", label: "News", icon: "news" },
    { href: "/services", label: "Services", icon: "services" },
    { href: user ? "/profile" : "/sign-in", label: "Profile", icon: "profile" },
  ];

  return (
    <nav
      aria-label="Primary mobile"
      className="fixed inset-x-0 bottom-0 z-40 flex border-t border-[var(--color-border)] bg-[var(--color-surface)] pb-[env(safe-area-inset-bottom)] md:hidden"
    >
      {tabs.map((tab) => {
        const active =
          tab.href === "/" ? pathname === "/" : pathname.startsWith(tab.href);
        return (
          <Link
            key={tab.label}
            href={tab.href}
            className={`flex flex-1 flex-col items-center gap-0.5 py-2 text-xs font-medium transition-colors ${
              active
                ? "text-gold"
                : "text-[var(--color-primary)]/70 hover:text-gold"
            }`}
          >
            {tab.icon === "profile" && avatarUrl ? (
              // unoptimized: Firebase Hosting's own image layer intercepts
              // /_next/image requests ahead of our Next.js function and
              // rejects Firebase Storage URLs with a 400 regardless of
              // next.config.ts's remotePatterns (see use-avatar-url.ts) —
              // this renders the avatarUrl directly instead, which is fine
              // since it's already resized to ~512px before upload.
              <Image
                src={avatarUrl}
                alt=""
                width={22}
                height={22}
                unoptimized
                className="h-[22px] w-[22px] rounded-full object-cover"
              />
            ) : (
              <TabIcon name={tab.icon} />
            )}
            {tab.label}
          </Link>
        );
      })}
    </nav>
  );
}
