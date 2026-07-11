import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wraps flutter_local_notifications for two jobs:
///  - showing FCM news alerts as a system notification while the app is
///    open (Android doesn't auto-display foreground FCM messages), and
///  - scheduling the weekly "study reminder" alarms set in Profile, which
///    previously just sat in Firestore doing nothing.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const _channelId = 'exam_prep_default';
  static const _channelName = 'Exam Coach';
  static const _channelDescription = 'News alerts and study reminders';

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// The app is built for the Nigerian exam-prep market, which sits in a
  /// single timezone with no daylight saving, so this is hardcoded rather
  /// than pulling in a separate device-timezone-lookup package.
  static const _localTimeZone = 'Africa/Lagos';

  Future<void> initialize({void Function(String? payload)? onTap}) async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_localTimeZone));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) => onTap?.call(response.payload),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );
  }

  Future<bool> requestPermission() async {
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    if (!_initialized) return Future.value();
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details,
      payload: payload,
    );
  }

  /// Schedules (or reschedules) a weekly reminder for [weekday]
  /// (1 = Monday .. 7 = Sunday, matching [DateTime.weekday]) at [time].
  Future<void> scheduleWeekly({
    required int id,
    required int weekday,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    await cancel(id);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfWeekday(weekday, time),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancel(int id) {
    if (!_initialized) return Future.value();
    return _plugin.cancel(id: id);
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, TimeOfDay time) {
    var scheduled = tz.TZDateTime.now(tz.local);
    scheduled = tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      time.hour,
      time.minute,
    );
    while (scheduled.weekday != weekday || scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Stable positive 32-bit id for scheduling, derived from a Firestore
/// document id string (local_notifications plugin requires an int id).
int notificationIdFromString(String id) => id.hashCode & 0x7fffffff;
