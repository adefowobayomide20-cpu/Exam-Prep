"use client";

import { useEffect, useRef, useState } from "react";
import { doc, onSnapshot } from "firebase/firestore";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { db } from "@/lib/firebase";
import type { SubjectSummary } from "@/lib/exam-content";
import {
  HEARTBEAT_INTERVAL_MS,
  heartbeat,
  leaveLobby,
  respondToChallenge,
  sendChallenge,
  watchChallenge,
  watchOnline,
} from "@/lib/duel-service";
import { POST_JAMB_SCHOOLS, type LobbyPresenceDoc } from "@/lib/duel-types";

// Slightly longer than the 15s IncomingChallengeListener's accept dialog
// waits before auto-declining, so a last-second accept isn't missed by this
// side giving up first — see that component for the matching constant.
const CHALLENGE_RESPONSE_TIMEOUT_MS = 16_000;

interface Props {
  subjects: SubjectSummary[];
}

/** Loose match: the profile's school tag is freeform text (see
 * ProfileGoals.tsx's "University" field, e.g. "UNILAG" or "University of
 * Lagos"), while the filter dropdown offers a fixed list — so this checks
 * either the school's short name or full name appears in the member's tag,
 * case-insensitively, rather than requiring an exact match. */
function matchesSchoolFilter(memberSchool: string | null, filterShortName: string): boolean {
  if (!memberSchool) return false;
  const school = POST_JAMB_SCHOOLS.find((s) => s.shortName === filterShortName);
  if (!school) return false;
  const tag = memberSchool.toLowerCase();
  return tag.includes(school.shortName.toLowerCase()) || tag.includes(school.name.toLowerCase());
}

/**
 * "Who's online" duel lobby — the web mirror of
 * lib/features/duel/lobby/school_lobby_page.dart, but with ONE key
 * difference from the Flutter app (and from this page's own earlier
 * version): presence is a single global list, not partitioned into
 * per-school "rooms". Everyone signed in and on this page shows up for
 * everyone else, regardless of school — the school tag (sourced from the
 * user's own `targetUniversity` profile field, see ProfileGoals.tsx, only
 * shown/usable if they've actually set one) is purely a display label plus
 * an optional client-side filter, never a gate on visibility. This was a
 * deliberate change requested after the previous per-school-room design
 * hid everyone by default unless you happened to pick the exact same
 * school as them.
 */
