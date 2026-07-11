import 'package:web/web.dart' as web;

/// Shows a real OS-level browser notification for an FCM message that
/// arrives while the tab is in the foreground. `flutter_local_notifications`
/// has no web implementation, so foreground web push otherwise only landed
/// silently in the in-app notification list with nothing visible — this is
/// why study reminders/streak nudges/news pushes appeared to "not beep" on
/// web specifically while the tab was open. Requires notification
/// permission to already be granted (via `FirebaseMessaging.requestPermission`,
/// which triggers the same browser permission prompt on web).
void showWebNotification({required String title, required String body}) {
  if (web.Notification.permission != 'granted') return;
  web.Notification(title, web.NotificationOptions(body: body, icon: '/icons/Icon-192.png'));
}
