import {
  collection,
  doc,
  deleteDoc,
  getDoc,
  increment,
  onSnapshot,
  query,
  runTransaction,
  setDoc,
  updateDoc,
  where,
  type Unsubscribe,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import type { QuizQuestionData } from "@/lib/exam-content";
import type { ChallengeDoc, ChallengeStatus, DuelDoc, DuelStatus, LobbyPresenceDoc } from "@/lib/duel-types";

/**
 * Firestore access for duels/lobbies/challenges — the web mirror of
 * lib/data/lobby_service.dart and lib/data/duel_service.dart. Every write
 * shape here is chosen to satisfy the existing firestore.rules (repo root)
 * unchanged; see duel-types.ts for the field-level mapping notes.
 */

export class DuelError extends Error {}

/** A member's heartbeat older than this is treated as offline (matches LobbyService.onlineWindow). */
export const ONLINE_WINDOW_MS = 45_000;
export const HEARTBEAT_INTERVAL_MS = 20_000;

// Single global "room" — everyone signed in shows up here, regardless of
// school. `firestore.rules`' `lobbies/{school}/members/{uid}` rule treats
// the middle segment as an opaque wildcard, so using the fixed literal
// "global" here satisfies the existing rule unchanged (no rules edit
// needed) while giving every student the same shared presence collection
// instead of one partitioned per school.
function membersCollection() {
  return collection(db, "lobbies", "global", "members");
}

export async function heartbeat(uid: string, name: string, school: string | null): Promise<void> {
  const presence: LobbyPresenceDoc = { uid, name, school, lastActiveAt: new Date().toISOString() };
  await setDoc(doc(membersCollection(), uid), presence);
}

export async function leaveLobby(uid: string): Promise<void> {
  await deleteDoc(doc(membersCollection(), uid));
}

export function watchOnline(
  selfUid: string,
  callback: (members: LobbyPresenceDoc[]) => void,
): Unsubscribe {
  return onSnapshot(membersCollection(), (snapshot) => {
    const cutoff = Date.now() - ONLINE_WINDOW_MS;
    const members = snapshot.docs
      .map((d) => d.data() as LobbyPresenceDoc)
      .filter((m) => m.uid !== selfUid && new Date(m.lastActiveAt).getTime() > cutoff);
    callback(members);
  });
}

const challengesCollection = () => collection(db, "challenges");

export async function sendChallenge(input: {
  fromUid: string;
  fromName: string;
  toUid: string;
  toName: string;
  school: string;
  subject: string;
}): Promise<string> {
  const ref = doc(challengesCollection());
  const challenge: ChallengeDoc = {
    id: ref.id,
    fromUid: input.fromUid,
    fromName: input.fromName,
    toUid: input.toUid,
    toName: input.toName,
    school: input.school,
    subject: input.subject,
    examCategory: "jamb",
    status: "pending",
    createdAt: new Date().toISOString(),
    duelId: null,
  };
  await setDoc(ref, challenge);
  return ref.id;
}

export function watchIncomingChallenges(
  uid: string,
  callback: (challenges: ChallengeDoc[]) => void,
): Unsubscribe {
  const q = query(challengesCollection(), where("toUid", "==", uid), where("status", "==", "pending"));
  return onSnapshot(q, (snapshot) => {
    const challenges = snapshot.docs
      .map((d) => d.data() as ChallengeDoc)
      .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    callback(challenges);
  });
}

export function watchChallenge(
  challengeId: string,
  callback: (challenge: ChallengeDoc | null) => void,
): Unsubscribe {
  return onSnapshot(doc(challengesCollection(), challengeId), (snapshot) => {
    callback(snapshot.exists() ? (snapshot.data() as ChallengeDoc) : null);
  });
}

export async function respondToChallenge(
  challengeId: string,
  status: ChallengeStatus,
  duelId?: string,
): Promise<void> {
  await updateDoc(doc(challengesCollection(), challengeId), {
    status,
    ...(duelId ? { duelId } : {}),
  });
}

const CODE_CHARS = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
const CODE_LENGTH = 6;

function generateCode(): string {
  let code = "";
  for (let i = 0; i < CODE_LENGTH; i += 1) {
    code += CODE_CHARS[Math.floor(Math.random() * CODE_CHARS.length)];
  }
  return code;
}

const duelsCollection = () => collection(db, "duels");

function baseDuelFields(input: {
  code: string;
  subject: string;
  subjectName: string;
  questions: QuizQuestionData[];
  durationSeconds: number;
  hostUid: string;
  hostName: string;
}) {
  return {
    id: input.code,
    subject: input.subject,
    subjectName: input.subjectName,
    questions: input.questions,
    durationSeconds: input.durationSeconds,
    createdAt: new Date().toISOString(),
    hostUid: input.hostUid,
    hostName: input.hostName,
    hostAnswered: 0,
    hostCorrect: 0,
    hostPoints: 0,
    hostFinishedAt: null,
    hostPenaltySeconds: 0,
  };
}

/** Creates a "waiting for a guest" duel a code can be shared for (join-by-code flow). */
export async function createDuel(input: {
  subject: string;
  subjectName: string;
  questions: QuizQuestionData[];
  durationSeconds: number;
  hostUid: string;
  hostName: string;
}): Promise<DuelDoc> {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const code = generateCode();
    const ref = doc(duelsCollection(), code);
    const existing = await getDoc(ref);
    if (existing.exists()) continue;

    const duel: DuelDoc = {
      ...baseDuelFields({ ...input, code }),
      status: "waiting",
      startedAt: null,
      // Explicitly null (not omitted) so security-rule checks like
      // `resource.data.guestUid == null` on later updates don't throw on a
      // missing field — Firestore rules error on accessing an absent key.
      guestUid: null,
      guestName: null,
      guestAnswered: 0,
      guestCorrect: 0,
      guestPoints: 0,
      guestFinishedAt: null,
      guestPenaltySeconds: 0,
    };
    await setDoc(ref, duel);
    return duel;
  }
  throw new DuelError("Could not create a duel right now. Try again.");
}

