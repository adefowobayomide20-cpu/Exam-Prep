import 'package:flutter/material.dart';

import '../../../data/app_data_store.dart';
import '../../../data/models/study_reminder.dart';

String formatReminderDays(List<String> days) {
  if (days.length == 7) return 'Every day';
  return days.map((d) => d.substring(0, 3)).join(', ');
}

class StudyReminderSection extends StatelessWidget {
  const StudyReminderSection({super.key});

  Future<void> _addReminder(BuildContext context) async {
    final result = await showDialog<_ReminderDialogResult>(
      context: context,
      builder: (context) => const _ReminderDialog(),
    );
    if (result != null && !result.delete) {
      AppDataStore.instance.addReminder(
        StudyReminder(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          days: result.days!,
          time: result.time!,
          description: result.description!,
        ),
      );
    }
  }

  Future<void> _editReminder(BuildContext context, StudyReminder reminder) async {
    final result = await showDialog<_ReminderDialogResult>(
      context: context,
      builder: (context) => _ReminderDialog(
        initialDays: reminder.days,
        initialTime: reminder.time,
        initialDescription: reminder.description,
        showDelete: true,
      ),
    );
    if (result == null) return;
    if (result.delete) {
      if (!context.mounted) return;
      final confirmed = await _confirmDelete(context);
      if (confirmed) AppDataStore.instance.deleteReminder(reminder.id);
    } else {
      AppDataStore.instance.updateReminder(
        reminder.id,
        days: result.days!,
        time: result.time!,
        description: result.description!,
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: const Text('This study reminder will be removed and its alarm cancelled.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final reminders = AppDataStore.instance.reminders;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Study Reminder Timetable', style: theme.textTheme.titleMedium),
                    IconButton(onPressed: () => _addReminder(context), icon: const Icon(Icons.add)),
                  ],
                ),
                ...reminders.map(
                  (reminder) => Dismissible(
                    key: ValueKey(reminder.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: theme.colorScheme.errorContainer,
                      child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
                    ),
                    confirmDismiss: (_) => _confirmDelete(context),
                    onDismissed: (_) => AppDataStore.instance.deleteReminder(reminder.id),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.alarm),
                      title: Text(formatReminderDays(reminder.days)),
                      subtitle: Text(
                        reminder.description.isEmpty
                            ? reminder.time.format(context)
                            : '${reminder.time.format(context)} · ${reminder.description}',
                      ),
                      onTap: () => _editReminder(context, reminder),
                      trailing: Switch(
                        value: reminder.enabled,
                        onChanged: (value) =>
                            AppDataStore.instance.setReminderEnabled(reminder.id, value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReminderDialogResult {
  _ReminderDialogResult.save(this.days, this.time, this.description) : delete = false;
  _ReminderDialogResult.delete()
      : days = null,
        time = null,
        description = null,
        delete = true;

  final List<String>? days;
  final TimeOfDay? time;
  final String? description;
  final bool delete;
}

class _ReminderDialog extends StatefulWidget {
  const _ReminderDialog({
    this.initialDays,
    this.initialTime,
    this.initialDescription,
    this.showDelete = false,
  });

  final List<String>? initialDays;
  final TimeOfDay? initialTime;
  final String? initialDescription;
  final bool showDelete;

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  late final Set<String> _selectedDays = {...?widget.initialDays};
  late TimeOfDay _time = widget.initialTime ?? TimeOfDay.now();
  late final _descriptionController =
      TextEditingController(text: widget.initialDescription ?? '');

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Study Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Repeat on', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: weekdayOrder
                .map(
                  (day) => FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: _selectedDays.contains(day),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('Time'),
            trailing: Text(_time.format(context)),
            onTap: _pickTime,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g. Revise Chemistry',
            ),
          ),
        ],
      ),
      actions: [
        if (widget.showDelete)
          TextButton(
            onPressed: () => Navigator.pop(context, _ReminderDialogResult.delete()),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _selectedDays.isEmpty
              ? null
              : () => Navigator.pop(
                    context,
                    _ReminderDialogResult.save(
                      weekdayOrder.where(_selectedDays.contains).toList(),
                      _time,
                      _descriptionController.text.trim(),
                    ),
                  ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
