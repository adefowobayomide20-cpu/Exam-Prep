import 'package:flutter/material.dart';

import '../exam/exam_types.dart';
import '../exam/subjects.dart';

/// The exam categories a duel can be fought over. Post-JAMB is excluded —
/// it's school-specific screening content, not a subject list shared across
/// students the way WAEC/NECO/JAMB are.
const duelExamCategories = [ExamCategory.waec, ExamCategory.neco, ExamCategory.jamb];

/// WAEC and NECO share one subject list and mostly share question banks;
/// JAMB has its own (see question_bank_registry.dart's per-category switch).
List<String> subjectsForDuelExamCategory(ExamCategory category) =>
    category == ExamCategory.jamb ? jambSubjects : waecNecoSubjects;

/// Bottom sheet letting the student pick which exam to duel over, since
/// WAEC/NECO and JAMB don't share a syllabus even for same-named subjects
/// (see question_bank_registry.dart).
Future<ExamCategory?> pickDuelExamCategory(BuildContext context) {
  return showModalBottomSheet<ExamCategory>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      expand: false,
      builder: (sheetContext, scrollController) => ListView(
        controller: scrollController,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Duel over which exam?', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...examTypes.where((type) => duelExamCategories.contains(type.category)).map(
                (type) => ListTile(
                  leading: Icon(type.icon),
                  title: Text(type.shortLabel),
                  onTap: () => Navigator.of(sheetContext).pop(type.category),
                ),
              ),
        ],
      ),
    ),
  );
}
