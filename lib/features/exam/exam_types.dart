import 'package:flutter/material.dart';

enum ExamCategory { waec, neco, jamb, postJamb }

class ExamTypeInfo {
  const ExamTypeInfo({
    required this.name,
    required this.icon,
    required this.category,
    this.shortLabelOverride,
  });

  final String name;
  final IconData icon;
  final ExamCategory category;
  final String? shortLabelOverride;

  String get shortLabel => shortLabelOverride ?? name;
}

const examTypes = [
  ExamTypeInfo(
    name: 'WAEC & WAEC GCE',
    shortLabelOverride: 'WAEC',
    icon: Icons.school,
    category: ExamCategory.waec,
  ),
  ExamTypeInfo(
    name: 'NECO & NECO GCE',
    shortLabelOverride: 'NECO',
    icon: Icons.school_outlined,
    category: ExamCategory.neco,
  ),
  ExamTypeInfo(
    name: 'JAMB Examination',
    shortLabelOverride: 'JAMB',
    icon: Icons.assignment,
    category: ExamCategory.jamb,
  ),
  ExamTypeInfo(
    name: 'Post-JAMB',
    icon: Icons.fact_check,
    category: ExamCategory.postJamb,
  ),
];
