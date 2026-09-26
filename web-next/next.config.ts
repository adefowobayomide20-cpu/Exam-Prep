import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */

  // NOTE on a dead end, kept here so it isn't retried: `outputFileTracingIncludes`
  // (Next's normal mechanism for force-bundling extra files a route reads via
  // dynamic `fs` calls) does NOT work with Firebase's current Next.js Hosting
  // integration — it appears correctly in Next's own .nft.json trace output,
  // but Firebase's packaging step builds its own minimal function bundle
  // (node_modules/public/server.js only) and ignores it entirely, confirmed
  // by inspecting the actual deployed function package. The real fix was
  // moving the question content JSON from src/content/questions to
  // public/content/questions — see the CONTENT_ROOT comment in
  // src/lib/exam-content.ts — since public/ is the one directory this
  // integration reliably bundles in full.

  // Avatar images (users/{uid}.avatarUrl) are Firebase Storage download
  // URLs served from firebasestorage.googleapis.com. This remotePatterns
  // entry is correct and does get bundled into the deployed function's own
  // images-manifest.json (verified directly) — but it turns out NOT to
  // matter in practice: Firebase Hosting's own image-serving layer
  // intercepts /_next/image requests before they ever reach our Next.js
  // Cloud Function (confirmed via the response headers on a live 400 —
  // no X-Nextjs-* headers at all, unlike every other route on this site)
  // and rejects any external Firebase Storage URL with a generic "url
  // parameter is not allowed", regardless of this config. The actual fix
  // was passing `unoptimized` on every <Image src={avatarUrl}> usage
  // (BottomNav, HomeTopBar, ProfileView) so those never go through
  // /_next/image at all — acceptable since avatars are already resized to
  // ~512px client-side before upload (see ProfileView.tsx's
  // resizeImageForAvatar). Left this config in place in case a future,
  // genuinely-server-optimized remote image is ever needed and this
  // Firebase Hosting limitation gets fixed upstream.
  images: {
    unoptimized: true,
    remotePatterns: [
      {
        protocol: "https",
        hostname: "firebasestorage.googleapis.com",
        pathname: "/v0/b/**",
      },
    ],
  },

  // Service workers only pick up updates when the browser re-fetches and
  // byte-compares the script; if it's cached (Next's default for /public
  // static assets is long-lived caching in production), users keep running
  // a stale service worker — with stale notification-click/news-link logic
  // — for as long as the cache lives. This exact bug shipped in the
  // Flutter/Firebase-Hosting build of this app (see firebase.json at the
  // repo root) and took multiple rounds of debugging to trace back to
  // caching rather than the code. Applies to `next start`/Vercel/any
  // Next.js-native host; a static-export + separate CDN deploy path would
  // need the equivalent header set at that layer instead.
  async headers() {
    return [
      {
        source: "/firebase-messaging-sw.js",
        headers: [{ key: "Cache-Control", value: "no-cache" }],
      },
    ];
  },
};

export default nextConfig;
