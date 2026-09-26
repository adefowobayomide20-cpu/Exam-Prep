"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useRef, useState, type ChangeEvent, type FormEvent } from "react";
import {
  EmailAuthProvider,
  deleteUser,
  reauthenticateWithCredential,
  signOut,
  updatePassword,
  updateProfile,
  verifyBeforeUpdateEmail,
} from "firebase/auth";
import { doc, onSnapshot, setDoc } from "firebase/firestore";
import { getDownloadURL, ref, uploadBytes } from "firebase/storage";
import { auth, db, storage } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { authErrorMessage } from "@/lib/auth-errors";
import { storageErrorMessage } from "@/lib/storage-errors";
import { enablePushNotifications, getNotificationPermission } from "@/lib/push-notifications";
import { useAvatarUrl } from "@/lib/use-avatar-url";
import { useTheme, type ThemeMode } from "@/lib/theme-context";
import { useGamification } from "@/lib/use-gamification";
import { levelProgress } from "@/lib/gamification";
import GamificationProgress from "@/components/profile/GamificationProgress";
import ProfileGoals from "@/components/profile/ProfileGoals";
import TodaysProgress from "@/components/profile/TodaysProgress";
import PerformanceBreakdown from "@/components/profile/PerformanceBreakdown";
import WeakSubjectsCard from "@/components/profile/WeakSubjectsCard";
import RankCard from "@/components/profile/RankCard";
import CollapsibleSection from "@/components/profile/CollapsibleSection";

// Sanity ceiling on the RAW file picked/captured, well above any real photo,
// just to reject something absurd (e.g. an accidentally-selected video)
// before spending time decoding it. The real, storage.rules-matching 5MB cap
// is enforced AFTER resize (see resizeImageForAvatar below) — checking it on
// the raw file was the bug: modern phone cameras routinely produce 8-15MB+
// photos, so most real camera captures were rejected outright before ever
// reaching the compression step whose whole purpose is to make size a
// non-issue.
const MAX_RAW_AVATAR_BYTES = 25 * 1024 * 1024;
const MAX_AVATAR_BYTES = 5 * 1024 * 1024; // matches storage.rules' 5MB cap — enforced on the RESIZED blob

const AVATAR_MAX_DIMENSION = 512; // plenty for a ~48-64px display circle at any DPI
const AVATAR_JPEG_QUALITY = 0.82;

/** Thrown when the browser genuinely can't decode/re-encode the picked
 * image at all (corrupt file, an exotic format some browsers can't decode,
 * or the device is too memory-constrained even for the downscaled decode
 * below) — kept distinct from AvatarTooLargeError so the UI can tell the
 * user what actually happened instead of a misleading "still too large
 * after compression" when no compression happened at all. */
class AvatarDecodeError extends Error {}

/**
 * Downscales/re-encodes an image client-side before upload. Phone camera
 * photos are commonly 3-10MB at 12MP+ (e.g. 4000x3000), which as a decoded
 * RGBA bitmap is ~48MB of raw memory — BEFORE any scaling down happens.
 * The previous version of this function called plain `createImageBitmap
 * (file)` and only scaled the result down afterwards when drawing to a
 * canvas, so it paid that full 48MB decode cost regardless of the small
 * 512px target output — this was the actual cause of "low memory" upload
 * failures on weaker phones (reported this session), not the final file
 * size. The fix is to pass `resizeWidth` directly to createImageBitmap: it
 * tells the browser's native image decoder to downscale WHILE decoding
 * (JPEG decoders in particular can do this very cheaply via built-in DCT
 * downscaling), so the full-resolution bitmap is never materialized in
 * memory at all. `resizeHeight` is deliberately left unset so the browser
 * preserves aspect ratio automatically instead of stretching the image.
 *
 * Falls back to a plain (non-resized) createImageBitmap call for browsers
 * that don't support the resize options, then to canvas 2D drawImage-based
 * downscaling either way. If every decode attempt genuinely fails (corrupt
 * file, unsupported format), throws AvatarDecodeError instead of silently
 * returning the original raw file — uploading that unprocessed file was
 * the second bug: it either reproduced the same memory pressure this
 * function exists to avoid, or tripped the "too large" error below with a
 * misleading message implying compression had been attempted.
 */
