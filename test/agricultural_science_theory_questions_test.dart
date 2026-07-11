import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/theory/agricultural_science_theory_questions.dart';

void main() {
  test('agricultural science theory bank has exactly 50 questions', () {
    expect(agriculturalScienceTheoryQuestions.length, 50);
  });

  test('every question has non-empty topic and question text', () {
    for (final q in agriculturalScienceTheoryQuestions) {
      expect(q.topic, isNotEmpty);
      expect(q.question, isNotEmpty);
    }
  });

  test('at least 15 distinct topics appear across the list', () {
    final topics = agriculturalScienceTheoryQuestions.map((q) => q.topic).toSet();
    expect(topics.length, greaterThanOrEqualTo(15));
  });
}
