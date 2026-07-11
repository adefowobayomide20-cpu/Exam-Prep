import 'package:flutter/material.dart';

/// Prompts the student to drill the subjects they're weakest in, computed
/// from their own quiz history (see [AppDataStore.weakSubjects]).
class BossLevelCard extends StatelessWidget {
  const BossLevelCard({
    super.key,
    required this.weakSubjects,
    this.onStart,
  });

  final List<(String subject, double percent)> weakSubjects;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(Icons.shield_moon_outlined, color: theme.colorScheme.onErrorContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Boss Level', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        weakSubjects.isEmpty
                            ? 'Take a few quizzes and we\'ll spot your weak topics here'
                            : 'A custom quiz targeting your weakest subjects',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (weakSubjects.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: weakSubjects
                    .map(
                      (entry) => Chip(
                        label: Text('${entry.$1} · ${(entry.$2 * 100).round()}%'),
                        backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.local_fire_department_outlined, size: 18),
                  label: const Text('Start Boss Quiz'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
