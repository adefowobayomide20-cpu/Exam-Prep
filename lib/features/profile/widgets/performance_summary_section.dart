import 'package:flutter/material.dart';

import '../../../data/app_data_store.dart';
import '../../../widgets/count_up_text.dart';

class PerformanceSummarySection extends StatelessWidget {
  const PerformanceSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.headlineSmall;
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final store = AppDataStore.instance;
        final subjectAverages = store.subjectAverages.take(3).toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Track Record', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatTile(
                      label: 'Quizzes taken',
                      value: CountUpText(value: store.quizzesTaken, style: valueStyle),
                    ),
                    _StatTile(
                      label: 'Avg. score',
                      value: CountUpPercentText(value: store.averageScorePercent, style: valueStyle),
                    ),
                    _StatTile(
                      label: 'Duels won',
                      value: CountUpText(value: store.duelsWon, style: valueStyle),
                    ),
                    _StatTile(
                      label: 'Day streak',
                      value: CountUpText(value: store.currentStreak, style: valueStyle),
                    ),
                  ],
                ),
                if (subjectAverages.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('By subject', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  ...subjectAverages.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.$1, style: theme.textTheme.bodyMedium),
                              Text('${(entry.$2 * 100).round()}%', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: entry.$2),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) =>
                                  LinearProgressIndicator(value: value, minHeight: 6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
