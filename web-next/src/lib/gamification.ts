import {
  arrayUnion,
  collection,
  doc,
  getDocs,
  limit,
  orderBy,
  query,
  runTransaction,
  updateDoc,
} from "firebase/firestore";
import { db } from "@/lib/firebase";

/**
 * Daily Streak + XP + Levels + Badges — the shared gamification core for
 * web-next. Every "qualifying activity" completion point (MCQ practice
 * finish, Theory answer graded, duel finish, AI Tutor response) calls one
 * of the `award*Xp` functions below, which updates `users/{uid}` in a
 * single Firestore transaction (xp, streakCount, longestStreak,
 * lastActivityDate, duelWins, badges) and then — for MCQ completions only —
 * makes a best-effort follow-up read of quizAttempts to evaluate
 * subject-mastery badges.
 *
 * CLIENT-TRUST LIMITATION (matches an existing, deliberate decision in this
 * codebase, not a new gap): `xp`, `streakCount`, `longestStreak`,
 * `lastActivityDate`, `duelWins`, and `badges` are plain fields on
 * `users/{userId}`, which firestore.rules (repo root) allows the owning
 * user to read/write freely — only `premium`/`aiUsage`/`bonusUses` are
 * server-only. A determined user could inflate these via devtools, exactly
 * like the pre-existing client-written `quizAttempts` subcollection. No
 * Cloud Function validation is added here (out of scope for this MVP).
 *
 * SCHEMA NOTE: the Flutter app already has a *different* streak shape on
 * this same `users/{uid}` doc — a nested `streak: { currentStreak,
 * lastActiveDate }` map (see functions/streak_push.js, read-only reference
 * here). This module intentionally uses the flat field names specified for
 * this web feature (`streakCount`, `longestStreak`, `lastActivityDate`)
 * rather than reusing/renaming the Flutter shape, since unifying the two
 * schemas (and therefore functions/streak_push.js's daily nudge job) is out
 * of scope for this task. Net effect: a streak built by practicing on the
 * web won't currently feed the mobile app's streak-nudge push notification,
 * and vice versa — worth reconciling in a future pass, not this one.
 */

// ---------------------------------------------------------------------------
// Timezone / date-key helpers — mirrors the Africa/Lagos convention and
// yyyy-MM-dd `dateKey` format used server-side in functions/reminders.js,
// functions/streak_push.js, and functions/entitlements.js (read-only
// reference, not modified).
// ---------------------------------------------------------------------------

const TIMEZONE = "Africa/Lagos";

/** Exported so other Africa/Lagos-calendar-day features (e.g.
 * src/lib/lifelines.ts's daily lifeline cap) can reuse the exact same
 * "today" definition rather than reimplementing timezone math. */
export function nowInLagos(): Date {
  return new Date(new Date().toLocaleString("en-US", { timeZone: TIMEZONE }));
}

/** yyyy-MM-dd for a given Date, in whatever timezone that Date's fields
 * already reflect (pass `nowInLagos()` for the Lagos calendar day).
 * Exported for reuse — see nowInLagos() note above. */
export function dateKey(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}

function yesterdayKeyOf(today: Date): string {
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  return dateKey(yesterday);
}

// ---------------------------------------------------------------------------
// XP point values — deliberately simple, not perfectly balanced. Documented
// here as the single source of truth for every award site.
// ---------------------------------------------------------------------------

/** MCQ practice test: flat completion XP, regardless of score. */
export const XP_MCQ_BASE = 10;
/** MCQ practice test: extra XP scaled by accuracy (0 correct = +0, all correct = +20). */
export const XP_MCQ_ACCURACY_MAX = 20;
/** One graded Theory answer (correct or not — attempting and getting feedback is what's rewarded). */
export const XP_THEORY_ANSWER = 15;
/** Winning a duel: base + speed/competition bonus. Losing/tying a duel earns 0 XP (but still counts toward the daily streak — see awardDuelCompletionXp). */
export const XP_DUEL_WIN_BASE = 25;
export const XP_DUEL_WIN_BONUS = 15;
/** One AI Tutor (Snap & Solve) response. Flat, not metered further — the `solveQuestion` Cloud Function's own daily usage cap already bounds how many of these a student can rack up per day. */
export const XP_TUTOR_RESPONSE = 5;
/** Awarded once per calendar day, alongside the first qualifying activity of that day (see below) — not on a bare page visit, to avoid an extra Firestore write on every load. */
export const XP_DAILY_LOGIN = 5;

