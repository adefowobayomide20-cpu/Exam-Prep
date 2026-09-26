import { addDoc, collection, serverTimestamp } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { auth } from "@/lib/firebase";

/**
 * Write-only client-error mailbox — no third-party error-monitoring account
 * (Sentry etc.) exists for this project, so this is the lightest possible
 * substitute: log to a Firestore collection reviewable via the Firebase
 * console, rather than errors vanishing silently with nothing but a user
 * complaint to go on. Deliberately allows unauthenticated writes (errors can
 * happen on public pages before sign-in) — see firestore.rules'
 * `errorLogs` rule for the matching size/shape constraints. Best-effort:
 * failures to log are swallowed so a broken logger can't itself become a
 * second error.
 */
export function logClientError(error: unknown, context: string): void {
  try {
    const message = error instanceof Error ? error.message : String(error);
    const stack = error instanceof Error ? (error.stack ?? null) : null;
    addDoc(collection(db, "errorLogs"), {
      message: message.slice(0, 500),
      stack: stack?.slice(0, 2000) ?? null,
      context: context.slice(0, 200),
      url: typeof window !== "undefined" ? window.location.href : null,
      userAgent: typeof navigator !== "undefined" ? navigator.userAgent.slice(0, 300) : null,
      uid: auth.currentUser?.uid ?? null,
      createdAt: serverTimestamp(),
    }).catch(() => {});
  } catch {
    // Never let the error logger itself throw.
  }
}
