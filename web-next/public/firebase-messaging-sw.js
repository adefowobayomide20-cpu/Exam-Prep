// Handles FCM push notifications that arrive while no tab is open/focused,
// for the web-next site (this is the Next.js equivalent of the Flutter
// app's web/firebase-messaging-sw.js — same exam-prep-ng Firebase project,
// same behavior). Firebase's web SDK requires this exact file at the site
// root; Next.js serves anything under public/ at the site root, so this
// lands at /firebase-messaging-sw.js.
//
// This is a plain script served as a static asset from public/ — it is NOT
// part of the Next.js/webpack bundle, so it can't `import` from
// src/lib/news-content.ts or src/lib/notification-types.ts. The handful of
// helpers below (hashKey, sourceNameFor, formatDate, article-href encoding)
// are deliberately duplicated from those files, kept minimal and in sync by
// hand. If those files' encoding ever changes, this file must be updated to
// match or notification taps will land on a broken/blank article page.
//
// It also can't read Next.js env vars (those only exist inside the
// Next.js build/runtime, not a standalone service-worker context), so the
// Firebase config below is hardcoded — same values as
// src/lib/firebase.ts / .env.local, same project the Flutter app's
// web/firebase-messaging-sw.js hardcodes too, for the same reason.
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDNNZqKZovbJZOB-u6-UlkNDwqgLG6b9sI',
  appId: '1:734285493928:web:ef4dd3fa2f41a1fa38749d',
  messagingSenderId: '734285493928',
  projectId: 'exam-prep-ng',
  authDomain: 'exam-prep-ng.firebaseapp.com',
  storageBucket: 'exam-prep-ng.firebasestorage.app',
});

const messaging = firebase.messaging();

// --- Duplicated from src/lib/news-content.ts (hashKey, sourceNameFor,
// formatDate, newsArticleHref's encoding) — see file header comment. ---

function hashKey(key) {
  let hash = 5381;
  for (let i = 0; i < key.length; i += 1) {
    hash = (hash * 33) ^ key.charCodeAt(i);
  }
  return (hash >>> 0).toString(16);
}

function sourceNameFor(sourceId) {
  if (!sourceId) return 'Unknown source';
  return sourceId[0].toUpperCase() + sourceId.slice(1).replaceAll('-', ' ');
}

function formatDate(pubDate) {
  if (!pubDate) return '';
  const parsed = new Date(pubDate);
  if (Number.isNaN(parsed.getTime())) return pubDate;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return `${months[parsed.getMonth()]} ${parsed.getDate()}, ${parsed.getFullYear()}`;
}

// Rebuilds the NewsArticle shape newsArticleHref()/decodeNewsArticleParam()
// expect, from the raw newsdata.io-shaped fields the pollEducationNews
// Cloud Function puts in the FCM data payload (functions/index.js) — type,
// title, link, source_id, pubDate, description, image_url. Mirrors
// fromNewsDataJson() in news-content.ts.
function articleFromPushData(data) {
  const key = data.link || data.title || 'untitled';
  return {
    id: hashKey(key),
    title: (data.title || '').trim() || 'Untitled',
    source: sourceNameFor(data.source_id),
    date: formatDate(data.pubDate),
    summary: (data.description || '').trim() || 'No summary available for this article.',
    imageUrl: data.image_url || null,
    link: data.link || null,
    publishedAt: data.pubDate || null,
  };
}

// Mirrors newsArticleHref() in news-content.ts exactly — the article travels
// with the link as a JSON-encoded `d` query param since there's no backend
// "fetch article by id" endpoint.
function newsArticleHref(article) {
  return `/news/${article.id}?d=${encodeURIComponent(JSON.stringify(article))}`;
}

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const data = payload.data || {};
  self.registration.showNotification(notification.title || 'Exam Coach', {
    body: notification.body || '',
    icon: '/icons/Icon-192.png',
    data,
  });
});