/** Creates a duel with both players already seated — used when a lobby challenge is accepted. */
export async function createDuelDirect(input: {
  subject: string;
  subjectName: string;
  questions: QuizQuestionData[];
  durationSeconds: number;
  hostUid: string;
  hostName: string;
  guestUid: string;
  guestName: string;
}): Promise<DuelDoc> {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const code = generateCode();
    const ref = doc(duelsCollection(), code);
    const existing = await getDoc(ref);
    if (existing.exists()) continue;

    const now = new Date().toISOString();
    const duel: DuelDoc = {
      ...baseDuelFields({ ...input, code }),
      status: "active",
      startedAt: now,
      guestUid: input.guestUid,
      guestName: input.guestName,
      guestAnswered: 0,
      guestCorrect: 0,
      guestPoints: 0,
      guestFinishedAt: null,
      guestPenaltySeconds: 0,
    };
    await setDoc(ref, duel);
    return duel;
  }
  throw new DuelError("Could not create a duel right now. Try again.");
}

export function watchDuel(code: string, callback: (duel: DuelDoc | null) => void): Unsubscribe {
  return onSnapshot(doc(duelsCollection(), code.toUpperCase()), (snapshot) => {
    callback(snapshot.exists() ? (snapshot.data() as DuelDoc) : null);
  });
}

export async function joinDuel(code: string, uid: string, name: string): Promise<void> {
  const ref = doc(duelsCollection(), code.toUpperCase());
  await runTransaction(db, async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists()) {
      throw new DuelError("No duel found with that code.");
    }
    const duel = snapshot.data() as DuelDoc;
    if (duel.hostUid === uid) {
      throw new DuelError("You can't join your own duel.");
    }
    if (duel.guestUid) {
      throw new DuelError("This duel already has two players.");
    }
    transaction.update(ref, {
      guestUid: uid,
      guestName: name,
      status: "active" satisfies DuelStatus,
      startedAt: new Date().toISOString(),
    });
  });
}

