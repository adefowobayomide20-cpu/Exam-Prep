import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/quiz/question_bank/waec_english_language_bank.dart';

void main() {
  test('WAEC English Language bank (merged Lexis + Structure + Oral + Comprehension) is well-formed', () {
    final questions = buildWaecEnglishLanguageQuestions();
    // ignore: avoid_print
    print('Total WAEC English Language questions: ${questions.length}');

    expect(questions.length, greaterThanOrEqualTo(1000));
    for (final q in questions) {
      expect(q.options.length, 4, reason: 'Question "${q.text}" must have 4 options');
      expect(q.options.toSet().length, 4, reason: 'Question "${q.text}" has duplicate options: ${q.options}');
      expect(q.correctIndex, inInclusiveRange(0, 3));
      expect(q.explanation, isNotEmpty);
      expect(q.subject, 'English Language');
    }
  });
}