// ---------------------------------------------------------------------------
// Levels — derived purely from cumulative XP at render time, never stored.
// ---------------------------------------------------------------------------

export interface LevelTier {
  level: number;
  name: string;
}

/** Milestone tier names from the product ask. Levels between milestones inherit the most recent milestone's name (e.g. level 7 is still "Scholar"). Level is capped at 50 ("Legend") — XP earned beyond the level-50 threshold just keeps the "Legend" tier. */
const LEVEL_TIERS: LevelTier[] = [
  { level: 1, name: "Fresher" },
  { level: 5, name: "Scholar" },
  { level: 10, name: "Genius" },
  { level: 20, name: "Professor" },
  { level: 35, name: "Academic Beast" },
  { level: 50, name: "Legend" },
];

export const MAX_LEVEL = 50;

/** Cumulative XP required to REACH a given level (level 1 requires 0 XP). Increasing per-level requirement via `100 * (level - 1)^1.5`, rounded — a simple, reasonable curve, not exactly balanced. */
export function xpForLevel(level: number): number {
  const clamped = Math.max(1, Math.min(level, MAX_LEVEL));
  return Math.round(100 * Math.pow(clamped - 1, 1.5));
}

/** Derives the current level (1..50) from cumulative XP. */
export function levelForXp(xp: number): number {
  let level = 1;
  for (let candidate = 2; candidate <= MAX_LEVEL; candidate += 1) {
    if (xp < xpForLevel(candidate)) break;
    level = candidate;
  }
  return level;
}

/** Tier name for a given level — the most recent milestone at or below it. */
export function tierNameForLevel(level: number): string {
  let name = LEVEL_TIERS[0].name;
  for (const tier of LEVEL_TIERS) {
    if (level >= tier.level) name = tier.name;
  }
  return name;
}

/** Progress toward the next level, for a simple width-percentage bar. At level 50 ("Legend"), returns `progress: 1` (bar full, no further level to chase). */
export function levelProgress(xp: number): {
  level: number;
  tierName: string;
  currentLevelXp: number;
  nextLevelXp: number | null;
  progress: number;
} {
  const level = levelForXp(xp);
  const tierName = tierNameForLevel(level);
  const currentLevelXp = xpForLevel(level);
  if (level >= MAX_LEVEL) {
    return { level, tierName, currentLevelXp, nextLevelXp: null, progress: 1 };
  }
  const nextLevelXp = xpForLevel(level + 1);
  const span = nextLevelXp - currentLevelXp;
  const progress = span <= 0 ? 1 : Math.min(1, Math.max(0, (xp - currentLevelXp) / span));
  return { level, tierName, currentLevelXp, nextLevelXp, progress };
}

// ---------------------------------------------------------------------------
// Badges — small starter set, rule-evaluated from data that already exists.
// ---------------------------------------------------------------------------

export interface BadgeDef {
  id: string;
  name: string;
  description: string;
  icon: string;
}

/** Correct-answer threshold (within the most recent 20 tracked attempts — the same sample use-quiz-attempts.ts already fetches, not a full-history rollup) for a subject-mastery badge. */
const SUBJECT_MASTERY_THRESHOLD = 50;

export const BADGES: BadgeDef[] = [
  { id: "streak-7", name: "7-Day Streak", description: "Reach a 7-day study streak.", icon: "🔥" },
  { id: "streak-30", name: "30-Day Streak", description: "Reach a 30-day study streak.", icon: "🏅" },
  { id: "first-duel-win", name: "First Duel Win", description: "Win your first live duel.", icon: "⚔️" },
  {
    id: "mathematics-wizard",
    name: "Mathematics Wizard",
    description: `Answer ${SUBJECT_MASTERY_THRESHOLD}+ Mathematics questions correctly.`,
    icon: "🧮",
  },
  {
    id: "english-ace",
    name: "English Language Ace",
    description: `Answer ${SUBJECT_MASTERY_THRESHOLD}+ English Language questions correctly.`,
    icon: "📚",
  },
  {
    id: "biology-buff",
    name: "Biology Buff",
    description: `Answer ${SUBJECT_MASTERY_THRESHOLD}+ Biology questions correctly.`,
    icon: "🧬",
  },
];

