import Link from "next/link";
import type { Metadata } from "next";

// Static legal page — plain Server Component (SSG). Split out from Terms of
// Service into its own page/URL since payment processors and some ad/review
// processes specifically look for an easy-to-find, dedicated refund policy
// URL rather than one buried in a longer terms document.
const WHATSAPP_NUMBER = "2349158452860";
const CONTACT_URL = `https://wa.me/${WHATSAPP_NUMBER}`;
const LAST_UPDATED = "July 2026";

export const metadata: Metadata = {
  title: "Refund Policy",
  description:
    "Exam Coach's refund policy for Premium subscriptions billed through Paystack — all sales are final.",
  alternates: { canonical: "/refund-policy" },
  openGraph: { title: "Refund Policy", url: "/refund-policy" },
};

export default function RefundPolicyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
      <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Refund Policy
      </h1>
      <p className="mt-2 text-sm text-[var(--color-primary)]/60">
        Last updated: {LAST_UPDATED}
      </p>

      <div className="mt-6 space-y-4 text-base leading-relaxed text-[var(--color-primary)]/80">
        <p>
          Exam Coach Premium subscriptions are billed through Paystack.{" "}
          <strong>All Premium payments are final and non-refundable.</strong>{" "}
          Once a payment is successfully processed and your account is
          upgraded, that charge is not eligible for a refund — including for
          change of mind, not using the features you paid for, or wanting to
          cancel partway through a subscription period.
        </p>
        <p>
          Please review what Premium includes on the{" "}
          <Link href="/premium" className="text-gold hover:underline">
            Go Premium
          </Link>{" "}
          page before paying, so you know exactly what you&apos;re getting.
        </p>
        <p>
          <strong>The only exception</strong> is a genuine billing error on
          our side — for example, you were charged twice for the same
          subscription period, or your payment succeeded but your account
          was never actually upgraded and our support could not resolve it
          by re-syncing your account. In that specific case, contact us and
          we&apos;ll correct the error.
        </p>
        <p>
          This policy is part of, and should be read alongside, our{" "}
          <Link href="/terms" className="text-gold hover:underline">
            Terms of Service
          </Link>
          .
        </p>
      </div>

      <a
        href={CONTACT_URL}
        target="_blank"
        rel="noopener noreferrer"
        className="mt-8 inline-flex items-center gap-2 rounded-full bg-navy px-6 py-3 font-semibold text-cream transition-colors hover:bg-navy-light"
      >
        Report a billing error on WhatsApp
      </a>
    </div>
  );
}
