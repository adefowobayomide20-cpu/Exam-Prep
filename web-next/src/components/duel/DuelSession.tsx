"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { httpsCallable } from "firebase/functions";
import { useAuth } from "@/lib/auth-context";
import { functions } from "@/lib/firebase";
import { awardDuelCompletionXp } from "@/lib/gamification";
import { functionsErrorMessage } from "@/lib/functions-errors";
import {
  applyLifelineElimination,
  canApplyLifeline,
  consumeDailyLifelineUse,
  MAX_LIFELINE_USES_PER_DAY,
  MAX_LIFELINE_USES_PER_SESSION,
  useDailyLifelineUsage,
  type LifelineKind,
} from "@/lib/lifelines";
import {
  finishDuel,
  forceFinishDuel,
  freezeOpponent,
  joinDuel,
  recordProgress,
  watchDuel,
  FREEZE_SECONDS,
} from "@/lib/duel-service";
import { AI_BOT_UID, runAiOpponent } from "@/lib/duel-ai-opponent";
import {
  duelOpponent,
  duelSelf,
  isDuelHost,
  type DuelDoc,
} from "@/lib/duel-types";
import DuelLifelineControls from "./DuelLifelineControls";

interface SolveQuestionRequest {
  question: string;
  history: { role: "user" | "assistant"; text: string }[];
}

interface SolveQuestionResponse {
  text: string;
  truncated?: boolean;
}

interface Props {
  code: string;
}

function scoreFor(questions: DuelDoc["questions"], answers: Record<number, number>): number {
  return questions.reduce(
    (score, question, index) => (answers[index] === question.correctIndex ? score + 1 : score),
    0,
  );
}

/** Correct answers earn more the faster they're submitted, floored so a slow-but-correct answer still beats a wrong one. Mirrors DuelSessionPage._pointsFor. */
function pointsFor(correct: boolean, timeTakenSeconds: number): number {
  if (!correct) return 0;
  return Math.min(20, Math.max(5, Math.round(20 - 1.5 * timeTakenSeconds)));
}

/** Thin wrapper so Date.now() calls needed inside the component body (event
 * handlers, ref initializers) aren't flagged as impure render-time calls by
 * react-hooks/purity — they're only ever invoked from effects or user
 * interactions, never during render itself. */
function nowMs(): number {
  return Date.now();
}

function formatRemaining(totalSeconds: number): string {
  const clamped = Math.max(0, totalSeconds);
  const minutes = String(Math.floor(clamped / 60)).padStart(2, "0");
  const seconds = String(clamped % 60).padStart(2, "0");
  return `${minutes}:${seconds}`;
}

/**
 * Live 1v1 duel session + result screen, mirroring
 * lib/features/duel/duel_session_page.dart and duel_result_page.dart in one
 * component (simpler routing than the Flutter app's two-page
 * pushReplacement flow — this page just re-renders based on the duel doc's
 * `status` and each side's `finishedAt`).
 *
 * The countdown is derived every tick from `startedAt + durationSeconds`
 * (server-shaped values in the Firestore doc), not a client-local timer —
 * so both players see the same remaining time regardless of when their own
 * tab loaded, matching the documented fix from the Flutter session. Each
 * side's own `*PenaltySeconds` (see duel-types.ts) is additionally subtracted
 * from THEIR OWN remaining time every tick, so a "Freeze" used against them
 * actually costs them time — see the countdown effect below.
 *
 * Five duel lifelines (Hint/50-50/Freeze/Ask-a-Friend/Ask-Computer), capped
 * at MAX_LIFELINE_USES_PER_SESSION combined uses per duel (local state) and
 * MAX_LIFELINE_USES_PER_DAY combined uses per day (Firestore, shared with
 * regular quiz practice — see src/lib/lifelines.ts). Hint/50-50 reuse
 * lifelines.ts's elimination mechanics; Freeze increments the opponent's
 * penalty field via duel-service.ts's `freezeOpponent`; Ask a Friend opens a
 * WhatsApp share-to-anyone link; Ask Computer calls the same `solveQuestion`
 * Cloud Function TutorChat.tsx uses, purely to reveal information (it never
 * auto-selects an answer).
 */
