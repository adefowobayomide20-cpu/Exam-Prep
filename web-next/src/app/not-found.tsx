import Link from "next/link";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Page Not Found",
  description: "The page you're looking for doesn't exist.",
  robots: { index: false, follow: true },
};

export default function NotFound() {
  return (
    <div className="mx-auto flex max-w-xl flex-1 flex-col items-center justify-center px-6 py-24 text-center">
      <p className="text-sm font-semibold uppercase tracking-wide text-gold">
        404
      </p>
      <h1 className="mt-2 text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Page not found
      </h1>
      <p className="mt-4 max-w-md text-base leading-relaxed text-[var(--color-primary)]/70">
        We couldn&apos;t find the page you&apos;re looking for. It may have
        been moved, or the link might be broken.
      </p>
      <Link
        href="/"
        className="mt-8 inline-flex items-center rounded-full bg-gold px-6 py-2.5 text-sm font-semibold text-navy transition-colors hover:brightness-105"
      >
        Back to Home
      </Link>
    </div>
  );
}
