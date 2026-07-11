import 'package:flutter/material.dart';

import '../../../widgets/count_up_text.dart';

class PerformanceTrackerCard extends StatelessWidget {
  const PerformanceTrackerCard({
    super.key,
    this.onTap,
    required this.quizzesTaken,
    required this.averageScorePercent,
    required this.duelsWon,
    required this.currentStreak,
  });

  final VoidCallback? onTap;
  final int quizzesTaken;
  final double averageScorePercent;
  final int duelsWon;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.headlineSmall;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Performance Track Record', style: theme.textTheme.titleMedium),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatTile(
                    label: 'Quizzes taken',
                    value: CountUpText(value: quizzesTaken, style: valueStyle),
                  ),
                  _StatTile(
                    label: 'Avg. score',
                    value: CountUpPercentText(value: averageScorePercent, style: valueStyle),
                  ),
                  _StatTile(
                    label: 'Duels won',
                    value: CountUpText(value: duelsWon, style: valueStyle),
                  ),
                  _StatTile(
                    label: 'Day streak',
                    value: CountUpText(value: currentStreak, style: valueStyle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          value,
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
