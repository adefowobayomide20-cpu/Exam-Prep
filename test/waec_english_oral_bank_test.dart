import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/quiz/question_bank/waec_english_oral_bank.dart';

void main() {
  test('WAEC English Oral bank is well-formed', () {
    final questions = buildWaecEnglishOralQuestions();
    // ignore: avoid_print
    print('Total Oral English questions: ${questions.length}');

    expect(questions, isNotEmpty);
    for (final q in questions) {
      expect(q.options.length, 4, reason: 'Question "${q.text}" must have 4 options');
      expect(q.options.toSet().length, 4, reason: 'Question "${q.text}" has duplicate options: ${q.options}');
      expect(q.correctIndex, inInclusiveRange(0, 3), reason: 'Bad correctIndex for "${q.text}"');
      expect(q.explanation, isNotEmpty);
      expect(q.subject, 'English Language');
    }
  });
}