async function resizeImageForAvatar(file: File): Promise<Blob> {
  let bitmap: ImageBitmap;
  try {
    bitmap = await createImageBitmap(file, {
      resizeWidth: AVATAR_MAX_DIMENSION,
      resizeQuality: "medium",
    });
  } catch {
    try {
      bitmap = await createImageBitmap(file);
    } catch {
      throw new AvatarDecodeError(
        "Couldn't read that image on this device. Try a different photo (JPEG or PNG works best).",
      );
    }
  }

  try {
    const scale = Math.min(1, AVATAR_MAX_DIMENSION / Math.max(bitmap.width, bitmap.height));
    const width = Math.round(bitmap.width * scale);
    const height = Math.round(bitmap.height * scale);

    const canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext("2d");
    if (!ctx) {
      throw new AvatarDecodeError("Couldn't process that image on this device. Try a different photo.");
    }
    ctx.drawImage(bitmap, 0, 0, width, height);
    bitmap.close();

    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, "image/jpeg", AVATAR_JPEG_QUALITY),
    );
    if (!blob) {
      throw new AvatarDecodeError("Couldn't process that image on this device. Try a different photo.");
    }
    return blob;
  } catch (error) {
    if (error instanceof AvatarDecodeError) throw error;
    throw new AvatarDecodeError("Couldn't process that image on this device. Try a different photo.");
  }
}

/**
 * Validate + upload a new avatar image, mirroring
 * lib/data/app_data_store.dart's `uploadAvatar`: same storage path
 * (avatars/{uid}/avatar.jpg), same cache-busting query param appended to
 * the download URL (Storage keeps the same token across overwrites of the
 * same path, so without busting the cache, clients keep showing the old
 * image), same write of the result to `users/{uid}.avatarUrl`. Unlike the
 * Flutter version, this resizes client-side first (see
 * resizeImageForAvatar) since the web upload path has no OS-level image
 * picker downscaling to rely on.
 */
/** Thrown only when the compressed blob is still oversized (rare — compression
 * only fails to shrink enough for an unusual/corrupt image) — kept distinct
 * from Firebase's own errors so the catch below can show this exact message
 * instead of falling through to storageErrorMessage's generic upload-failure
 * text. */
class AvatarTooLargeError extends Error {}

async function uploadAvatar(uid: string, file: File): Promise<string> {
  const resized = await resizeImageForAvatar(file);
  if (resized.size > MAX_AVATAR_BYTES) {
    throw new AvatarTooLargeError("Image is still too large after compression. Try a different photo.");
  }
  const avatarRef = ref(storage, `avatars/${uid}/avatar.jpg`);
  await uploadBytes(avatarRef, resized, { contentType: "image/jpeg" });
  const rawUrl = await getDownloadURL(avatarRef);
  const cacheBustedUrl = `${rawUrl}${rawUrl.includes("?") ? "&" : "?"}cb=${Date.now()}`;
  await setDoc(doc(db, "users", uid), { avatarUrl: cacheBustedUrl }, { merge: true });
  return cacheBustedUrl;
}

interface PremiumStatus {
  active: boolean;
  expiresAt: string | null;
  plan: string | null;
}

const DEFAULT_PREMIUM: PremiumStatus = { active: false, expiresAt: null, plan: null };

const THEME_OPTIONS: { value: ThemeMode; label: string }[] = [
  { value: "light", label: "Light" },
  { value: "dark", label: "Dark" },
  { value: "system", label: "System" },
];