// News notifications open this site's own /news/[id] article page (built
// from the FCM data payload) instead of the publisher's raw external link —
// this was a real, previously-shipped bug in the Flutter version (see
// web/firebase-messaging-sw.js) that defeated the point of having our own
// site. Any other notification type falls back to data.link if present,
// else the homepage.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const data = event.notification.data || {};
  const origin = self.location.origin;
  let target = '/';
  if (data.type === 'news') {
    target = newsArticleHref(articleFromPushData(data));
  } else if (data.link) {
    target = data.link;
  }
  const targetUrl = new URL(target, origin).href;

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url === targetUrl && 'focus' in client) return client.focus();
      }
      return clients.openWindow(targetUrl);
    })
  );
});

// --- Minimal offline app-shell caching (PWA nicety, unrelated to FCM above) ---
//
// This file is the only service worker registered for the site (one SW per
// scope), so any offline support has to live here rather than in a second
// SW — see the Phase-11 PWA task notes. Scope is deliberately small: the
// shell URLs below plus same-origin static assets (icons, Next's
// content-hashed /_next/static/ chunks). It does NOT try to cache the ~236
// content pages themselves, cross-origin requests (Firebase/gstatic APIs,
// backend calls), or non-GET requests — none of that is touched, so this
// can't interfere with onBackgroundMessage/notificationclick above or with
// live data freshness on question/news pages.
//
// Strategy split by whether a URL is immutable:
//  - `/_next/static/` chunks are content-hashed (a new deploy produces new
//    filenames), so cache-first is safe and correct for them.
//  - `/`, the manifest, and icons are NOT content-hashed — same URL every
//    deploy, but their content changes. An earlier version of this file
//    cached `/` with cache-first too, which meant an installed PWA that had
//    ever loaded the site would keep serving that exact cached HTML (and
//    therefore the OLD JS bundle it references) forever — the SW never had
//    a reason to re-fetch it once cached. That's why fixes could work in a
//    normal browser tab but never reach someone testing via the installed
//    PWA/home-screen shortcut. Fixed by using network-first for those URLs:
//    always try the network first, only fall back to the cached copy if the
//    fetch itself fails (i.e. genuinely offline).
const SHELL_CACHE = 'exam-coach-shell-v2';
const NETWORK_FIRST_URLS = [
  '/',
  '/manifest.webmanifest',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(SHELL_CACHE)
      .then((cache) => cache.addAll(NETWORK_FIRST_URLS))
      .catch(() => {
        // Best-effort — a failed pre-cache (e.g. offline install) shouldn't
        // block the service worker from installing/activating.
      })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((key) => key !== SHELL_CACHE).map((key) => caches.delete(key)))
      )
      .then(() => self.clients.claim())
  );
});

function isImmutableStaticAsset(pathname) {
  return pathname.startsWith('/_next/static/');
}

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return; // leave FCM/API/cross-origin traffic alone

  if (isImmutableStaticAsset(url.pathname)) {
    // Cache-first: content-hashed filenames mean a hit is always correct.
    event.respondWith(
      caches.match(request).then((cached) => {
        if (cached) return cached;
        return fetch(request).then((response) => {
          if (response && response.ok) {
            const copy = response.clone();
            caches.open(SHELL_CACHE).then((cache) => cache.put(request, copy));
          }
          return response;
        });
      })
    );
    return;
  }

  if (NETWORK_FIRST_URLS.includes(url.pathname)) {
    // Network-first: always prefer the live response so redeploys reach
    // installed/standalone PWA sessions immediately; only fall back to the
    // cache when the network is genuinely unreachable.
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response && response.ok) {
            const copy = response.clone();
            caches.open(SHELL_CACHE).then((cache) => cache.put(request, copy));
          }
          return response;
        })
        .catch(() => caches.match(request))
    );
  }

  // Everything else (content pages, API calls) passes straight through.
});
