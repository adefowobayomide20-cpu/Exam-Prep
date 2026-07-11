import 'package:flutter/material.dart';

/// Hero "flame" card showing the student's daily streak — a Duolingo-style
/// nudge to keep a quiz/duel habit going every day.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.activeToday,
  });

  final int currentStreak;
  final int longestStreak;
  final bool activeToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStreak = currentStreak > 0;
    final flameColor = activeToday
        ? Colors.deepOrange
        : hasStreak
            ? Colors.deepOrange.withValues(alpha: 0.55)
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    final String title;
    final String subtitle;
    if (!hasStreak) {
      title = 'Start a streak today';
      subtitle = 'Finish one quiz or duel to light the flame.';
    } else if (activeToday) {
      title = '$currentStreak-day streak';
      subtitle = "You're locked in for today. Come back tomorrow to keep it alive.";
    } else {
      title = '$currentStreak-day streak';
      subtitle = 'Finish a quiz or duel today before it resets.';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: activeToday ? 1.0 : 0.85),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Icon(Icons.local_fire_department, size: 40, color: flameColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (longestStreak > currentStreak) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Best: $longestStreak days',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
