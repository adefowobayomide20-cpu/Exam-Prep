import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import '../features/news/news_article.dart';
import '../features/news/news_detail_page.dart';
import '../navigation/root_navigator.dart';
import '../widgets/slide_up_route.dart';
import 'local_notification_service.dart';
import 'web_notification.dart';

/// Web push has no OS-level channel to broker the subscription the way
/// Android/iOS do, so it needs its own key pair. Generated once in Firebase
/// Console > Project settings > Cloud Messaging > Web Push certificates.
/// This is the *public* half of that pair — Firebase's own docs say it's
/// safe to ship in client code — so it's baked in as the default instead of
/// relying on every build remembering `--dart-define=FCM_WEB_VAPID_KEY=...`
/// (a manual build without that flag was the actual cause of web push
/// silently never registering a token).
const _webPushVapidKey = String.fromEnvironment(
  'FCM_WEB_VAPID_KEY',
  defaultValue:
      'BGCs_Oz4q8d518c_q1-Kqkzt3XlOBBriwG_I3-eCGnXLtJNyzstXOKq_EnF0FlmqT7HBbKs7vv9bs4lHCpJzUHI',
);

/// Registered via [FirebaseMessaging.onBackgroundMessage] in main.dart. This
/// is intentionally a no-op: the system tray notification for a
/// backgrounded/terminated app is displayed automatically from the FCM
/// message's `notification` payload, and persistence to the notification
/// bell is now written server-side (see functions/notifications.js) instead
/// of from here — this isolate has no signed-in [NotificationStore] bound to
/// it, which previously made that write silently fail every time.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Routes a tapped notification to the right in-app destination — news
/// alerts open [NewsDetailPage] so users land on Exam Coach first, instead
/// of jumping straight to the external article. Other types fall back to
/// whatever `link` they carry, if any.
void openNotificationTarget(Map<String, dynamic> data) {
  if (data['type'] == 'news') {
    rootNavigatorKey.currentState?.push(
      SlideUpRoute(builder: (_) => NewsDetailPage(article: NewsArticle.fromNewsDataJson(data))),
    );
    return;
  }
  final link = data['link'] as String?;
  if (link != null && link.isNotEmpty) {
    launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification != null) {
        final title = notification.title ?? 'Exam Coach';
        final body = notification.body ?? '';
        if (kIsWeb) {
          showWebNotification(title: title, body: body);
        } else {
          await LocalNotificationService.instance.showNow(
            id: message.hashCode & 0x7fffffff,
            title: title,
            body: body,
            payload: jsonEncode(message.data),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleTap(initialMessage);
  }

  void _handleTap(RemoteMessage message) => openNotificationTarget(message.data);

  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Saves this device/browser's FCM token to Firestore so the
  /// `checkStudyReminders`, `sendDailyStreakNudge`, and `pollEducationNews`
  /// Cloud Functions can push to it directly — all three send straight to
  /// each user's saved tokens (gated by the "Push notifications" toggle on
  /// the server side) rather than topics, since topic subscription throws
  /// on Firebase's web SDK and would leave web users unable to receive
  /// exam-news pushes at all. Called on sign-in from main.dart; safe to
  /// call repeatedly.
  Future<void> syncTokenForUser(String uid) async {
    try {
      final token = kIsWeb
          ? (_webPushVapidKey.isEmpty
              ? null
              : await FirebaseMessaging.instance.getToken(vapidKey: _webPushVapidKey))
          : await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(uid, token);
    } catch (error) {
      // Missing web VAPID key, denied permission, or unsupported browser —
      // reminders still work wherever push is available, so don't block
      // sign-in over this.
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((token) => _saveToken(uid, token));
  }

  Future<void> _saveToken(String uid, String token) {
    return FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }
}
