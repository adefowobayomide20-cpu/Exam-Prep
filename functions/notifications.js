const admin = require('firebase-admin');

// Firestore batched writes cap at 500 mutations; stay well under it.
const BATCH_LIMIT = 450;

// Writes the same notification document into every listed user's
// `users/{uid}/notifications` subcollection, mirroring the schema
// lib/data/models/app_notification.dart reads via NotificationStore. Keyed
// by `notification.id` so re-running a schedule (retry, overlap) merges
// instead of duplicating.
async function writeNotifications(uids, notification) {
  const db = admin.firestore();
  for (let i = 0; i < uids.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    for (const uid of uids.slice(i, i + BATCH_LIMIT)) {
      const ref = db.collection('users').doc(uid).collection('notifications').doc(notification.id);
      batch.set(ref, notification, {merge: true});
    }
    await batch.commit();
  }
}

module.exports = {writeNotifications};
