"use client";

import { useRef } from "react";
import type { SubjectSummary } from "@/lib/exam-content";

/**
 * Bottom-sheet/modal subject picker — same visual pattern as DuelLobby's
 * internal SubjectSheet, extracted here so DuelHome's "Invite a friend" and
 * "Play vs computer" flows can reuse it without duplicating the markup.
 */
export default function SubjectPicker({
  title,
  subjects,
  onPick,
  onCancel,
  disabled,
}: {
  title: string;
  subjects: SubjectSummary[];
  onPick: (subjectSlug: string) => void;
  onCancel: () => void;
  disabled?: boolean;
}) {
  const listRef = useRef<HTMLDivElement>(null);
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 sm:items-center">
      <div
        ref={listRef}
        className="max-h-[70vh] w-full max-w-sm overflow-y-auto rounded-t-2xl bg-[var(--color-surface-alt)] p-4 sm:rounded-2xl"
      >
        <p className="px-2 py-2 text-sm font-semibold text-[var(--color-primary)]">{title}</p>
        <div className="mt-1 space-y-1">
          {subjects.map((subject) => (
            <button
              key={subject.slug}
              type="button"
              disabled={disabled}
              onClick={() => onPick(subject.slug)}
              className="block w-full rounded-lg px-3 py-2 text-left text-sm text-[var(--color-primary)] hover:bg-gold/10 disabled:opacity-60"
            >
              {subject.name}
            </button>
          ))}
        </div>
        <button
          type="button"
          onClick={onCancel}
          className="mt-3 block w-full rounded-full border border-[var(--color-border)] px-4 py-2 text-center text-xs font-semibold text-[var(--color-primary)]"
        >
          Cancel
        </button>
      </div>
    </div>
  );
}
