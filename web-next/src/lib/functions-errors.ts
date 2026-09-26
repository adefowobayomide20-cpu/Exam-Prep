import { FunctionsError } from "firebase/functions";

/**
 * Maps a Firebase Functions (callable) error to a short, user-facing
 * message. Previously AI Tutor, Theory, and Premium checkout all used the
 * same inline fallback — `error.message || \`Something went wrong
 * (${error.code}). Try again shortly.\`` — which shows a raw code like
 * "(functions/internal)" or "(functions/unavailable)" straight to the user
 * whenever the server-set message was empty (common for uncaught/internal
 * errors). That's the "error code" bug reported this session — this is the
 * dedicated fix, shared across all three call sites instead of duplicated
 * inline.
 */
export function functionsErrorMessage(error: unknown): string {
  if (error instanceof FunctionsError) {
    switch (error.code) {
      case "functions/unauthenticated":
        return "Please sign in again to continue.";
      case "functions/resource-exhausted":
        return "You've reached today's free limit. Try again tomorrow, or upgrade for unlimited access.";
      case "functions/invalid-argument":
        return error.message || "That request wasn't quite right — please try again.";
      case "functions/deadline-exceeded":
      case "functions/unavailable":
        return "The server is taking too long to respond. Check your connection and try again.";
      case "functions/cancelled":
        return "Request canceled. Try again.";
      case "functions/not-found":
        return "That wasn't found. Please try again.";
      case "functions/permission-denied":
        return "You don't have permission to do that.";
      default:
        // Only trust the server-set message here (it's written by our own
        // Cloud Functions to be human-readable) — never fall back to
        // showing the raw error code itself.
        return error.message || "Something went wrong on our end. Please try again shortly.";
    }
  }
  return "Couldn't reach the server. Check your connection and try again.";
}
