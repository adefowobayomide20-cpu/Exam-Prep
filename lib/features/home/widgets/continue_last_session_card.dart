import 'package:flutter/material.dart';

import '../../../data/models/quiz_attempt.dart';

class ContinueLastSessionCard extends StatelessWidget {
  const ContinueLastSessionCard({super.key, this.lastAttempt, this.onStartQuiz});

  final QuizAttempt? lastAttempt;
  final VoidCallback? onStartQuiz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attempt = lastAttempt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.history, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Continue where you left off', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        attempt == null
                            ? 'Take your first quiz to see your progress here'
                            : '${attempt.title} · ${attempt.score}/${attempt.totalQuestions} '
                                '(${(attempt.percent * 100).round()}%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStartQuiz,
                icon: Icon(attempt == null ? Icons.bolt_outlined : Icons.refresh, size: 18),
                label: Text(attempt == null ? 'Start Your First Quiz' : 'Take Another Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
