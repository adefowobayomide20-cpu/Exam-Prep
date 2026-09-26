"use client";

import { useState } from "react";
import { useAuth } from "@/lib/auth-context";
import { reportQuestion } from "@/lib/question-reports";
import type { QuizQuestionData } from "@/lib/exam-content";

/**
 * Small "flag this question" affordance shown in the answer-review list
 * (QuizResult.tsx / CombinedQuizResult.tsx). Signed-out users never see
 * this — reports need a uid to attribute to, same gating convention as
 * lifelines/duels elsewhere in this app. Uses a plain window.prompt for the
 * optional comment, matching the existing lightweight-confirm pattern this
 * codebase already uses (DuelSession's leave-duel confirm, ProfileView's
 * delete-account password prompt) rather than introducing a new modal
 * component for a rarely-used, low-stakes action.
 */
export default function ReportQuestionButton({ question }: { question: QuizQuestionData }) {
  const { user } = useAuth();
  const [state, setState] = useState<"idle" | "sending" | "sent" | "error">("idle");

  if (!user) return null;

  const handleReport = async () => {
    const comment = window.prompt(
      "What's wrong with this question? (optional — leave blank to just flag it)",
    );
    if (comment === null) return; // cancelled
    setState("sending");
    try {
      await reportQuestion(question, user.uid, comment);
      setState("sent");
    } catch {
      setState("error");
    }
  };

  if (state === "sent") {
    return (
      <p className="mt-2 text-xs font-medium text-teal">
        Reported — thanks for the heads up.
      </p>
    );
  }

  return (
    <button
      type="button"
      onClick={() => void handleReport()}
      disabled={state === "sending"}
      className="mt-2 text-xs font-medium text-[var(--color-primary)]/50 underline-offset-2 hover:text-gold hover:underline disabled:opacity-60"
    >
      {state === "sending"
        ? "Reporting…"
        : state === "error"
          ? "Couldn't send — tap to retry"
          : "⚠ Report an issue with this question"}
    </button>
  );
}
