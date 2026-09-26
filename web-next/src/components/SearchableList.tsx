"use client";

import { useMemo, useState, type ReactNode } from "react";

/**
 * Generic client-side "search box + filtered list" wrapper.
 *
 * Server Components build the full list of `{key, searchText, node}` entries
 * — `node` already-rendered JSX for that item's card/link markup — and pass
 * that plain-data array in as a prop. This deliberately does NOT take
 * `getKey`/`getSearchText`/`children` callback props: React Server
 * Components cannot pass plain functions (only Server Actions) across the
 * server->client boundary, so a render-prop API here would break at build
 * time for any Server Component caller (as it did before this fix — see
 * git history). Passing pre-rendered ReactNode + plain strings is the
 * RSC-legal way to let each page keep its own card styling while the search
 * box and filtering stay client-interactive with no network round-trip on
 * keystroke, and the full list is still present pre-hydration for
 * SEO/crawlability.
 */
export interface SearchableListItem {
  /** Stable key for this item, used for the React list key. */
  key: string;
  /** Text to match the search query against. */
  searchText: string;
  /** Already-rendered markup for this item (built server-side). */
  node: ReactNode;
}

export type SearchableListProps = {
  items: SearchableListItem[];
  placeholder?: string;
  /** Extra className for the wrapping <ul>/<ol> list element. */
  listClassName?: string;
  listTag?: "ul" | "ol";
  emptyMessage?: string;
  /** Extra className for the search <input>. */
  inputClassName?: string;
  /** Label rendered above the input for accessibility (visually hidden by default via sr-only wrapper if omitted a11y label is still applied via aria-label). */
  ariaLabel?: string;
};

/**
 * Underlying filter logic as a hook, for pages that need more than one
 * rendered list (e.g. grouped sections) driven by a single search box —
 * see PostUtmeSchoolSearch.tsx for an example consumer.
 */
export function useSearchFilter<T>(items: T[], getSearchText: (item: T) => string) {
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return items;
    return items.filter((item) => getSearchText(item).toLowerCase().includes(q));
  }, [items, query, getSearchText]);

  return { query, setQuery, filtered };
}

export default function SearchableList({
  items,
  placeholder = "Search…",
  listClassName = "mt-8 grid grid-cols-1 gap-3 sm:grid-cols-2",
  listTag = "ul",
  emptyMessage = "No matches found.",
  inputClassName = "",
  ariaLabel,
}: SearchableListProps) {
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return items;
    return items.filter((item) => item.searchText.toLowerCase().includes(q));
  }, [items, query]);

  const ListTag = listTag;

  return (
    <>
      <div className="mt-6 max-w-sm">
        <input
          type="search"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder={placeholder}
          aria-label={ariaLabel ?? placeholder}
          className={
            inputClassName ||
            "w-full rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 text-base font-normal text-[var(--color-primary)] outline-none focus:border-gold"
          }
        />
      </div>

      {filtered.length === 0 ? (
        <p className="mt-6 text-sm text-[var(--color-primary)]/60">{emptyMessage}</p>
      ) : (
        <ListTag className={listClassName}>
          {filtered.map((item) => (
            <li key={item.key}>{item.node}</li>
          ))}
        </ListTag>
      )}
    </>
  );
}
