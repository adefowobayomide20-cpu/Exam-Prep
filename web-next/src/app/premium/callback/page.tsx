import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Payment processing",
  description: "Your Exam Coach Premium payment is processing.",
  alternates: { canonical: "/premium/callback" },
  robots: { index: false, follow: false },
};

/**
 * Landing page for the browser redirect Paystack's hosted checkout sends
 * after a payment attempt. This page is purely informational — Premium is
 * only ever granted by the `paystackWebhook` Cloud Function
 * (functions/payments.js) receiving and verifying the async `charge.success`
 * event server-to-server, which can land a few seconds after this redirect.
 * There's nothing to read from the URL here (no transaction reference is
 * required client-side): we just tell the student to check back.
 *
 * NOTE: `initializePayment` doesn't pass a `callback_url` to Paystack, so
 * the redirect target is whatever's configured as the default callback URL
 * on the Paystack dashboard for this integration — that may still point at
 * a Flutter-web/mobile-specific URL from before this Next.js site existed.
 * Confirm/update it in the Paystack dashboard to
 * https://www.examcoach.com.ng/premium/callback once this site is live.
 */
export default function PremiumCallbackPage() {
  return (
    <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
      <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-gold/15 text-2xl">
        ⏳
      </div>
      <h1 className="mt-4 text-2xl font-bold text-[var(--color-primary)] sm:text-3xl">
        Payment processing
      </h1>
      <p className="mt-3 text-[var(--color-primary)]/80">
        Thanks! We&apos;re confirming your payment with Paystack — this usually only takes a few
        seconds. Your Premium status will update automatically once it&apos;s confirmed.
      </p>
      <Link
        href="/profile"
        className="mt-6 inline-block rounded-full bg-navy px-5 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light"
      >
        Check my profile
      </Link>
    </div>
  );
}
