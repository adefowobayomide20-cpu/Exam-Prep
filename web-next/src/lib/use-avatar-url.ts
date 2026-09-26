"use client";

import { doc, onSnapshot } from "firebase/firestore";
import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";

/**
 * Live-reads `users/{uid}.avatarUrl` for the signed-in user, mirroring the
 * Flutter app's avatar field (see lib/data/app_data_store.dart's
 * `uploadAvatar`). Shared by every place that shows the profile
 * icon/avatar (HomeTopBar, BottomNav, ProfileView) so there's a single
 * Firestore listener pattern instead of three copies.
 *
 * Returns null when signed out or when the user has no avatar set yet —
 * callers should fall back to the generic person-icon SVG in that case.
 */
export function useAvatarUrl(): string | null {
  const { user } = useAuth();
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null);

  useEffect(() => {
    if (!user) return;
    return onSnapshot(doc(db, "users", user.uid), (snapshot) => {
      const url = snapshot.data()?.avatarUrl as string | undefined;
      setAvatarUrl(url ?? null);
    });
  }, [user]);

  // Ignore any stale URL from a previous session once signed out, rather
  // than resetting state synchronously inside the effect above (same
  // pattern as HomeTopBar's displayedUnreadCount).
  return user ? avatarUrl : null;
}
