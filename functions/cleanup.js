const {auth} = require('firebase-functions/v1');
const admin = require('firebase-admin');

// When a student deletes their account, the client only deletes the Auth
// user (see AuthService.deleteAccount in the Flutter app). This trigger
// removes their Firestore data — quiz history, reminders, notifications,
// tutor chats, duel history — so nothing orphaned is left behind.
exports.cleanupUserData = auth.user().onDelete(async (user) => {
  const userDoc = admin.firestore().collection('users').doc(user.uid);
  await admin.firestore().recursiveDelete(userDoc);
});
