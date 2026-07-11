import 'package:flutter_test/flutter_test.dart';
import 'package:exam_prep/features/exam/quiz/question_bank/mathematics_bank.dart';

void main() {
  test('Mathematics bank is well-formed', () {
    final questions = buildMathematicsQuestions();
    // ignore: avoid_print
    print('Total Mathematics questions: ${questions.length}');

    expect(questions, isNotEmpty);
    for (final q in questions) {
      expect(q.options.length, 4, reason: 'Question "${q.text}" must have 4 options');
      expect(q.options.toSet().length, 4, reason: 'Question "${q.text}" has duplicate options: ${q.options}');
      expect(q.correctIndex, inInclusiveRange(0, 3));
      expect(q.explanation, isNotNull);
      expect(q.explanation, isNotEmpty);
    }
  });

  test('spot-check known facts across every syllabus topic', () {
    final questions = buildMathematicsQuestions();

    QuizFinder find(bool Function(String text) matcher) =>
        QuizFinder(questions.firstWhere((q) => matcher(q.text)));

    find((t) => t.contains('Convert 10 (base 10) to base 2')).expectAnswer('1010');
    find((t) => t.contains('101₂ + 110₂')).expectAnswer('1011'); // 5+6=11 -> binary 1011
    find((t) => t.contains('23 ≡ n (mod 5)')).expectAnswer('3');
    find((t) => t.contains('(15 + 22) mod 7')).expectAnswer('2'); // 37 mod 7 = 2
    final fractionQ = questions.firstWhere((q) => q.text.startsWith('Evaluate') && q.text.contains('lowest terms'));
    final match = RegExp(r'Evaluate (\d+)/(\d+) \+ (\d+)/(\d+)').firstMatch(fractionQ.text)!;
    final n1 = int.parse(match.group(1)!), d1 = int.parse(match.group(2)!);
    final n2 = int.parse(match.group(3)!), d2 = int.parse(match.group(4)!);
    final expectedNumerator = n1 * d2 + n2 * d1;
    final expectedDenominator = d1 * d2;
    final divisor = _gcdForTest(expectedNumerator, expectedDenominator);
    final expected = divisor == expectedDenominator
        ? '${expectedNumerator ~/ divisor}'
        : '${expectedNumerator ~/ divisor}/${expectedDenominator ~/ divisor}';
    expect(fractionQ.options[fractionQ.correctIndex], expected);
    find((t) => t.contains('What is 20% of 200?')).expectAnswer('40');
    find((t) => t.contains('simple interest on ₦1000 for 2 years at 5%')).expectAnswer('100');
    find((t) => t.contains('compound amount on ₦100 for 2 years at 10%')).expectAnswer('121');
    find((t) => t.contains('Simplify a^2 × a^3')).expectAnswer('a^5');
    find((t) => t.contains('Evaluate log₁₀(10^3)')).expectAnswer('3');
    find((t) => t.contains('Simplify log p + log q')).expectAnswer('log (pq)');
    find((t) => t.contains('Simplify √50')).expectAnswer('5√2');
    find((t) => t.contains('n(A) = 12, n(B) = 9, and n(A∩B) = 5')).expectAnswer('16');
    find((t) => t.contains('Expand (x + 2)(x + 3)')).expectAnswer('x² + 5x + 6');
    find((t) => t.contains('Given v = u + at, find a when v = 30, u = 6, and t = 6')).expectAnswer('4');
    find((t) => t.contains('Solve for x: 2 x +')).expectAnswer(null); // existence check only
    find((t) => t.contains('sum of the roots') && t.contains('Find the sum of the roots'))
        .expectAnswer(null);
    find((t) => t.contains('Solve the inequality: 3 x + 2 > 11')).expectAnswer('x > 3');
    find((t) => t.contains("10th term of the Arithmetic Progression 2, 5, 8")).expectAnswer('29');
    find((t) => t.contains('y varies directly as x. If y = 12 when x = 3')).expectAnswer('20');
    find((t) => t.contains('a * b = a + b + ab. Evaluate 2 * 3')).expectAnswer('11');
    find((t) => t.contains('determinant of the matrix [1 2; 3 4]')).expectAnswer('-2');
    find((t) => t.contains('sum of interior angles of a triangle')).expectAnswer('180');
    find((t) => t.contains('inscribed angle subtending an arc is 30°')).expectAnswer('60');
    find((t) => t.contains('triangle with base 10cm and height 6cm')).expectAnswer('30');
    find((t) => t.contains('radius 7cm') && t.contains('area')).expectAnswer('154');
    find((t) => t.contains('cuboid with length 4cm, width 4cm and height 4cm')).expectAnswer('64');
    find((t) => t.contains('distance between points (0, 0) and (3, 4)')).expectAnswer('5');
    find((t) => t.contains('opposite angle θ is 3 cm') && t.contains('Find tan')).expectAnswer('3/4');
    find((t) => t.contains('bearing of point A from point B is 40°')).expectAnswer('220');
    find((t) => t.contains('mean') && t.contains('4, 8, 6, 5, 7, 8, 9')).expectAnswer('6.71');
    find((t) => t.contains('3 red, 5 blue, 2 green') && t.contains('is red')).expectAnswer('3/10');
    find((t) => t.contains('a + b') && t.contains('vector a = (2, 3) and vector b = (4, 1)'))
        .expectAnswer('(6, 4)');
    find((t) => t.contains('magnitude of the vector (3, 4)')).expectAnswer('5');
    find((t) => t.contains('reflection in the x-axis, the point (3, 5)')).expectAnswer('(3, -5)');
    find((t) => t.contains('Differentiate 2 x^3')).expectAnswer('6 x^2');
    find((t) => t.contains('∫ 6 x^2 dx')).expectAnswer('2 x^3 + C');
  });
}

int _gcdForTest(int a, int b) => b == 0 ? a.abs() : _gcdForTest(b, a % b);

class QuizFinder {
  QuizFinder(this.question);
  final dynamic question;

  void expectAnswer(String? expected) {
    if (expected == null) return; // existence-only check
    expect(question.options[question.correctIndex], expected);
  }
}
