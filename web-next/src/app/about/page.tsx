import Link from "next/link";
import type { Metadata } from "next";

// Static marketing page — plain Server Component (SSG). Exists mainly to
// give the site a real "who runs this and why" page: useful for student
// trust, and Google's site-quality/AdSense review process specifically
// looks for this kind of authorship/purpose context, which the site didn't
// have before (every other page is product-functional, not about the org
// itself).
export const metadata: Metadata = {
  title: "About Us",
  description:
    "Exam Coach helps Nigerian students prepare for WAEC, NECO, JAMB, and Post-UTME with free past questions, timed CBT practice, live duels, and an AI tutor.",
  alternates: { canonical: "/about" },
  openGraph: { title: "About Us", url: "/about" },
};

export default function AboutPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
      <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        About Exam Coach
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
        Exam Coach exists for one reason: to make serious exam preparation
        free, or nearly free, for every Nigerian student sitting WAEC, NECO,
        JAMB, or a Post-UTME screening test — regardless of whether they can
        afford expensive lesson centres or past-question booklets.
      </p>

      <section className="mt-8">
        <h2 className="text-xl font-semibold text-[var(--color-primary)]">
          What we do
        </h2>
        <div className="mt-3 space-y-3 text-base leading-relaxed text-[var(--color-primary)]/80">
          <p>
            We build free, timed CBT-style practice tests across every WAEC,
            NECO, and JAMB subject, plus school-specific Post-UTME screening
            practice for several Nigerian universities — all with instant
            scoring and explanations, not just a bare pass/fail.
          </p>
          <p>
            Beyond solo practice, students can challenge friends (or anyone
            online) to a live 1v1 duel, track their progress, streaks, and
            rank on a leaderboard, and get unstuck on a tough question with
            our AI Tutor — snap a photo of a question and get a step-by-step
            explanation.
          </p>
        </div>
      </section>

      <section className="mt-8">
        <h2 className="text-xl font-semibold text-[var(--color-primary)]">
          Where we&apos;re headed
        </h2>
        <p className="mt-3 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
          We&apos;re continuously expanding our question banks, adding more
          Post-UTME schools, and improving the practice experience based on
          direct feedback from students using the app. Exam Coach will always
          keep a genuinely free path to full exam practice — Premium exists
          to fund that, not replace it.
        </p>
      </section>

      <section className="mt-8">
        <h2 className="text-xl font-semibold text-[var(--color-primary)]">
          Get in touch
        </h2>
        <p className="mt-3 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
          Have feedback, a correction to a question, or a partnership
          enquiry? Visit our{" "}
          <Link href="/services" className="text-gold hover:underline">
            Services page
          </Link>{" "}
          to reach us directly on WhatsApp.
        </p>
      </section>
    </div>
  );
}
