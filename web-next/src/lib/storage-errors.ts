import { FirebaseError } from "firebase/app";

/**
 * Maps a Firebase Storage error code to a short, user-facing message.
 * Previously the avatar-upload flow reused `authErrorMessage` (built only
 * for Firebase Auth codes like "auth/wrong-password") for Storage errors —
 * since "storage/..." codes aren't in that mapping, it fell through to
 * `error.message`, a raw technical string like 'Firebase Storage: Max retry
 * time for operation exceeded, please try again. (storage/retry-limit-exceeded)'
 * shown directly to the user. That's the "error code" bug reported this
 * session — this is the dedicated fix.
 */
export function storageErrorMessage(error: unknown): string {
  if (error instanceof FirebaseError) {
    switch (error.code) {
      case "storage/unauthorized":
        return "You don't have permission to upload this file.";
      case "storage/canceled":
        return "Upload canceled.";
      case "storage/retry-limit-exceeded":
        return "Upload timed out — check your connection and try again.";
      case "storage/quota-exceeded":
        return "Storage limit reached. Please try again later.";
      case "storage/invalid-checksum":
        return "The upload got corrupted in transit. Please try again.";
      case "storage/object-not-found":
        return "That file could not be found.";
      case "storage/unknown":
        return "Upload failed — this can happen on a weak connection or if the device is low on memory. Try again, or use a smaller photo.";
      default:
        return "Could not upload your photo. Please try again.";
    }
  }
  return "Could not upload your photo. Please try again.";
}
