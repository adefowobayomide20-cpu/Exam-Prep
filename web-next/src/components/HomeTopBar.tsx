"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { useAuth } from "@/lib/auth-context";
import { watchNotifications } from "@/lib/notification-service";
import { useAvatarUrl } from "@/lib/use-avatar-url";

// Home-only variant of the mobile top bar (rendered by MobileTopBar when
// pathname === "/"): Exam Coach branding on the left instead of a generic
// page title, notification bell (with unread badge) + profile icon on the
// right. Every other route keeps MobileTopBar's plain centered title.
const ICONS = {
  bell: (
    <path d="M6 9a6 6 0 1 1 12 0c0 3.4 1 5 1.6 5.8a1 1 0 0 1-.8 1.7H5.2a1 1 0 0 1-.8-1.7C5 14 6 12.4 6 9ZM9.5 19a2.5 2.5 0 0 0 5 0" />
  ),
  profile: (
    <path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM5 20a7 7 0 0 1 14 0" />
  ),
};

function Icon({ name }: { name: keyof typeof ICONS }) {
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

export default function HomeTopBar() {
  const { user } = useAuth();
  const [unreadCount, setUnreadCount] = useState(0);
  const avatarUrl = useAvatarUrl();

  useEffect(() => {
    // Signed-out visitors have no `users/{uid}/notifications` doc to read —
    // skip the Firestore listener entirely rather than querying with no uid.
    if (!user) return;
    return watchNotifications(user.uid, (docs) => {
      setUnreadCount(docs.filter((n) => !n.read).length);
    });
  }, [user]);

  // Ignore any stale count from a previous session once signed out, rather
  // than resetting state synchronously inside the effect above.
  const displayedUnreadCount = user ? unreadCount : 0;

  return (
    <header className="fixed inset-x-0 top-0 z-40 flex h-12 items-center justify-between gap-3 border-b border-[var(--color-border)] bg-navy px-4 pt-[env(safe-area-inset-top)] md:hidden">
      <Link href="/" className="flex min-w-0 items-center gap-2">
        <Image src="/logo/logo_mark.png" alt="" width={22} height={22} priority />
        <span className="truncate text-sm font-semibold text-cream">Exam Coach</span>
      </Link>

      <div className="flex shrink-0 items-center gap-4 text-cream">
        <Link href="/notifications" aria-label="Notifications" className="relative">
          <Icon name="bell" />
          {displayedUnreadCount > 0 && (
            <span
              aria-hidden="true"
              className="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-gold px-1 text-[10px] font-semibold leading-none text-navy"
            >
              {displayedUnreadCount > 9 ? "9+" : displayedUnreadCount}
            </span>
          )}
        </Link>
        <Link href={user ? "/profile" : "/sign-in"} aria-label="Profile">
          {avatarUrl ? (
            // unoptimized: see BottomNav.tsx's matching comment — Firebase
            // Hosting's own image layer rejects /_next/image requests for
            // Firebase Storage URLs ahead of our Next.js function.
            <Image
              src={avatarUrl}
              alt=""
              width={22}
              height={22}
              unoptimized
              className="h-[22px] w-[22px] rounded-full object-cover"
            />
          ) : (
            <Icon name="profile" />
          )}
        </Link>
      </div>
    </header>
  );
}
