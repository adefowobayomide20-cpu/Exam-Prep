"use client";

import { collection, doc, getDoc, onSnapshot, setDoc } from "firebase/firestore";
import { httpsCallable } from "firebase/functions";
import { useEffect, useState } from "react";
import { db, functions } from "@/lib/firebase";

/**
 * Minimal friends system — just enough to support a "Friends rank" on the
 * leaderboard (see leaderboard.ts). Explicitly NOT the full social
 * feed/follow system from the larger feature wishlist: no activity posts,
 * no "Sarah completed 50 questions today"-style social proof. Out of scope.
 *
 * SIMPLIFICATION: adding a friend is one-directional — adding B via B's
 * code writes only `users/{A}/friends/{B}`, not the reverse. Mutuality
 * isn't required for "rank among people I've added" purposes. See
 * functions/friends.js for the matching backend note.
 *
 * CROSS-USER READS ARE BLOCKED BY firestore.rules (repo root, not
 * modified): `users/{userId}` only allows `request.auth.uid == userId` to
 * read, for both a direct `getDoc` by another uid AND a
 * `where('friendCode', '==', code)` query (Firestore evaluates rules
 * per-matched-doc, so any doc that isn't the caller's own is rejected).
 * That blocks BOTH (a) looking up who owns a friend code, and (b) live
 * client-side joining of a friend's displayName/avatarUrl/xp once added.
 * Both are therefore handled server-side via onCall Cloud Functions
 * (functions/friends.js: `addFriendByCode`, `refreshFriendsData`) using the
 * Admin SDK, which bypasses these rules — the documented, sanctioned
 * workaround for this exact situation. Friend-CODE *creation*
 * (`getOrCreateFriendCode`) only ever touches the caller's own doc, so that
 * one stays a plain client Firestore call, no function needed.
 */

const FRIEND_CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // excludes O/0/I/1 to avoid visual ambiguity

function generateFriendCode(length = 6): string {
  let code = "";
  for (let i = 0; i < length; i += 1) {
    code += FRIEND_CODE_CHARS[Math.floor(Math.random() * FRIEND_CODE_CHARS.length)];
  }
  return code;
}

/**
 * Returns the user's existing friend code, generating and persisting one
 * (client-generated-once-and-persisted, matching this system's existing
 * client-trust model — same as gamification.ts's flat xp/streak fields) if
 * they don't have one yet. Collision risk across the whole user base isn't
 * checked (that would require the blocked cross-user query described
 * above) — acceptable at this scale for a 6-char, 33-symbol alphabet
 * (~1.4 billion combinations).
 */
export async function getOrCreateFriendCode(uid: string): Promise<string> {
  const userRef = doc(db, "users", uid);
  const snapshot = await getDoc(userRef);
  const existing = snapshot.data()?.friendCode;
  if (typeof existing === "string" && existing) return existing;

  const code = generateFriendCode();
  await setDoc(userRef, { friendCode: code }, { merge: true });
  return code;
}

export type AddFriendResult =
  | { ok: true }
  | { ok: false; reason: "not-found" | "self" | "already-added" };

const addFriendByCodeCallable = httpsCallable<{ code: string }, AddFriendResult>(
  functions,
  "addFriendByCode",
);
const refreshFriendsDataCallable = httpsCallable<Record<string, never>, { ok: boolean; updated: number }>(
  functions,
  "refreshFriendsData",
);

/**
 * Adds a friend by their friend code, via the `addFriendByCode` onCall
 * function (see module doc for why this can't be a direct client query).
 * `uid` is accepted to match the documented contract, but the actual
 * lookup is scoped server-side to the caller's auth token — the two must
 * match for a signed-in user anyway.
 */
export async function addFriendByCode(uid: string, code: string): Promise<AddFriendResult> {
  void uid;
  const trimmed = code.trim().toUpperCase();
  if (!trimmed) return { ok: false, reason: "not-found" };
  const result = await addFriendByCodeCallable({ code: trimmed });
  return result.data;
}

export interface FriendEntry {
  uid: string;
  displayName: string | null;
  avatarUrl: string | null;
  xp: number;
}

/**
 * Live list of friends this user has added (onSnapshot on
 * `users/{uid}/friends`, allowed under the existing per-user subcollection
 * rule), with displayName/avatarUrl/xp joined from the denormalized
 * snapshot each friend doc carries (see module doc — live cross-user reads
 * are blocked, so these fields can go stale between refreshes). On mount,
 * fires a best-effort call to `refreshFriendsData` to resync those
 * snapshots before rendering settles; failures are swallowed since the
 * list still renders from whatever's cached.
 *
 * Returns `null` while signed-out or before the first snapshot resolves.
 */
export function useFriendsList(uid: string | null): FriendEntry[] | null {
  const [entries, setEntries] = useState<FriendEntry[] | null>(null);

  useEffect(() => {
    if (!uid) return;
    refreshFriendsDataCallable({}).catch(() => {
      // Best-effort — a failed resync just means slightly staler xp than usual.
    });
    return onSnapshot(collection(db, "users", uid, "friends"), (snapshot) => {
      const list: FriendEntry[] = snapshot.docs.map((friendDoc) => {
        const data = friendDoc.data();
        return {
          uid: friendDoc.id,
          displayName: typeof data.displayName === "string" ? data.displayName : null,
          avatarUrl: typeof data.avatarUrl === "string" ? data.avatarUrl : null,
          xp: typeof data.xp === "number" ? data.xp : 0,
        };
      });
      setEntries(list);
    });
  }, [uid]);

  return uid ? entries : null;
}

/**
 * The signed-in user's 1-based rank among their own added friends (plus
 * themselves) by xp — computed entirely client-side from the small friends
 * list (no backend call needed for the ranking itself, only for keeping
 * the friend xp snapshots fresh via useFriendsList above). Ties resolve to
 * the first matching position (simple, not specified further).
 *
 * Returns `null` while loading, signed-out, or once loaded if the user has
 * no friends added yet (per the RankInfo.friendsRank contract in
 * leaderboard.ts).
 */
export function useFriendsRank(uid: string | null): number | null {
  const friends = useFriendsList(uid);
  const [ownXp, setOwnXp] = useState<number | null>(null);

  useEffect(() => {
    if (!uid) return;
    return onSnapshot(doc(db, "users", uid), (snapshot) => {
      const xp = snapshot.data()?.xp;
      setOwnXp(typeof xp === "number" ? xp : 0);
    });
  }, [uid]);

  if (!uid || friends === null || ownXp === null) return null;
  if (friends.length === 0) return null;

  const allXp = [...friends.map((f) => f.xp), ownXp].sort((a, b) => b - a);
  return allXp.indexOf(ownXp) + 1;
}
