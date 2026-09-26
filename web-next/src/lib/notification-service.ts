import {
  collection,
  deleteDoc,
  doc,
  onSnapshot,
  orderBy,
  query,
  limit,
  updateDoc,
  writeBatch,
  type Unsubscribe,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import type { NotificationDoc } from "@/lib/notification-types";

/**
 * Firestore access for `users/{uid}/notifications` — the web mirror of
 * lib/data/notification_store.dart. Scoped to the signed-in user only, per
 * firestore.rules' `match /{subcollection}/{docId}` rule under `users/{userId}`.
 */

function notificationsCollection(uid: string) {
  return collection(db, "users", uid, "notifications");
}

export function watchNotifications(
  uid: string,
  callback: (notifications: NotificationDoc[]) => void,
): Unsubscribe {
  const q = query(notificationsCollection(uid), orderBy("createdAt", "desc"), limit(100));
  return onSnapshot(q, (snapshot) => {
    callback(snapshot.docs.map((d) => d.data() as NotificationDoc));
  });
}

export async function markNotificationRead(uid: string, id: string): Promise<void> {
  await updateDoc(doc(notificationsCollection(uid), id), { read: true });
}

export async function markAllNotificationsRead(uid: string, unreadIds: string[]): Promise<void> {
  if (unreadIds.length === 0) return;
  const batch = writeBatch(db);
  for (const id of unreadIds) {
    batch.update(doc(notificationsCollection(uid), id), { read: true });
  }
  await batch.commit();
}

/** Deletes a single notification. Only meant to be offered for already-read
 * notifications in the UI (see NotificationsView.tsx) — nothing here
 * enforces that server-side, it's just the intended UX. */
export async function deleteNotification(uid: string, id: string): Promise<void> {
  await deleteDoc(doc(notificationsCollection(uid), id));
}
