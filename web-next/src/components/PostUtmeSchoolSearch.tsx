"use client";

import Link from "next/link";
import { useSearchFilter } from "@/components/SearchableList";
import type { PostUtmeSchool } from "@/lib/post-utme-content";

/**
 * Post-UTME's school list — a single unified list (not split into "Curated"
 * vs "More Schools" sections). Every school runs the same combined General
 * Paper + 3 JAMB electives flow against the same shared question pool
 * (school-specific banks for the 8 dedicated schools, the common/post-jamb
 * fallback pool for the rest — see post-utme-content.ts), so presenting them
 * as two separate tiers overstated a difference students don't actually
 * experience. Reuses SearchableList's `useSearchFilter` hook for the search
 * box.
 */
export default function PostUtmeSchoolSearch({
  schools,
}: {
  schools: PostUtmeSchool[];
}) {
  const { query, setQuery, filtered } = useSearchFilter(
    schools,
    (school) => `${school.name} ${school.shortName}`
  );

  return (
    <>
      <div className="mt-6 max-w-sm">
        <input
          type="search"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Search schools…"
          aria-label="Search schools"
          className="w-full rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold"
        />
      </div>

      {filtered.length === 0 ? (
        <p className="mt-6 text-sm text-[var(--color-primary)]/60">
          No schools match &ldquo;{query}&rdquo;.
        </p>
      ) : (
        <ul className="mt-8 grid grid-cols-1 gap-3 sm:grid-cols-2">
          {filtered.map((school) => (
            <li key={school.slug}>
              <Link
                href={`/post-utme/${school.slug}`}
                className="flex items-center justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 transition-colors hover:border-gold"
              >
                <span>
                  <span className="block font-medium text-[var(--color-primary)]">
                    {school.name}
                  </span>
                  <span className="text-xs text-[var(--color-primary)]/60">
                    {school.shortName} · {school.type}
                  </span>
                </span>
                <span className="rounded-full bg-gold/15 px-2 py-1 text-[10px] font-semibold uppercase tracking-wide text-gold">
                  Curated
                </span>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </>
  );
}
