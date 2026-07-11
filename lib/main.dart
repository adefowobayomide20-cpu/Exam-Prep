import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:url_launcher/url_launcher.dart';

import 'app.dart';
import 'data/app_data_store.dart';
import 'data/auth_service.dart';
import 'data/deep_link_service.dart';
import 'data/local_notification_service.dart';
import 'data/lobby_presence_controller.dart';
import 'data/notification_store.dart';
import 'data/push_notification_service.dart';
import 'data/tutor_chat_store.dart';
import 'firebase_options.dart';

/// Renders whatever killed startup directly on screen. Diagnosing a blank
/// splash screen over chat with a non-technical user is impossible if the
/// only error lives in a browser console they can't easily relay, so any
/// startup failure below shows its own message instead of hanging forever.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF12203D),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  'Startup failed:\n\n$message',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// On web, Firebase's plugin registrant sometimes hasn't finished wiring up
/// its platform channel by the time this runs, which throws a transient
/// PlatformException("channel-error", ...) even though the app is
/// configured correctly. Retrying after a short delay clears it.
Future<void> _initializeFirebaseWithRetry() async {
  const maxAttempts = 8;
  for (var attempt = 1; ; attempt++) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      return;
    } catch (error) {
      if (attempt >= maxAttempts || error is! PlatformException || error.code != 'channel-error') {
        rethrow;
      }
      debugPrint('Firebase init channel-error, retrying (attempt $attempt): $error');
      await Future.delayed(Duration(milliseconds: 500 * attempt));
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter's recommended hook for errors escaping normal widget-build error
  // handling, without the zone-mismatch pitfalls of wrapping main() in
  // runZonedGuarded (binding init and runApp must share a zone, and async
  // gaps around Firebase init made that fragile).
  WidgetsBinding.instance.platformDispatcher.onError = (error, stackTrace) {
    debugPrint('Uncaught error: $error\n$stackTrace');
    runApp(_StartupErrorApp(message: '${error.runtimeType}: $error'));
    return true;
  };

  try {
    await _initializeFirebaseWithRetry();
  } catch (error, stackTrace) {
    runApp(_StartupErrorApp(message: '${error.runtimeType}: $error\n\n$stackTrace'));
    return;
  }

  // flutter_local_notifications has no web support at all — foreground
  // system notifications there come from the browser's own Notification
  // API via the FCM SDK instead, so this stays mobile-only.
  if (!kIsWeb) {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await LocalNotificationService.instance.initialize(
        onTap: (payload) {
          if (payload == null) return;
          try {
            openNotificationTarget(jsonDecode(payload) as Map<String, dynamic>);
          } on FormatException {
            // Legacy payload from before notification data was JSON-encoded
            // (a bare URL string) — still safe to open directly.
            launchUrl(Uri.parse(payload), mode: LaunchMode.externalApplication);
          }
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Notification initialization failed: $error\n$stackTrace');
    }
  }

  // Neither of these needs to finish before first paint — they just attach
  // listeners for taps/links that can arrive any time after startup, so
  // running them fire-and-forget instead of awaiting keeps first paint from
  // being held up by FCM/plugin setup (this was blocking `runApp` for every
  // platform, web included).
  unawaited(
    PushNotificationService.instance.initialize().catchError((error, stackTrace) {
      debugPrint('Push notification initialization failed: $error\n$stackTrace');
    }),
  );

  // App Links/Universal Links only make sense for the native app being
  // cold-started or resumed via an OS-level link tap — a web PWA reached at
  // /duel/<code> just loads normally, there's no separate "incoming link"
  // event to intercept, so this is native-only.
  if (!kIsWeb) {
    unawaited(
      DeepLinkService.instance.init().catchError((error, stackTrace) {
        debugPrint('Deep link initialization failed: $error\n$stackTrace');
      }),
    );
  }

  AuthService.instance.authStateChanges.listen((user) {
    if (user != null) {
      AppDataStore.instance.bindToUser(user.uid);
      NotificationStore.instance.bindToUser(user.uid);
      TutorChatStore.instance.bindToUser(user.uid);
      LobbyPresenceController.instance.bindToUser(user.uid);
      // Lets checkStudyReminders/sendDailyStreakNudge/pollEducationNews push
      // straight to this device/browser; each Cloud Function checks the
      // "Push notifications" toggle itself before sending.
      PushNotificationService.instance.syncTokenForUser(user.uid);
    } else {
      AppDataStore.instance.unbind();
      NotificationStore.instance.unbind();
      TutorChatStore.instance.unbind();
      LobbyPresenceController.instance.unbind();
    }
  });

  runApp(const ExamCoachApp());
}
