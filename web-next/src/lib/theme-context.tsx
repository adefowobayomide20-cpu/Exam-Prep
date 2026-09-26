"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import { doc, onSnapshot, setDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";

export type ThemeMode = "light" | "dark" | "system";

const STORAGE_KEY = "themeMode";

function isThemeMode(value: unknown): value is ThemeMode {
  return value === "light" || value === "dark" || value === "system";
}

function readStoredThemeMode(): ThemeMode {
  if (typeof window === "undefined") return "system";
  const stored = window.localStorage.getItem(STORAGE_KEY);
  return isThemeMode(stored) ? stored : "system";
}

function applyThemeClass(mode: ThemeMode) {
  const root = document.documentElement;
  root.classList.remove("light", "dark");
  if (mode !== "system") root.classList.add(mode);
}

type ThemeContextValue = {
  themeMode: ThemeMode;
  setThemeMode: (mode: ThemeMode) => void;
};

const ThemeContext = createContext<ThemeContextValue>({
  themeMode: "system",
  setThemeMode: () => {},
});

/**
 * Web mirror of lib/data/models/profile_settings.dart's `themeMode` field
 * ('light' | 'dark' | 'system'), persisted to `users/{uid}.themeMode` once
 * signed in — same doc + field name the Flutter app uses, so both apps
 * could eventually share the preference. While signed out (or before the
 * first Firestore read resolves), the preference lives in localStorage
 * only.
 *
 * A blocking inline script in layout.tsx reads the same localStorage key
 * and applies the class to <html> before hydration, to avoid a flash of
 * the wrong theme. This provider's initial state (via the lazy
 * `readStoredThemeMode` initializer, not an effect — see
 * use-quiz-attempts.ts's comment on why plain state updates inside effects
 * are avoided here) mirrors that same script so React's view of the theme
 * matches what's already applied to the DOM, then reconciles with
 * Firestore once auth resolves.
 */
export function ThemeProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [themeMode, setThemeModeState] = useState<ThemeMode>(readStoredThemeMode);

  useEffect(() => {
    applyThemeClass(themeMode);
  }, [themeMode]);

  useEffect(() => {
    if (!user) return;
    return onSnapshot(doc(db, "users", user.uid), (snapshot) => {
      const remote = snapshot.data()?.themeMode;
      if (isThemeMode(remote)) {
        setThemeModeState(remote);
        window.localStorage.setItem(STORAGE_KEY, remote);
      }
    });
  }, [user]);

  const setThemeMode = useCallback(
    (mode: ThemeMode) => {
      setThemeModeState(mode);
      window.localStorage.setItem(STORAGE_KEY, mode);
      if (user) {
        void setDoc(doc(db, "users", user.uid), { themeMode: mode }, { merge: true });
      }
    },
    [user],
  );

  const value = useMemo(() => ({ themeMode, setThemeMode }), [themeMode, setThemeMode]);

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

/** Read/set the user's Light/Dark/System theme preference — see ThemeProvider. */
export function useTheme() {
  return useContext(ThemeContext);
}
