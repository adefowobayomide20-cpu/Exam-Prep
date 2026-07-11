import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'local_notification_service.dart';
import 'models/duel_result.dart';
import 'models/profile_settings.dart';
import 'models/quiz_attempt.dart';
import 'models/streak_data.dart';
import 'models/study_reminder.dart';

/// App-wide data store: holds the signed-in user's profile, study
/// reminders, and quiz history in memory, synced with Cloud Firestore under
/// `users/{uid}`. Widgets listen to this via [ListenableBuilder] to stay in
/// sync as data changes anywhere in the app.
///
/// Call [bindToUser] when a user signs in and [unbind] when they sign out
/// (see `main.dart`, which does this in response to [AuthService]'s auth
/// state stream). Firestore's built-in offline cache means reads/writes
/// still work without a network connection.
class AppDataStore extends ChangeNotifier {
  AppDataStore._();

  static final AppDataStore instance = AppDataStore._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? _uid;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _historySub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _duelHistorySub;

  ProfileSettings _profile = ProfileSettings.defaults();
  List<StudyReminder> _reminders = StudyReminder.defaults();
  List<QuizAttempt> _quizHistory = [];
  List<DuelResult> _duelHistory = [];
  StreakData _streak = StreakData.defaults();
  bool _loading = false;

  bool get loading => _loading;
  ProfileSettings get profile => _profile;
  List<StudyReminder> get reminders => List.unmodifiable(_reminders);
  List<QuizAttempt> get quizHistory => List.unmodifiable(_quizHistory);
  List<DuelResult> get duelHistory => List.unmodifiable(_duelHistory);
  StreakData get streak => _streak;
  int get currentStreak => _streak.displayedStreak;
  int get longestStreak => _streak.longestStreak;
  bool get streakActiveToday => _streak.activeToday;

  int get quizzesTaken => _quizHistory.length;
  int get duelsWon => _duelHistory.where((d) => d.won).length;

  double get averageScorePercent {
    if (_quizHistory.isEmpty) return 0;
    final total = _quizHistory.fold<double>(0, (total, attempt) => total + attempt.percent);
    return total / _quizHistory.length;
  }

  QuizAttempt? get lastAttempt => _quizHistory.isEmpty ? null : _quizHistory.last;

  /// The soonest upcoming enabled reminder, or null if none are enabled.
  StudyReminder? get nextReminder {
    final enabled = _reminders.where((r) => r.enabled).toList();
    if (enabled.isEmpty) return null;
    final now = DateTime.now();
    return enabled.reduce(
      (a, b) => _delayUntil(now, a) <= _delayUntil(now, b) ? a : b,
    );
  }

  static Duration _delayUntil(DateTime now, StudyReminder reminder) {
    Duration? shortest;
    for (final day in reminder.days) {
      final targetWeekday = weekdayIndex(day) + 1; // DateTime.weekday: Monday=1..Sunday=7
      final daysUntil = (targetWeekday - now.weekday) % 7;
      var candidate = DateTime(now.year, now.month, now.day, reminder.time.hour, reminder.time.minute)
          .add(Duration(days: daysUntil));
      if (candidate.isBefore(now)) candidate = candidate.add(const Duration(days: 7));
      final delay = candidate.difference(now);
      if (shortest == null || delay < shortest) shortest = delay;
    }
    return shortest ?? const Duration(days: 7);
  }

  /// Average percent score per subject across all attempts, most recently
  /// seen subject first.
  List<(String subject, double percent)> get subjectAverages {
    final order = <String>[];
    final correctBySubject = <String, int>{};
    final totalBySubject = <String, int>{};
    for (final attempt in _quizHistory) {
      for (final subjectScore in attempt.subjectScores) {
        if (!correctBySubject.containsKey(subjectScore.subject)) {
          order.add(subjectScore.subject);
        }
        correctBySubject[subjectScore.subject] =
            (correctBySubject[subjectScore.subject] ?? 0) + subjectScore.correct;
        totalBySubject[subjectScore.subject] =
            (totalBySubject[subjectScore.subject] ?? 0) + subjectScore.total;
      }
    }
    return order.reversed
        .map((subject) => (subject, correctBySubject[subject]! / totalBySubject[subject]!))
        .toList();
  }

