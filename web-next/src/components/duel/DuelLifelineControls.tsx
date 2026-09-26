"use client";

/**
 * Duel-specific lifeline button row — Hint, 50/50, Freeze, Ask a Friend, Ask
 * Computer. A sibling of components/quiz/LifelineControls.tsx rather than a
 * reuse of it: duels have three extra lifeline kinds (Freeze/Ask-a-Friend/
 * Ask-Computer) that regular quiz practice doesn't, so a unified 5-button bar
 * is cleaner here than bolting three more buttons onto the shared component
 * (which stays untouched, still used as-is by QuizSession/CombinedQuizSession).
 *
 * All usage-cap logic (per-session cap shared across all 5 kinds, per-day cap
 * shared with regular quiz practice via src/lib/lifelines.ts) lives in the
 * caller (DuelSession.tsx) — this component just renders buttons and a
 * remaining-uses label from props, same division of responsibility as
 * LifelineControls.tsx.
 */

interface Props {
  onHint: () => void;
  onFiftyFifty: () => void;
  onFreeze: () => void;
  onAskFriend: () => void;
  onAskComputer: () => void;
  hintDisabled: boolean;
  fiftyFiftyDisabled: boolean;
  freezeDisabled: boolean;
  askFriendDisabled: boolean;
  askComputerDisabled: boolean;
  askComputerLoading: boolean;
  /** Uses left today (the daily cap, shared with regular quiz practice). */
  usesRemaining: number;
}

const buttonClasses =
  "inline-flex items-center gap-1.5 rounded-full border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-xs font-semibold text-[var(--color-primary)] transition-colors hover:border-gold/50 disabled:cursor-not-allowed disabled:opacity-40";

export default function DuelLifelineControls({
  onHint,
  onFiftyFifty,
  onFreeze,
  onAskFriend,
  onAskComputer,
  hintDisabled,
  fiftyFiftyDisabled,
  freezeDisabled,
  askFriendDisabled,
  askComputerDisabled,
  askComputerLoading,
  usesRemaining,
}: Props) {
  return (
    <div className="mt-4 flex flex-wrap items-center gap-2">
      <button type="button" onClick={onHint} disabled={hintDisabled} className={buttonClasses}>
        💡 Hint
      </button>
      <button type="button" onClick={onFiftyFifty} disabled={fiftyFiftyDisabled} className={buttonClasses}>
        50/50
      </button>
      <button type="button" onClick={onFreeze} disabled={freezeDisabled} className={buttonClasses}>
        ❄️ Freeze
      </button>
      <button type="button" onClick={onAskFriend} disabled={askFriendDisabled} className={buttonClasses}>
        📤 Ask a Friend
      </button>
      <button type="button" onClick={onAskComputer} disabled={askComputerDisabled} className={buttonClasses}>
        {askComputerLoading ? "Asking…" : "🤖 Ask Computer"}
      </button>
      <span className="text-xs text-[var(--color-primary)]/50">
        {usesRemaining} lifeline{usesRemaining === 1 ? "" : "s"} left today
      </span>
    </div>
  );
}
