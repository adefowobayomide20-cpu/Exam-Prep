const {onSchedule} = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const {writeNotifications} = require('./notifications');

// Matches the hardcoded Africa/Lagos assumption elsewhere (reminders.js,
// lib/data/local_notification_service.dart).
const TIMEZONE = 'Africa/Lagos';

function nowInLagos() {
  return new Date(new Date().toLocaleString('en-US', {timeZone: TIMEZONE}));
}

// yyyy-MM-dd, zero-padded — must match StreakData.dateKey in
// lib/data/models/streak_data.dart so string comparison works.
function dateKey(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}

function yesterdayKey(today) {
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  return dateKey(yesterday);
}

// Runs once daily in the evening, after most students have had a chance to
// study but before the day resets. Nudges anyone who hasn't practiced yet
// today: streak-loss urgency if they have one going, a softer nudge to
// start one otherwise. Respects the "Push notifications" profile toggle.
exports.sendDailyStreakNudge = onSchedule(
  {
    schedule: 'every day 19:00',
    timeZone: TIMEZONE,
    region: 'us-central1',
  },
  async () => {
    const now = nowInLagos();
    const today = dateKey(now);
    const yesterday = yesterdayKey(now);

    const usersSnapshot = await admin.firestore().collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const data = userDoc.data();
      const tokens = data.fcmTokens || [];
      const pushEnabled = data.profile?.pushNotifications !== false;
      if (tokens.length === 0 || !pushEnabled) continue;

      const streak = data.streak || {};
      if (streak.lastActiveDate === today) continue; // already practiced today

      const currentStreak = streak.currentStreak || 0;
      const atRisk = currentStreak > 0 && streak.lastActiveDate === yesterday;

      const title = atRisk
        ? `Your ${currentStreak}-day streak ends at midnight!`
        : 'Keep your prep on track';
      const body = atRisk
        ? 'Take one quiz or duel now to keep it alive.'
        : "You haven't practiced today — a quick quiz keeps you exam-ready.";

      await admin
        .messaging()
        .sendEachForMulticast({
          tokens,
          notification: {title, body},
          data: {type: 'streak_nudge'},
          android: {notification: {channelId: 'exam_prep_default'}},
          webpush: {notification: {icon: '/icons/Icon-192.png'}},
        })
        .catch((err) => console.error(`Failed to send streak nudge for user ${userDoc.id}:`, err));

      writeNotifications([userDoc.id], {
        id: `streak_${today}`,
        type: 'system',
        title,
        body,
        link: '',
        createdAt: new Date().toISOString(),
        read: false,
      }).catch((err) => console.error(`Failed to write streak notification for user ${userDoc.id}:`, err));
    }
  },
);
