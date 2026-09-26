"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import type { SubjectSummary } from "@/lib/exam-content";
import { fetchDuelQuestions } from "@/lib/duel-content";
import { createDuel, createDuelDirect } from "@/lib/duel-service";
import { AI_BOT_NAME, AI_BOT_UID } from "@/lib/duel-ai-opponent";
import { DUEL_DURATION_SECONDS, DUEL_QUESTION_COUNT } from "@/lib/duel-types";
import DuelLobby from "@/components/duel/DuelLobby";
import SubjectPicker from "@/components/duel/SubjectPicker";

type View = "menu" | "online" | "invite" | "bot";

interface Props {
  subjects: SubjectSummary[];
}

/**
 * `/duel` landing screen — three entry points into the same underlying
 * duel system (DuelSession.tsx renders the actual quiz for all three):
 *
 * 1. "Challenge someone online" — hands off to the existing DuelLobby
 *    (who's-online + challenge-a-specific-person flow), unchanged.
 * 2. "Invite a friend" — creates a "waiting for opponent" duel via
 *    createDuel and immediately routes to /duel/[code]; DuelSession's
 *    existing host-waiting-room screen (see its `duel.status === "waiting"`
 *    branch) already shows the code and now also a shareable
 *    /duel/join?code=XXX link (Web Share API with clipboard fallback).
 * 3. "Play vs computer" — creates a duel with the bot already seated as
 *    guest via createDuelDirect (guestUid: AI_BOT_UID), so it starts
 *    "active" immediately with no waiting room. DuelSession detects the
 *    bot guest and drives its simulated answers client-side — see
 *    src/lib/duel-ai-opponent.ts for the full mechanism/limitations.
 */
export default function DuelHome({ subjects }: Props) {
  const { user } = useAuth();
  const uid = user?.uid ?? "";
  const displayName = user?.displayName || user?.email || "Student";

  const [view, setView] = useState<View>("menu");
  const [creating, setCreating] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const router = useRouter();

  const createInvite = async (subjectSlug: string) => {
    setCreating(true);
    setErrorMessage(null);
    try {
      const { subjectName, questions } = await fetchDuelQuestions(subjectSlug, DUEL_QUESTION_COUNT);
      const duel = await createDuel({
        subject: subjectSlug,
        subjectName,
        questions,
        durationSeconds: DUEL_DURATION_SECONDS,
        hostUid: uid,
        hostName: displayName,
      });
      router.push(`/duel/${duel.id}`);
    } catch {
      setErrorMessage("Could not create a duel right now. Try again.");
      setCreating(false);
    }
  };

  const createBotDuel = async (subjectSlug: string) => {
    setCreating(true);
    setErrorMessage(null);
    try {
      const { subjectName, questions } = await fetchDuelQuestions(subjectSlug, DUEL_QUESTION_COUNT);
      const duel = await createDuelDirect({
        subject: subjectSlug,
        subjectName,
        questions,
        durationSeconds: DUEL_DURATION_SECONDS,
        hostUid: uid,
        hostName: displayName,
        guestUid: AI_BOT_UID,
        guestName: AI_BOT_NAME,
      });
      router.push(`/duel/${duel.id}`);
    } catch {
      setErrorMessage("Could not start a duel right now. Try again.");
      setCreating(false);
    }
  };

  if (view === "online") {
    return (
      <div className="mx-auto max-w-2xl px-4 pt-4 sm:px-6">
        <button
          type="button"
          onClick={() => setView("menu")}
          className="text-sm text-[var(--color-primary)]/60 hover:underline"
        >
          ← Back
        </button>
        <DuelLobby subjects={subjects} />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl px-4 py-8 sm:px-6">
      <h1 className="text-xl font-bold text-[var(--color-primary)]">Duel</h1>
      <p className="mt-1 text-sm text-[var(--color-primary)]/60">
        Pick how you want to play a live, timed 1v1 quiz duel.
      </p>

      {errorMessage && (
        <p className="mt-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorMessage}</p>
      )}

      <div className="mt-6 space-y-3">
        <ModeCard
          emoji="🌐"
          title="Challenge someone online"
          description="See who else is online in your school's lobby and challenge them directly."
          onClick={() => setView("online")}
        />
        <ModeCard
          emoji="🔗"
          title="Invite a friend"
          description="Get a shareable code and link — the duel starts the moment they open it."
          onClick={() => setView("invite")}
        />
        <ModeCard
          emoji="🤖"
          title="Play vs computer"
          description="No one online? Duel Exam Coach Bot right now — starts instantly."
          onClick={() => setView("bot")}
        />
      </div>

      {view === "invite" && (
        <SubjectPicker
          title="Invite a friend to duel over…"
          subjects={subjects}
          disabled={creating}
          onCancel={() => setView("menu")}
          onPick={createInvite}
        />
      )}

      {view === "bot" && (
        <SubjectPicker
          title="Duel the computer over…"
          subjects={subjects}
          disabled={creating}
          onCancel={() => setView("menu")}
          onPick={createBotDuel}
        />
      )}
    </div>
  );
}

function ModeCard({
  emoji,
  title,
  description,
  onClick,
}: {
  emoji: string;
  title: string;
  description: string;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="flex w-full items-start gap-4 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-4 text-left transition-colors hover:border-gold"
    >
      <span className="text-2xl">{emoji}</span>
      <span>
        <span className="block text-sm font-semibold text-[var(--color-primary)]">{title}</span>
        <span className="mt-0.5 block text-xs text-[var(--color-primary)]/60">{description}</span>
      </span>
    </button>
  );
}
