import type { NewsArticle } from "@/lib/news-content";

/**
 * In-app notification doc shape under `users/{uid}/notifications`, written
 * server-side by `writeNotifications` (functions/notifications.js) and read
 * here — must match that function's document shape and
 * lib/data/models/app_notification.dart's `toJson`/`fromJson` field-for-field
 * since both clients read the same Firestore docs.
 */
export type NotificationType = "news" | "reminder" | "system";

export interface NotificationDoc {
  id: string;
  type: NotificationType;
  title: string;
  body: string;
  createdAt: string;
  link: string | null;
  read: boolean;
  /** Raw newsdata.io-shaped fields, present only on `type: "news"` docs — lets the notification rebuild the full article for /news/[id] instead of linking straight to the external source. */
  sourceId?: string;
  pubDate?: string;
  description?: string;
  imageUrl?: string;
}

/** Rebuilds the full article from a persisted news notification, mirroring NewsArticle.fromAppNotification in news_article.dart, so a notification tap can route into our own /news/[id] page instead of jumping straight to the external link. */
export function newsArticleFromNotification(notification: NotificationDoc): NewsArticle {
  return {
    id: notification.id,
    title: notification.title,
    source: notification.sourceId
      ? notification.sourceId[0].toUpperCase() + notification.sourceId.slice(1).replaceAll("-", " ")
      : "Unknown source",
    date: notification.pubDate ?? "",
    summary: notification.description?.trim() || notification.body || "No summary available for this article.",
    imageUrl: notification.imageUrl || null,
    link: notification.link || null,
    publishedAt: notification.pubDate ?? null,
  };
}