function formatDate(iso: string): string {
  const parsed = new Date(iso);
  if (Number.isNaN(parsed.getTime())) return iso;
  return parsed.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
}

/**
 * Profile page — the web mirror of lib/features/profile/profile_page.dart,
 * restructured around the product's requested dashboard layout: a top
 * summary card (avatar, name — both original functionality — plus a
 * compact level/streak/XP/coins line), Target University/course/JAMB-score +
 * home-state goals (ProfileGoals), Today's Progress / Performance / Weak
 * Subjects (all derived from users/{uid}/quizAttempts via
 * useProfileInsights.ts), Achievements (GamificationProgress — level
 * progress bar, streak detail, badge grid), and Rank (RankCard — Nigeria/
 * state/friends placement + friend-code UI, from the parallel leaderboard/
 * friends task's lib/leaderboard.ts + lib/friends.ts contract). The
 * original settings-oriented cards — premium status (read-only; the actual
 * upgrade flow is Phase 9, so the CTA here just links to /premium), an
 * "enable notifications" toggle (Phase 10 — see src/lib/push-notifications.ts)
 * that requests permission and saves an FCM token to `users/{uid}.fcmTokens`
 * on click only, never automatically on load, Appearance (Light/Dark/System,
 * see src/lib/theme-context.tsx), and sign out — are kept fully functional,
 * just moved below the new dashboard content. Avatar upload mirrors
 * lib/data/app_data_store.dart's `uploadAvatar` (see the module-level
 * `uploadAvatar` helper above). The old inline PerformanceTrackRecord card
 * (attempts tracked / average score / most-practiced subject) was removed
 * from this page — its numbers are now superseded by the more detailed
 * Today's Progress + Performance cards below; PerformanceTrackRecord itself
 * is untouched and still used on the home page.
 */
