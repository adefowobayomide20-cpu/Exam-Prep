import Link from "next/link";
import type { Metadata } from "next";
import { CATEGORIES } from "@/lib/exam-content";

// Minimal hub page linking out to the 4 exam category landing pages
// (/waec, /neco, /jamb, /post-utme). Header.tsx and BottomNav.tsx both link
// here as the "Exam" tab.
export const metadata: Metadata = {
  title: "Exam Prep",
  description:
    "Choose an exam — WAEC, NECO, JAMB, or Post-UTME — to start free past-question practice.",
  alternates: { canonical: "/exam" },
};

export default function ExamHubPage() {
  const categories = Object.values(CATEGORIES);

  return (
    <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6">
      <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Exam
      </h1>
      <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--color-primary)]/80">
        Pick an exam type below to see available subjects and start free
        practice.
      </p>

      <ul className="mt-8 grid grid-cols-1 gap-3 sm:grid-cols-2">
        {categories.map((category) => (
          <li key={category.slug}>
            <Link
              // JAMB's real exam format is one combined session (English
              // compulsory + 3 electives), so this jumps straight there
              // instead of the flat single-subject list every other
              // category shows first — matches /jamb/combined's own
              // "Recommended" framing on the category page itself.
              href={category.slug === "jamb" ? "/jamb/combined" : `/${category.slug}`}
              className="flex items-center justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 transition-colors hover:border-gold"
            >
              <span className="font-medium text-[var(--color-primary)]">
                {category.name}
              </span>
              <span className="text-xs text-[var(--color-primary)]/60">
                {category.shortLabel}
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
