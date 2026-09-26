import type { Metadata, Viewport } from "next";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import BottomNav from "@/components/BottomNav";
import MobileTopBar from "@/components/MobileTopBar";
import InstallPrompt from "@/components/InstallPrompt";
import WhatsAppFloatingButton from "@/components/WhatsAppFloatingButton";
import CookieNotice from "@/components/CookieNotice";
import GlobalErrorListener from "@/components/GlobalErrorListener";
import { AuthProvider } from "@/lib/auth-context";
import { ThemeProvider } from "@/lib/theme-context";
import IncomingChallengeListener from "@/components/duel/IncomingChallengeListener";
import "./globals.css";

// Blocking, pre-hydration theme-flash prevention: reads the same
// localStorage key ThemeProvider (src/lib/theme-context.tsx) reads/writes
// and applies the .dark/.light class to <html> before first paint. Kept as
// a plain string (not a template literal referencing shared constants) so
// it stays inlined without a build step reaching into client-only code.
const THEME_INIT_SCRIPT = `(function(){try{var m=localStorage.getItem('themeMode');if(m!=='light'&&m!=='dark')return;document.documentElement.classList.add(m);}catch(e){}})();`;

const SITE_URL = "https://www.examcoach.com.ng";
const SITE_NAME = "Exam Coach";
const SITE_DESCRIPTION =
  "Exam Coach — free WAEC, NECO, JAMB, and Post-UTME past questions, timed CBT practice tests, live duels with friends, and an AI tutor for tough questions.";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    template: "%s | Exam Coach",
    default: "Exam Coach — WAEC, NECO, JAMB & Post-UTME Exam Prep",
  },
  description: SITE_DESCRIPTION,
  manifest: "/manifest.webmanifest",
  alternates: {
    canonical: "/",
  },
  // iOS "add to home screen" parity with the old Flutter web build's
  // web/index.html (apple-mobile-web-app-capable/title/status-bar-style +
  // apple-touch-icon) — iOS Safari doesn't honor display:standalone or
  // theme_color from manifest.ts, so these meta tags are still needed.
  appleWebApp: {
    capable: true,
    title: SITE_NAME,
    statusBarStyle: "black",
  },
  icons: {
    apple: "/icons/Icon-192.png",
  },
  openGraph: {
    type: "website",
    siteName: SITE_NAME,
    title: "Exam Coach — WAEC, NECO, JAMB & Post-UTME Exam Prep",
    description: SITE_DESCRIPTION,
    url: SITE_URL,
    images: [
      {
        url: "/icons/Icon-512.png",
        width: 512,
        height: 512,
        alt: "Exam Coach logo",
      },
    ],
  },
  twitter: {
    card: "summary",
    title: "Exam Coach — WAEC, NECO, JAMB & Post-UTME Exam Prep",
    description: SITE_DESCRIPTION,
    images: ["/icons/Icon-512.png"],
  },
  // TODO (AdSense, Phase 9 prep): once an AdSense account is approved for
  // this site, uncomment and set the real publisher ID — this renders
  // <meta name="google-adsense-account" content="..." /> in <head>, which
  // Google uses for site-ownership verification during the AdSense review.
  // other: { "google-adsense-account": "ca-pub-XXXXXXXXXXXXXXXX" },
};

export const viewport: Viewport = {
  themeColor: "#12203D",
  // Lets the app draw under the iOS notch/home-indicator safe areas so
  // BottomNav can pad itself out with env(safe-area-inset-bottom).
  viewportFit: "cover",
};

const jsonLd = {
  "@context": "https://schema.org",
  "@type": "EducationalOrganization",
  name: SITE_NAME,
  url: SITE_URL,
  description: SITE_DESCRIPTION,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full flex flex-col">
        {/* Must run before any themed content paints — see THEME_INIT_SCRIPT comment above. */}
        <script
          suppressHydrationWarning
          dangerouslySetInnerHTML={{ __html: THEME_INIT_SCRIPT }}
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
          }}
        />
        {/*
          AdSense prep (Phase 9) — not live yet, no account exists.
          TODO: once an AdSense account is approved for this site (requires
          enough real, crawlable content — already in place via the News,
          exam/subject landing, and Theory pages from Phases 4/8), set the
          real publisher ID in the `other["google-adsense-account"]` entry
          in `metadata` above, replace "ca-pub-XXXXXXXXXXXXXXXX" below with
          the same ID, and uncomment this script tag.
          Do not enable this with a placeholder ID — Google will reject the
          site review and repeated invalid requests can also get a domain
          flagged.
        */}
        {/*
        <script
          async
          src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXXXXXXXX"
          crossOrigin="anonymous"
        />
        */}
        <AuthProvider>
          <ThemeProvider>
            <IncomingChallengeListener>
              <Header />
              <MobileTopBar />
              <main className="flex-1 pt-12 pb-16 md:pt-0 md:pb-0">
                {children}
              </main>
              <Footer />
              <BottomNav />
              <InstallPrompt />
              <WhatsAppFloatingButton />
              <CookieNotice />
              <GlobalErrorListener />
            </IncomingChallengeListener>
          </ThemeProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
