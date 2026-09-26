"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState, type FormEvent } from "react";
import {
  GoogleAuthProvider,
  createUserWithEmailAndPassword,
  getRedirectResult,
  signInWithRedirect,
  updateProfile,
} from "firebase/auth";
import { auth } from "@/lib/firebase";
import { authErrorMessage } from "@/lib/auth-errors";
import PageHero from "@/components/PageHero";

export default function SignUpPage() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [googleSubmitting, setGoogleSubmitting] = useState(false);

  // See sign-in/page.tsx's matching effect for why this is signInWithRedirect
  // + getRedirectResult rather than signInWithPopup.
  useEffect(() => {
    getRedirectResult(auth)
      .then((result) => {
        if (result) router.push("/");
      })
      .catch((err) => setError(authErrorMessage(err)));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const credential = await createUserWithEmailAndPassword(
        auth,
        email.trim(),
        password,
      );
      const trimmedName = name.trim();
      if (trimmedName) {
        await updateProfile(credential.user, { displayName: trimmedName });
      }
      router.push("/");
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
      await signInWithRedirect(auth, new GoogleAuthProvider());
    } catch (err) {
      const message = authErrorMessage(err);
      if (message) setError(message);
      setGoogleSubmitting(false);
    }
  };

  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-8 sm:px-6 sm:py-12">
      <PageHero
        size="large"
        heading="Create an account"
        subtext="Free past questions, CBT practice, and an AI tutor — sign up in seconds."
        subtextClassName="max-w-xs"
      />

      <div className="mt-8 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6">
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
            Name (optional)
            <input
              type="text"
              autoComplete="name"
              value={name}
              onChange={(event) => setName(event.target.value)}
              className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold"
            />
          </label>
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
              minLength={6}
              autoComplete="new-password"
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
            {submitting ? "Creating account…" : "Create account"}
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

      <p className="mt-6 text-center text-sm text-[var(--color-primary)]/70">
        Already have an account?{" "}
        <Link href="/sign-in" className="font-semibold text-gold">
          Sign in
        </Link>
      </p>
    </div>
  );
}
