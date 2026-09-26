"use client";

import { useEffect, useState, useSyncExternalStore } from "react";
import {
  getDismissedServerSnapshot,
  isDismissed,
  persistDismissed,
  subscribeDismissed,
} from "@/lib/persistent-dismiss";

const DISMISS_KEY = "exam-coach:install-prompt-dismissed";

// Chrome's `beforeinstallprompt` type isn't in lib.dom yet.
interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
}

// Custom install banner, mirroring the Flutter app's PwaInstallOverlay:
// listen for the browser's install-eligibility event, stash it, and show our
// own bottom banner instead of relying on the browser's native mini-infobar.
export default function InstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] =
    useState<BeforeInstallPromptEvent | null>(null);
  // Reads localStorage/cookie state via useSyncExternalStore rather than a
  // useState lazy initializer — see the doc comment in persistent-dismiss.ts
  // for why: on this site's statically-prerendered routes, a lazy
  // initializer's localStorage read doesn't reliably reflect the visitor's
  // actual browser storage (confirmed by direct reproduction against the
  // live site). Session-only fallback covers the case where both the
  // localStorage and cookie writes throw (private browsing, some in-app
  // browser webviews) — persistedDismissed would never flip true then, but
  // the dismissal should still hold for the rest of this page view.
  const persistedDismissed = useSyncExternalStore(
    subscribeDismissed,
    () => isDismissed(DISMISS_KEY),
    getDismissedServerSnapshot,
  );
  const [sessionDismissed, setSessionDismissed] = useState(false);
  const dismissed = persistedDismissed || sessionDismissed;

  useEffect(() => {
    const handler = (event: Event) => {
      event.preventDefault();
      setDeferredPrompt(event as BeforeInstallPromptEvent);
    };
    window.addEventListener("beforeinstallprompt", handler);
    return () => window.removeEventListener("beforeinstallprompt", handler);
  }, []);

  if (!deferredPrompt || dismissed) return null;

  const dismiss = () => {
    // Hide immediately regardless of whether persisting the choice
    // succeeds — see src/lib/persistent-dismiss.ts for why a plain
    // localStorage-only version of this didn't reliably persist.
    setSessionDismissed(true);
    persistDismissed(DISMISS_KEY);
  };

  const install = async () => {
    await deferredPrompt.prompt();
    await deferredPrompt.userChoice;
    setDeferredPrompt(null);
    dismiss();
  };

  return (
    <div className="fixed inset-x-0 bottom-16 z-50 mx-auto mb-2 flex max-w-md items-center justify-between gap-3 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 shadow-lg md:bottom-4">
      <p className="text-sm font-medium text-[var(--color-primary)]">
        Install Exam Coach for quick, offline-friendly access.
      </p>
      <div className="flex shrink-0 items-center gap-2">
        <button
          type="button"
          onClick={dismiss}
          className="rounded-full px-3 py-1.5 text-sm font-medium text-[var(--color-primary)]/70 transition-colors hover:text-gold"
        >
          Dismiss
        </button>
        <button
          type="button"
          onClick={install}
          className="rounded-full bg-navy px-4 py-1.5 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
        >
          Install
        </button>
      </div>
    </div>
  );
}
