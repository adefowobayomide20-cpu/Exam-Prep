"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useAuth } from "@/lib/auth-context";
import {
  deleteNotification,
  markAllNotificationsRead,
  markNotificationRead,
  watchNotifications,
} from "@/lib/notification-service";
import { newsArticleFromNotification, type NotificationDoc, type NotificationType } from "@/lib/notification-types";
import { newsArticleHref } from "@/lib/news-content";

const ICON_FOR: Record<NotificationType, string> = {
  news: "📰",
  reminder: "⏰",
  system: "ℹ️",
};

/**
 * In-app notification center — the web mirror of
 * lib/features/notifications/notification_center_page.dart, reading
 * `users/{uid}/notifications` live via onSnapshot (see notification-service.ts).
 *
 * News notifications route into our own /news/[id] page (rebuilt from the
 * notification's stored newsdata.io-shaped fields via
 * newsArticleFromNotification, mirroring NewsArticle.fromAppNotification in
 * the Flutter app) instead of jumping straight to the external `link` — this
 * was a deliberate bug-fix in the Flutter app this session and must hold
 * here too. Only non-news notifications with a `link` open externally.
 */
export default function NotificationsView() {
  const { user } = useAuth();
  const [notifications, setNotifications] = useState<NotificationDoc[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    if (!user) return;
    return watchNotifications(user.uid, (docs) => {
      setNotifications(docs);
      setLoaded(true);
    });
  }, [user]);

  if (!user) return null;

  const unread = notifications.filter((n) => !n.read);

  const handleOpen = (notification: NotificationDoc) => {
    if (!notification.read) {
      markNotificationRead(user.uid, notification.id).catch(() => {});
    }
  };

  const handleMarkAllRead = () => {
    markAllNotificationsRead(
      user.uid,
      unread.map((n) => n.id),
    ).catch(() => {});
  };

  const handleDelete = (id: string) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id));
    deleteNotification(user.uid, id).catch(() => {});
  };

  return (
    <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
      <div className="flex items-center justify-between gap-4">
        <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
          Notifications
        </h1>
        {unread.length > 0 && (
          <button
            type="button"
            onClick={handleMarkAllRead}
            className="shrink-0 text-sm font-medium text-gold hover:underline"
          >
            Mark all read
          </button>
        )}
      </div>

      {loaded && notifications.length === 0 && (
        <p className="mt-10 text-center text-[var(--color-primary)]/60">No notifications yet.</p>
      )}

      <ul className="mt-8 space-y-3">
        {notifications.map((notification) => {
          const cardClasses = `flex gap-3 rounded-xl border border-[var(--color-border)] p-4 transition-colors hover:border-gold ${
            notification.read ? "bg-[var(--color-surface)]" : "bg-gold/10"
          }`;
          const icon = (
            <span aria-hidden className="shrink-0 text-xl">
              {ICON_FOR[notification.type]}
            </span>
          );
          const body = (
            <div className="min-w-0">
              <p
                className={`text-[var(--color-primary)] ${notification.read ? "font-normal" : "font-semibold"}`}
              >
                {notification.title}
              </p>
              <p className="mt-1 text-sm text-[var(--color-primary)]/70">{notification.body}</p>
            </div>
          );

          // Delete is only offered for already-read notifications (unread
          // ones should be seen/acted on first) — rendered as a sibling
          // button next to the card, not nested inside it, since the card
          // itself is already a Link/a/button (nesting interactive elements
          // is invalid HTML and unreliable to click).
          const deleteButton = notification.read && (
            <button
              type="button"
              onClick={() => handleDelete(notification.id)}
              aria-label="Delete notification"
              className="shrink-0 self-start rounded-full p-1.5 text-[var(--color-primary)]/40 transition-colors hover:bg-[var(--color-border)] hover:text-red-600"
            >
              ✕
            </button>
          );

          if (notification.type === "news") {
            const article = newsArticleFromNotification(notification);
            return (
              <li key={notification.id} className="flex items-start gap-2">
                <Link
                  href={newsArticleHref(article)}
                  onClick={() => handleOpen(notification)}
                  className={`flex-1 ${cardClasses}`}
                >
                  {icon}
                  {body}
                </Link>
                {deleteButton}
              </li>
            );
          }

          if (notification.link) {
            return (
              <li key={notification.id} className="flex items-start gap-2">
                <a
                  href={notification.link}
                  target="_blank"
                  rel="noopener noreferrer"
                  onClick={() => handleOpen(notification)}
                  className={`flex-1 ${cardClasses}`}
                >
                  {icon}
                  {body}
                </a>
                {deleteButton}
              </li>
            );
          }

          return (
            <li key={notification.id} className="flex items-start gap-2">
              <button
                type="button"
                onClick={() => handleOpen(notification)}
                className={`flex-1 ${cardClasses} text-left`}
              >
                {icon}
                {body}
              </button>
              {deleteButton}
            </li>
          );
        })}
      </ul>
    </div>
  );
}
