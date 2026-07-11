const {onSchedule} = require('firebase-functions/v2/scheduler');
const {defineSecret} = require('firebase-functions/params');
const admin = require('firebase-admin');
const https = require('https');
const crypto = require('crypto');

admin.initializeApp();

const {writeNotifications} = require('./notifications');

const newsDataApiKey = defineSecret('NEWSDATA_API_KEY');

// Mirrors lib/features/news/news_service.dart on the Flutter side. Kept in
// sync manually since this runs server-side against the same free-tier
// 100-char qInTitle limit.
const EXAM_KEYWORDS = 'WAEC OR NECO OR JAMB OR GCE OR "Post-JAMB" OR "Post-UTME" OR admission';
const CAMPUS_KEYWORDS = 'ASUU OR ASUP OR "school fees" OR "admission form" OR "cut-off mark"';
const FUNDING_KEYWORDS = 'scholarship OR bursary OR "admission list" OR CAPS';

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (d) => (data += d));
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function fetchKeyword(apiKey, qInTitle) {
  const url = `https://newsdata.io/api/1/latest?apikey=${apiKey}&country=ng&language=en&qInTitle=${encodeURIComponent(qInTitle)}`;
  const json = await fetchJson(url);
  if (json.status !== 'success') return [];
  return json.results || [];
}

function sourceNameFor(article) {
  const sourceId = article.source_id || '';
  if (!sourceId) return 'Exam Prep';
  return sourceId[0].toUpperCase() + sourceId.slice(1).replace(/-/g, ' ');
}

// FCM's multicast API caps each request at 500 registration tokens.
const FCM_MULTICAST_LIMIT = 500;

function chunk(array, size) {
  const chunks = [];
  for (let i = 0; i < array.length; i += size) chunks.push(array.slice(i, i + size));
  return chunks;
}

// Every subscribed user (filtered by their "Push notifications" toggle),
// with their uid (to write the in-app notification record) and saved
// device/browser tokens (to push to directly — not via a topic, since
// Firebase's web SDK doesn't implement topic subscription, matching the
// same per-token approach already used by `checkStudyReminders` and
// `sendDailyStreakNudge`).
async function newsRecipients() {
  const usersSnapshot = await admin.firestore().collection('users').get();
  const recipients = [];
  for (const userDoc of usersSnapshot.docs) {
    const data = userDoc.data();
    if (data.profile?.pushNotifications === false) continue;
    recipients.push({uid: userDoc.id, tokens: data.fcmTokens || []});
  }
  return recipients;
}

// Stable id for a notified article, derived from the same dedup key used
// for `seenIds` below, so retried/overlapping runs write (merge) the same
// Firestore doc instead of duplicating it in each recipient's bell.
function articleNotificationId(key) {
  return crypto.createHash('sha1').update(String(key)).digest('hex');
}

async function sendToTokens(tokens, {notification, data}) {
  for (const tokenChunk of chunk(tokens, FCM_MULTICAST_LIMIT)) {
    await admin.messaging().sendEachForMulticast({
      tokens: tokenChunk,
      notification,
      data,
      android: {notification: {channelId: 'exam_prep_default'}},
      webpush: {notification: {icon: '/icons/Icon-192.png'}},
    });
  }
}

// Runs every 30 minutes, checks newsdata.io for anything new since the last
// run, and pushes at most a few notifications per run (capped) to every
// subscribed user's devices so students aren't spammed if several stories
// land at once.
exports.pollEducationNews = onSchedule(
  {
    schedule: 'every 30 minutes',
    secrets: [newsDataApiKey],
    region: 'us-central1',
  },
  async () => {
    const apiKey = newsDataApiKey.value();
    const [exam, campus, funding] = await Promise.all([
      fetchKeyword(apiKey, EXAM_KEYWORDS),
      fetchKeyword(apiKey, CAMPUS_KEYWORDS),
      fetchKeyword(apiKey, FUNDING_KEYWORDS),
    ]);

    const seenRef = admin.firestore().collection('meta').doc('seenNewsArticles');
    const seenDoc = await seenRef.get();
    const seenIds = new Set(seenDoc.exists ? seenDoc.data().ids || [] : []);

    const dedupedByKey = new Map();
    for (const article of [...exam, ...campus, ...funding]) {
      const key = article.article_id || article.link || article.title;
      if (!dedupedByKey.has(key)) dedupedByKey.set(key, article);
    }

    const freshArticles = [...dedupedByKey.entries()].filter(([key]) => !seenIds.has(key));

    // Cap how many we actually notify about per run; still record every
    // article we saw so nothing gets notified twice later.
    const toNotify = freshArticles.slice(0, 3);

    if (toNotify.length > 0) {
      const recipients = await newsRecipients();
      const tokens = recipients.flatMap((r) => r.tokens);
      const uids = recipients.map((r) => r.uid);

      for (const [key, article] of toNotify) {
        const title = article.title || 'Untitled';
        const body = sourceNameFor(article);

        if (tokens.length > 0) {
          await sendToTokens(tokens, {
            notification: {title, body},
            data: {
              type: 'news',
              title,
              link: article.link || '',
              source_id: article.source_id || '',
              pubDate: article.pubDate || '',
              description: article.description || '',
              image_url: article.image_url || '',
            },
          });
        }

        if (uids.length > 0) {
          await writeNotifications(uids, {
            id: articleNotificationId(key),
            type: 'news',
            title,
            body,
            link: article.link || '',
            sourceId: article.source_id || '',
            pubDate: article.pubDate || '',
            description: article.description || '',
            imageUrl: article.image_url || '',
            createdAt: new Date().toISOString(),
            read: false,
          });
        }
      }
    }

    const newSeenIds = [...seenIds, ...dedupedByKey.keys()].slice(-500);
    await seenRef.set({
      ids: newSeenIds,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  },
);

exports.solveQuestion = require('./tutor').solveQuestion;
exports.explainLikeImFive = require('./eli5').explainLikeImFive;
exports.cleanupUserData = require('./cleanup').cleanupUserData;
exports.generateTheoryQuestion = require('./theory').generateTheoryQuestion;
exports.gradeTheoryAnswer = require('./theory').gradeTheoryAnswer;
exports.checkStudyReminders = require('./reminders').checkStudyReminders;
exports.sendDailyStreakNudge = require('./streak_push').sendDailyStreakNudge;
