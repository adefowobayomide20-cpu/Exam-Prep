"use client";

import Image from "next/image";
import Link from "next/link";
import { signOut } from "firebase/auth";
import { useState } from "react";
import { auth } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";

const NAV_LINKS = [
  { href: "/", label: "Home" },
  { href: "/exam", label: "Exam" },
  { href: "/tutor", label: "Tutor" },
  { href: "/teacher", label: "AI Teacher" },
  { href: "/news", label: "News" },
  { href: "/services", label: "Services" },
];

export default function Header() {
  const { user, loading } = useAuth();
  const [signingOut, setSigningOut] = useState(false);

  const handleSignOut = async () => {
    setSigningOut(true);
    try {
      await signOut(auth);
    } finally {
      setSigningOut(false);
    }
  };

  return (
    <header className="hidden border-b border-[var(--color-border)] bg-[var(--color-surface)] md:block">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-3 sm:px-6">
        <Link href="/" className="flex items-center gap-2">
          <Image
            src="/logo/logo_mark.png"
            alt="Exam Coach logo"
            width={36}
            height={36}
            priority
          />
          <span className="text-lg font-semibold tracking-tight text-[var(--color-primary)]">
            Exam Coach
          </span>
        </Link>
        <nav aria-label="Primary" className="flex items-center gap-5 text-sm font-medium">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-[var(--color-primary)] transition-colors hover:text-gold"
            >
              {link.label}
            </Link>
          ))}
          {!loading && (
            <>
              {user ? (
                <div className="flex items-center gap-3">
                  <Link
                    href="/notifications"
                    className="text-[var(--color-primary)] transition-colors hover:text-gold"
                  >
                    Notifications
                  </Link>
                  <Link
                    href="/profile"
                    className="hidden text-[var(--color-primary)]/70 transition-colors hover:text-gold sm:inline"
                  >
                    {user.displayName || user.email}
                  </Link>
                  <button
                    type="button"
                    onClick={handleSignOut}
                    disabled={signingOut}
                    className="rounded-full border border-[var(--color-border)] px-4 py-1.5 text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold disabled:opacity-60"
                  >
                    {signingOut ? "Signing out…" : "Sign out"}
                  </button>
                </div>
              ) : (
                <Link
                  href="/sign-in"
                  className="rounded-full bg-navy px-4 py-1.5 font-semibold text-cream transition-colors hover:bg-navy-light"
                >
                  Sign in
                </Link>
              )}
            </>
          )}
        </nav>
      </div>
    </header>
  );
}