export default function DuelSession({ code }: Props) {
  const { user } = useAuth();
  const uid = user?.uid ?? "";
  const displayName = user?.displayName || user?.email || "Student";

  const [duel, setDuel] = useState<DuelDoc | null>(null);
  const [loaded, setLoaded] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [pointsEarned, setPointsEarned] = useState<Record<number, number>>({});
  const [remainingSeconds, setRemainingSeconds] = useState<number | null>(null);
  const [revealedIndex, setRevealedIndex] = useState<number | null>(null);
  const [selfFinished, setSelfFinished] = useState(false);
  const [joining, setJoining] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  // Duel lifelines — see the module doc above and src/lib/lifelines.ts.
  // Session cap (2 uses, all 5 kinds combined) is plain local state that
  // resets naturally with a fresh mount of this component (a new duel).
  // Daily cap (3 uses/day) is read live from Firestore and SHARED with
  // regular quiz practice (same `users/{uid}.lifelineUsage` field).
  const dailyUsage = useDailyLifelineUsage(user?.uid ?? null);
  const [sessionUses, setSessionUses] = useState(0);
  const [eliminatedByQuestion, setEliminatedByQuestion] = useState<Record<number, Set<number>>>({});
  const [freezeMessage, setFreezeMessage] = useState<string | null>(null);
  const [askComputerAnswers, setAskComputerAnswers] = useState<Record<number, string>>({});
  const [askComputerLoading, setAskComputerLoading] = useState(false);
  const [askComputerError, setAskComputerError] = useState<string | null>(null);

  const answersRef = useRef(answers);
  const pointsRef = useRef(pointsEarned);
  const finishedRef = useRef(false);
  const gamificationAwardedRef = useRef(false);
  const aiOpponentStartedRef = useRef(false);
  // Initialized to 0 (not Date.now() — an impure call isn't allowed during
  // render) and set to a real timestamp by the effect below and by
  // goToQuestion/selectAnswer as the quiz progresses.
  const questionStartedAtRef = useRef(0);

  useEffect(() => {
    answersRef.current = answers;
  }, [answers]);
  useEffect(() => {
    pointsRef.current = pointsEarned;
  }, [pointsEarned]);
  useEffect(() => {
    questionStartedAtRef.current = nowMs();
  }, []);

  // Subscribe to the shared duel document.
  useEffect(() => {
    const unsubscribe = watchDuel(code, (next) => {
      setDuel(next);
      setLoaded(true);
    });
    return unsubscribe;
  }, [code]);

  const submit = useRef(async (duelToSubmit: DuelDoc) => {
    if (finishedRef.current || !uid) return;
    finishedRef.current = true;
    setSelfFinished(true);
    const isHost = isDuelHost(duelToSubmit, uid);
    try {
      await recordProgress({
        duelId: duelToSubmit.id,
        isHost,
        answered: Object.keys(answersRef.current).length,
        correct: scoreFor(duelToSubmit.questions, answersRef.current),
        points: Object.values(pointsRef.current).reduce((sum, p) => sum + p, 0),
      });
      await finishDuel(duelToSubmit.id, isHost);
    } catch {
      setErrorMessage("Could not submit your result. Check your connection and try again.");
      finishedRef.current = false;
      setSelfFinished(false);
    }
  });

  // Shared countdown, derived from startedAt + durationSeconds every tick —
  // not a locally-owned timer, so it can't drift between the two players.
  useEffect(() => {
    if (!duel || duel.status !== "active" || !duel.startedAt || selfFinished) return;
    const startedAtMs = new Date(duel.startedAt).getTime();
    const totalMs = duel.durationSeconds * 1000;
    // The CALLER's own penalty (seconds the OPPONENT froze off them), not the
    // opponent's — this is what makes being frozen actually cost the victim
    // time. Re-read from `duel` fresh on every effect run (the effect
    // already re-runs on every snapshot tick since `duel` gets a new
    // reference each time), so a freeze lands within one countdown tick.
    const penaltyMs = (duelSelf(duel, uid)?.penaltySeconds ?? 0) * 1000;

    const tick = () => {
      const remainingMs = startedAtMs + totalMs - penaltyMs - Date.now();
      const remaining = Math.max(0, Math.round(remainingMs / 1000));
      setRemainingSeconds(remaining);
      if (remainingMs <= 0) {
        submit.current(duel);
        // Also finalize the OPPONENT's side, in case their own tab is
        // backgrounded and never notices the timeout themselves — see
        // forceFinishDuel's doc comment in duel-service.ts.
        forceFinishDuel(duel.id).catch(() => {});
      }
    };
    tick();
    const interval = setInterval(tick, 1000);
    return () => clearInterval(interval);
  }, [duel, selfFinished, uid]);

  // "Play vs computer" only: drive the bot's side of the duel from this
  // same (the host's) browser tab — see duel-ai-opponent.ts for the full
  // rationale/limitations. Gated on primitive fields (not the whole `duel`
  // object, which gets a new reference on every snapshot tick) so this
  // doesn't restart on each progress write; a ref additionally ensures it
  // only ever starts once per mount.
  useEffect(() => {
    if (!duel || !uid) return;
    if (duel.status !== "active") return;
    if (duel.guestUid !== AI_BOT_UID) return;
    if (!isDuelHost(duel, uid)) return;
    if (aiOpponentStartedRef.current) return;
    aiOpponentStartedRef.current = true;
    const controller = new AbortController();
    runAiOpponent(duel, controller.signal).catch(() => {});
    return () => controller.abort();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [duel?.id, duel?.status, duel?.guestUid, uid]);

  // Daily Streak + XP once the duel is fully finished (both sides done) —
  // guarded by a ref (not state) so this fires exactly once per duel per
  // mount, mirroring QuizSession's attemptRecorded ref pattern. Streak
  // always advances (finishing a duel is a qualifying activity whether it's
  // a win or a loss); XP/the "First Duel Win" badge only apply on a win —
  // see awardDuelCompletionXp in src/lib/gamification.ts.
  useEffect(() => {
    if (!uid || !duel || duel.status !== "finished" || gamificationAwardedRef.current) return;
    const self = duelSelf(duel, uid);
    const opponent = duelOpponent(duel, uid);
    if (!self || !opponent) return;
    gamificationAwardedRef.current = true;
    awardDuelCompletionXp(uid, self.points > opponent.points).catch(() => {});
  }, [duel, uid]);

  if (!loaded) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <p className="text-[var(--color-primary)]/70">Loading duel…</p>
      </div>
    );
  }

  if (!duel) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <h1 className="text-xl font-bold text-[var(--color-primary)]">Duel not found</h1>
        <p className="mt-3 text-[var(--color-primary)]/70">
          That duel code doesn&apos;t exist, or the duel has been removed.
        </p>
        <Link href="/duel" className="mt-6 inline-block text-sm text-gold hover:underline">
          Back to lobby
        </Link>
      </div>
    );
  }

  const self = duelSelf(duel, uid);
  const opponent = duelOpponent(duel, uid);
  const isParticipant = Boolean(self);

  const handleJoin = async () => {
    setJoining(true);
    setErrorMessage(null);
    try {
      await joinDuel(duel.id, uid, displayName);
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : "Could not join this duel.");
    } finally {
      setJoining(false);
    }
  };

  const copyCode = async () => {
    try {
      await navigator.clipboard.writeText(duel.id);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Clipboard API can be unavailable (e.g. insecure context) — the code is shown on screen regardless.
    }
  };

  const shareInviteLink = async () => {
    const link = `${window.location.origin}/duel/join?code=${duel.id}`;
    if (navigator.share) {
      try {
        await navigator.share({
          title: "Join my Exam Coach duel",
          text: `Join my ${duel.subjectName} duel on Exam Coach — code ${duel.id}`,
          url: link,
        });
        return;
      } catch {
        // User cancelled the share sheet, or share() isn't actually
        // supported for this payload — fall through to clipboard copy.
      }
    }
    try {
      await navigator.clipboard.writeText(link);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Clipboard API can be unavailable (e.g. insecure context) — the code is shown on screen regardless.
    }
  };

  // Not a participant: only option is to join an open code-share duel.
  if (!isParticipant) {
    const canJoin = duel.status === "waiting" && !duel.guestUid;
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <h1 className="text-xl font-bold text-[var(--color-primary)]">
          {duel.subjectName} duel · {duel.id}
        </h1>
        {canJoin ? (
          <>
            <p className="mt-3 text-[var(--color-primary)]/70">
              {duel.hostName} is waiting for an opponent. Join to start a 5-minute, {duel.questions.length}
              -question duel.
            </p>
            <button
              type="button"
              onClick={handleJoin}
              disabled={joining}
              className="mt-6 inline-flex items-center rounded-full bg-gold px-6 py-3 text-sm font-semibold text-navy transition-colors hover:brightness-105 disabled:opacity-60"
            >
              {joining ? "Joining…" : "Join duel"}
            </button>
          </>
        ) : (
          <p className="mt-3 text-[var(--color-primary)]/70">
            This duel already has two players and you&apos;re not one of them.
          </p>
        )}
        {errorMessage && <p className="mt-4 text-sm text-red-600">{errorMessage}</p>}
        <Link href="/duel" className="mt-6 block text-sm text-[var(--color-primary)]/50 hover:underline">
          Back to lobby
        </Link>
      </div>
    );
  }

  // Waiting for a second player (code-share flow, host only sees this).
  if (duel.status === "waiting") {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <h1 className="text-xl font-bold text-[var(--color-primary)]">Waiting for an opponent</h1>
        <p className="mt-3 text-[var(--color-primary)]/70">
          Share this code with a friend — the duel starts as soon as they join.
        </p>
        <div className="mt-6 flex items-center justify-center gap-3">
          <span className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-6 py-3 text-3xl font-bold tracking-widest text-[var(--color-primary)]">
            {duel.id}
          </span>
          <button
            type="button"
            onClick={copyCode}
            className="rounded-full border border-[var(--color-border)] px-4 py-2 text-sm font-semibold text-[var(--color-primary)] hover:border-gold hover:text-gold"
          >
            {copied ? "Copied!" : "Copy code"}
          </button>
        </div>
        <button
          type="button"
          onClick={shareInviteLink}
          className="mt-4 inline-flex items-center rounded-full bg-gold px-5 py-2.5 text-sm font-semibold text-navy transition-colors hover:brightness-105"
        >
          {copied ? "Link copied!" : "Share invite link"}
        </button>
        <p className="mt-6 text-sm text-[var(--color-primary)]/60">
          {duel.subjectName} · {duel.questions.length} questions · 5 minutes
        </p>
        <Link href="/duel" className="mt-8 block text-sm text-[var(--color-primary)]/50 hover:underline">
          Cancel and go back
        </Link>
      </div>
    );
  }

  // Finished — either both sides submitted, or the doc says so already on reload.
  if (duel.status === "finished") {
    if (!self || !opponent) {
      return (
        <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
          <p className="text-[var(--color-primary)]/70">Could not load the result.</p>
        </div>
      );
    }
    const won = self.points > opponent.points;
    const tied = self.points === opponent.points;
    return (
      <div className="mx-auto max-w-2xl px-4 py-12 sm:px-6">
        <div className="text-center">
          <p className="text-4xl">{tied ? "🤝" : won ? "🏆" : "🙂"}</p>
          <h1 className="mt-3 text-2xl font-bold text-[var(--color-primary)]">
            {tied ? "It's a tie!" : won ? "You won!" : "You lost this one"}
          </h1>
        </div>
        <div className="mt-8 grid grid-cols-2 gap-4">
          <div
            className={`rounded-2xl border p-5 text-center ${won ? "border-gold bg-gold/10" : "border-[var(--color-border)] bg-[var(--color-surface-alt)]"}`}
          >
            <p className="text-sm text-[var(--color-primary)]/60">You</p>
            <p className="mt-2 text-3xl font-bold text-[var(--color-primary)]">{self.points} pts</p>
            <p className="mt-1 text-xs text-[var(--color-primary)]/50">
              {self.correct}/{duel.questions.length} correct
            </p>
          </div>
          <div
            className={`rounded-2xl border p-5 text-center ${!won && !tied ? "border-gold bg-gold/10" : "border-[var(--color-border)] bg-[var(--color-surface-alt)]"}`}
          >
            <p className="text-sm text-[var(--color-primary)]/60">{opponent.name}</p>
            <p className="mt-2 text-3xl font-bold text-[var(--color-primary)]">{opponent.points} pts</p>
            <p className="mt-1 text-xs text-[var(--color-primary)]/50">
              {opponent.correct}/{duel.questions.length} correct
            </p>
          </div>
        </div>
        <div className="mt-8 text-center">
          <Link
            href="/duel"
            className="inline-block rounded-full bg-navy px-6 py-3 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
          >
            Back to lobby
          </Link>
        </div>
      </div>
    );
  }

  // Self has submitted but the opponent hasn't yet.
  if (selfFinished || self?.finishedAt) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center sm:px-6">
        <p className="text-[var(--color-primary)]/70">Waiting for {opponent?.name ?? "your opponent"} to finish…</p>
      </div>
    );
  }

  // Active quiz.
  const question = duel.questions[currentIndex];
  const isLast = currentIndex === duel.questions.length - 1;
  const remaining = remainingSeconds ?? duel.durationSeconds;
  const isLowTime = remaining <= 30;
  // Hoisted so both the option-rendering below and the lifeline
  // disabled-state checks share one definition — a lifeline can only be used
  // "before you lock in your answer", same rule the answer-locking fix
  // already enforces on the option buttons themselves.
  const alreadyAnswered = answers[currentIndex] !== undefined;
  const currentEliminated = eliminatedByQuestion[currentIndex] ?? new Set<number>();
  const capReached =
    sessionUses >= MAX_LIFELINE_USES_PER_SESSION || dailyUsage.used >= MAX_LIFELINE_USES_PER_DAY;

  const goToQuestion = (index: number) => {
    setCurrentIndex(index);
    setRevealedIndex(null);
    questionStartedAtRef.current = nowMs();
  };

  const selectAnswer = (optionIndex: number) => {
    const correct = optionIndex === question.correctIndex;
    const timeTaken = Math.round((nowMs() - questionStartedAtRef.current) / 1000);
    const points = pointsFor(correct, timeTaken);
    const nextAnswers = { ...answers, [currentIndex]: optionIndex };
    const nextPoints = { ...pointsEarned, [currentIndex]: points };
    setAnswers(nextAnswers);
    setPointsEarned(nextPoints);
    setRevealedIndex(currentIndex);
    setTimeout(() => setRevealedIndex((i) => (i === currentIndex ? null : i)), 900);

    const isHost = isDuelHost(duel, uid);
    recordProgress({
      duelId: duel.id,
      isHost,
      answered: Object.keys(nextAnswers).length,
      correct: scoreFor(duel.questions, nextAnswers),
      points: Object.values(nextPoints).reduce((sum, p) => sum + p, 0),
    }).catch(() => {
      // A single progress write failing isn't fatal — the next answer (or
      // the final submit) will retry with the latest totals.
    });
  };

  // Shared gate for all 5 lifeline kinds: checks both caps, then claims one
  // use against the daily Firestore cap (which also enforces the cap
  // server-side-ish via a transaction — see consumeDailyLifelineUse). Only
  // increments the local session counter once the daily claim actually
  // succeeds, mirroring QuizSession.tsx's lifeline gating order.
  const consumeLifelineUse = async (): Promise<boolean> => {
    if (!user || alreadyAnswered || capReached) return false;
    const result = await consumeDailyLifelineUse(user.uid).catch(() => ({ ok: false, used: dailyUsage.used }));
    if (!result.ok) return false;
    setSessionUses((n) => n + 1);
    return true;
  };

  // Named without a "use" prefix (unlike QuizSession.tsx's `useLifeline`,
  // which isn't touched here) so ESLint's react-hooks/rules-of-hooks doesn't
  // misidentify this plain event-handler function as a custom hook — it's
  // only ever called from JSX onClick callbacks below, never at the top
  // level of the component, so a "use"-prefixed name would trip that rule.
  const applyLifeline = async (kind: LifelineKind) => {
    if (!canApplyLifeline(question.options.length, currentEliminated)) return;
    const ok = await consumeLifelineUse();
    if (!ok) return;
    setEliminatedByQuestion((prev) => ({
      ...prev,
      [currentIndex]: applyLifelineElimination(
        kind,
        question.options.length,
        question.correctIndex,
        currentEliminated,
      ),
    }));
  };

  const triggerFreeze = async () => {
    const ok = await consumeLifelineUse();
    if (!ok) return;
    const isHost = isDuelHost(duel, uid);
    try {
      await freezeOpponent(duel.id, isHost, FREEZE_SECONDS);
      setFreezeMessage(`Froze ${opponent?.name ?? "your opponent"}'s timer for ${FREEZE_SECONDS}s!`);
      setTimeout(() => setFreezeMessage(null), 3000);
    } catch {
      setErrorMessage("Could not freeze your opponent's timer. Try again.");
    }
  };

  const shareAskFriend = async () => {
    const ok = await consumeLifelineUse();
    if (!ok) return;
    const optionsText = question.options
      .map((option, index) => `${String.fromCharCode(65 + index)}. ${option}`)
      .join("\n");
    const text = `Help me answer this question:\n\n${question.text}\n\n${optionsText}`;
    const url = new URL("https://wa.me/");
    url.searchParams.set("text", text);
    window.open(url.toString(), "_blank", "noopener,noreferrer");
  };

  const runAskComputer = async () => {
    if (askComputerLoading) return;
    const ok = await consumeLifelineUse();
    if (!ok) return;
    setAskComputerLoading(true);
    setAskComputerError(null);
    const askedIndex = currentIndex;
    try {
      const solveQuestion = httpsCallable<SolveQuestionRequest, SolveQuestionResponse>(
        functions,
        "solveQuestion",
      );
      const optionsText = question.options
        .map((option, index) => `${String.fromCharCode(65 + index)}. ${option}`)
        .join("\n");
      const { data } = await solveQuestion({
        question: `${question.text}\n\n${optionsText}\n\nWhich option is correct, and why?`,
        history: [],
      });
      setAskComputerAnswers((prev) => ({ ...prev, [askedIndex]: data.text }));
    } catch (error) {
      setAskComputerError(functionsErrorMessage(error));
    } finally {
      setAskComputerLoading(false);
    }
  };

  const handleLeave = () => {
    if (window.confirm("Leaving now counts as a loss — your opponent keeps playing. Leave anyway?")) {
      submit.current(duel);
    }
  };

  return (
    <div className="mx-auto max-w-2xl px-4 py-8 sm:px-6">
      {errorMessage && (
        <p className="mb-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorMessage}</p>
      )}
      <div className="flex items-center justify-between">
        <h1 className="text-lg font-semibold text-[var(--color-primary)]">{duel.subjectName}</h1>
        <span
          className={`rounded-full px-3 py-1 text-sm font-bold tabular-nums ${
            isLowTime ? "bg-[var(--color-danger-bg)] text-[var(--color-danger-text)]" : "bg-[var(--color-surface-alt)] text-[var(--color-primary)]"
          }`}
        >
          {formatRemaining(remaining)}
        </span>
      </div>

      {opponent && (
        <p className="mt-1 text-xs text-[var(--color-primary)]/60">
          {opponent.name}: {opponent.answered}/{duel.questions.length} answered
          {opponent.finishedAt ? " · done" : ""}
        </p>
      )}

      <div className="mt-4 h-1.5 w-full overflow-hidden rounded-full bg-[var(--color-border)]">
        <div
          className="h-full rounded-full bg-gold transition-all duration-300"
          style={{ width: `${((currentIndex + 1) / duel.questions.length) * 100}%` }}
        />
      </div>
      <p className="mt-2 text-xs text-[var(--color-primary)]/60">
        Question {currentIndex + 1} of {duel.questions.length}
      </p>

      {user && (
        <DuelLifelineControls
          onHint={() => void applyLifeline("hint")}
          onFiftyFifty={() => void applyLifeline("fiftyFifty")}
          onFreeze={() => void triggerFreeze()}
          onAskFriend={() => void shareAskFriend()}
          onAskComputer={() => void runAskComputer()}
          hintDisabled={
            alreadyAnswered || capReached || !canApplyLifeline(question.options.length, currentEliminated)
          }
          fiftyFiftyDisabled={
            alreadyAnswered || capReached || !canApplyLifeline(question.options.length, currentEliminated)
          }
          freezeDisabled={alreadyAnswered || capReached}
          askFriendDisabled={alreadyAnswered || capReached}
          askComputerDisabled={alreadyAnswered || capReached || askComputerLoading}
          askComputerLoading={askComputerLoading}
          usesRemaining={Math.max(0, MAX_LIFELINE_USES_PER_DAY - dailyUsage.used)}
        />
      )}

      {freezeMessage && (
        <p className="mt-2 text-xs font-semibold text-blue-600">❄️ {freezeMessage}</p>
      )}

      <div className="mt-6">
        <p className="text-base font-medium text-[var(--color-primary)]">{question.text}</p>
        <div className="mt-4 space-y-2">
          {question.options.map((option, optionIndex) => {
            const selected = answers[currentIndex] === optionIndex;
            // `alreadyAnswered` (not just the transient `revealedIndex` flash)
            // is what actually locks the question — previously the buttons
            // only stayed disabled for the ~900ms reveal animation, then
            // re-enabled, letting a student see the correct answer highlighted
            // and then click it to retroactively "fix" an already-scored wrong
            // pick. Locking permanently once answered fixes that; `revealed`
            // is now just a synonym used for the styling below (kept as its
            // own variable so a "Previous" revisit to an answered question
            // shows the same correct/incorrect highlighting, not just gold).
            // `alreadyAnswered` itself is hoisted above (shared with the
            // lifeline disabled-state checks) rather than redeclared here.
            const eliminated = currentEliminated.has(optionIndex) && !alreadyAnswered;
            const revealed = revealedIndex === currentIndex || alreadyAnswered;
            const isCorrectOption = optionIndex === question.correctIndex;
            let classes =
              "border-[var(--color-border)] bg-[var(--color-surface-alt)] hover:border-gold/50";
            if (revealed && selected && isCorrectOption) classes = "border-[var(--color-success-border)] bg-[var(--color-success-bg)]";
            else if (revealed && selected && !isCorrectOption) classes = "border-[var(--color-danger-border)] bg-[var(--color-danger-bg)]";
            else if (revealed && isCorrectOption) classes = "border-[var(--color-success-border)] bg-[var(--color-success-bg-soft)]";
            else if (selected) classes = "border-gold bg-gold/10";
            else if (eliminated) classes = "border-[var(--color-border)] bg-[var(--color-surface-alt)] opacity-40 line-through";

            return (
              <button
                key={optionIndex}
                type="button"
                disabled={alreadyAnswered || eliminated}
                onClick={() => selectAnswer(optionIndex)}
                className={`flex w-full items-center gap-3 rounded-xl border px-4 py-3 text-left transition-colors ${classes}`}
              >
                <span
                  className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-full border text-xs font-semibold ${
                    selected
                      ? "border-gold bg-gold text-navy"
                      : "border-[var(--color-border)] text-[var(--color-primary)]/60"
                  }`}
                >
                  {String.fromCharCode(65 + optionIndex)}
                </span>
                <span className="text-sm text-[var(--color-primary)]">{option}</span>
              </button>
            );
          })}
        </div>

        {(askComputerLoading || askComputerAnswers[currentIndex] || askComputerError) && (
          <div className="mt-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4">
            <p className="text-xs font-semibold text-[var(--color-primary)]/70">🤖 Ask Computer</p>
            {askComputerLoading && (
              <p className="mt-2 text-sm text-[var(--color-primary)]/70">Thinking&hellip;</p>
            )}
            {!askComputerLoading && askComputerError && (
              <p className="mt-2 text-sm text-red-600">{askComputerError}</p>
            )}
            {!askComputerLoading && !askComputerError && askComputerAnswers[currentIndex] && (
              <p className="mt-2 whitespace-pre-wrap text-sm text-[var(--color-primary)]">
                {askComputerAnswers[currentIndex]}
              </p>
            )}
          </div>
        )}
      </div>

      <div className="mt-8 flex items-center gap-3">
        {currentIndex > 0 && (
          <button
            type="button"
            onClick={() => goToQuestion(currentIndex - 1)}
            className="flex-1 rounded-full border border-[var(--color-border)] px-4 py-3 text-sm font-semibold text-[var(--color-primary)]"
          >
            Previous
          </button>
        )}
        <button
          type="button"
          onClick={isLast ? () => submit.current(duel) : () => goToQuestion(currentIndex + 1)}
          className="flex-1 rounded-full bg-navy px-4 py-3 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
        >
          {isLast ? "Submit" : "Next"}
        </button>
      </div>

      <button
        type="button"
        onClick={handleLeave}
        className="mt-6 block w-full text-center text-xs text-[var(--color-primary)]/50 hover:underline"
      >
        Leave duel (counts as a loss)
      </button>
    </div>
  );
}
