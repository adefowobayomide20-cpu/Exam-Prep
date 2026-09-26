import { finishDuel, recordProgress } from "@/lib/duel-service";
import type { DuelDoc } from "@/lib/duel-types";

/**
 * "Play vs computer" bot opponent — simulated entirely client-side from the
 * HUMAN player's own browser tab. There is no second real Firebase Auth
 * user/client for the bot, so this module does not add any backend
 * infrastructure (no Cloud Function, no second account): it just drives the
 * SAME `duels/{code}` document a real guest would, using the ordinary
 * `recordProgress`/`finishDuel` calls from duel-service.ts with
 * `isHost: false`.
 *
 * This is allowed under the existing firestore.rules `duels/{duelId}`
 * `update` rule unmodified: the rule grants write access whenever
 * `resource.data.hostUid == request.auth.uid` (true for the human, who is
 * always the host of a vs-bot duel — see DuelHome's "Play vs Computer"
 * flow), regardless of which field prefix (`host*`/`guest*`) the update
 * touches. So the host's own authenticated session can legally write the
 * bot's `guestAnswered`/`guestCorrect`/`guestPoints`/`guestFinishedAt`
 * fields.
 *
 * IMPORTANT LIMITATION (v1, documented/accepted): because the bot only runs
 * from the human's tab, its move-timing depends on that tab staying open
 * and this module's promise chain continuing to run. If the human
 * navigates away or closes the tab mid-duel, the bot simply stops
 * progressing (same as a real opponent losing connection) — there is no
 * server-side fallback.
 */

export const AI_BOT_UID = "ai-bot";
export const AI_BOT_NAME = "Exam Coach Bot";

/** "Thinking time" per question, uniformly randomized in this range. */
const MIN_THINK_MS = 3_000;
const MAX_THINK_MS = 8_000;

/** Fixed "medium" difficulty for v1 — a single accuracy rate rather than a
 * difficulty picker, per the task's documented v1 scope call. Tune this one
 * constant (0.6–0.75 suggested range) to retune bot strength. */
const BOT_ACCURACY = 0.68;

function randomThinkMs(): number {
  return MIN_THINK_MS + Math.random() * (MAX_THINK_MS - MIN_THINK_MS);
}

/** Mirrors DuelSession's local `pointsFor` so bot scoring feels consistent
 * with how the human's own answers are scored: faster correct answers earn
 * more, floored so a slow-but-correct answer still beats a wrong one. */
function pointsFor(correct: boolean, timeTakenSeconds: number): number {
  if (!correct) return 0;
  return Math.min(20, Math.max(5, Math.round(20 - 1.5 * timeTakenSeconds)));
}

function sleep(ms: number, signal: AbortSignal): Promise<void> {
  return new Promise((resolve) => {
    if (signal.aborted) {
      resolve();
      return;
    }
    const timeout = setTimeout(resolve, ms);
    signal.addEventListener(
      "abort",
      () => {
        clearTimeout(timeout);
        resolve();
      },
      { once: true },
    );
  });
}

/**
 * Runs the bot through every question in `duel.questions` sequentially,
 * writing progress via `recordProgress({ isHost: false, ... })` after each
 * one and calling `finishDuel(duel.id, false)` once done. Call this once,
 * from an effect gated to `isDuelHost(duel, uid) && duel.guestUid ===
 * AI_BOT_UID && duel.status === "active"` (see DuelSession.tsx), and abort
 * `signal` on unmount/duel-end so the timers don't keep firing pointlessly.
 *
 * Total expected runtime for the default 10-question duel is roughly
 * 30–80s (10 questions × 3–8s thinking time), comfortably inside the
 * 5-minute duel window, so the bot reliably finishes and calls
 * `finishDuel` before the shared countdown expires.
 */
export async function runAiOpponent(duel: DuelDoc, signal: AbortSignal): Promise<void> {
  let answered = 0;
  let correct = 0;
  let points = 0;

  for (let index = 0; index < duel.questions.length; index += 1) {
    if (signal.aborted) return;
    const thinkMs = randomThinkMs();
    await sleep(thinkMs, signal);
    if (signal.aborted) return;

    const isCorrect = Math.random() < BOT_ACCURACY;
    answered += 1;
    if (isCorrect) correct += 1;
    points += pointsFor(isCorrect, thinkMs / 1000);

    try {
      await recordProgress({ duelId: duel.id, isHost: false, answered, correct, points });
    } catch {
      // A single progress write failing isn't fatal — the next question's
      // write (or the final finishDuel) carries the latest totals forward.
    }
  }

  if (signal.aborted) return;
  try {
    await finishDuel(duel.id, false);
  } catch {
    // Best-effort — if this fails the human's own finish (or a reload) will
    // still eventually resolve the duel via the timeout path.
  }
}
