// Handles FCM push notifications that arrive while no tab is open/focused.
// Firebase's web SDK requires this exact file at the site root; it runs in
// its own service-worker context, separate from the Flutter app bundle, so
// it re-declares the same firebaseConfig from lib/firebase_options.dart
// rather than importing it.
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDNNZqKZovbJZOB-u6-UlkNDwqgLG6b9sI',
  appId: '1:734285493928:web:ef4dd3fa2f41a1fa38749d',
  messagingSenderId: '734285493928',
  projectId: 'exam-prep-ng',
  authDomain: 'exam-prep-ng.firebaseapp.com',
  storageBucket: 'exam-prep-ng.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  self.registration.showNotification(notification.title || 'Exam Coach', {
    body: notification.body || '',
    icon: '/icons/Icon-192.png',
    data: {link: payload.data && payload.data.link},
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const link = event.notification.data && event.notification.data.link;
  event.waitUntil(clients.openWindow(link || '/'));
});
