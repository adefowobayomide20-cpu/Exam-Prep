const {onSchedule} = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const {writeNotifications} = require('./notifications');

// Nigerian exam-prep market sits in a single timezone with no DST — matches
// the hardcoded `Africa/Lagos` assumption in lib/data/local_notification_service.dart.
const TIMEZONE = 'Africa/Lagos';
const WEEKDAY_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

function nowInLagos() {
  return new Date(new Date().toLocaleString('en-US', {timeZone: TIMEZONE}));
}

function todayKey(date) {
  return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
}

// Study reminders are stored client-side as {id, days: ['Monday', ...], time:
// {hour, minute}, enabled} inline on the user's profile doc (see
// AppDataStore._writeReminders). This mirrors that shape rather than
// requiring a schema change just to make reminders fire on web too.
//
// Runs every 5 minutes and fires any enabled reminder whose scheduled
// time falls within the run's window, once per calendar day (tracked via
// `lastFiredDate` written back onto the reminder) so a slow run or clock
// drift can't double-send.
exports.checkStudyReminders = onSchedule(
  {
    schedule: 'every 5 minutes',
    region: 'us-central1',
    timeZone: TIMEZONE,
  },
  async () => {
    const now = nowInLagos();
    const today = todayKey(now);
    const todayName = WEEKDAY_NAMES[now.getDay()];
    const minutesNow = now.getHours() * 60 + now.getMinutes();

    const usersSnapshot = await admin.firestore().collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const data = userDoc.data();
      const reminders = data.reminders || [];
      const tokens = data.fcmTokens || [];
      const pushEnabled = data.profile?.pushNotifications !== false;
      if (tokens.length === 0 || !pushEnabled) continue;

      let changed = false;
      const updatedReminders = reminders.map((reminder) => {
        if (!reminder.enabled) return reminder;
        if (!Array.isArray(reminder.days) || !reminder.days.includes(todayName)) return reminder;
        if (reminder.lastFiredDate === today) return reminder;

        const scheduledMinutes = (reminder.hour ?? 0) * 60 + (reminder.minute ?? 0);
        // Window matches the 5-minute schedule so a reminder fires on the
        // first run at or after its scheduled minute, never before.
        if (minutesNow < scheduledMinutes || minutesNow - scheduledMinutes >= 5) return reminder;

        changed = true;
        const body = reminder.description && reminder.description.trim()
          ? reminder.description.trim()
          : "It's time for your scheduled study session — let's go.";
        _sendReminderPush(tokens, reminder.description).catch((err) =>
          console.error(`Failed to send reminder push for user ${userDoc.id}:`, err),
        );
        writeNotifications([userDoc.id], {
          id: `reminder_${today}_${reminder.id}`,
          type: 'reminder',
          title: 'Study time!',
          body,
          link: '',
          createdAt: new Date().toISOString(),
          read: false,
        }).catch((err) =>
          console.error(`Failed to write reminder notification for user ${userDoc.id}:`, err),
        );
        return {...reminder, lastFiredDate: today};
      });

      if (changed) {
        await userDoc.ref.set({reminders: updatedReminders}, {merge: true});
      }
    }
  },
);

async function _sendReminderPush(tokens, description) {
  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {
      title: 'Study time!',
      body: description && description.trim()
        ? description.trim()
        : "It's time for your scheduled study session — let's go.",
    },
    data: {type: 'study_reminder'},
    android: {notification: {channelId: 'exam_prep_default'}},
    webpush: {notification: {icon: '/icons/Icon-192.png'}},
  });
}