export default function ProfileView() {
  const { user } = useAuth();
  const [premium, setPremium] = useState<PremiumStatus>(DEFAULT_PREMIUM);
  const { themeMode, setThemeMode } = useTheme();
  const gamification = useGamification();
  // `coins` is a field the parallel gamification task is adding to
  // users/{uid} (same pattern/trust model as `xp` — see gamification.ts's
  // CLIENT-TRUST LIMITATION note). Read locally here rather than via
  // use-gamification.ts, since that hook's GamificationState type doesn't
  // include `coins` yet and this task's scope excludes editing src/lib/**.
  const [coins, setCoins] = useState(0);

  const [editingName, setEditingName] = useState(false);
  const [nameInput, setNameInput] = useState(user?.displayName ?? "");
  const [savingName, setSavingName] = useState(false);
  const [nameError, setNameError] = useState<string | null>(null);

  const [signingOut, setSigningOut] = useState(false);

  const [editingPassword, setEditingPassword] = useState(false);
  const [currentPasswordInput, setCurrentPasswordInput] = useState("");
  const [newPasswordInput, setNewPasswordInput] = useState("");
  const [savingPassword, setSavingPassword] = useState(false);
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [passwordSuccess, setPasswordSuccess] = useState(false);

  const [editingEmail, setEditingEmail] = useState(false);
  const [emailPasswordInput, setEmailPasswordInput] = useState("");
  const [newEmailInput, setNewEmailInput] = useState("");
  const [savingEmail, setSavingEmail] = useState(false);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [emailSuccess, setEmailSuccess] = useState(false);

  const [deletingAccount, setDeletingAccount] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  const avatarUrl = useAvatarUrl();
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [avatarError, setAvatarError] = useState<string | null>(null);
  const avatarInputRef = useRef<HTMLInputElement>(null);

  // Lazy initializer, not an effect: ProfileView only ever mounts inside
  // RequireAuth once the auth check has already resolved (see
  // require-auth.tsx), i.e. always after hydration, so reading a browser
  // API here at mount time can't cause a server/client mismatch.
  const [notifPermission, setNotifPermission] = useState<NotificationPermission | null>(
    () => getNotificationPermission(),
  );
  const [notifBusy, setNotifBusy] = useState(false);
  const [notifError, setNotifError] = useState<string | null>(null);

  useEffect(() => {
    if (!user) return;
    return onSnapshot(doc(db, "users", user.uid), (snapshot) => {
      const data = snapshot.data();
      const raw = data?.premium as Partial<PremiumStatus> | undefined;
      setPremium({
        active: raw?.active ?? false,
        expiresAt: raw?.expiresAt ?? null,
        plan: raw?.plan ?? null,
      });
      setCoins(typeof data?.coins === "number" ? data.coins : 0);
    });
  }, [user]);

  if (!user) return null;

  const startEditingName = () => {
    setNameInput(user.displayName ?? "");
    setNameError(null);
    setEditingName(true);
  };

  const handleSaveName = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const trimmed = nameInput.trim();
    if (!trimmed) {
      setNameError("Name can't be empty.");
      return;
    }
    setSavingName(true);
    setNameError(null);
    try {
      await updateProfile(user, { displayName: trimmed });
      setEditingName(false);
    } catch (err) {
      setNameError(authErrorMessage(err));
    } finally {
      setSavingName(false);
    }
  };

  const handleEnableNotifications = async () => {
    setNotifBusy(true);
    setNotifError(null);
    const result = await enablePushNotifications(user.uid);
    if (result.ok) {
      setNotifPermission("granted");
    } else if (result.reason === "denied") {
      setNotifError("Notifications are blocked. Enable them in your browser's site settings and try again.");
      setNotifPermission(getNotificationPermission());
    } else if (result.reason === "unsupported") {
      setNotifError("Push notifications aren't supported in this browser.");
    } else {
      setNotifError("Couldn't enable notifications. Please try again.");
    }
    setNotifBusy(false);
  };

  const handleAvatarSelected = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    event.target.value = ""; // allow re-selecting the same file next time
    if (!file) return;

    setAvatarError(null);
    if (!file.type.startsWith("image/")) {
      setAvatarError("Please choose an image file.");
      return;
    }
    if (file.size > MAX_RAW_AVATAR_BYTES) {
      setAvatarError("That file is too large. Please choose a smaller image.");
      return;
    }

    setUploadingAvatar(true);
    try {
      await uploadAvatar(user.uid, file);
    } catch (err) {
      setAvatarError(
        err instanceof AvatarTooLargeError || err instanceof AvatarDecodeError
          ? err.message
          : storageErrorMessage(err),
      );
    } finally {
      setUploadingAvatar(false);
    }
  };

  const handleSignOut = async () => {
    setSigningOut(true);
    try {
      await signOut(auth);
    } finally {
      setSigningOut(false);
    }
  };

  // Only email/password accounts have a password to reauthenticate with —
  // Google-only accounts have no `providerData` entry with providerId
  // "password", so the change-password/change-email forms below are gated
  // on this and show a "managed by Google" message instead.
  const isPasswordProvider = user.providerData[0]?.providerId === "password";

  const startEditingPassword = () => {
    setCurrentPasswordInput("");
    setNewPasswordInput("");
    setPasswordError(null);
    setPasswordSuccess(false);
    setEditingPassword(true);
  };

  const handleSavePassword = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (newPasswordInput.length < 6) {
      setPasswordError("New password must be at least 6 characters.");
      return;
    }
    setSavingPassword(true);
    setPasswordError(null);
    try {
      const credential = EmailAuthProvider.credential(user.email ?? "", currentPasswordInput);
      await reauthenticateWithCredential(user, credential);
      await updatePassword(user, newPasswordInput);
      setPasswordSuccess(true);
      setEditingPassword(false);
      setCurrentPasswordInput("");
      setNewPasswordInput("");
    } catch (err) {
      setPasswordError(authErrorMessage(err));
    } finally {
      setSavingPassword(false);
    }
  };

  const startEditingEmail = () => {
    setEmailPasswordInput("");
    setNewEmailInput("");
    setEmailError(null);
    setEmailSuccess(false);
    setEditingEmail(true);
  };

  const handleSaveEmail = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const trimmed = newEmailInput.trim();
    if (!trimmed) {
      setEmailError("Enter a new email address.");
      return;
    }
    setSavingEmail(true);
    setEmailError(null);
    try {
      const credential = EmailAuthProvider.credential(user.email ?? "", emailPasswordInput);
      await reauthenticateWithCredential(user, credential);
      // verifyBeforeUpdateEmail (not the deprecated updateEmail) sends a
      // confirmation link to the NEW address rather than switching it
      // instantly — the address only actually changes once the user clicks
      // that link, which is Firebase's current recommended flow.
      await verifyBeforeUpdateEmail(user, trimmed);
      setEmailSuccess(true);
      setEditingEmail(false);
      setEmailPasswordInput("");
      setNewEmailInput("");
    } catch (err) {
      setEmailError(authErrorMessage(err));
    } finally {
      setSavingEmail(false);
    }
  };

  const handleDeleteAccount = async () => {
    if (
      !window.confirm(
        "Deleting your account is permanent and can't be undone. Are you sure you want to continue?",
      )
    ) {
      return;
    }
    setDeleteError(null);
    let credentialPassword = "";
    if (isPasswordProvider) {
      const entered = window.prompt("Enter your password to confirm account deletion:");
      if (entered === null) return;
      credentialPassword = entered;
    }
    setDeletingAccount(true);
    try {
      if (isPasswordProvider) {
        const credential = EmailAuthProvider.credential(user.email ?? "", credentialPassword);
        await reauthenticateWithCredential(user, credential);
      }
      // Deletes only the Firebase Auth account. Any Firestore doc/
      // subcollections and Storage avatar for this uid are intentionally
      // left behind — a known, accepted gap, out of scope for this task.
      await deleteUser(user);
    } catch (err) {
      setDeleteError(authErrorMessage(err));
      setDeletingAccount(false);
    }
  };

  return (
    <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
      <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Profile
      </h1>

      <div className="mt-8 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6">
        <div className="flex items-center gap-4">
          <button
            type="button"
            onClick={() => avatarInputRef.current?.click()}
            disabled={uploadingAvatar}
            aria-label={avatarUrl ? "Change avatar" : "Upload avatar"}
            className="relative flex h-14 w-14 shrink-0 items-center justify-center overflow-hidden rounded-full bg-navy text-xl font-semibold text-cream ring-offset-2 transition-opacity hover:opacity-90 disabled:opacity-60"
          >
            {avatarUrl ? (
              // unoptimized: see BottomNav.tsx's matching comment — Firebase
              // Hosting's own image layer rejects /_next/image requests for
              // Firebase Storage URLs ahead of our Next.js function.
              <Image src={avatarUrl} alt="" fill sizes="56px" unoptimized className="object-cover" />
            ) : (
              (user.displayName || user.email || "?").charAt(0).toUpperCase()
            )}
            {uploadingAvatar && (
              <span className="absolute inset-0 flex items-center justify-center bg-navy/60">
                <span
                  aria-hidden="true"
                  className="h-5 w-5 animate-spin rounded-full border-2 border-cream border-t-transparent"
                />
              </span>
            )}
          </button>
          <input
            ref={avatarInputRef}
            type="file"
            accept="image/*"
            onChange={handleAvatarSelected}
            className="hidden"
          />
          <div className="min-w-0">
            {editingName ? (
              <form onSubmit={handleSaveName} className="flex flex-wrap items-center gap-2">
                <input
                  autoFocus
                  type="text"
                  value={nameInput}
                  onChange={(event) => setNameInput(event.target.value)}
                  className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-1.5 text-base text-[var(--color-primary)] outline-none focus:border-gold"
                />
                <button
                  type="submit"
                  disabled={savingName}
                  className="rounded-full bg-navy px-4 py-1.5 text-sm font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
                >
                  {savingName ? "Saving…" : "Save"}
                </button>
                <button
                  type="button"
                  onClick={() => setEditingName(false)}
                  className="rounded-full border border-[var(--color-border)] px-4 py-1.5 text-sm font-medium text-[var(--color-primary)] transition-colors hover:border-gold"
                >
                  Cancel
                </button>
              </form>
            ) : (
              <div className="flex items-center gap-2">
                <p className="truncate text-lg font-semibold text-[var(--color-primary)]">
                  {user.displayName || "Add your name"}
                </p>
                <button
                  type="button"
                  onClick={startEditingName}
                  className="text-sm text-gold hover:underline"
                >
                  Edit
                </button>
              </div>
            )}
            <p className="mt-0.5 truncate text-sm text-[var(--color-primary)]/60">{user.email}</p>
          </div>
        </div>
        {nameError && <p className="mt-3 text-sm text-red-600">{nameError}</p>}
        {avatarError && <p className="mt-3 text-sm text-red-600">{avatarError}</p>}

        {/* Compact level/streak/XP/coins line — the fuller level-progress
            bar + streak detail + badge grid live in the "Achievements" card
            (GamificationProgress) further down the page. */}
        {gamification && (
          <div className="mt-4 flex flex-wrap items-center gap-x-4 gap-y-1 border-t border-[var(--color-border)] pt-4 text-sm text-[var(--color-primary)]">
            <span className="font-semibold">
              Level {levelProgress(gamification.xp).level} · {levelProgress(gamification.xp).tierName}
            </span>
            <span>
              🔥 {gamification.streakCount}-Day Streak
            </span>
            <span>⭐ {gamification.xp.toLocaleString()} XP</span>
            <span>🪙 {coins.toLocaleString()} Coins</span>
          </div>
        )}
      </div>

      <ProfileGoals />

      {/* Today's Progress / Performance / Weak Subjects / Achievements share
          one horizontally-scrollable row instead of stacking full-width —
          same CSS-only scroll-snap carousel pattern as the homepage's "Exam
          type" carousel (see src/app/page.tsx), reused here for consistency
          and to keep this less vertical-space-consuming. Each card is now
          collapsed to just its title by default (CollapsibleSection, used
          internally by each of the 4 components below) so all 4 sit at the
          same short height in this row instead of stretching unevenly —
          tapping one open only affects that card's own height. */}
      <ul className="mt-6 flex snap-x snap-mandatory gap-3 overflow-x-auto pb-2 -mx-4 px-4 sm:-mx-6 sm:px-6">
        <li className="w-[85vw] max-w-sm shrink-0 snap-start">
          <TodaysProgress />
        </li>
        <li className="w-[85vw] max-w-sm shrink-0 snap-start">
          <PerformanceBreakdown />
        </li>
        <li className="w-[85vw] max-w-sm shrink-0 snap-start">
          <WeakSubjectsCard />
        </li>
        <li className="w-[85vw] max-w-sm shrink-0 snap-start">
          <GamificationProgress />
        </li>
      </ul>

      {/* Rank, Notifications, Subscription, Appearance, and Account &
          Security share ONE container (product request) instead of each
          being its own card — CollapsibleSection's `bare` mode drops its
          usual rounded/border/bg shell and renders a divider instead, so
          these stack as sections of a single box. */}
      <div className="mt-6 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6">
        <div className="space-y-4">
          <RankCard bare />

          <CollapsibleSection title="Push notifications" bare>
            <div className="flex items-center justify-between gap-4">
              <div>
                <p className="text-sm text-[var(--color-primary)]/70">
                  {notifPermission === "granted"
                    ? "Enabled — you'll get alerts for education news and reminders."
                    : notifPermission === "denied"
                      ? "Blocked in your browser's site settings."
                      : "Get notified about exam news and reminders."}
                </p>
                {notifError && <p className="mt-2 text-sm text-red-600">{notifError}</p>}
              </div>
              {notifPermission !== "granted" && (
                <button
                  type="button"
                  onClick={handleEnableNotifications}
                  disabled={notifBusy || notifPermission === "denied"}
                  className="shrink-0 rounded-full bg-gold px-5 py-2.5 text-sm font-semibold text-navy transition-colors hover:opacity-90 disabled:opacity-60"
                >
                  {notifBusy ? "Enabling…" : "Enable notifications"}
                </button>
              )}
            </div>
          </CollapsibleSection>

          <CollapsibleSection title="Subscription" bare>
            <div className="flex items-center justify-between gap-4">
              <div>
                <p className="font-semibold text-[var(--color-primary)]">
                  {premium.active ? "Premium" : "Free plan"}
                </p>
                <p className="mt-1 text-sm text-[var(--color-primary)]/70">
                  {premium.active
                    ? premium.expiresAt
                      ? `Active until ${formatDate(premium.expiresAt)}`
                      : "Unlimited Snap & Solve and Theory help"
                    : "Upgrade for unlimited AI-powered help."}
                </p>
              </div>
              {!premium.active && (
                <Link
                  href="/premium"
                  className="shrink-0 rounded-full bg-gold px-5 py-2.5 text-sm font-semibold text-navy transition-colors hover:opacity-90"
                >
                  Go Premium
                </Link>
              )}
            </div>
          </CollapsibleSection>

          <CollapsibleSection title="Appearance" bare>
            <p className="text-sm text-[var(--color-primary)]/70">
              Choose how Exam Coach looks on this device.
            </p>
            <div className="mt-4 inline-flex rounded-full border border-[var(--color-border)] p-1">
              {THEME_OPTIONS.map((option) => (
                <button
                  key={option.value}
                  type="button"
                  onClick={() => setThemeMode(option.value)}
                  aria-pressed={themeMode === option.value}
                  className={`rounded-full px-4 py-1.5 text-sm font-medium transition-colors ${
                    themeMode === option.value
                      ? "bg-navy text-cream"
                      : "text-[var(--color-primary)] hover:text-gold"
                  }`}
                >
                  {option.label}
                </button>
              ))}
            </div>
          </CollapsibleSection>

          <CollapsibleSection title="Account & Security" bare>
        {!isPasswordProvider ? (
          <p className="mt-2 text-sm text-[var(--color-primary)]/70">
            Your password and email are managed by your Google account.
          </p>
        ) : (
          <>
            {/* Change password */}
            <div className="mt-4 border-t border-[var(--color-border)] pt-4">
              <div className="flex items-center justify-between gap-4">
                <p className="text-sm font-medium text-[var(--color-primary)]">Password</p>
                {!editingPassword && (
                  <button
                    type="button"
                    onClick={startEditingPassword}
                    className="text-sm text-gold hover:underline"
                  >
                    Change
                  </button>
                )}
              </div>
              {editingPassword ? (
                <form onSubmit={handleSavePassword} className="mt-3 space-y-2">
                  <input
                    autoFocus
                    type="password"
                    placeholder="Current password"
                    value={currentPasswordInput}
                    onChange={(event) => setCurrentPasswordInput(event.target.value)}
                    className="w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-1.5 text-sm text-[var(--color-primary)] outline-none focus:border-gold"
                  />
                  <input
                    type="password"
                    placeholder="New password (min 6 characters)"
                    value={newPasswordInput}
                    onChange={(event) => setNewPasswordInput(event.target.value)}
                    className="w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-1.5 text-sm text-[var(--color-primary)] outline-none focus:border-gold"
                  />
                  <div className="flex items-center gap-2">
                    <button
                      type="submit"
                      disabled={savingPassword}
                      className="rounded-full bg-navy px-4 py-1.5 text-sm font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
                    >
                      {savingPassword ? "Saving…" : "Save"}
                    </button>
                    <button
                      type="button"
                      onClick={() => setEditingPassword(false)}
                      className="rounded-full border border-[var(--color-border)] px-4 py-1.5 text-sm font-medium text-[var(--color-primary)] transition-colors hover:border-gold"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              ) : (
                passwordSuccess && (
                  <p className="mt-2 text-sm text-green-600">Password updated.</p>
                )
              )}
              {passwordError && <p className="mt-2 text-sm text-red-600">{passwordError}</p>}
            </div>

            {/* Change email */}
            <div className="mt-4 border-t border-[var(--color-border)] pt-4">
              <div className="flex items-center justify-between gap-4">
                <p className="text-sm font-medium text-[var(--color-primary)]">Email</p>
                {!editingEmail && (
                  <button
                    type="button"
                    onClick={startEditingEmail}
                    className="text-sm text-gold hover:underline"
                  >
                    Change
                  </button>
                )}
              </div>
              {editingEmail ? (
                <form onSubmit={handleSaveEmail} className="mt-3 space-y-2">
                  <input
                    autoFocus
                    type="password"
                    placeholder="Current password"
                    value={emailPasswordInput}
                    onChange={(event) => setEmailPasswordInput(event.target.value)}
                    className="w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-1.5 text-sm text-[var(--color-primary)] outline-none focus:border-gold"
                  />
                  <input
                    type="email"
                    placeholder="New email address"
                    value={newEmailInput}
                    onChange={(event) => setNewEmailInput(event.target.value)}
                    className="w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-1.5 text-sm text-[var(--color-primary)] outline-none focus:border-gold"
                  />
                  <div className="flex items-center gap-2">
                    <button
                      type="submit"
                      disabled={savingEmail}
                      className="rounded-full bg-navy px-4 py-1.5 text-sm font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
                    >
                      {savingEmail ? "Saving…" : "Save"}
                    </button>
                    <button
                      type="button"
                      onClick={() => setEditingEmail(false)}
                      className="rounded-full border border-[var(--color-border)] px-4 py-1.5 text-sm font-medium text-[var(--color-primary)] transition-colors hover:border-gold"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              ) : (
                emailSuccess && (
                  <p className="mt-2 text-sm text-green-600">
                    Check your new email&apos;s inbox to confirm the change.
                  </p>
                )
              )}
              {emailError && <p className="mt-2 text-sm text-red-600">{emailError}</p>}
            </div>
          </>
        )}

        {/* Delete account */}
        <div className="mt-4 border-t border-[var(--color-border)] pt-4">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="text-sm font-medium text-[var(--color-primary)]">Delete account</p>
              <p className="mt-0.5 text-xs text-[var(--color-primary)]/60">
                Permanently deletes your account. This can&apos;t be undone.
              </p>
            </div>
            <button
              type="button"
              onClick={handleDeleteAccount}
              disabled={deletingAccount}
              className="shrink-0 rounded-full border border-red-600 px-4 py-1.5 text-sm font-semibold text-red-600 transition-colors hover:bg-red-600 hover:text-white disabled:opacity-60"
            >
              {deletingAccount ? "Deleting…" : "Delete"}
            </button>
          </div>
          {deleteError && <p className="mt-2 text-sm text-red-600">{deleteError}</p>}
        </div>
          </CollapsibleSection>
        </div>
      </div>

      <button
        type="button"
        onClick={handleSignOut}
        disabled={signingOut}
        className="mt-8 rounded-full border border-[var(--color-border)] px-5 py-2.5 font-semibold text-[var(--color-primary)] transition-colors hover:border-gold hover:text-gold disabled:opacity-60"
      >
        {signingOut ? "Signing out…" : "Sign out"}
      </button>
    </div>
  );
}
