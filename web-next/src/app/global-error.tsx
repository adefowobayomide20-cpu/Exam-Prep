"use client";

import { useEffect } from "react";
import { logClientError } from "@/lib/error-logger";

/**
 * Catches errors thrown by the ROOT layout itself (rare — error.tsx handles
 * everything below it). Per Next.js's requirement, this must render its own
 * <html>/<body> since it fully replaces the root layout when active.
 */
export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    logClientError(error, "app/global-error.tsx boundary");
  }, [error]);

  return (
    <html lang="en">
      <body>
        <div style={{ maxWidth: 480, margin: "80px auto", textAlign: "center", padding: "0 24px" }}>
          <h1 style={{ fontSize: 22, fontWeight: 700 }}>Something went wrong</h1>
          <p style={{ marginTop: 12, color: "#666" }}>
            Exam Coach hit an unexpected error. We&apos;ve logged it.
          </p>
          <button
            type="button"
            onClick={reset}
            style={{
              marginTop: 20,
              padding: "10px 24px",
              borderRadius: 999,
              background: "#12203D",
              color: "#F7F4ED",
              fontWeight: 600,
              border: "none",
              cursor: "pointer",
            }}
          >
            Try again
          </button>
        </div>
      </body>
    </html>
  );
}
