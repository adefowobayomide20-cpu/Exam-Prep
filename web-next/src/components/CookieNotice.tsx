"use client";

import Link from "next/link";
import { useEffect, useState, useSyncExternalStore } from "react";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import {
  getDismissedServerSnapshot,
  isDismissed,
  persistDismissed,
  subscribeDismissed,
} from "@/lib/persistent-dismiss";

const DISMISS_KEY = "exam-coach:cookie-notice-dismissed";

/**
 * Simple cookie/consent disclosure banner. Not a full consent-management
 * platform (no granular opt-in/opt-out toggles) — this site's audience is
 * overwhelmingly Nigerian, so strict GDPR-style prior-consent gating isn't
 * required, but a plain disclosure is good practice and standard once
 * Google-served ads are live (they set advertising cookies/identifiers).
 *
 * Dismissal is remembered THREE ways, layered:
 *  1. localStorage + a cookie (src/lib/persistent-dismiss.ts) — instant,
 *     no network round-trip, but tied to one browser and can be blocked by
 *     some in-app/private-browsing contexts.
 *  2. For SIGNED-IN users only: `users/{uid}.cookieNoticeDismissed` in
 *     Firestore. This is the one layer that survives browser storage being
 *     blocked entirely, a different browser/device, or the CDN/ISR page
 *     cache serving a stale HTML response for up to an hour (this route
 *     inherits Next.js's `revalidate` caching) — since this check runs
 *     client-side against live Firestore, not the cached HTML.
 * Whichever layer says "dismissed" wins; the Firestore check only ever
 * HIDES an already-visible banner (never un-hides one), so there's no
 * flash-then-reappear regardless of which check resolves first.
 */
export default function CookieNotice() {
  const { user } = useAuth();
  // Reads localStorage/cookie state via useSyncExternalStore rather than a
  // useState lazy initializer or a plain useEffect+setState — see the doc
  // comment in persistent-dismiss.ts for why: this site prerenders most
  // routes statically at build time, and confirmed-by-reproduction, those
  // other patterns don't reliably reflect the visitor's real browser
  // storage on those routes. useSyncExternalStore is the primitive React
  // guarantees will resync against the live browser after hydration.
  const persistedDismissed = useSyncExternalStore(
    subscribeDismissed,
    () => isDismissed(DISMISS_KEY),
    getDismissedServerSnapshot,
  );
  // Session-only fallback: if localStorage AND the cookie write both throw
  // (private browsing, some in-app browser webviews), persistedDismissed
  // above would never flip true. This still hides the banner for the rest
  // of the current page view — it just won't survive a fresh page load.
  const [sessionDismissed, setSessionDismissed] = useState(false);
  const dismissed = persistedDismissed || sessionDismissed;

  useEffect(() => {
    if (!user) return;
    let cancelled = false;
    getDoc(doc(db, "users", user.uid))
      .then((snapshot) => {
        if (cancelled) return;
        if (snapshot.data()?.cookieNoticeDismissed) {
          persistDismissed(DISMISS_KEY); // syncs local storage + notifies subscribers
        }
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, [user]);

  if (dismissed) return null;

  const dismiss = () => {
    // Hide immediately regardless of whether persistence succeeds.
    setSessionDismissed(true);
    persistDismissed(DISMISS_KEY);
    if (user) {
      setDoc(doc(db, "users", user.uid), { cookieNoticeDismissed: true }, { merge: true }).catch(
        () => {},
      );
    }
  };

  return (
    // Sits above InstallPrompt (which occupies bottom-16 / md:bottom-4) so
    // the two banners stack without overlapping if both are shown.
    <div className="fixed inset-x-0 bottom-32 z-50 mx-auto mb-2 flex max-w-2xl flex-col items-start gap-3 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 shadow-lg sm:flex-row sm:items-center sm:justify-between md:bottom-20">
      <p className="text-sm text-[var(--color-primary)]/80">
        We use cookies and similar technologies to keep you signed in and, if
        ads are shown on this site, Google may use its own advertising
        cookies. See our{" "}
        <Link href="/privacy" className="text-gold hover:underline">
          Privacy Policy
        </Link>
        .
      </p>
      <button
        type="button"
        onClick={dismiss}
        className="shrink-0 rounded-full bg-navy px-4 py-1.5 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
      >
        Got it
      </button>
    </div>
  );
}
