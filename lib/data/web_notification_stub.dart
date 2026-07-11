/// Non-web platforms show FCM foreground messages via
/// [LocalNotificationService] instead — this is a no-op there.
void showWebNotification({required String title, required String body}) {}
