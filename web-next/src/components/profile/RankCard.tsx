"use client";

import { useEffect, useState, type FormEvent } from "react";
import { useAuth } from "@/lib/auth-context";
// Parallel-task hook contracts (web-next/src/lib/leaderboard.ts,
// web-next/src/lib/friends.ts) — see task brief. Not yet present at the time
// this file was written; coded against the documented contract.
import { useRankInfo } from "@/lib/leaderboard";
import { addFriendByCode, getOrCreateFriendCode, useFriendsList } from "@/lib/friends";
import CollapsibleSection from "@/components/profile/CollapsibleSection";

function RankRow({
  label,
  value,
  fallback,
}: {
  label: string;
  value: number | null;
  fallback: string;
}) {
  return (
    <div className="flex items-center justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3">
      <span className="text-sm text-[var(--color-primary)]/70">{label}</span>
      <span className="font-semibold text-[var(--color-primary)]">
        {value !== null ? `#${value.toLocaleString()}` : fallback}
      </span>
    </div>
  );
}

/** "Rank" card — Nigeria/state/friends placement from useRankInfo(), plus
 * the friend-code share/add UI (the only natural home for it on this page).
 * Each rank row falls back to a specific, actionable message when null
 * rather than a bare "—", per the task brief. Collapsed by default — see
 * TodaysProgress.tsx's doc comment for why. */
export default function RankCard({ bare = false }: { bare?: boolean }) {
  const { user } = useAuth();
  const rankInfo = useRankInfo(user?.uid ?? null);
  const friends = useFriendsList(user?.uid ?? "");

  const [code, setCode] = useState<string | null>(null);
  const [codeError, setCodeError] = useState<string | null>(null);

  const [addCodeInput, setAddCodeInput] = useState("");
  const [addBusy, setAddBusy] = useState(false);
  const [addError, setAddError] = useState<string | null>(null);
  const [addSuccess, setAddSuccess] = useState(false);

  useEffect(() => {
    if (!user) return;
    let cancelled = false;
    getOrCreateFriendCode(user.uid)
      .then((c) => {
        if (!cancelled) setCode(c);
      })
      .catch(() => {
        if (!cancelled) setCodeError("Couldn't load your friend code.");
      });
    return () => {
      cancelled = true;
    };
  }, [user]);

  if (!user) return null;

  const handleAddFriend = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const trimmed = addCodeInput.trim();
    if (!trimmed) return;
    setAddBusy(true);
    setAddError(null);
    setAddSuccess(false);
    try {
      const result = await addFriendByCode(user.uid, trimmed);
      if (result.ok) {
        setAddSuccess(true);
        setAddCodeInput("");
      } else {
        setAddError(result.reason);
      }
    } catch {
      setAddError("Couldn't add friend. Please try again.");
    } finally {
      setAddBusy(false);
    }
  };

  return (
    <CollapsibleSection title="Rank" className={bare ? "" : "mt-6"} bare={bare}>
      <div className="space-y-2">
        <RankRow label="Nigeria" value={rankInfo?.nigeriaRank ?? null} fallback="Not ranked yet" />
        <RankRow
          label="State"
          value={rankInfo?.stateRank ?? null}
          fallback={rankInfo?.state ? "Not ranked yet" : "Set your state to see state rank"}
        />
        <RankRow
          label="Friends"
          value={rankInfo?.friendsRank ?? null}
          fallback="Add friends to see friends rank"
        />
      </div>

      <div className="mt-5 border-t border-[var(--color-border)] pt-4">
        <p className="text-sm font-semibold text-[var(--color-primary)]">Friends</p>
        <p className="mt-1 text-xs text-[var(--color-primary)]/60">
          Share your code so friends can add you, or enter theirs below.
        </p>
        <div className="mt-2">
          <code className="rounded-lg bg-[var(--color-surface-alt)] px-3 py-1.5 text-sm font-mono text-[var(--color-primary)]">
            {code ?? "…"}
          </code>
        </div>
        {codeError && <p className="mt-1 text-sm text-red-600">{codeError}</p>}

        <form onSubmit={handleAddFriend} className="mt-3 flex flex-wrap gap-2">
          <input
            type="text"
            value={addCodeInput}
            onChange={(e) => setAddCodeInput(e.target.value)}
            placeholder="Enter a friend's code"
            className="min-w-0 flex-1 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-sm text-[var(--color-primary)] outline-none focus:border-gold"
          />
          <button
            type="submit"
            disabled={addBusy}
            className="rounded-full bg-navy px-4 py-2 text-sm font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
          >
            {addBusy ? "Adding…" : "Add"}
          </button>
        </form>
        {addError && <p className="mt-2 text-sm text-red-600">{addError}</p>}
        {addSuccess && <p className="mt-2 text-sm text-green-600">Friend added!</p>}

        {friends && friends.length > 0 && (
          <ul className="mt-3 space-y-1 text-sm text-[var(--color-primary)]/80">
            {friends.map((f, i) => (
              <li key={i}>
                {f.displayName ?? "Friend"} — {(f.xp ?? 0).toLocaleString()} XP
              </li>
            ))}
          </ul>
        )}
      </div>
    </CollapsibleSection>
  );
}
