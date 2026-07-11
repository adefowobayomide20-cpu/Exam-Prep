import 'package:flutter/material.dart';

class StudyReminder {
  StudyReminder({
    required this.id,
    required this.days,
    required this.time,
    this.enabled = true,
    this.description = '',
  });

  final String id;
  final List<String> days;
  TimeOfDay time;
  bool enabled;
  String description;

  static List<StudyReminder> defaults() => [
        StudyReminder(
          id: '1',
          days: const ['Monday', 'Wednesday'],
          time: const TimeOfDay(hour: 18, minute: 0),
        ),
        StudyReminder(
          id: '3',
          days: const ['Saturday'],
          time: const TimeOfDay(hour: 10, minute: 0),
          enabled: false,
        ),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'days': days,
        'hour': time.hour,
        'minute': time.minute,
        'enabled': enabled,
        'description': description,
      };

  factory StudyReminder.fromJson(Map<String, dynamic> json) {
    return StudyReminder(
      id: json['id'] as String,
      days: json['days'] != null
          ? List<String>.from(json['days'] as List)
          : [if (json['day'] != null) json['day'] as String],
      time: TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int),
      enabled: json['enabled'] as bool? ?? true,
      description: json['description'] as String? ?? '',
    );
  }
}

const weekdayOrder = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

int weekdayIndex(String day) {
  final index = weekdayOrder.indexOf(day);
  return index == -1 ? weekdayOrder.length : index;
}
