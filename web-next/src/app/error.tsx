"use client";

import { useEffect } from "react";
import Link from "next/link";
import { logClientError } from "@/lib/error-logger";

/**
 * Route-segment error boundary — Next.js renders this in place of the page
 * whenever a rendering/effect error is thrown anywhere below the root
 * layout (Header/Footer/nav still render normally around it). Logs to
 * Firestore (see error-logger.ts) so a crash surfaces somewhere besides a
 * user's WhatsApp complaint.
 */
export default function ErrorBoundary({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    logClientError(error, "app/error.tsx boundary");
  }, [error]);

  return (
    <div className="mx-auto flex max-w-xl flex-1 flex-col items-center justify-center px-6 py-24 text-center">
      <p className="text-sm font-semibold uppercase tracking-wide text-gold">
        Something went wrong
      </p>
      <h1 className="mt-2 text-2xl font-bold text-[var(--color-primary)]">
        This page hit an unexpected error
      </h1>
      <p className="mt-3 max-w-md text-sm text-[var(--color-primary)]/70">
        We&apos;ve logged the issue. You can try again, or head back home.
      </p>
      <div className="mt-6 flex items-center gap-3">
        <button
          type="button"
          onClick={reset}
          className="rounded-full bg-gold px-5 py-2.5 text-sm font-semibold text-navy transition-colors hover:brightness-105"
        >
          Try again
        </button>
        <Link
          href="/"
          className="rounded-full border border-[var(--color-border)] px-5 py-2.5 text-sm font-medium text-[var(--color-primary)] transition-colors hover:border-gold"
        >
          Back to Home
        </Link>
      </div>
    </div>
  );
}
