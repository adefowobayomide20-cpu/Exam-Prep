"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { fetchDuelQuestions } from "@/lib/duel-content";
import { createDuelDirect, respondToChallenge, watchIncomingChallenges } from "@/lib/duel-service";
import { DUEL_DURATION_SECONDS, DUEL_QUESTION_COUNT, type ChallengeDoc } from "@/lib/duel-types";

// The recipient's accept/decline countdown. Kept shorter than the sender's
// CHALLENGE_RESPONSE_TIMEOUT_MS in DuelLobby.tsx so a last-second accept
// written here reaches Firestore before the sender's own timer gives up
// and reports "no response" instead of showing the real outcome.
const CHALLENGE_TIMEOUT_SECONDS = 15;

/**
 * Mounted once near the app root (inside AuthProvider — see layout.tsx) so
 * a duel challenge can pop up from anywhere on the site, mirroring the
 * Flutter app's IncomingChallengeListener mounted at the app root.
 *
 * Bug-fix parity with the Flutter session (see lib/features/duel/lobby/
 * incoming_challenge_listener.dart's comments for the original bugs):
 *  1. The accept handler below catches ALL errors from question-loading,
 *     duel creation, and the challenge-status write — not just a narrow
 *     "expected" error type — so a failure always resolves into a visible
 *     message instead of leaving both sides stuck with nothing happening.
 *  2. On any accept failure the challenge is marked `failed` (not
 *     `declined`), so the sender's lobby screen shows "could not start the
 *     duel" instead of incorrectly reporting a decline.
 */
export default function IncomingChallengeListener({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const router = useRouter();
  const [pending, setPending] = useState<ChallengeDoc | null>(null);
  const [banner, setBanner] = useState<string | null>(null);
  const handledRef = useRef<Set<string>>(new Set());
  const dialogOpenRef = useRef(false);

  useEffect(() => {
    if (!user) return;
    const unsubscribe = watchIncomingChallenges(user.uid, (challenges) => {
      if (dialogOpenRef.current) return;
      const next = challenges.find((c) => !handledRef.current.has(c.id));
      if (!next) return;
      handledRef.current.add(next.id);
      dialogOpenRef.current = true;
      setPending(next);
    });
    return unsubscribe;
  }, [user]);

  const closeDialog = () => {
    dialogOpenRef.current = false;
    setPending(null);
  };

  const decline = async (challenge: ChallengeDoc) => {
    closeDialog();
    try {
      await respondToChallenge(challenge.id, "declined");
    } catch {
      // Nothing further to do — the sender's own response-timeout will
      // eventually resolve their waiting dialog.
    }
  };

  const accept = async (challenge: ChallengeDoc) => {
    closeDialog();
    if (!user) return;
    try {
      const { subjectName, questions } = await fetchDuelQuestions(challenge.subject, DUEL_QUESTION_COUNT);
      const duel = await createDuelDirect({
        subject: challenge.subject,
        subjectName,
        questions,
        durationSeconds: DUEL_DURATION_SECONDS,
        hostUid: user.uid,
        hostName: user.displayName || user.email || "Student",
        guestUid: challenge.fromUid,
        guestName: challenge.fromName,
      });
      await respondToChallenge(challenge.id, "accepted", duel.id);
      router.push(`/duel/${duel.id}`);
    } catch (error) {
      // Broad catch by design — see the file-level doc comment above.
      try {
        await respondToChallenge(challenge.id, "failed");
      } catch {
        // Best-effort: if this write also fails the sender will still time out on their own.
      }
      console.error("Duel accept failed:", error);
      setBanner("Could not start the duel. Try again.");
    }
  };

  return (
    <>
      {children}
      {pending && (
        // Keyed on the challenge id so a fresh dialog instance (and a
        // freshly-initialized countdown) mounts per challenge, instead of
        // resetting the countdown state imperatively inside an effect.
        <ChallengeDialog key={pending.id} challenge={pending} onAccept={accept} onDecline={decline} />
      )}
      {banner && (
        <div className="fixed inset-x-0 top-4 z-[60] flex justify-center px-4">
          <div className="flex items-center gap-3 rounded-full bg-red-600 px-4 py-2 text-sm text-white shadow-lg">
            <span>{banner}</span>
            <button type="button" onClick={() => setBanner(null)} aria-label="Dismiss">
              ✕
            </button>
          </div>
        </div>
      )}
    </>
  );
}

function ChallengeDialog({
  challenge,
  onAccept,
  onDecline,
}: {
  challenge: ChallengeDoc;
  onAccept: (challenge: ChallengeDoc) => void;
  onDecline: (challenge: ChallengeDoc) => void;
}) {
  const [secondsLeft, setSecondsLeft] = useState(CHALLENGE_TIMEOUT_SECONDS);

  useEffect(() => {
    const interval = setInterval(() => {
      setSecondsLeft((s) => {
        if (s <= 1) {
          clearInterval(interval);
          onDecline(challenge);
          return 0;
        }
        return s - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [challenge.id]);

  return (
    <div className="fixed inset-0 z-[70] flex items-center justify-center bg-black/60 px-4">
      <div className="w-full max-w-sm rounded-2xl bg-[var(--color-surface-alt)] p-6 text-center shadow-2xl">
        <p className="text-4xl">⚔️</p>
        <h2 className="mt-3 text-lg font-bold text-[var(--color-primary)]">
          {challenge.fromName} is challenging you!
        </h2>
        <p className="mt-1 text-sm text-[var(--color-primary)]/60">
          {challenge.subject} · {challenge.school}
        </p>
        <p className="mt-4 text-3xl font-bold tabular-nums text-[var(--color-primary)]">{secondsLeft}</p>
        <div className="mt-5 flex gap-3">
          <button
            type="button"
            onClick={() => onDecline(challenge)}
            className="flex-1 rounded-full border border-[var(--color-border)] px-4 py-2.5 text-sm font-semibold text-[var(--color-primary)]"
          >
            Decline
          </button>
          <button
            type="button"
            onClick={() => onAccept(challenge)}
            className="flex-1 rounded-full bg-gold px-4 py-2.5 text-sm font-semibold text-navy"
          >
            Accept ⚔️
          </button>
        </div>
      </div>
    </div>
  );
}
