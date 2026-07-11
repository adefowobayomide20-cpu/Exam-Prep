/// Daily study streak: bumps by one the first time a student completes any
/// quiz/duel on a new calendar day, and resets to 1 if a day is missed.
class StreakData {
  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
  });

  factory StreakData.defaults() => const StreakData(
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: null,
      );

  final int currentStreak;
  final int longestStreak;

  /// yyyy-MM-dd, in the device's local timezone.
  final String? lastActiveDate;

  bool get activeToday => lastActiveDate == _todayKey();

  /// The streak as it should be displayed right now: [currentStreak] is only
  /// "alive" through today and yesterday. Once a full day has been missed
  /// without new activity, the streak reads as broken (0) even though the
  /// stored value isn't reset until the next activity is recorded.
  int get displayedStreak {
    if (lastActiveDate == null) return 0;
    if (activeToday) return currentStreak;
    final yesterday = dateKey(DateTime.now().subtract(const Duration(days: 1)));
    if (lastActiveDate == yesterday) return currentStreak;
    return 0;
  }

  static String _todayKey() => dateKey(DateTime.now());

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Returns the streak state after recording activity "now". No-ops if
  /// activity was already recorded today.
  StreakData withActivityRecorded() {
    final today = _todayKey();
    if (lastActiveDate == today) return this;

    final yesterday = dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final newCurrent = lastActiveDate == yesterday ? currentStreak + 1 : 1;
    return StreakData(
      currentStreak: newCurrent,
      longestStreak: newCurrent > longestStreak ? newCurrent : longestStreak,
      lastActiveDate: today,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate': lastActiveDate,
      };

  factory StreakData.fromJson(Map<String, dynamic> json) {
    final defaults = StreakData.defaults();
    return StreakData(
      currentStreak: json['currentStreak'] as int? ?? defaults.currentStreak,
      longestStreak: json['longestStreak'] as int? ?? defaults.longestStreak,
      lastActiveDate: json['lastActiveDate'] as String?,
    );
  }
}
