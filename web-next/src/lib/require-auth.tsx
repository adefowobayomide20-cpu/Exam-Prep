"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, type ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";

/**
 * Gate for pages/components that require a signed-in Firebase Auth user —
 * e.g. Theory practice, the AI Tutor, Duels, Profile. Unlike the MCQ
 * practice pages (Phase 4, deliberately public/no-auth), these all call
 * Cloud Functions that throw `unauthenticated` without `request.auth`.
 *
 * Usage: wrap the auth-requiring content in a client component —
 *   <RequireAuth>{children}</RequireAuth>
 * While the initial auth check is in flight it shows a lightweight loading
 * state (matches useAuth().loading). Once resolved, a signed-out user is
 * redirected to /sign-in?redirect=<current path> (and shown an inline
 * "sign in to continue" fallback in case the redirect hasn't happened yet,
 * e.g. JS disabled or the router navigation is still pending) instead of
 * ever rendering the gated content.
 *
 * The redirect itself is a router navigation, not a setState call, so it's
 * safe inside a bare useEffect under the react-hooks/set-state-in-effect
 * rule — no synchronous setState happens during render or effect.
 */
export default function RequireAuth({ children }: { children: ReactNode }) {
  const { user, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const signInHref = `/sign-in?redirect=${encodeURIComponent(pathname)}`;

  useEffect(() => {
    if (!loading && !user) {
      router.replace(signInHref);
    }
  }, [loading, user, signInHref, router]);

  if (loading) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <p className="text-[var(--color-primary)]/70">Checking your sign-in status…</p>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <h1 className="text-2xl font-bold text-[var(--color-primary)]">
          Sign in required
        </h1>
        <p className="mt-3 text-[var(--color-primary)]/80">
          You need to be signed in to continue.
        </p>
        <Link
          href={signInHref}
          className="mt-6 inline-block rounded-full bg-navy px-5 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light"
        >
          Sign in
        </Link>
      </div>
    );
  }

  return <>{children}</>;
}