/** Subject-mastery badge id -> substring to match against QuizAttempt.subjectName. */
const SUBJECT_BADGE_MATCH: { badgeId: string; subjectNameIncludes: string }[] = [
  { badgeId: "mathematics-wizard", subjectNameIncludes: "Mathematics" },
  { badgeId: "english-ace", subjectNameIncludes: "English" },
  { badgeId: "biology-buff", subjectNameIncludes: "Biology" },
];

export function badgeDef(id: string): BadgeDef | undefined {
  return BADGES.find((b) => b.id === id);
}

// ---------------------------------------------------------------------------
// Core transactional update — streak + XP + streak/duel badges in one write.
// ---------------------------------------------------------------------------

/**
 * COINS (the one, deliberately isolated addition to this shared file — see
 * project notes): a `coins` field on `users/{uid}`, awarded 1:1 with xp at
 * every one of the same award sites below (MCQ, Theory, duel win, tutor
 * usage, daily login) — whatever xpDelta a call ends up applying (including
 * the daily-login bonus folded into it), the same amount is added to
 * `coins` in the same transaction. No separate `awardCoins` export: coins
 * are folded directly into `applyActivity` below so they can never drift
 * out of sync with xp. This does NOT touch xp/streak/level/badge logic —
 * purely additive. Ratio (1:1) is intentionally simple, not balanced
 * against any planned coin-spend feature; revisit once coins have a spend
 * sink.
 */

interface ActivityOptions {
  /** XP to add this call (before any daily-login bonus). Coins are awarded at the same 1:1 rate — see COINS note above. */
  xpDelta: number;
  /** Whether this activity type counts toward the daily streak (MCQ practice, Theory, duel finish — NOT Tutor use). */
  countsForStreak: boolean;
  /** Whether this specific call represents a duel win (increments `duelWins`, may unlock "First Duel Win"). */
  duelWin?: boolean;
}

async function applyActivity(uid: string, options: ActivityOptions): Promise<void> {
  const userRef = doc(db, "users", uid);
  await runTransaction(db, async (transaction) => {
    const snapshot = await transaction.get(userRef);
    const data = snapshot.data() ?? {};

    const currentXp = typeof data.xp === "number" ? data.xp : 0;
    const currentCoins = typeof data.coins === "number" ? data.coins : 0;
    let streakCount = typeof data.streakCount === "number" ? data.streakCount : 0;
    let longestStreak = typeof data.longestStreak === "number" ? data.longestStreak : 0;
    let lastActivityDate = typeof data.lastActivityDate === "string" ? data.lastActivityDate : null;
    let duelWins = typeof data.duelWins === "number" ? data.duelWins : 0;
    const badges: string[] = Array.isArray(data.badges) ? data.badges : [];

    let xpDelta = options.xpDelta;

    if (options.countsForStreak) {
      const today = dateKey(nowInLagos());
      if (lastActivityDate !== today) {
        // First qualifying activity of the (Lagos) calendar day: advance the
        // streak and award the once-per-day login bonus alongside it.
        const yesterday = yesterdayKeyOf(nowInLagos());
        streakCount = lastActivityDate === yesterday ? streakCount + 1 : 1;
        longestStreak = Math.max(longestStreak, streakCount);
        lastActivityDate = today;
        xpDelta += XP_DAILY_LOGIN;
      }
      // Else: already logged a qualifying activity today — no streak change,
      // no second daily-login bonus, but this call's base xpDelta still applies.
    }

    if (options.duelWin) {
      duelWins += 1;
    }

    const newXp = currentXp + xpDelta;
    // Coins earned = xp earned, 1:1, in the same transaction — see COINS note above.
    const newCoins = currentCoins + xpDelta;

    const newBadges = new Set(badges);
    if (longestStreak >= 7) newBadges.add("streak-7");
    if (longestStreak >= 30) newBadges.add("streak-30");
    if (duelWins >= 1) newBadges.add("first-duel-win");

    transaction.set(
      userRef,
      {
        xp: newXp,
        coins: newCoins,
        streakCount,
        longestStreak,
        lastActivityDate,
        duelWins,
        badges: Array.from(newBadges),
      },
      { merge: true },
    );
  });
}

