"use client";

import { useState, type ReactNode } from "react";

interface CollapsibleSectionProps {
  /** Header content — always visible, collapsed or not. Usually a plain
   * string ("Account & Security") but left as ReactNode in case a caller
   * ever needs a badge/icon next to the text. */
  title: ReactNode;
  /** Full body content — only rendered in the DOM while expanded, so a
   * collapsed card never pays for its children's height (this is what fixes
   * the "irregular box stretches" complaint: every collapsed card in the
   * Today's Progress carousel row is now the same short height). */
  children: ReactNode;
  /** Default collapsed (false) unless a caller has a specific reason to
   * default a section open — see call sites in ProfileView.tsx/the carousel
   * cards for the reasoning per section. */
  defaultOpen?: boolean;
  className?: string;
  /** When true, skips the outer rounded/border/bg/padding shell and instead
   * renders a top divider — used when several sections need to share ONE
   * surrounding container (see the merged Rank/Notifications/Subscription/
   * Appearance/Account Security block in ProfileView.tsx) instead of each
   * being its own separate card. */
  bare?: boolean;
}

/**
 * Shared collapsed-by-default accordion shell for Profile page cards/
 * sections (product feedback: cards showing full content inline caused
 * inconsistent heights in the horizontal carousel, and the settings-style
 * sections further down felt cluttered). Renders the same rounded-2xl/
 * border/bg-[var(--color-surface)]/p-6 shell every standalone card on this page uses, with
 * the title as a clickable row (chevron rotates on expand) and `children`
 * shown only when open. Pass `bare` to omit that shell (divider instead)
 * when nesting inside a shared parent container.
 */
export default function CollapsibleSection({
  title,
  children,
  defaultOpen = false,
  className = "",
  bare = false,
}: CollapsibleSectionProps) {
  const [open, setOpen] = useState(defaultOpen);

  return (
    <div
      className={
        bare
          ? `border-t border-[var(--color-border)] pt-4 first:border-t-0 first:pt-0 ${className}`
          : `rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6 ${className}`
      }
    >
      <button
        type="button"
        onClick={() => setOpen((prev) => !prev)}
        aria-expanded={open}
        className="flex w-full items-center justify-between gap-4 text-left"
      >
        <span className="font-semibold text-[var(--color-primary)]">{title}</span>
        <svg
          aria-hidden="true"
          viewBox="0 0 20 20"
          fill="none"
          stroke="currentColor"
          strokeWidth={2}
          strokeLinecap="round"
          strokeLinejoin="round"
          className={`h-5 w-5 shrink-0 text-[var(--color-primary)]/60 transition-transform duration-200 ${
            open ? "rotate-180" : ""
          }`}
        >
          <path d="M5 7.5 10 12.5 15 7.5" />
        </svg>
      </button>
      {open && <div className="mt-4">{children}</div>}
    </div>
  );
}