  /// Subjects the student consistently struggles with (below
  /// [_weakSubjectThreshold]), weakest first — feeds the "Boss Level"
  /// weakness quiz. Empty until they've built up some quiz history.
  static const _weakSubjectThreshold = 0.75;

  List<(String subject, double percent)> get weakSubjects {
    final weak = subjectAverages.where((entry) => entry.$2 < _weakSubjectThreshold).toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    return weak.take(3).toList();
  }

  DocumentReference<Map<String, dynamic>>? get _userDoc =>
      _uid == null ? null : _firestore.collection('users').doc(_uid);

  /// Starts listening to [uid]'s data in Firestore. Safe to call again with
  /// the same uid (no-op) or a different uid (rebinds).
  void bindToUser(String uid) {
    if (_uid == uid) return;
    unbind();
    _uid = uid;
    _loading = true;
    notifyListeners();

    final userDoc = _firestore.collection('users').doc(uid);
    _profileSub = userDoc.snapshots().listen((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        // First sign-in: seed the document with defaults.
        _profile = ProfileSettings.defaults();
        _reminders = StudyReminder.defaults();
        userDoc.set({
          'profile': _profile.toJson(),
          'reminders': _reminders.map((r) => r.toJson()).toList(),
        });
      } else {
        _profile = ProfileSettings.fromJson(
          Map<String, dynamic>.from(data['profile'] as Map? ?? {}),
        );
        _reminders = ((data['reminders'] as List?) ?? [])
            .map((e) => StudyReminder.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _streak = data['streak'] == null
            ? StreakData.defaults()
            : StreakData.fromJson(Map<String, dynamic>.from(data['streak'] as Map));
      }
      _loading = false;
      notifyListeners();
      _syncReminderSchedules(_reminders);
    });

    _historySub = userDoc
        .collection('quizAttempts')
        .orderBy('takenAt')
        .snapshots()
        .listen((snapshot) {
      _quizHistory = snapshot.docs.map((doc) => QuizAttempt.fromJson(doc.data())).toList();
      notifyListeners();
    });

    _duelHistorySub = userDoc
        .collection('duelHistory')
        .orderBy('at')
        .snapshots()
        .listen((snapshot) {
      _duelHistory = snapshot.docs.map((doc) => DuelResult.fromJson(doc.data())).toList();
      notifyListeners();
    });
  }

  /// Stops listening and clears in-memory state (call on sign-out).
  void unbind() {
    _profileSub?.cancel();
    _historySub?.cancel();
    _duelHistorySub?.cancel();
    _profileSub = null;
    _historySub = null;
    _duelHistorySub = null;
    _uid = null;
    _profile = ProfileSettings.defaults();
    _reminders = StudyReminder.defaults();
    _quizHistory = [];
    _duelHistory = [];
    _streak = StreakData.defaults();
    _loading = false;
    notifyListeners();
  }

