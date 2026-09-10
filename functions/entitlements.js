const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

// Matches the hardcoded Africa/Lagos assumption elsewhere (reminders.js,
// streak_push.js, lib/data/local_notification_service.dart) — "today" for
// the free-action counter should follow the student's actual day, not
// whatever timezone the Cloud Function happens to run in.
const TIMEZONE = 'Africa/Lagos';

// Shared across Snap & Solve and Theory (generation + grading each count as
// one action) — one daily allowance, not a separate cap per feature.
const FREE_DAILY_AI_ACTIONS = 3;

function nowInLagos() {
  return new Date(new Date().toLocaleString('en-US', {timeZone: TIMEZONE}));
}

function dateKey(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}

function isPremiumActive(premium) {
  if (!premium || !premium.active) return false;
  if (!premium.expiresAt) return true;
  return new Date(premium.expiresAt).getTime() > Date.now();
}

// Runs inside a Firestore transaction so concurrent calls (e.g. a fast
// double-tap) can't both read the same pre-increment count and slip past the
// limit. Premium users are never metered. Free users draw down today's free
// actions first, then any rewarded-ad bonus uses, then get
// HttpsError('resource-exhausted', ...), which the Flutter side catches to
// show the paywall instead of a generic error.
async function checkAndConsumeAiAction(uid, {freeLimit}) {
  const db = admin.firestore();
  const ref = db.collection('users').doc(uid);
  const today = dateKey(nowInLagos());

  await db.runTransaction(async (tx) => {
    const doc = await tx.get(ref);
    const data = doc.data() || {};
    if (isPremiumActive(data.premium)) return;

    const aiUsage = data.aiUsage || {};
    const countToday = aiUsage.date === today ? aiUsage.count || 0 : 0;

    if (countToday < freeLimit) {
      tx.set(ref, {aiUsage: {date: today, count: countToday + 1}}, {merge: true});
      return;
    }

    const bonusUses = typeof data.bonusUses === 'number' ? data.bonusUses : 0;
    if (bonusUses > 0) {
      tx.set(ref, {bonusUses: bonusUses - 1}, {merge: true});
      return;
    }

    throw new HttpsError(
      'resource-exhausted',
      "You've used today's free AI helps. Upgrade to Premium for unlimited, or watch an ad for one more.",
    );
  });
}

// Called after the client reports an AdMob rewarded-ad "earned reward"
// callback. This trusts the client's claim rather than verifying Google's
// signed server-side callback (AdMob SSV) — acceptable here since the stakes
// are a few bonus AI actions, not money. Full SSV is a reasonable future
// hardening step if abuse turns out to be a problem, not needed for this
// pass.
async function grantBonusAiAction(uid) {
  const db = admin.firestore();
  const ref = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const doc = await tx.get(ref);
    const bonusUses = typeof (doc.data() || {}).bonusUses === 'number' ? doc.data().bonusUses : 0;
    tx.set(ref, {bonusUses: bonusUses + 1}, {merge: true});
  });
}

// Callable from the app the instant AdMob's onUserEarnedReward fires.
const claimRewardedAdBonus = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  await grantBonusAiAction(request.auth.uid);
  return {ok: true};
});

module.exports = {
  checkAndConsumeAiAction,
  grantBonusAiAction,
  isPremiumActive,
  dateKey,
  nowInLagos,
  FREE_DAILY_AI_ACTIONS,
  claimRewardedAdBonus,
};
