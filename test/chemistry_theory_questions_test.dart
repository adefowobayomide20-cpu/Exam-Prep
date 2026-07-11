import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/theory/chemistry_theory_questions.dart';

void main() {
  test('Chemistry theory bank has exactly 50 questions', () {
    expect(chemistryTheoryQuestions.length, 50);
  });

  test('every Chemistry theory question has non-empty topic and question text', () {
    for (final q in chemistryTheoryQuestions) {
      expect(q.topic, isNotEmpty);
      expect(q.question, isNotEmpty);
    }
  });

  test('Chemistry theory bank has at least 15 distinct topics', () {
    final topics = chemistryTheoryQuestions.map((q) => q.topic).toSet();
    expect(topics.length, greaterThanOrEqualTo(15));
  });
}
