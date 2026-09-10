import 'streak_data.dart' show StreakData;

/// Today's free-tier usage of the metered AI features (Snap & Solve, Theory
/// question generation/grading) — one shared daily counter across both,
/// since they're both "AI helps" from the student's point of view.
/// Incremented only by the Cloud Functions transaction in
/// functions/entitlements.js, never by the client directly.
class AiUsage {
  const AiUsage({required this.date, required this.count});

  factory AiUsage.defaults() => const AiUsage(date: null, count: 0);

  /// yyyy-MM-dd — null until the first AI action of any day.
  final String? date;
  final int count;

  /// [count] as of today; resets to 0 once the stored date is stale, mirroring
  /// how StreakData treats a missed day.
  int get countToday => date == StreakData.dateKey(DateTime.now()) ? count : 0;

  Map<String, dynamic> toJson() => {'date': date, 'count': count};

  factory AiUsage.fromJson(Map<String, dynamic> json) => AiUsage(
        date: json['date'] as String?,
        count: json['count'] as int? ?? 0,
      );
}
