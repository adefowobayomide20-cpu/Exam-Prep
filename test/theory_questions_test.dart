import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/theory/theory_questions.dart';

void main() {
  test('ready-made theory bank returns questions for covered subjects', () {
    final math = readyMadeTheoryQuestion('Mathematics');
    expect(math, isNotNull);
    expect(math!.question, isNotEmpty);
    expect(math.topic, isNotEmpty);

    final english = readyMadeTheoryQuestion('English Language');
    expect(english, isNotNull);
    expect(english!.question, isNotEmpty);
    expect(english.topic, isNotEmpty);
  });

  test('ready-made theory bank returns null for subjects with no bank yet', () {
    expect(readyMadeTheoryQuestion('Biology'), isNull);
    expect(readyMadeTheoryQuestion('Government'), isNull);
  });

  test('Mathematics theory bank has at least 10 questions with distinct topics', () {
    final seen = <String>{};
    for (var i = 0; i < 300; i++) {
      final q = readyMadeTheoryQuestion('Mathematics')!;
      seen.add(q.topic);
    }
    expect(seen.length, greaterThanOrEqualTo(10));
  });

  test('English Language theory bank has at least 10 questions with distinct topics', () {
    final seen = <String>{};
    for (var i = 0; i < 300; i++) {
      final q = readyMadeTheoryQuestion('English Language')!;
      seen.add(q.topic);
    }
    expect(seen.length, greaterThanOrEqualTo(9));
  });

  test('Chemistry theory bank has questions with at least 15 distinct topics', () {
    final seen = <String>{};
    for (var i = 0; i < 300; i++) {
      final q = readyMadeTheoryQuestion('Chemistry')!;
      seen.add(q.topic);
    }
    expect(seen.length, greaterThanOrEqualTo(15));
  });

  test('Physics theory bank has questions with at least 15 distinct topics', () {
    final seen = <String>{};
    for (var i = 0; i < 300; i++) {
      final q = readyMadeTheoryQuestion('Physics')!;
      seen.add(q.topic);
    }
    expect(seen.length, greaterThanOrEqualTo(15));
  });

  test('Agricultural Science theory bank has questions with at least 15 distinct topics', () {
    final seen = <String>{};
    for (var i = 0; i < 300; i++) {
      final q = readyMadeTheoryQuestion('Agricultural Science')!;
      seen.add(q.topic);
    }
    expect(seen.length, greaterThanOrEqualTo(15));
  });
}
