import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/quiz/question_bank/further_mathematics_bank.dart';

void main() {
  test('Further Mathematics bank is well-formed', () {
    final questions = buildFurtherMathematicsQuestions();
    // ignore: avoid_print
    print('Total Further Mathematics questions: ${questions.length}');

    expect(questions.length, greaterThanOrEqualTo(1000));
    for (final q in questions) {
      expect(q.options.length, 4, reason: 'Question "${q.text}" must have 4 options');
      expect(q.options.toSet().length, 4, reason: 'Question "${q.text}" has duplicate options: ${q.options}');
      expect(q.correctIndex, inInclusiveRange(0, 3), reason: 'Bad correctIndex for "${q.text}"');
      expect(q.explanation, isNotEmpty);
      expect(q.subject, 'Further Mathematics');
    }
  });

  test('spot-check known facts across every syllabus topic', () {
    final questions = buildFurtherMathematicsQuestions();

    void expectAnswer(bool Function(String text) matcher, String expected) {
      final q = questions.firstWhere(
        (question) => matcher(question.text),
        orElse: () => throw StateError('No question matched the given text fragment'),
      );
      expect(q.options[q.correctIndex], expected);
    }

    // Sets
    expectAnswer((t) => t.contains('A set A has 3 elements'), '8');

    // Permutations and combinations
    expectAnswer((t) => t.contains('ⁿPᵣ for n = 5 and r = 2'), '20');
    expectAnswer((t) => t.contains('ⁿCᵣ for n = 5 and r = 2'), '10');

    // Kinematics
    expectAnswer(
        (t) => t.contains('initial velocity 0 m/s and accelerates uniformly at 2 m/s²') && t.contains('distance of 4m'),
        '4');

    // Dynamics
    expectAnswer((t) => t.contains('mass 5kg at 4 m/s²'), '20');
    expectAnswer((t) => t.contains('mass 4kg moving with velocity 5 m/s'), '20');

    // Statics
    expectAnswer((t) => t.contains('forces of 3N and 4N'), '5');
  });
}
