"use client";

import { useEffect } from "react";
import { logClientError } from "@/lib/error-logger";

/**
 * Catches errors React's error.tsx boundary CAN'T see — uncaught throws in
 * plain event handlers and unhandled promise rejections (e.g. a missed
 * .catch() somewhere) don't propagate through React's render tree, so they
 * never reach app/error.tsx. This is the net for those. Renders nothing.
 */
export default function GlobalErrorListener() {
  useEffect(() => {
    const onError = (event: ErrorEvent) => {
      logClientError(event.error ?? event.message, "window.onerror");
    };
    const onRejection = (event: PromiseRejectionEvent) => {
      logClientError(event.reason, "unhandledrejection");
    };
    window.addEventListener("error", onError);
    window.addEventListener("unhandledrejection", onRejection);
    return () => {
      window.removeEventListener("error", onError);
      window.removeEventListener("unhandledrejection", onRejection);
    };
  }, []);

  return null;
}
