"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useEffect, useState, type FormEvent } from "react";
import {
  GoogleAuthProvider,
  getRedirectResult,
  signInWithEmailAndPassword,
  signInWithRedirect,
} from "firebase/auth";
import { auth } from "@/lib/firebase";
import { authErrorMessage } from "@/lib/auth-errors";
import PageHero from "@/components/PageHero";

/** Only allow redirecting back into this site, never to an external URL. */
function safeRedirect(value: string | null): string {
  if (value && value.startsWith("/") && !value.startsWith("//")) return value;
  return "/";
}

// useSearchParams (for the optional ?redirect= target set by RequireAuth)
// bails prerendering out to client-side rendering for anything below it, so
// it needs its own Suspense boundary — see
// node_modules/next/dist/docs/01-app/03-api-reference/04-functions/use-search-params.md.
export default function SignInPage() {
  return (
    <Suspense fallback={null}>
      <SignInForm />
    </Suspense>
  );
}

function SignInForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const redirectTo = safeRedirect(searchParams.get("redirect"));
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [googleSubmitting, setGoogleSubmitting] = useState(false);

  // Completes the redirect-based Google sign-in below — signInWithPopup was
  // switched to signInWithRedirect because popups are unreliable in exactly
  // the contexts this site's own InstallPrompt encourages (installed PWAs
  // have no browser chrome to host a popup, and many mobile in-app/webview
  // browsers block window.open outright), which is the most common real-world
  // cause of "Google sign-in doesn't work". A redirect navigates away and
  // back to this same page, so the result has to be picked up here on mount.
  useEffect(() => {
    getRedirectResult(auth)
      .then((result) => {
        if (result) router.push(redirectTo);
      })
      .catch((err) => setError(authErrorMessage(err)));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await signInWithEmailAndPassword(auth, email.trim(), password);
      router.push(redirectTo);
    } catch (err) {
      setError(authErrorMessage(err));
    } finally {
      setSubmitting(false);
    }
  };

  const handleGoogleSignIn = async () => {
    setError(null);
    setGoogleSubmitting(true);
    try {
      // Navigates away immediately — completion is handled by the
      // getRedirectResult effect above once the browser comes back.
      await signInWithRedirect(auth, new GoogleAuthProvider());
    } catch (err) {
      const message = authErrorMessage(err);
      if (message) setError(message);
      setGoogleSubmitting(false);
    }
  };

  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-8 sm:px-6 sm:py-12">
      <PageHero size="large" heading="Welcome back" subtext="Sign in to continue your prep." />

      <div className="mt-8 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6">
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
            Email
            <input
              type="email"
              required
              autoComplete="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold"
            />
          </label>
          <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
            Password
            <input
              type="password"
              required
              autoComplete="current-password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold"
            />
          </label>

          {error && <p className="text-sm text-red-600">{error}</p>}

          <button
            type="submit"
            disabled={submitting}
            className="mt-2 rounded-full bg-navy px-5 py-3.5 font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
          >
            {submitting ? "Signing in…" : "Sign in"}
          </button>
        </form>

        <div className="my-6 flex items-center gap-3 text-xs text-[var(--color-primary)]/50">
          <span className="h-px flex-1 bg-[var(--color-border)]" />
          or
          <span className="h-px flex-1 bg-[var(--color-border)]" />
        </div>

        <button
          type="button"
          onClick={handleGoogleSignIn}
          disabled={googleSubmitting}
          className="w-full rounded-full border border-[var(--color-border)] px-5 py-3.5 font-semibold text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold disabled:opacity-60"
        >
          {googleSubmitting ? "Connecting…" : "Continue with Google"}
        </button>
      </div>

      <div className="mt-6 flex flex-col items-center gap-2 text-sm text-[var(--color-primary)]/70">
        <p>
          New here?{" "}
          <Link href="/sign-up" className="font-semibold text-gold">
            Create an account
          </Link>
        </p>
        <p>
          <Link href="/reset-password" className="font-semibold text-gold">
            Forgot your password?
          </Link>
        </p>
      </div>
    </div>
  );
}
