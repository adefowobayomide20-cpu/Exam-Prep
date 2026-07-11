import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/theory/physics_theory_questions.dart';

void main() {
  test('Physics theory bank has exactly 50 questions', () {
    expect(physicsTheoryQuestions.length, 50);
  });

  test('every Physics theory question has non-empty topic and question text', () {
    for (final q in physicsTheoryQuestions) {
      expect(q.topic, isNotEmpty);
      expect(q.question, isNotEmpty);
    }
  });

  test('Physics theory bank has at least 15 distinct topics', () {
    final topics = physicsTheoryQuestions.map((q) => q.topic).toSet();
    expect(topics.length, greaterThanOrEqualTo(15));
  });
}