  Future<void> updateProfile(ProfileSettings profile) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.set({'profile': profile.toJson()}, SetOptions(merge: true));
  }

  /// Uploads a new profile photo to `avatars/{uid}/avatar.jpg` (overwriting
  /// any previous one) and saves its download URL onto the profile.
  Future<void> uploadAvatar(Uint8List bytes, {required String contentType}) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = FirebaseStorage.instance.ref('avatars/$uid/avatar.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    final url = await ref.getDownloadURL();
    // Firebase Storage keeps the same download token across overwrites of
    // the same path, so re-uploading a new photo returns the exact same URL
    // as before — Flutter's NetworkImage cache then keeps showing the old
    // image since it caches by URL. A cache-busting param forces a refetch.
    final cacheBustedUrl = '$url&cb=${DateTime.now().millisecondsSinceEpoch}';
    await updateProfile(_profile.copyWith(avatarUrl: cacheBustedUrl));
  }

  Future<void> _writeReminders(List<StudyReminder> reminders) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.set({
      'reminders': reminders.map((r) => r.toJson()).toList(),
    }, SetOptions(merge: true));
    await _syncReminderSchedules(reminders);
  }

  /// Schedules a weekly local notification for each day of every enabled
  /// reminder, and cancels the alarm for any day that's disabled or no
  /// longer selected on that reminder.
  Future<void> _syncReminderSchedules(List<StudyReminder> reminders) async {
    for (final reminder in reminders) {
      for (final day in weekdayOrder) {
        final id = notificationIdFromString('${reminder.id}_$day');
        if (reminder.enabled && reminder.days.contains(day)) {
          await LocalNotificationService.instance.scheduleWeekly(
            id: id,
            weekday: weekdayIndex(day) + 1,
            time: reminder.time,
            title: 'Study time!',
            body: 'Your $day study session is starting now.',
          );
        } else {
          await LocalNotificationService.instance.cancel(id);
        }
      }
    }
  }

  Future<void> addReminder(StudyReminder reminder) {
    return _writeReminders([..._reminders, reminder]);
  }

  Future<void> updateReminder(
    String id, {
    required List<String> days,
    required TimeOfDay time,
    required String description,
  }) {
    return _writeReminders([
      for (final reminder in _reminders)
        if (reminder.id == id)
          StudyReminder(
            id: reminder.id,
            days: days,
            time: time,
            enabled: reminder.enabled,
            description: description,
          )
        else
          reminder,
    ]);
  }

  Future<void> deleteReminder(String id) async {
    for (final day in weekdayOrder) {
      await LocalNotificationService.instance.cancel(notificationIdFromString('${id}_$day'));
    }
    return _writeReminders([
      for (final reminder in _reminders)
        if (reminder.id != id) reminder,
    ]);
  }

  Future<void> setReminderEnabled(String id, bool enabled) {
    return _writeReminders([
      for (final reminder in _reminders)
        if (reminder.id == id)
          StudyReminder(
            id: reminder.id,
            days: reminder.days,
            time: reminder.time,
            enabled: enabled,
            description: reminder.description,
          )
        else
          reminder,
    ]);
  }

  Future<void> addQuizAttempt(QuizAttempt attempt) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.collection('quizAttempts').doc(attempt.id).set(attempt.toJson());
    await _recordStreakActivity();
  }

  Future<void> recordDuelResult({
    required String duelId,
    required String subject,
    required bool won,
    required int selfScore,
    required int opponentScore,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;
    final result = DuelResult(
      duelId: duelId,
      subject: subject,
      won: won,
      selfScore: selfScore,
      opponentScore: opponentScore,
      at: DateTime.now(),
    );
    await doc.collection('duelHistory').doc(duelId).set(result.toJson());
    await _recordStreakActivity();
  }

  /// Adds an opponent as a study buddy after a duel — a lightweight
  /// accountability-friend list, not a mutual friendship (no reciprocal
  /// write on the other user's doc).
  Future<void> addStudyBuddy({required String uid, required String name}) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.collection('studyBuddies').doc(uid).set({
      'uid': uid,
      'name': name,
      'addedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Bumps the daily streak the first time the student finishes a quiz or
  /// duel on a new calendar day (see [StreakData.withActivityRecorded]).
  Future<void> _recordStreakActivity() async {
    final doc = _userDoc;
    if (doc == null || _streak.activeToday) return;
    final updated = _streak.withActivityRecorded();
    _streak = updated;
    notifyListeners();
    await doc.set({'streak': updated.toJson()}, SetOptions(merge: true));
  }
}
