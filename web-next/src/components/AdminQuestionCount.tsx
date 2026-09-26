"use client";

import type { ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";

/** Only this account sees per-subject question counts anywhere on the site —
 * everyone else sees nothing in their place. Server components (the static
 * exam/Post-UTME listing and subject-detail pages) can't know the signed-in
 * user at build time, so these small client components defer the check to
 * render time instead. */
const ADMIN_EMAIL = "adefowobayomide20@gmail.com";

function useIsAdmin(): boolean {
  const { user } = useAuth();
  return user?.email === ADMIN_EMAIL;
}

export default function AdminQuestionCount({ count }: { count: number }) {
  const isAdmin = useIsAdmin();
  if (!isAdmin) return null;
  return <span className="text-xs text-[var(--color-primary)]/60">{count} Qs</span>;
}

/** Wraps any children (e.g. a "Question bank" stat card, or an inline count
 * mention in a paragraph) that should only render for the admin account. */
export function AdminOnly({ children }: { children: ReactNode }) {
  const isAdmin = useIsAdmin();
  if (!isAdmin) return null;
  return <>{children}</>;
}
