import type { QuizQuestionData } from "@/lib/exam-content";

/**
 * Duels/Lobby data shapes — must match `firestore.rules` (repo root, not
 * touched by this phase) field-for-field with the Flutter app's
 * lib/data/models/duel.dart, challenge.dart, and lobby_presence.dart, since
 * both clients read/write the same Firestore collections. Field names use
 * the same flat `hostX`/`guestX` prefixes (not nested objects) the rules
 * check via `request.resource.data.hostUid` etc.
 *
 *
 * `hostPenaltySeconds`/`guestPenaltySeconds` back the "Freeze" duel lifeline
 * (see duel-service.ts's `freezeOpponent`) — mirrors `duel.dart`'s
 * `penaltySeconds` field per side. Hint/50-50/Ask-a-Friend/Ask-Computer need
 * no server-side field at all (they're purely local UI state, reusing
 * src/lib/lifelines.ts for elimination + the shared daily-use cap), so
 * Freeze's penalty counters are the only lifeline-related addition to this
 * shared document shape.
 */

export type ChallengeStatus = "pending" | "accepted" | "declined" | "expired" | "failed";

export interface ChallengeDoc {
  id: string;
  fromUid: string;
  fromName: string;
  toUid: string;
  toName: string;
  school: string;
  /** Subject slug from src/content/questions/jamb/<slug>.json — duels always run over JAMB content (see duel-content.ts). */
  subject: string;
  examCategory: "jamb";
  status: ChallengeStatus;
  createdAt: string;
  duelId: string | null;
}

export type DuelStatus = "waiting" | "active" | "finished";

export interface DuelPlayerFields {
  uid: string;
  name: string;
  answered: number;
  correct: number;
  points: number;
  finishedAt: string | null;
  /** This side's own Freeze penalty, in seconds — how much time THEY'VE lost
   * to the opponent's Freeze uses (not seconds they've frozen off others). */
  penaltySeconds: number;
}

export interface DuelDoc {
  id: string;
  subject: string;
  subjectName: string;
  questions: QuizQuestionData[];
  durationSeconds: number;
  status: DuelStatus;
  createdAt: string;
  startedAt: string | null;
  hostUid: string;
  hostName: string;
  hostAnswered: number;
  hostCorrect: number;
  hostPoints: number;
  hostFinishedAt: string | null;
  /** Seconds knocked off the HOST's own remaining time by the GUEST using
   * Freeze against them (0 for new duels). See duel-service.ts's
   * `freezeOpponent` and DuelSession.tsx's countdown effect. */
  hostPenaltySeconds: number;
  guestUid: string | null;
  guestName: string | null;
  guestAnswered: number;
  guestCorrect: number;
  guestPoints: number;
  guestFinishedAt: string | null;
  /** Seconds knocked off the GUEST's own remaining time by the HOST using
   * Freeze against them (0 for new duels). */
  guestPenaltySeconds: number;
}

export function duelHost(duel: DuelDoc): DuelPlayerFields {
  return {
    uid: duel.hostUid,
    name: duel.hostName,
    answered: duel.hostAnswered,
    correct: duel.hostCorrect,
    points: duel.hostPoints,
    finishedAt: duel.hostFinishedAt,
    penaltySeconds: duel.hostPenaltySeconds ?? 0,
  };
}

export function duelGuest(duel: DuelDoc): DuelPlayerFields | null {
  if (!duel.guestUid) return null;
  return {
    uid: duel.guestUid,
    name: duel.guestName ?? "Opponent",
    answered: duel.guestAnswered,
    correct: duel.guestCorrect,
    points: duel.guestPoints,
    finishedAt: duel.guestFinishedAt,
    penaltySeconds: duel.guestPenaltySeconds ?? 0,
  };
}

export function isDuelHost(duel: DuelDoc, uid: string): boolean {
  return duel.hostUid === uid;
}

export function duelSelf(duel: DuelDoc, uid: string): DuelPlayerFields | null {
  if (isDuelHost(duel, uid)) return duelHost(duel);
  const guest = duelGuest(duel);
  return guest?.uid === uid ? guest : null;
}

export function duelOpponent(duel: DuelDoc, uid: string): DuelPlayerFields | null {
  return isDuelHost(duel, uid) ? duelGuest(duel) : duelHost(duel);
}

export interface LobbyPresenceDoc {
  uid: string;
  name: string;
  /**
   * Optional school tag, sourced from the user's own `targetUniversity`
   * profile field (see ProfileGoals.tsx) if they've set one — null if they
   * haven't. Everyone shows up in the online list regardless of whether
   * they've set this; it's a display tag plus an optional client-side
   * filter, never a gate on visibility (that used to be the case — the
   * lobby was previously partitioned into per-school "rooms" via
   * `lobbies/{school}/members`, which hid everyone not viewing the exact
   * same school room; that's been replaced with a single global list, see
   * duel-service.ts's `membersCollection()`).
   */
  school: string | null;
  lastActiveAt: string;
}

export interface PostJambSchool {
  name: string;
  shortName: string;
}

/** Mirrors lib/features/exam/post_jamb_schools.dart's postJambSchools list — used only as the optional filter dropdown's options in the duel lobby (matched loosely against each member's freeform `school` tag), not tied to a stored user profile field of the same fixed shape. */
export const POST_JAMB_SCHOOLS: PostJambSchool[] = [
  { name: "University of Lagos", shortName: "UNILAG" },
  { name: "University of Ilorin", shortName: "UNILORIN" },
  { name: "University of Ibadan", shortName: "UI" },
  { name: "Obafemi Awolowo University", shortName: "OAU" },
  { name: "University of Benin", shortName: "UNIBEN" },
  { name: "University of Nigeria Nsukka (UNN)", shortName: "UNN" },
  { name: "Federal University of Technology Akure", shortName: "FUTA" },
  { name: "Ladoke Akintola University of Technology", shortName: "LAUTECH" },
];

export const DUEL_QUESTION_COUNT = 10;
export const DUEL_DURATION_SECONDS = 5 * 60;