export default function DuelLobby({ subjects }: Props) {
  const { user } = useAuth();
  const uid = user?.uid ?? "";
  const displayName = user?.displayName || user?.email || "Student";

  const [ownSchool, setOwnSchool] = useState<string | null>(null);
  const [filterSchool, setFilterSchool] = useState<string>(""); // "" = all schools
  const [members, setMembers] = useState<LobbyPresenceDoc[]>([]);
  const [challengeTarget, setChallengeTarget] = useState<LobbyPresenceDoc | null>(null);
  const [sending, setSending] = useState(false);
  const [waitingChallengeId, setWaitingChallengeId] = useState<string | null>(null);
  const [waitingOpponent, setWaitingOpponent] = useState<string | null>(null);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const router = useRouter();

  // Read the signed-in user's own school tag (their `targetUniversity`
  // profile field, if set) so it can be included in our own presence doc.
  useEffect(() => {
    if (!uid) return;
    return onSnapshot(doc(db, "users", uid), (snapshot) => {
      const value = snapshot.data()?.targetUniversity;
      setOwnSchool(typeof value === "string" && value.trim() ? value.trim() : null);
    });
  }, [uid]);

  // Presence heartbeat into the single global list.
  useEffect(() => {
    if (!uid) return;
    heartbeat(uid, displayName, ownSchool).catch(() => {});
    const interval = setInterval(() => {
      heartbeat(uid, displayName, ownSchool).catch(() => {});
    }, HEARTBEAT_INTERVAL_MS);
    return () => {
      clearInterval(interval);
      leaveLobby(uid).catch(() => {});
    };
  }, [uid, displayName, ownSchool]);

  // Who else is online, globally.
  useEffect(() => {
    if (!uid) return;
    return watchOnline(uid, setMembers);
  }, [uid]);

  const visibleMembers = filterSchool
    ? members.filter((m) => matchesSchoolFilter(m.school, filterSchool))
    : members;

  const openChallengePicker = (member: LobbyPresenceDoc) => {
    setChallengeTarget(member);
    setErrorMessage(null);
  };

  const sendChallengeTo = async (subjectSlug: string) => {
    const target = challengeTarget;
    if (!target) return;
    setSending(true);
    setErrorMessage(null);
    try {
      const challengeId = await sendChallenge({
        fromUid: uid,
        fromName: displayName,
        toUid: target.uid,
        toName: target.name,
        school: ownSchool ?? "",
        subject: subjectSlug,
      });
      setChallengeTarget(null);
      setWaitingChallengeId(challengeId);
      setWaitingOpponent(target.name);
    } catch {
      setErrorMessage("Could not send the challenge. Try again.");
    } finally {
      setSending(false);
    }
  };

  // Watch the sent challenge for a response, with a timeout matching the
  // recipient's accept-dialog window (see the constant above and
  // IncomingChallengeListener for the fixed-bug context this mirrors).
  useEffect(() => {
    if (!waitingChallengeId) return;
    let resolved = false;
    const resolve = () => {
      if (resolved) return;
      resolved = true;
      setWaitingChallengeId(null);
      setWaitingOpponent(null);
    };
    const unsubscribe = watchChallenge(waitingChallengeId, (challenge) => {
      if (!challenge || challenge.status === "pending") return;
      if (challenge.status === "accepted" && challenge.duelId) {
        resolve();
        router.push(`/duel/${challenge.duelId}`);
      } else if (challenge.status === "declined") {
        setStatusMessage(`${waitingOpponent ?? "They"} declined the challenge.`);
        resolve();
      } else if (challenge.status === "expired") {
        setStatusMessage(`${waitingOpponent ?? "They"} didn't respond in time.`);
        resolve();
      } else if (challenge.status === "failed") {
        setStatusMessage("Could not start the duel. Try again.");
        resolve();
      }
    });
    const timeout = setTimeout(() => {
      respondToChallenge(waitingChallengeId, "expired").catch(() => {});
      resolve();
    }, CHALLENGE_RESPONSE_TIMEOUT_MS);
    return () => {
      unsubscribe();
      clearTimeout(timeout);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [waitingChallengeId]);

  const cancelWaiting = () => {
    if (waitingChallengeId) {
      respondToChallenge(waitingChallengeId, "expired").catch(() => {});
    }
    setWaitingChallengeId(null);
    setWaitingOpponent(null);
  };

  return (
    <div className="mx-auto max-w-2xl px-4 py-8 sm:px-6">
      <div className="flex items-center justify-between gap-3">
        <h1 className="text-xl font-bold text-[var(--color-primary)]">Who&apos;s Online</h1>
        <select
          value={filterSchool}
          onChange={(e) => setFilterSchool(e.target.value)}
          className="rounded-full border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-1.5 text-sm text-[var(--color-primary)]"
        >
          <option value="">All schools</option>
          {POST_JAMB_SCHOOLS.map((s) => (
            <option key={s.shortName} value={s.shortName}>
              {s.shortName}
            </option>
          ))}
        </select>
      </div>
      <p className="mt-1 text-sm text-[var(--color-primary)]/60">
        {filterSchool ? `Showing students tagged with ${filterSchool}` : "Everyone online right now"}
      </p>

      {statusMessage && (
        <p className="mt-4 rounded-lg bg-[var(--color-surface-alt)] px-3 py-2 text-sm text-[var(--color-primary)]">
          {statusMessage}
        </p>
      )}
      {errorMessage && (
        <p className="mt-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorMessage}</p>
      )}

      <div className="mt-6 space-y-2">
        {visibleMembers.length === 0 ? (
          <p className="rounded-xl border border-dashed border-[var(--color-border)] px-4 py-8 text-center text-sm text-[var(--color-primary)]/60">
            {filterSchool
              ? `No one tagged with ${filterSchool} is online right now — try "All schools", or share Exam Coach with friends to duel them here.`
              : "No one else is online right now. Share Exam Coach with friends to duel them here, or invite a friend / play the computer instead."}
          </p>
        ) : (
          visibleMembers.map((member) => (
            <div
              key={member.uid}
              className="flex items-center justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3"
            >
              <div className="flex items-center gap-3">
                <span className="relative flex h-9 w-9 items-center justify-center rounded-full bg-navy/10 text-sm font-semibold text-navy">
                  {member.name.charAt(0).toUpperCase()}
                  <span className="absolute -bottom-0.5 -right-0.5 h-2.5 w-2.5 rounded-full border-2 border-[var(--color-surface-alt)] bg-green-500" />
                </span>
                <div>
                  <p className="text-sm font-semibold text-[var(--color-primary)]">{member.name}</p>
                  <p className="text-xs text-[var(--color-primary)]/50">
                    {member.school ? member.school : "Online now"}
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => openChallengePicker(member)}
                className="rounded-full bg-gold px-4 py-1.5 text-xs font-semibold text-navy transition-colors hover:brightness-105"
              >
                Challenge
              </button>
            </div>
          ))
        )}
      </div>

      {challengeTarget && (
        <SubjectSheet
          title={`Challenge ${challengeTarget.name} in…`}
          subjects={subjects}
          disabled={sending}
          onCancel={() => setChallengeTarget(null)}
          onPick={sendChallengeTo}
        />
      )}

      {waitingChallengeId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
          <div className="w-full max-w-sm rounded-2xl bg-[var(--color-surface-alt)] p-6 text-center shadow-xl">
            <p className="text-sm font-semibold text-[var(--color-primary)]">
              Waiting for {waitingOpponent}…
            </p>
            <p className="mt-2 text-xs text-[var(--color-primary)]/60">
              The duel starts as soon as they accept.
            </p>
            <button
              type="button"
              onClick={cancelWaiting}
              className="mt-5 rounded-full border border-[var(--color-border)] px-4 py-2 text-xs font-semibold text-[var(--color-primary)]"
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function SubjectSheet({
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
