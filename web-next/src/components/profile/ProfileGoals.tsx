"use client";

import { useEffect, useState, type ChangeEvent, type FormEvent } from "react";
import { doc, onSnapshot, setDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
// Parallel-task hook contract (web-next/src/lib/leaderboard.ts) — see task
// brief: NIGERIAN_STATES/setUserState/useRankInfo. Not yet present at the
// time this file was written; coded against the documented contract.
import { NIGERIAN_STATES, setUserState, useRankInfo } from "@/lib/leaderboard";

interface Goals {
  targetUniversity: string;
  targetCourse: string;
  /** Kept as a string for the input; parsed/validated to a number on save. */
  targetJambScore: string;
}

const EMPTY_GOALS: Goals = { targetUniversity: "", targetCourse: "", targetJambScore: "" };

/**
 * "Target University" card: target school / course / JAMB score (new plain
 * fields on users/{uid} — targetUniversity, targetCourse, targetJambScore —
 * client-writable like the rest of this system's gamification fields, see
 * gamification.ts's CLIENT-TRUST LIMITATION note) plus the student's home
 * state for the state leaderboard (useRankInfo/setUserState from
 * lib/leaderboard.ts). Combined into one card rather than split: both are
 * one-time "profile goal-setting" fields, and state directly determines the
 * Rank card's state-leaderboard row shown further down this page, so keeping
 * them adjacent reads naturally as "tell us about your target and where
 * you're competing from."
 */
export default function ProfileGoals() {
  const { user } = useAuth();
  const rankInfo = useRankInfo(user?.uid ?? null);

  const [saved, setSaved] = useState<Goals>(EMPTY_GOALS);
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState<Goals>(EMPTY_GOALS);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [stateSaving, setStateSaving] = useState(false);

  useEffect(() => {
    if (!user) return;
    return onSnapshot(doc(db, "users", user.uid), (snapshot) => {
      const data = snapshot.data();
      setSaved({
        targetUniversity: typeof data?.targetUniversity === "string" ? data.targetUniversity : "",
        targetCourse: typeof data?.targetCourse === "string" ? data.targetCourse : "",
        targetJambScore:
          typeof data?.targetJambScore === "number" ? String(data.targetJambScore) : "",
      });
    });
  }, [user]);

  if (!user) return null;

  const startEditing = () => {
    setDraft(saved);
    setError(null);
    setEditing(true);
  };

  const handleSave = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);

    let score: number | null = null;
    const trimmedScore = draft.targetJambScore.trim();
    if (trimmedScore) {
      score = Number(trimmedScore);
      if (!Number.isFinite(score) || score < 0 || score > 400) {
        setError("Enter a JAMB score between 0 and 400.");
        return;
      }
    }

    setSaving(true);
    try {
      await setDoc(
        doc(db, "users", user.uid),
        {
          targetUniversity: draft.targetUniversity.trim(),
          targetCourse: draft.targetCourse.trim(),
          targetJambScore: score,
        },
        { merge: true },
      );
      setEditing(false);
    } catch {
      setError("Couldn't save. Please try again.");
    } finally {
      setSaving(false);
    }
  };

  const handleStateChange = async (event: ChangeEvent<HTMLSelectElement>) => {
    const nextState = event.target.value;
    if (!nextState) return;
    setStateSaving(true);
    try {
      await setUserState(user.uid, nextState);
    } finally {
      setStateSaving(false);
    }
  };

  const hasGoals = saved.targetUniversity || saved.targetCourse || saved.targetJambScore;

  return (
    <div className="mt-6 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6">
      <p className="font-semibold text-[var(--color-primary)]">Target University</p>

      {editing ? (
        <form onSubmit={handleSave} className="mt-4 space-y-3">
          <div>
            <label className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
              University
            </label>
            <input
              type="text"
              value={draft.targetUniversity}
              onChange={(e) => setDraft((d) => ({ ...d, targetUniversity: e.target.value }))}
              placeholder="e.g. UNILAG"
              className="mt-1 w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-sm text-[var(--color-primary)] outline-none focus:border-gold"
            />
          </div>
          <div>
            <label className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
              Course
            </label>
            <input
              type="text"
              value={draft.targetCourse}
              onChange={(e) => setDraft((d) => ({ ...d, targetCourse: e.target.value }))}
              placeholder="e.g. Computer Science"
              className="mt-1 w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-sm text-[var(--color-primary)] outline-none focus:border-gold"
            />
          </div>
          <div>
            <label className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
              Target JAMB score
            </label>
            <input
              type="number"
              min={0}
              max={400}
              value={draft.targetJambScore}
              onChange={(e) => setDraft((d) => ({ ...d, targetJambScore: e.target.value }))}
              placeholder="e.g. 280"
              className="mt-1 w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-sm text-[var(--color-primary)] outline-none focus:border-gold"
            />
          </div>
          {error && <p className="text-sm text-red-600">{error}</p>}
          <div className="flex gap-2">
            <button
              type="submit"
              disabled={saving}
              className="rounded-full bg-navy px-4 py-1.5 text-sm font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
            >
              {saving ? "Saving…" : "Save"}
            </button>
            <button
              type="button"
              onClick={() => setEditing(false)}
              className="rounded-full border border-[var(--color-border)] px-4 py-1.5 text-sm font-medium text-[var(--color-primary)] transition-colors hover:border-gold"
            >
              Cancel
            </button>
          </div>
        </form>
      ) : (
        <div className="mt-3">
          {hasGoals ? (
            <dl className="space-y-1">
              {saved.targetUniversity && (
                <dd className="text-lg font-bold text-[var(--color-primary)]">{saved.targetUniversity}</dd>
              )}
              {saved.targetCourse && (
                <dd className="text-sm text-[var(--color-primary)]/80">{saved.targetCourse}</dd>
              )}
              {saved.targetJambScore && (
                <dd className="text-sm text-[var(--color-primary)]/70">
                  Target JAMB Score: {saved.targetJambScore}
                </dd>
              )}
            </dl>
          ) : (
            <p className="text-sm text-[var(--color-primary)]/70">
              Set your target school, course, and JAMB score.
            </p>
          )}
          <button
            type="button"
            onClick={startEditing}
            className="mt-2 text-sm text-gold hover:underline"
          >
            Edit
          </button>
        </div>
      )}

      <div className="mt-5 border-t border-[var(--color-border)] pt-4">
        <label className="text-xs uppercase tracking-wide text-[var(--color-primary)]/60">
          Your state (for the state leaderboard)
        </label>
        <select
          value={rankInfo?.state ?? ""}
          onChange={handleStateChange}
          disabled={stateSaving}
          className="mt-1 w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-sm text-[var(--color-primary)] outline-none focus:border-gold disabled:opacity-60"
        >
          <option value="" disabled>
            Select your state…
          </option>
          {NIGERIAN_STATES.map((state) => (
            <option key={state} value={state}>
              {state}
            </option>
          ))}
        </select>
      </div>
    </div>
  );
}
