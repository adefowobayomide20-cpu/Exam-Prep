const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

/**
 * Minimal friends system backend — see web-next/src/lib/friends.ts for the
 * full design rationale. Two onCall functions live here because both need
 * a cross-user Firestore read that firestore.rules (repo root, NOT
 * modified) doesn't allow from the client:
 *
 *   match /users/{userId} {
 *     allow read: if request.auth != null && request.auth.uid == userId;
 *     ...
 *   }
 *
 * That rule only allows a signed-in user to read their OWN `users/{uid}`
 * doc — not another user's doc by ID, and not a `where('friendCode', '==',
 * ...)` query across the collection (Firestore evaluates security rules
 * per-matched-document, so a query that would touch any doc other than the
 * caller's own is rejected outright, not just filtered). Both operations
 * below need to read other users' docs, so both are Admin-SDK server-side
 * calls instead of client Firestore calls.
 */

/**
 * Looks up which user owns `code` and, if found (and not the caller, and
 * not already added), writes `users/{callerUid}/friends/{friendUid}` with a
 * denormalized snapshot of the friend's displayName/avatarUrl/xp — the
 * friends subcollection is only ever read by its owner (allowed under the
 * existing `users/{userId}/{subcollection}/{docId}` rule), so join fields
 * that need to survive rule restrictions must be copied in at write time.
 *
 * SIMPLIFICATION: this is one-directional. Adding B via B's code writes
 * only `A/friends/B`, not `B/friends/A` — "mutual friending" isn't
 * required for a "rank among people I've added" computation. Documented in
 * friends.ts too.
 */
exports.addFriendByCode = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  const uid = request.auth.uid;
  const rawCode = request.data && request.data.code;
  const code = typeof rawCode === 'string' ? rawCode.trim().toUpperCase() : '';
  if (!code) {
    throw new HttpsError('invalid-argument', 'A friend code is required.');
  }

  const db = admin.firestore();
  const matches = await db.collection('users').where('friendCode', '==', code).limit(1).get();
  if (matches.empty) {
    return {ok: false, reason: 'not-found'};
  }

  const friendDoc = matches.docs[0];
  const friendUid = friendDoc.id;
  if (friendUid === uid) {
    return {ok: false, reason: 'self'};
  }

  const friendRef = db.collection('users').doc(uid).collection('friends').doc(friendUid);
  const existing = await friendRef.get();
  if (existing.exists) {
    return {ok: false, reason: 'already-added'};
  }

  const friendData = friendDoc.data() || {};
  await friendRef.set({
    uid: friendUid,
    displayName: typeof friendData.displayName === 'string' ? friendData.displayName : null,
    avatarUrl: typeof friendData.avatarUrl === 'string' ? friendData.avatarUrl : null,
    xp: typeof friendData.xp === 'number' ? friendData.xp : 0,
    addedAt: new Date().toISOString(),
  });

  return {ok: true};
});

const XP_QUERY_CHUNK = 30; // Firestore `in` query cap.

/**
 * Best-effort re-sync of the denormalized displayName/avatarUrl/xp copies
 * stored on the caller's own `friends/{friendUid}` docs (see
 * addFriendByCode above for why those are snapshots, not live joins).
 * Called opportunistically by useFriendsList (web-next/src/lib/friends.ts)
 * whenever the friends list mounts, so "Friends rank" reflects reasonably
 * fresh XP without needing a live cross-user listener (which rules don't
 * allow). Not scheduled/automatic — a friend's xp only refreshes the next
 * time the viewing user opens their friends list. Acceptable staleness for
 * a v1 "rank among friends" feature; document as a known simplification.
 */
exports.refreshFriendsData = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  const uid = request.auth.uid;
  const db = admin.firestore();

  const friendsSnap = await db.collection('users').doc(uid).collection('friends').get();
  if (friendsSnap.empty) {
    return {ok: true, updated: 0};
  }
  const friendIds = friendsSnap.docs.map((d) => d.id);

  let updated = 0;
  for (let i = 0; i < friendIds.length; i += XP_QUERY_CHUNK) {
    const chunk = friendIds.slice(i, i + XP_QUERY_CHUNK);
    const usersSnap = await db
      .collection('users')
      .where(admin.firestore.FieldPath.documentId(), 'in', chunk)
      .get();

    const batch = db.batch();
    for (const friendUserDoc of usersSnap.docs) {
      const data = friendUserDoc.data() || {};
      batch.set(
        db.collection('users').doc(uid).collection('friends').doc(friendUserDoc.id),
        {
          displayName: typeof data.displayName === 'string' ? data.displayName : null,
          avatarUrl: typeof data.avatarUrl === 'string' ? data.avatarUrl : null,
          xp: typeof data.xp === 'number' ? data.xp : 0,
        },
        {merge: true},
      );
      updated += 1;
    }
    await batch.commit();
  }

  return {ok: true, updated};
});
