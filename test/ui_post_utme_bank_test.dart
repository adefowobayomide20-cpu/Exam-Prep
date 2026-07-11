import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/quiz/question_bank/ui_post_utme_bank.dart';

void main() {
  test('UI Post-UTME bank is well-formed', () {
    final questions = buildUiPostUtmeQuestions();
    // ignore: avoid_print
    print('Total UI Post-UTME questions: ${questions.length}');

    expect(questions.length, greaterThanOrEqualTo(100));
    for (final q in questions) {
      expect(q.options.length, 4, reason: 'Question "${q.text}" must have 4 options');
      expect(q.options.toSet().length, 4, reason: 'Question "${q.text}" has duplicate options: ${q.options}');
      expect(q.correctIndex, inInclusiveRange(0, 3), reason: 'Bad correctIndex for "${q.text}"');
      expect(q.explanation, isNotEmpty);
    }

    final subjects = questions.map((q) => q.subject).toSet();
    expect(subjects, {'English Language', 'Mathematics', 'General Knowledge'});
  });
}
