"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { doc, onSnapshot } from "firebase/firestore";
import { httpsCallable } from "firebase/functions";
import { db, functions } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { functionsErrorMessage } from "@/lib/functions-errors";

interface PremiumStatus {
  active: boolean;
  expiresAt: string | null;
  plan: string | null;
}

const DEFAULT_PREMIUM: PremiumStatus = { active: false, expiresAt: null, plan: null };

const BENEFITS = [
  "Unlimited Snap & Solve and Theory help",
  "No ads",
  "Support Exam Coach",
];

function formatDate(iso: string): string {
  const parsed = new Date(iso);
  if (Number.isNaN(parsed.getTime())) return iso;
  return parsed.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
}

interface InitializePaymentResponse {
  authorizationUrl: string;
}

const describeError = functionsErrorMessage;

/**
 * Premium/paywall page — the web mirror of
 * lib/features/premium/paywall_page.dart. Shows the benefit pitch and,
 * depending on live `users/{uid}.premium` state (same read pattern as
 * ProfileView), either the current plan's expiry or an "Upgrade" CTA that
 * calls the `initializePayment` Cloud Function and redirects the browser to
 * the returned hosted Paystack checkout URL. Premium is only ever actually
 * granted by the `paystackWebhook` Cloud Function (functions/payments.js) —
 * this page never writes to `premium` itself.
 *
 * No rewarded-ad bonus button here (unlike the Flutter page): that path is
 * `!kIsWeb`-gated in paywall_page.dart, i.e. mobile-app-only, since it needs
 * a native rewarded-ad SDK.
 */
export default function PremiumView() {
  const { user } = useAuth();
  const [premium, setPremium] = useState<PremiumStatus>(DEFAULT_PREMIUM);
  const [subscribing, setSubscribing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!user) return;
    return onSnapshot(doc(db, "users", user.uid), (snapshot) => {
      const data = snapshot.data();
      const raw = data?.premium as Partial<PremiumStatus> | undefined;
      setPremium({
        active: raw?.active ?? false,
        expiresAt: raw?.expiresAt ?? null,
        plan: raw?.plan ?? null,
      });
    });
  }, [user]);

  if (!user) return null;

  const handleSubscribe = async () => {
    setSubscribing(true);
    setError(null);
    try {
      const initializePayment = httpsCallable<void, InitializePaymentResponse>(
        functions,
        "initializePayment",
      );
      const result = await initializePayment();
      const url = result.data?.authorizationUrl;
      if (!url) {
        setError("Could not start checkout. Try again shortly.");
        return;
      }
      window.location.href = url;
    } catch (err) {
      setError(describeError(err));
    } finally {
      setSubscribing(false);
    }
  };

  return (
    <div className="mx-auto max-w-xl px-4 py-10 sm:px-6">
      <div className="text-center">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-gold/15 text-3xl">
          🏆
        </div>
        <h1 className="mt-4 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
          Exam Coach Premium
        </h1>
        <p className="mt-3 text-[var(--color-primary)]/70">
          Go Premium for unlimited AI-powered help, an ad-free experience, and to support Exam
          Coach.
        </p>
      </div>

      <div className="mt-8 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6">
        <ul className="space-y-3">
          {BENEFITS.map((benefit) => (
            <li key={benefit} className="flex items-start gap-3">
              <span className="mt-0.5 text-gold">✓</span>
              <span className="text-[var(--color-primary)]">{benefit}</span>
            </li>
          ))}
        </ul>
      </div>

      <div className="mt-6 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6 text-center">
        {premium.active ? (
          <>
            <p className="text-lg font-semibold text-[var(--color-primary)]">
              You&apos;re on Premium
            </p>
            <p className="mt-1 text-sm text-[var(--color-primary)]/70">
              {premium.expiresAt
                ? `Active until ${formatDate(premium.expiresAt)}`
                : "Unlimited Snap & Solve and Theory help"}
            </p>
            <Link
              href="/profile"
              className="mt-5 inline-block rounded-full border border-[var(--color-border)] px-5 py-2.5 text-sm font-medium text-[var(--color-primary)] transition-colors hover:border-gold"
            >
              View profile
            </Link>
          </>
        ) : (
          <>
            {error && (
              <p className="mb-4 text-sm text-red-600" role="alert">
                {error}
              </p>
            )}
            <button
              type="button"
              onClick={handleSubscribe}
              disabled={subscribing}
              className="w-full rounded-full bg-gold px-5 py-3 text-base font-semibold text-navy transition-colors hover:opacity-90 disabled:opacity-60 sm:w-auto sm:px-8"
            >
              {subscribing ? "Starting checkout…" : error ? "Retry — ₦700/mo" : "Upgrade — ₦700/mo"}
            </button>
            <p className="mt-4 text-xs text-[var(--color-primary)]/50">
              You&apos;ll be redirected to Paystack&apos;s secure checkout to complete payment.
            </p>
          </>
        )}
      </div>
    </div>
  );
}
