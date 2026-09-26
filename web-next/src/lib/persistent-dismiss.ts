/**
 * Remembers a one-time "dismissed" choice (cookie notice, install prompt)
 * as durably as a browser reasonably allows, without a server round-trip.
 * Tries BOTH localStorage and a first-party cookie independently — some
 * contexts block one but not the other (certain in-app browsers, e.g. the
 * webviews WhatsApp/Facebook use for shared links, and various privacy
 * settings, are inconsistent about which storage APIs they restrict), so
 * using both roughly doubles the chance the choice actually survives a
 * fresh page load. Every operation is wrapped so a blocked API degrades to
 * "not remembered" instead of throwing and breaking the caller.
 *
 * Exposed as a tiny useSyncExternalStore-compatible store (subscribe +
 * getSnapshot) rather than a plain function pair. This site prerenders most
 * routes statically at build time (everything except `/` and `/news`,
 * which use ISR) — reproduced directly against the live site that reading
 * this via a `useState(() => isDismissed(key))` lazy initializer (or even a
 * plain `useEffect` calling `setState`) does not reliably reflect the
 * visitor's actual browser storage on those static routes: pre-seeding
 * localStorage/cookies and hard-reloading a static page still showed the
 * "not dismissed" banner, even though a separate direct read confirmed the
 * storage value was correct. `useSyncExternalStore` is the one primitive
 * React guarantees will re-check its snapshot against the live browser
 * after hydration and force a resync if the server/client values differ —
 * exactly the mismatch happening here.
 */

const COOKIE_MAX_AGE_SECONDS = 60 * 60 * 24 * 365; // ~1 year

const listeners = new Set<() => void>();

function readLocalStorage(key: string): boolean {
  try {
    return localStorage.getItem(key) === "1";
  } catch {
    return false;
  }
}

function readCookie(key: string): boolean {
  try {
    return document.cookie
      .split("; ")
      .some((entry) => entry === `${key}=1`);
  } catch {
    return false;
  }
}

export function isDismissed(key: string): boolean {
  if (typeof window === "undefined") return false;
  return readLocalStorage(key) || readCookie(key);
}

export function persistDismissed(key: string): void {
  try {
    localStorage.setItem(key, "1");
  } catch {
    // Fall through to the cookie attempt below.
  }
  try {
    document.cookie = `${key}=1; max-age=${COOKIE_MAX_AGE_SECONDS}; path=/; SameSite=Lax`;
  } catch {
    // Both blocked — the choice just won't survive a fresh page load this
    // time. Callers still hide the UI for the current session regardless.
  }
  for (const listener of listeners) listener();
}

/** For useSyncExternalStore's subscribe argument. */
export function subscribeDismissed(onChange: () => void): () => void {
  listeners.add(onChange);
  return () => listeners.delete(onChange);
}

export function getDismissedServerSnapshot(): boolean {
  return false;
}
