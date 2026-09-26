import Link from "next/link";
import type { Metadata } from "next";

const WHATSAPP_NUMBER = "2349158452860";
const CONTACT_URL = `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(
  "Hello Exam Coach, I want to request deletion of my account and any related data. Please help me complete the account deletion process.",
)}`;

export const metadata: Metadata = {
  title: "Account Deletion Request",
  description:
    "How to request deletion of your Exam Coach account and related data.",
  alternates: { canonical: "/account-deletion-request" },
  openGraph: { title: "Account Deletion Request", url: "/account-deletion-request" },
};

export default function AccountDeletionRequestPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
      <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Account Deletion Request
      </h1>

      <p className="mt-4 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
        If you want to permanently remove your Exam Coach account, you can do it from your profile in a few steps.
        If you need help or are unable to complete the deletion in-app, you can also request support below.
      </p>

      <section className="mt-8 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6">
        <h2 className="text-xl font-semibold text-[var(--color-primary)]">Delete your account in-app</h2>
        <ol className="mt-4 list-decimal space-y-3 pl-5 text-base leading-relaxed text-[var(--color-primary)]/80">
          <li>Open your <Link href="/profile" className="text-gold hover:underline">Profile</Link>.</li>
          <li>Go to <strong>Account &amp; Security</strong>.</li>
          <li>Tap <strong>Delete account</strong>.</li>
          <li>Confirm the prompt to permanently remove your account.</li>
        </ol>

        <div className="mt-6 flex flex-wrap gap-3">
          <Link
            href="/profile"
            className="inline-flex rounded-full bg-navy px-5 py-3 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
          >
            Go to my profile
          </Link>
          <a
            href={CONTACT_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex rounded-full border border-[var(--color-border)] px-5 py-3 text-sm font-semibold text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold"
          >
            Request help on WhatsApp
          </a>
        </div>
      </section>

      <section className="mt-8">
        <h2 className="text-xl font-semibold text-[var(--color-primary)]">Important note</h2>
        <p className="mt-3 text-base leading-relaxed text-[var(--color-primary)]/80">
          Account deletion is permanent. Once completed, your sign-in credentials and account progress will be removed
          from the active app account. If you have any remaining questions about your data or want help with a manual
          deletion request, contact us through WhatsApp and we will assist you.
        </p>
      </section>

      <p className="mt-10 text-sm text-[var(--color-primary)]/60">
        See also our <Link href="/privacy" className="text-gold hover:underline">Privacy Policy</Link> and
        <Link href="/terms" className="ml-1 text-gold hover:underline">Terms of Service</Link>.
      </p>
    </div>
  );
}