export async function recordProgress(input: {
  duelId: string;
  isHost: boolean;
  answered: number;
  correct: number;
  points: number;
}): Promise<void> {
  const prefix = input.isHost ? "host" : "guest";
  await updateDoc(doc(duelsCollection(), input.duelId), {
    [`${prefix}Answered`]: input.answered,
    [`${prefix}Correct`]: input.correct,
    [`${prefix}Points`]: input.points,
  });
}

/** Default "Freeze" penalty, in seconds, per use — mirrors
 * `_freezeSeconds` in the Flutter app's duel_session_page.dart. */
export const FREEZE_SECONDS = 10;

/**
 * "Freeze" lifeline: knocks `seconds` off the OPPONENT's remaining time.
 * `isHost` refers to the CALLER (the student using the lifeline) — the
 * penalty always lands on the other side's `*PenaltySeconds` field, via a
 * plain increment (no transaction needed — concurrent freezes should just
 * add up, same as duel_service.dart's `freezeOpponent`). Allowed under the
 * existing firestore.rules `duels/{duelId}` update rule unmodified: it
 * grants write access to the host or guest with no per-field restriction, so
 * writing the opponent's penalty field is fine for either side.
 */
export async function freezeOpponent(
  duelId: string,
  isHost: boolean,
  seconds: number = FREEZE_SECONDS,
): Promise<void> {
  const targetPrefix = isHost ? "guest" : "host";
  await updateDoc(doc(duelsCollection(), duelId), {
    [`${targetPrefix}PenaltySeconds`]: increment(seconds),
  });
}

/**
 * Called by WHICHEVER side's own countdown notices the shared timer has
 * run out — finalizes the ENTIRE duel (both sides), not just the caller's
 * own. Needed because a real opponent's tab can be backgrounded (mobile
 * browsers routinely throttle/suspend `setInterval` for hidden tabs), so
 * their own countdown effect may never fire to submit their side — leaving
 * the duel stuck showing "waiting for opponent" indefinitely even though
 * time is actually up. Since firestore.rules' `duels/{duelId}` update rule
 * grants either side write access to the WHOLE document (no per-field
 * restriction — see the `resource.data.hostUid == request.auth.uid ||
 * resource.data.guestUid == request.auth.uid` check), whichever side's timer
 * fires first can safely finalize both `*FinishedAt` fields and flip
 * `status` to "finished" directly, locking in each side's already-recorded
 * `*Answered`/`*Correct`/`*Points` (kept live via recordProgress on every
 * answer — nothing else needs to change here).
 */
export async function forceFinishDuel(duelId: string): Promise<void> {
  const ref = doc(duelsCollection(), duelId);
  await runTransaction(db, async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists()) return;
    const duel = snapshot.data() as DuelDoc;
    if (duel.status === "finished") return;
    const now = new Date().toISOString();
    transaction.update(ref, {
      hostFinishedAt: duel.hostFinishedAt ?? now,
      ...(duel.guestUid ? { guestFinishedAt: duel.guestFinishedAt ?? now } : {}),
      status: "finished" satisfies DuelStatus,
    });
  });
}

export async function finishDuel(duelId: string, isHost: boolean): Promise<void> {
  const ref = doc(duelsCollection(), duelId);
  await runTransaction(db, async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists()) return;
    const duel = snapshot.data() as DuelDoc;
    const prefix = isHost ? "host" : "guest";
    const update: Record<string, unknown> = { [`${prefix}FinishedAt`]: new Date().toISOString() };

    const otherFinished = isHost ? Boolean(duel.guestFinishedAt) : Boolean(duel.hostFinishedAt);
    if (otherFinished) {
      update.status = "finished" satisfies DuelStatus;
    }
    transaction.update(ref, update);
  });
}
