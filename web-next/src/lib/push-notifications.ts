import { doc, setDoc, arrayUnion } from "firebase/firestore";
import { firebaseApp, db } from "@/lib/firebase";

// Same Web Push VAPID key the Flutter app uses (lib/data/push_notification_service.dart,
// _webPushVapidKey) — a Firebase Cloud Messaging web push certificate is
// scoped to the Firebase project, not the client platform, so the same key
// pair applies here.
const VAPID_KEY =
  "BGCs_Oz4q8d518c_q1-Kqkzt3XlOBBriwG_I3-eCGnXLtJNyzstXOKq_EnF0FlmqT7HBbKs7vv9bs4lHCpJzUHI";

export type EnablePushResult =
  | { ok: true }
  | { ok: false; reason: "unsupported" | "denied" | "no-token" | "error"; error?: unknown };

/**
 * Requests notification permission (if not already decided), registers
 * /firebase-messaging-sw.js, fetches an FCM token, and saves it to
 * `users/{uid}.fcmTokens` via arrayUnion — mirrors `_saveToken` in
 * lib/data/push_notification_service.dart so the same Cloud Function
 * (pollEducationNews, functions/index.js) can push to both the Flutter app
 * and this site from the same recipient list.
 *
 * Must only be called from a user gesture (e.g. a button click), not on
 * page load — auto-prompting for notification permission on every visit is
 * exactly the kind of thing that reads as spam.
 */
export async function enablePushNotifications(uid: string): Promise<EnablePushResult> {
  if (typeof window === "undefined" || !("Notification" in window) || !("serviceWorker" in navigator)) {
    return { ok: false, reason: "unsupported" };
  }

  try {
    const { isSupported, getMessaging, getToken } = await import("firebase/messaging");
    if (!(await isSupported())) return { ok: false, reason: "unsupported" };

    const permission =
      Notification.permission === "default" ? await Notification.requestPermission() : Notification.permission;
    if (permission !== "granted") return { ok: false, reason: "denied" };

    const registration = await navigator.serviceWorker.register("/firebase-messaging-sw.js");

    const messaging = getMessaging(firebaseApp);
    const token = await getToken(messaging, {
      vapidKey: VAPID_KEY,
      serviceWorkerRegistration: registration,
    });
    if (!token) return { ok: false, reason: "no-token" };

    await setDoc(doc(db, "users", uid), { fcmTokens: arrayUnion(token) }, { merge: true });
    return { ok: true };
  } catch (error) {
    return { ok: false, reason: "error", error };
  }
}

/** Current permission state, or null on the server / unsupported browsers — for reflecting "already enabled" in UI without prompting. */
export function getNotificationPermission(): NotificationPermission | null {
  if (typeof window === "undefined" || !("Notification" in window)) return null;
  return Notification.permission;
}
