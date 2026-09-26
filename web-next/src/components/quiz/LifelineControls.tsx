"use client";

/**
 * Small, reusable lifeline button row — Hint + 50/50 — shared by
 * QuizSession.tsx and CombinedQuizSession.tsx. Hint and 50/50 are two fully
 * independent allowances (see src/lib/lifelines.ts's MAX_HINT_USES_PER_* /
 * MAX_FIFTY_FIFTY_USES_PER_*), so their remaining-today counts are tracked
 * and displayed separately rather than as one shared number. All usage-cap
 * logic (per-session, per-day) lives in the caller — this component just
 * renders two buttons, a remaining-uses label per kind, and (if provided) the
 * revealed Hint text for the current question.
 */

interface Props {
  onHint: () => void;
  onFiftyFifty: () => void;
  hintDisabled: boolean;
  fiftyFiftyDisabled: boolean;
  /** Hint uses left today, out of MAX_HINT_USES_PER_DAY. */
  hintUsesRemaining: number;
  /** 50/50 uses left today, out of MAX_FIFTY_FIFTY_USES_PER_DAY. */
  fiftyFiftyUsesRemaining: number;
  /** Revealed hint clue text for the CURRENT question, if Hint has already
   * been used on it — see src/lib/lifelines.ts's `buildHintText`. */
  hintText?: string;
}

export default function LifelineControls({
  onHint,
  onFiftyFifty,
  hintDisabled,
  fiftyFiftyDisabled,
  hintUsesRemaining,
  fiftyFiftyUsesRemaining,
  hintText,
}: Props) {
  return (
    <div className="mt-4">
      <div className="flex flex-wrap items-center gap-2">
        <button
          type="button"
          onClick={onHint}
          disabled={hintDisabled}
          className="inline-flex items-center gap-1.5 rounded-full border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-2 text-xs font-semibold text-[var(--color-primary)] transition-colors hover:border-gold/50 disabled:cursor-not-allowed disabled:opacity-40"
        >
          💡 Hint
        </button>
        <button
          type="button"
          onClick={onFiftyFifty}
          disabled={fiftyFiftyDisabled}
          className="inline-flex items-center gap-1.5 rounded-full border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-2 text-xs font-semibold text-[var(--color-primary)] transition-colors hover:border-gold/50 disabled:cursor-not-allowed disabled:opacity-40"
        >
          50/50
        </button>
        <span className="text-xs text-[var(--color-primary)]/50">
          {hintUsesRemaining} hint{hintUsesRemaining === 1 ? "" : "s"} · {fiftyFiftyUsesRemaining} 50/50
          {fiftyFiftyUsesRemaining === 1 ? "" : "s"} left today
        </span>
      </div>
      {hintText && (
        <p className="mt-2 rounded-lg bg-gold/10 px-3 py-2 text-xs font-medium text-[var(--color-primary)]">
          💡 {hintText}
        </p>
      )}
    </div>
  );
}
