"use client";

import { Suspense, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";

/**
 * Code-entry form — the actual join transaction happens on /duel/[code]
 * once the code resolves to a real, open duel. Also accepts a `?code=`
 * query param (the shareable invite link DuelSession's waiting screen
 * generates, e.g. /duel/join?code=ABC123) and redirects straight through
 * without requiring the friend to retype the code.
 *
 * useSearchParams bails prerendering out to client-side rendering for
 * anything below it, so it needs its own Suspense boundary — see
 * node_modules/next/dist/docs/01-app/03-api-reference/04-functions/use-search-params.md
 * (same pattern as src/app/sign-in/page.tsx).
 */
export default function JoinDuelForm() {
  return (
    <Suspense fallback={null}>
      <JoinDuelFormInner />
    </Suspense>
  );
}

function JoinDuelFormInner() {
  const searchParams = useSearchParams();
  const linkedCode = searchParams.get("code")?.trim().toUpperCase() ?? "";
  const [code, setCode] = useState(linkedCode);
  const router = useRouter();

  // A code arriving via invite link goes straight to the duel — no need to
  // make the friend retype and re-submit it.
  useEffect(() => {
    if (linkedCode) {
      router.push(`/duel/${linkedCode}`);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [linkedCode]);

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    const trimmed = code.trim().toUpperCase();
    if (!trimmed) return;
    router.push(`/duel/${trimmed}`);
  };

  if (linkedCode) {
    return (
      <div className="mx-auto max-w-sm px-4 py-16 text-center sm:px-6">
        <p className="text-[var(--color-primary)]/70">Joining duel {linkedCode}…</p>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-sm px-4 py-16 text-center sm:px-6">
      <h1 className="text-xl font-bold text-[var(--color-primary)]">Join a Duel</h1>
      <p className="mt-2 text-sm text-[var(--color-primary)]/60">
        Enter the 6-character code your friend shared with you.
      </p>
      <form onSubmit={handleSubmit} className="mt-6">
        <input
          value={code}
          onChange={(e) => setCode(e.target.value.toUpperCase())}
          maxLength={6}
          placeholder="ABC123"
          autoCapitalize="characters"
          className="w-full rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 text-center text-2xl font-bold tracking-widest text-[var(--color-primary)] outline-none focus:border-gold"
        />
        <button
          type="submit"
          disabled={code.trim().length === 0}
          className="mt-4 w-full rounded-full bg-gold px-6 py-3 text-sm font-semibold text-navy transition-colors hover:brightness-105 disabled:opacity-60"
        >
          Go
        </button>
      </form>
    </div>
  );
}
