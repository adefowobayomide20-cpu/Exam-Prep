import Link from "next/link";
import type { Metadata } from "next";

// Static marketing/legal page — plain Server Component (SSG at build time),
// no backend calls needed. Required before submitting the site for Google
// AdSense review; also just good practice for a site handling student
// accounts, payments, and AI-submitted photos/text.
const WHATSAPP_NUMBER = "2349158452860";
const CONTACT_URL = `https://wa.me/${WHATSAPP_NUMBER}`;
const LAST_UPDATED = "July 2026";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description:
    "How Exam Coach collects, uses, and protects your data — account details, quiz activity, AI Tutor submissions, and payments.",
  alternates: { canonical: "/privacy" },
  openGraph: { title: "Privacy Policy", url: "/privacy" },
};

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section className="mt-8">
      <h2 className="text-xl font-semibold text-[var(--color-primary)]">{title}</h2>
      <div className="mt-3 space-y-3 text-base leading-relaxed text-[var(--color-primary)]/80">
        {children}
      </div>
    </section>
  );
}

export default function PrivacyPolicyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
      <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Privacy Policy
      </h1>
      <p className="mt-2 text-sm text-[var(--color-primary)]/60">
        Last updated: {LAST_UPDATED}
      </p>
      <p className="mt-4 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
        Exam Coach (&ldquo;we&rdquo;, &ldquo;us&rdquo;) provides free and
        premium exam-preparation tools for WAEC, NECO, JAMB, and Post-UTME
        candidates. This page explains what information we collect through
        our website and app, why we collect it, and how it&apos;s handled.
      </p>

      <Section title="1. Information we collect">
        <p>
          <strong>Account information.</strong> When you sign up, we collect
          your name, email address, and (if you sign in with Google) the
          basic profile details Google shares with us. Passwords are handled
          entirely by Firebase Authentication — we never see or store your
          raw password.
        </p>
        <p>
          <strong>Profile and study data.</strong> Your target university,
          course of interest, home state, JAMB score goal, quiz attempts,
          scores, streaks, XP, badges, and coins are stored against your
          account so your progress and rank are saved across sessions.
        </p>
        <p>
          <strong>Avatar photos.</strong> If you upload a profile picture, it
          is stored in our file storage and is publicly viewable (e.g. in
          duel results and leaderboards), the same way a username or display
          name would be.
        </p>
        <p>
          <strong>AI Tutor and Theory submissions.</strong> Photos, typed
          questions, and answers you submit to Snap &amp; Solve or Theory
          practice are sent to our AI provider (Google Gemini) to generate a
          response, and a record of that exchange is kept in your account so
          you can revisit it.
        </p>
        <p>
          <strong>Duels and social features.</strong> Your display name,
          optional school tag, and online/offline presence are visible to
          other signed-in students so you can be challenged to a duel or
          added as a friend.
        </p>
        <p>
          <strong>Payments.</strong> Premium subscriptions are processed by
          Paystack. We do not collect or store your card number, PIN, or
          bank details — Paystack handles that directly and shares with us
          only the confirmation needed to activate your subscription.
        </p>
        <p>
          <strong>Device and notification data.</strong> If you enable push
          notifications, we store a device token (via Firebase Cloud
          Messaging) so we can send you exam news and reminders. We also use
          your browser&apos;s local storage for small preferences like your
          light/dark theme choice and whether you&apos;ve dismissed the
          install prompt.
        </p>
      </Section>

      <Section title="2. How we use your information">
        <p>
          We use the information above to: run your account and save your
          progress; personalize practice recommendations and your profile
          dashboard; power duels, leaderboards, and the friend system;
          process Premium payments and enforce usage limits on free
          AI-powered features; send you exam-related news and study
          reminders (only if you&apos;ve enabled notifications); and keep the
          service secure and working correctly.
        </p>
        <p>
          We do not sell your personal data to third parties, and we do not
          use your quiz answers or AI Tutor submissions for anything beyond
          providing you the service and reasonable, aggregated product
          improvement (e.g. seeing which subjects are most practiced).
        </p>
      </Section>

      <Section title="3. Who we share information with">
        <p>
          We rely on a small number of service providers to run Exam Coach,
          each of whom only receives what they need to do their job:
        </p>
        <ul className="list-disc space-y-1 pl-5">
          <li>
            <strong>Google Firebase</strong> — authentication, database,
            file storage, and push notifications.
          </li>
          <li>
            <strong>Google Gemini</strong> — generates AI Tutor and Theory
            responses from the text/photos you submit to those features.
          </li>
          <li>
            <strong>Paystack</strong> — processes Premium subscription
            payments.
          </li>
        </ul>
        <p>
          We don&apos;t share your data with advertisers or data brokers.
          If this site displays Google-served ads, Google may use standard
          advertising cookies/identifiers under its own privacy policy —
          see{" "}
          <a
            href="https://policies.google.com/technologies/ads"
            target="_blank"
            rel="noopener noreferrer"
            className="text-gold hover:underline"
          >
            how Google uses information from sites that use its services
          </a>
          .
        </p>
      </Section>

      <Section title="4. Your choices and rights">
        <p>
          You can update your name, email, password, and avatar at any time
          from your Profile page. You can turn push notifications off in
          your browser/device settings, and you can delete your account
          directly from Profile → Account &amp; Security, which removes your
          sign-in credentials. Contact us (details below) if you&apos;d like
          us to help remove other data tied to your account that isn&apos;t
          covered by the in-app delete option.
        </p>
      </Section>

      <Section title="5. Data security">
        <p>
          Your data is stored with Firebase, protected by access rules that
          restrict each account to its own data — nobody else can read your
          quiz history, profile, or messages through the app. No online
          service can guarantee perfect security, but we take reasonable,
          industry-standard steps to protect your information.
        </p>
      </Section>

      <Section title="6. Students and young users">
        <p>
          Exam Coach is built for secondary school leavers and exam
          candidates, many of whom are minors. We only collect the
          information described above, and we encourage parents/guardians to
          be involved in a younger student&apos;s account where appropriate.
          If you believe a child has provided us with personal information
          without appropriate consent, please contact us and we&apos;ll
          address it.
        </p>
      </Section>

      <Section title="7. Changes to this policy">
        <p>
          We may update this policy as the app changes. If we make a
          material change, we&apos;ll update the &ldquo;Last updated&rdquo;
          date above.
        </p>
      </Section>

      <Section title="8. Contact us">
        <p>
          Questions about this policy or your data? Reach us on WhatsApp:
        </p>
        <a
          href={CONTACT_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="mt-2 inline-flex items-center gap-2 rounded-full bg-navy px-6 py-3 font-semibold text-cream transition-colors hover:bg-navy-light"
        >
          Chat with us on WhatsApp
        </a>
      </Section>

      <p className="mt-10 text-sm text-[var(--color-primary)]/60">
        See also our{" "}
        <Link href="/terms" className="text-gold hover:underline">
          Terms of Service
        </Link>
        .
      </p>
    </div>
  );
}
