const {onSchedule} = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');

// Matches the Africa/Lagos convention used elsewhere (reminders.js,
// streak_push.js, entitlements.js) even though ranking itself isn't
// calendar-sensitive — kept for consistency/observability (logs line up
// with the same "day" students experience).
const TIMEZONE = 'Africa/Lagos';

// Every 6 hours: leaderboard position isn't something students need
// second-by-second, and a full `users` collection scan (see scaling note
// below) four times a day keeps read costs low while still feeling "fresh
// enough" for a rank display. Easy to tighten later if it feels stale.
const SCHEDULE = 'every 6 hours';

const BATCH_WRITE_LIMIT = 450; // Firestore hard cap is 500 ops/batch; leave headroom.

async function commitInChunks(db, entries) {
  for (let i = 0; i < entries.length; i += BATCH_WRITE_LIMIT) {
    const chunk = entries.slice(i, i + BATCH_WRITE_LIMIT);
    const batch = db.batch();
    for (const [uid, data] of chunk) {
      batch.set(db.collection('users').doc(uid), data, {merge: true});
    }
    await batch.commit();
  }
}

/**
 * Recomputes `nigeriaRank` (1-based position by cumulative `xp`, across all
 * users) and `stateRank` (1-based position by `xp` within a user's `state`
 * field, if set) and writes them back onto each `users/{uid}` doc. Pure
 * server-side batch job — runs under the Admin SDK, so it bypasses
 * firestore.rules entirely; no rule changes needed for this write.
 *
 * SCALING LIMITATION (documented, not fixed here): this reads the *entire*
 * `users` collection into memory in one `.get()` every run. Fine at
 * thousands of users; at tens/hundreds of thousands this should be
 * rewritten to paginate (`startAfter` cursors) and/or shard by school or
 * region instead of one global scan. Out of scope for v1.
 *
 * DEFENSIVE: a user doc with a non-numeric/missing `xp` is skipped from
 * ranking entirely (no `nigeriaRank`/`stateRank` written — matches the
 * `RankInfo.nigeriaRank: null` "not yet computed" contract in
 * web-next/src/lib/leaderboard.ts). A doc that throws while being read is
 * logged and skipped rather than aborting the whole run.
 */
async function computeLeaderboardRanks() {
  const db = admin.firestore();
  const snapshot = await db.collection('users').get();

  // {uid, xp, state|null}, already filtered to "has a valid xp field".
  const ranked = [];
  for (const userDoc of snapshot.docs) {
    try {
      const data = userDoc.data() || {};
      if (typeof data.xp !== 'number' || Number.isNaN(data.xp)) continue;
      const state = typeof data.state === 'string' && data.state.trim() ? data.state : null;
      ranked.push({uid: userDoc.id, xp: data.xp, state});
    } catch (err) {
      console.error(`computeLeaderboardRanks: skipping malformed user doc ${userDoc.id}:`, err);
    }
  }

  // Descending by xp — ties keep insertion order (stable sort), which is
  // fine; exact tie-breaking isn't specified.
  ranked.sort((a, b) => b.xp - a.xp);

  // uid -> partial update ({nigeriaRank} and/or {stateRank}), merged into a
  // single write per user rather than two separate batch ops.
  const updates = new Map();
  ranked.forEach((entry, index) => {
    updates.set(entry.uid, {nigeriaRank: index + 1});
  });

  const byState = new Map();
  for (const entry of ranked) {
    if (!entry.state) continue; // no state set yet — stateRank stays unwritten (null per contract)
    if (!byState.has(entry.state)) byState.set(entry.state, []);
    byState.get(entry.state).push(entry);
  }
  // Each byState bucket is already in descending-xp order because `ranked`
  // was sorted before this grouping loop ran.
  for (const stateEntries of byState.values()) {
    stateEntries.forEach((entry, index) => {
      const existing = updates.get(entry.uid) || {};
      existing.stateRank = index + 1;
      updates.set(entry.uid, existing);
    });
  }

  await commitInChunks(db, Array.from(updates.entries()));
  console.log(
    `computeLeaderboardRanks: ranked ${ranked.length} users across ${byState.size} states (of ${snapshot.size} total user docs).`,
  );
}

exports.computeLeaderboardRanks = onSchedule(
  {
    schedule: SCHEDULE,
    timeZone: TIMEZONE,
    region: 'us-central1',
  },
  async () => {
    await computeLeaderboardRanks();
  },
);

// Exposed for tests/manual invocation if ever needed.
exports._computeLeaderboardRanks = computeLeaderboardRanks;
