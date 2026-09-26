import { FirebaseError } from "firebase/app";

/**
 * Maps a Firebase Auth error code to a short, user-facing message. Mirrors
 * AuthService.messageFor in lib/data/auth_service.dart so web and Flutter
 * show the same copy for the same failures.
 */
export function authErrorMessage(error: unknown): string {
  if (error instanceof FirebaseError) {
    switch (error.code) {
      case "auth/invalid-email":
        return "That email address looks invalid.";
      case "auth/user-disabled":
        return "This account has been disabled.";
      case "auth/user-not-found":
        return "No account found with that email.";
      case "auth/wrong-password":
      case "auth/invalid-credential":
        return "Incorrect email or password.";
      case "auth/email-already-in-use":
        return "An account already exists for that email.";
      case "auth/weak-password":
        return "Choose a stronger password (at least 6 characters).";
      case "auth/network-request-failed":
        return "Network error — check your connection and try again.";
      case "auth/requires-recent-login":
        return "Please re-enter your password to confirm this change.";
      case "auth/popup-closed-by-user":
      case "auth/cancelled-popup-request":
        return "";
      default:
        return error.message || "Something went wrong. Please try again.";
    }
  }
  return "Something went wrong. Please try again.";
}