// ---------------------------------------------------------------------------
// Subject-mastery badges — best-effort follow-up read after an MCQ
// completion (outside the transaction above: aggregating a subcollection
// query isn't a single-document transaction read, so this mirrors
// use-quiz-attempts.ts's plain getDocs pattern and merges any newly-earned
// badge ids with arrayUnion).
// ---------------------------------------------------------------------------

const RECENT_ATTEMPTS_LIMIT = 20;

async function evaluateSubjectMasteryBadges(uid: string): Promise<void> {
  const attemptsQuery = query(
    collection(db, "users", uid, "quizAttempts"),
    orderBy("completedAt", "desc"),
    limit(RECENT_ATTEMPTS_LIMIT),
  );
  const snapshot = await getDocs(attemptsQuery);
  const correctBySubjectName = new Map<string, number>();
  for (const docSnap of snapshot.docs) {
    const data = docSnap.data() as { subjectName?: string; score?: number };
    if (!data.subjectName || typeof data.score !== "number") continue;
    correctBySubjectName.set(
      data.subjectName,
      (correctBySubjectName.get(data.subjectName) ?? 0) + data.score,
    );
  }

  const earned: string[] = [];
  for (const { badgeId, subjectNameIncludes } of SUBJECT_BADGE_MATCH) {
    let total = 0;
    for (const [subjectName, correct] of correctBySubjectName) {
      if (subjectName.includes(subjectNameIncludes)) total += correct;
    }
    if (total >= SUBJECT_MASTERY_THRESHOLD) earned.push(badgeId);
  }

  if (earned.length === 0) return;
  await updateDoc(doc(db, "users", uid), { badges: arrayUnion(...earned) });
}

// ---------------------------------------------------------------------------
// Public award functions — one per qualifying-activity completion point.
// All are best-effort/fire-and-forget from the caller's perspective: a
// failed gamification write shouldn't block the student from seeing their
// result, so callers should `.catch()` and swallow errors (see wiring in
// QuizSession.tsx / TheorySession.tsx / DuelSession.tsx / TutorChat.tsx).
// ---------------------------------------------------------------------------

/** MCQ practice test finished. `correct`/`total` drive the accuracy bonus; also triggers a best-effort subject-mastery badge check. */
export async function awardMcqCompletionXp(uid: string, correct: number, total: number): Promise<void> {
  const accuracy = total > 0 ? correct / total : 0;
  const xpDelta = XP_MCQ_BASE + Math.round(XP_MCQ_ACCURACY_MAX * accuracy);
  await applyActivity(uid, { xpDelta, countsForStreak: true });
  await evaluateSubjectMasteryBadges(uid).catch(() => {
    // Best-effort — badge detection failing shouldn't surface as an error.
  });
}

/** One Theory question graded (called per graded answer, not once per multi-question "session" — a student who answers 5 Theory questions in a row earns Theory XP 5 times, which keeps this a simple per-completion award like the MCQ/duel cases rather than needing extra session-boundary bookkeeping). */
export async function awardTheoryCompletionXp(uid: string): Promise<void> {
  await applyActivity(uid, { xpDelta: XP_THEORY_ANSWER, countsForStreak: true });
}

/** A duel finished for this player. Streak always advances (finishing a duel — win or lose — is a qualifying activity), but XP/duelWins/the "First Duel Win" badge only apply when `won` is true. */
export async function awardDuelCompletionXp(uid: string, won: boolean): Promise<void> {
  const xpDelta = won ? XP_DUEL_WIN_BASE + XP_DUEL_WIN_BONUS : 0;
  await applyActivity(uid, { xpDelta, countsForStreak: true, duelWin: won });
}

/** One successful AI Tutor (Snap & Solve) response. Does NOT count toward the daily streak (only MCQ/Theory/duel completions do, per spec — "not just visiting the site" extends to "not just asking the tutor one thing" for streak purposes, though it's still small flat XP). */
export async function awardTutorUsageXp(uid: string): Promise<void> {
  await applyActivity(uid, { xpDelta: XP_TUTOR_RESPONSE, countsForStreak: false });
}
