"use client";

import { doc, onSnapshot, setDoc } from "firebase/firestore";
import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { useFriendsRank } from "@/lib/friends";

/**
 * Leaderboard ranks — reads server-computed `nigeriaRank`/`stateRank`/
 * `state` off `users/{uid}` (written by the `computeLeaderboardRanks`
 * scheduled Cloud Function, functions/leaderboard.js, every 6 hours) and
 * combines them with the client-computed `friendsRank` from friends.ts.
 */
export interface RankInfo {
  /** 1-based position by cumulative xp across all users. `null` if the scheduled job hasn't ranked this user yet (e.g. brand-new account, or it just hasn't run since signup). */
  nigeriaRank: number | null;
  /** 1-based position by xp within this user's `state`. `null` if not yet computed OR the user has no `state` set. */
  stateRank: number | null;
  /** 1-based position by xp among this user's added friends (+ self). `null` if the user has no friends added yet. */
  friendsRank: number | null;
  /** The user's chosen Nigerian state, or `null` if unset (see `setUserState`). */
  state: string | null;
}

interface ServerRankFields {
  nigeriaRank: number | null;
  stateRank: number | null;
  state: string | null;
}

/**
 * Live-reads the signed-in user's rank info. Returns `null` while
 * loading/signed-out (matches useGamification/useAvatarUrl's convention).
 */
export function useRankInfo(uid: string | null): RankInfo | null {
  const [server, setServer] = useState<ServerRankFields | null>(null);
  const friendsRank = useFriendsRank(uid);

  useEffect(() => {
    if (!uid) return;
    return onSnapshot(doc(db, "users", uid), (snapshot) => {
      const data = snapshot.data();
      setServer({
        nigeriaRank: typeof data?.nigeriaRank === "number" ? data.nigeriaRank : null,
        stateRank: typeof data?.stateRank === "number" ? data.stateRank : null,
        state: typeof data?.state === "string" && data.state ? data.state : null,
      });
    });
  }, [uid]);

  if (!uid || server === null) return null;
  return { ...server, friendsRank };
}

/** Lets the user pick/change their Nigerian state (feeds `stateRank` on the next scheduled ranking run). A plain merge write to the user's own doc — allowed under the existing firestore.rules (only premium/aiUsage/bonusUses are server-only). */
export function setUserState(uid: string, state: string): Promise<void> {
  return setDoc(doc(db, "users", uid), { state }, { merge: true });
}

/** All 36 Nigerian states + the Federal Capital Territory, for a state picker dropdown. */
export const NIGERIAN_STATES: string[] = [
  "Abia",
  "Adamawa",
  "Akwa Ibom",
  "Anambra",
  "Bauchi",
  "Bayelsa",
  "Benue",
  "Borno",
  "Cross River",
  "Delta",
  "Ebonyi",
  "Edo",
  "Ekiti",
  "Enugu",
  "Federal Capital Territory (Abuja)",
  "Gombe",
  "Imo",
  "Jigawa",
  "Kaduna",
  "Kano",
  "Katsina",
  "Kebbi",
  "Kogi",
  "Kwara",
  "Lagos",
  "Nasarawa",
  "Niger",
  "Ogun",
  "Ondo",
  "Osun",
  "Oyo",
  "Plateau",
  "Rivers",
  "Sokoto",
  "Taraba",
  "Yobe",
  "Zamfara",
];
