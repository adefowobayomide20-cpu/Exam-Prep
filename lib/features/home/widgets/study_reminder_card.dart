import 'package:flutter/material.dart';

import '../../../data/models/study_reminder.dart';
import '../../profile/widgets/study_reminder_section.dart' show formatReminderDays;

class StudyReminderCard extends StatelessWidget {
  const StudyReminderCard({super.key, this.onManage, this.nextReminder});

  final VoidCallback? onManage;
  final StudyReminder? nextReminder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = nextReminder;
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: InkWell(
        onTap: onManage,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.alarm, color: theme.colorScheme.onTertiaryContainer, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Reminder',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminder == null
                          ? 'No reminders set'
                          : 'Next reminder: ${formatReminderDays(reminder.days)} ${reminder.time.format(context)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: onManage,
                child: const Text('Manage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
