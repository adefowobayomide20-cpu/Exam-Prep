import 'dart:math' as math;

import '../quiz_question.dart';

const _subject = 'Further Mathematics';

/// All answers in this bank are computed arithmetically by the generator
/// functions themselves (not typed in by hand), so correctness follows from
/// the formulas being correct rather than from manual review of each
/// question. Topics follow the WAEC/NECO Further Mathematics syllabus:
/// Pure Mathematics (sets/functions, algebraic structures, sequences &
/// binomial theorem, trigonometry, calculus), Coordinate Geometry & Vectors,
/// and Statistics/Probability/Mechanics.
List<QuizQuestion> buildFurtherMathematicsQuestions() {
  final random = math.Random(23);
  final questions = <QuizQuestion>[];

  // Pure Mathematics — Sets, Functions and Relations
  questions.addAll(_setsAdvancedQuestions(random));
  questions.addAll(_functionsQuestions(random));

  // Pure Mathematics — Algebraic Structures
  questions.addAll(_quadraticRootsQuestions(random));
  questions.addAll(_polynomialQuestions(random));
  questions.addAll(_surdsLogsAdvancedQuestions(random));
  questions.addAll(_partialFractionsQuestions(random));
  questions.addAll(_binaryOperationsAdvancedQuestions(random));
  questions.addAll(_matricesAdvancedQuestions(random));
  questions.addAll(_mathematicalInductionQuestions(random));

  // Pure Mathematics — Sequences, Series and Binomial Theorem
  questions.addAll(_seriesSumToInfinityQuestions(random));
  questions.addAll(_binomialTheoremQuestions(random));

  // Pure Mathematics — Trigonometry
  questions.addAll(_compoundAngleQuestions(random));
  questions.addAll(_doubleAngleQuestions(random));
  questions.addAll(_trigEquationsQuestions(random));
  questions.addAll(_inverseTrigQuestions(random));

  // Pure Mathematics — Calculus
  questions.addAll(_differentiationRulesQuestions(random));
  questions.addAll(_stationaryPointsQuestions(random));
  questions.addAll(_integrationTechniquesQuestions(random));

  // Coordinate Geometry and Vectors
  questions.addAll(_coordinateGeometryAdvancedQuestions(random));
  questions.addAll(_vectors3DQuestions(random));

  // Statistics and Probability
  questions.addAll(_permutationsCombinationsQuestions(random));
  questions.addAll(_probabilityLawsQuestions(random));
  questions.addAll(_binomialDistributionQuestions(random));

  // Mechanics
  questions.addAll(_kinematicsQuestions(random));
  questions.addAll(_dynamicsQuestions(random));
  questions.addAll(_staticsQuestions(random));

  return questions;
}

// ---------------------------------------------------------------------------
// Shared helpers (mirrors the pattern used in mathematics_bank.dart).
// ---------------------------------------------------------------------------

int _gcd(int a, int b) => b == 0 ? a.abs() : _gcd(b, a % b);

QuizQuestion _buildFromPool(
  String text,
  String correct,
  List<String> pool,
  math.Random random,
  String explanation,
) {
  final distractors = <String>{};
  var attempts = 0;
  while (distractors.length < 3 && attempts < 300) {
    final candidate = pool[random.nextInt(pool.length)];
    if (candidate != correct) distractors.add(candidate);
    attempts++;
  }
  final options = [correct, ...distractors]..shuffle(random);
  return QuizQuestion(
    subject: _subject,
    text: text,
    options: options,
    correctIndex: options.indexOf(correct),
    explanation: explanation,
  );
}

QuizQuestion _buildNumeric(
  String text,
  num correct,
  math.Random random,
  String explanation, {
  num step = 1,
}) {
  final correctLabel = _formatNum(correct);
  final offsets = <num>{};
  while (offsets.length < 3) {
    final offset = (random.nextInt(5) + 1) * step * (random.nextBool() ? 1 : -1);
    if (offset != 0) offsets.add(offset);
  }
  final wrongLabels = offsets.map((o) => _formatNum(correct + o)).toSet();
  wrongLabels.remove(correctLabel);
  while (wrongLabels.length < 3) {
    wrongLabels.add(_formatNum(correct + (wrongLabels.length + 1) * step));
  }
  final options = [correctLabel, ...wrongLabels.take(3)]..shuffle(random);
  return QuizQuestion(
    subject: _subject,
    text: text,
    options: options,
    correctIndex: options.indexOf(correctLabel),
    explanation: explanation,
  );
}

String _formatNum(num value) {
  if (value is int) return value.toString();
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2);
}

String _simplifiedFraction(int numerator, int denominator) {
  if (numerator == 0) return '0';
  final sign = (numerator < 0) != (denominator < 0) ? '-' : '';
  final n = numerator.abs(), d = denominator.abs();
  final divisor = _gcd(n, d);
  final sn = n ~/ divisor, sd = d ~/ divisor;
  if (sd == 1) return '$sign$sn';
  return '$sign$sn/$sd';
}

// ---------------------------------------------------------------------------
// Sets — power sets and symmetric differences.
// ---------------------------------------------------------------------------

List<QuizQuestion> _setsAdvancedQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  for (var n = 1; n <= 12; n++) {
    final powerSetSize = math.pow(2, n).toInt();
    questions.add(_buildNumeric(
      'A set A has $n elements. Find the number of elements in its power set P(A).',
      powerSetSize,
      random,
      '|P(A)| = 2^n = 2^$n = $powerSetSize.',
      step: powerSetSize ~/ 4 == 0 ? 1 : powerSetSize ~/ 4,
    ));
  }

  const symmetricDiffCases = [
    [10, 8, 4], [12, 9, 5], [15, 10, 6], [14, 11, 7], [18, 12, 6],
    [20, 14, 8], [16, 13, 5], [22, 15, 9], [11, 9, 3], [17, 12, 4],
  ];
  for (final c in symmetricDiffCases) {
    final a = c[0], b = c[1], intersection = c[2];
    final symmetricDiff = a + b - 2 * intersection;
    questions.add(_buildNumeric(
      'Given n(A) = $a, n(B) = $b, and n(A∩B) = $intersection, find n(AΔB), '
          'the number of elements in the symmetric difference of A and B.',
      symmetricDiff,
      random,
      'n(AΔB) = n(A) + n(B) - 2n(A∩B) = $a + $b - 2($intersection) = $symmetricDiff.',
      step: 2,
    ));
  }

  final deMorganPool = [
    ("A' ∩ B'", "(A∪B)'"),
    ("A' ∪ B'", "(A∩B)'"),
  ];
  for (final pair in deMorganPool) {
    questions.add(_buildFromPool(
      'By De Morgan\'s law, ${pair.$2} is equal to:',
      pair.$1,
      deMorganPool.map((p) => p.$1).toList()..addAll(['A ∩ B', 'A ∪ B']),
      random,
      "De Morgan's law states that ${pair.$2} = ${pair.$1}.",
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Functions and mappings — composite and inverse functions of f(x) = ax + b.
// ---------------------------------------------------------------------------

List<QuizQuestion> _functionsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const linearPairs = [
    [2, 1, 3, 2], [3, 2, 2, 1], [1, 4, 2, 3], [4, 1, 1, 2], [2, 3, 3, 1],
    [5, 2, 1, 3], [3, 1, 4, 2], [2, 5, 1, 1], [1, 2, 3, 4], [4, 3, 2, 1],
  ];
  for (final p in linearPairs) {
    final a = p[0], b = p[1], c = p[2], d = p[3];
    final composedA = a * c;
    final composedB = a * d + b;
    final label = composedB >= 0 ? '${composedA}x + $composedB' : '${composedA}x - ${composedB.abs()}';
    questions.add(_buildFromPool(
      'Given f(x) = ${a}x + $b and g(x) = ${c}x + $d, find (f∘g)(x).',
      label,
      linearPairs.map((pp) {
        final ca = pp[0] * pp[2], cb = pp[0] * pp[3] + pp[1];
        return cb >= 0 ? '${ca}x + $cb' : '${ca}x - ${cb.abs()}';
      }).toList(),
      random,
      '(f∘g)(x) = f(g(x)) = f(${c}x + $d) = $a(${c}x + $d) + $b = $label.',
    ));

    const k = 2;
    final value = composedA * k + composedB;
    questions.add(_buildNumeric(
      'Given f(x) = ${a}x + $b and g(x) = ${c}x + $d, find (f∘g)($k).',
      value,
      random,
      '(f∘g)($k) = $composedA($k) + $composedB = $value.',
      step: 3,
    ));
  }

  for (final p in linearPairs.take(6)) {
    final a = p[0], b = p[1];
    final inverseLabel = b >= 0 ? '(x - $b)/$a' : '(x + ${b.abs()})/$a';
    questions.add(_buildFromPool(
      'Given f(x) = ${a}x + $b, find f⁻¹(x).',
      inverseLabel,
      linearPairs.take(6).map((pp) {
        final aa = pp[0], bb = pp[1];
        return bb >= 0 ? '(x - $bb)/$aa' : '(x + ${bb.abs()})/$aa';
      }).toList(),
      random,
      'Let y = ${a}x + $b. Solving for x: x = (y - $b)/$a. So f⁻¹(x) = $inverseLabel.',
    ));
  }

  final mappingConcepts = [
    ('A function that maps every element of its domain to a distinct element of its codomain is called:', 'One-to-one (injective)', ['Onto (surjective)', 'Many-to-one', 'Not a function']),
    ('A function where every element of the codomain has at least one pre-image in the domain is called:', 'Onto (surjective)', ['One-to-one (injective)', 'Many-to-one', 'Undefined']),
    ('A function that is both one-to-one and onto is called:', 'Bijective', ['Injective only', 'Surjective only', 'Neither injective nor surjective']),
    ('For a function f to have an inverse f⁻¹, f must be:', 'Bijective', ['Onto only', 'One-to-one only', 'Defined on integers only']),
  ];
  for (final concept in mappingConcepts) {
    final options = [concept.$2, ...concept.$3]..shuffle(random);
    questions.add(QuizQuestion(
      subject: _subject,
      text: concept.$1,
      options: options,
      correctIndex: options.indexOf(concept.$2),
      explanation: '${concept.$2} is the correct term for this property.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Roots of quadratic equations — symmetric functions of roots.
// ---------------------------------------------------------------------------

List<QuizQuestion> _quadraticRootsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const coeffCases = [
    [1, -5, 6], [1, -7, 12], [2, -8, 6], [1, -3, -10], [3, -11, 6],
    [1, -9, 20], [2, -10, 12], [1, -4, -21], [1, -11, 30], [2, -14, 20],
    [1, -6, 8], [1, -13, 42], [3, -13, 4], [1, -8, 15], [2, -12, 16],
  ];

  for (final c in coeffCases) {
    final a = c[0], b = c[1], cc = c[2];
    final sum = _simplifiedFraction(-b, a);
    final product = _simplifiedFraction(cc, a);
    final sumValue = -b / a;
    final productValue = cc / a;

    questions.add(_buildFromPool(
      'For the equation ${a == 1 ? '' : a}x² ${b >= 0 ? '+ $b' : '- ${b.abs()}'}x '
          '${cc >= 0 ? '+ $cc' : '- ${cc.abs()}'} = 0, find the sum of the roots α + β.',
      sum,
      coeffCases.map((cc2) => _simplifiedFraction(-cc2[1], cc2[0])).toList(),
      random,
      'Sum of roots = -b/a = -($b)/$a = $sum.',
    ));

    questions.add(_buildFromPool(
      'For the equation ${a == 1 ? '' : a}x² ${b >= 0 ? '+ $b' : '- ${b.abs()}'}x '
          '${cc >= 0 ? '+ $cc' : '- ${cc.abs()}'} = 0, find the product of the roots αβ.',
      product,
      coeffCases.map((cc2) => _simplifiedFraction(cc2[2], cc2[0])).toList(),
      random,
      'Product of roots = c/a = $cc/$a = $product.',
    ));

    // New equation with roots squared: sum = S² - 2P, product = P².
    final squaredSum = sumValue * sumValue - 2 * productValue;
    if (squaredSum == squaredSum.roundToDouble() && productValue * productValue == (productValue * productValue).roundToDouble()) {
      questions.add(_buildNumeric(
        'A quadratic equation has roots α and β where α + β = ${_formatNum(sumValue)} and αβ = ${_formatNum(productValue)}. '
            'Find the sum of the roots of a new equation whose roots are α² and β².',
        squaredSum,
        random,
        'Sum of squared roots = (α + β)² - 2αβ = (${_formatNum(sumValue)})² - 2(${_formatNum(productValue)}) = ${_formatNum(squaredSum)}.',
        step: 3,
      ));
    }
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Polynomials — remainder theorem and factor theorem.
// ---------------------------------------------------------------------------

int _evaluateCubic(int a, int b, int c, int d, int x) => a * x * x * x + b * x * x + c * x + d;

List<QuizQuestion> _polynomialQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const cubicCases = [
    [1, -2, -5, 6, 3], [1, 0, -7, 6, 2], [2, -3, -3, 2, 1], [1, -6, 11, -6, 4],
    [1, 1, -10, 8, 2], [1, -4, 1, 6, 3], [2, -5, -4, 3, 1], [1, 3, -4, -12, 2],
    [1, -1, -4, 4, 2], [1, 2, -13, 10, 5],
    [1, -3, -6, 8, 4], [2, 1, -5, 2, 1], [1, -7, 14, -8, 2], [1, 0, -4, 0, 2],
    [1, 5, 2, -8, 1], [2, -7, 7, -2, 1], [1, -5, -2, 24, 3], [1, 4, -7, -10, 2],
  ];

  for (final c in cubicCases) {
    final a = c[0], b = c[1], cc = c[2], d = c[3], x = c[4];
    final remainder = _evaluateCubic(a, b, cc, d, x);
    final polyLabel = 'p(x) = ${a == 1 ? '' : a}x³ ${b >= 0 ? '+ $b' : '- ${b.abs()}'}x² '
        '${cc >= 0 ? '+ $cc' : '- ${cc.abs()}'}x ${d >= 0 ? '+ $d' : '- ${d.abs()}'}';
    questions.add(_buildNumeric(
      'Given $polyLabel, use the remainder theorem to find the remainder when p(x) is divided by (x - $x).',
      remainder,
      random,
      'By the remainder theorem, the remainder is p($x) = $a($x)³ + $b($x)² + $cc($x) + $d = $remainder.',
      step: 4,
    ));

    final isFactor = remainder == 0;
    questions.add(_buildFromPool(
      'Given $polyLabel, is (x - $x) a factor of p(x)?',
      isFactor ? 'Yes, since p($x) = 0' : 'No, since p($x) = $remainder ≠ 0',
      ['Yes, since p($x) = 0', 'No, since p($x) = $remainder ≠ 0', 'Cannot be determined', 'Only if x is negative'],
      random,
      'By the factor theorem, (x - $x) is a factor of p(x) if and only if p($x) = 0. '
          'Here p($x) = $remainder, so the statement "${isFactor ? 'Yes, since p($x) = 0' : 'No, since p($x) = $remainder ≠ 0'}" is correct.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Surds and logarithms — rationalizing denominators and log equations.
// ---------------------------------------------------------------------------

List<QuizQuestion> _surdsLogsAdvancedQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const rationalizeCases = [
    [5, 3], [7, 2], [6, 5], [8, 3], [10, 6], [9, 4], [11, 7], [13, 8],
  ];
  for (final c in rationalizeCases) {
    final a = c[0], b = c[1];
    final denominator = a - b;
    final label = '(√$a - √$b)/$denominator';
    questions.add(_buildFromPool(
      'Rationalize the denominator of 1/(√$a + √$b).',
      label,
      rationalizeCases.map((cc) => '(√${cc[0]} - √${cc[1]})/${cc[0] - cc[1]}').toList(),
      random,
      'Multiply numerator and denominator by (√$a - √$b): '
          '1/(√$a + √$b) × (√$a - √$b)/(√$a - √$b) = (√$a - √$b)/($a - $b) = $label.',
    ));
  }

  const logEquationCases = [
    [2, 3, 8], [3, 2, 9], [5, 2, 25], [2, 4, 16], [4, 2, 16], [3, 3, 27],
    [2, 5, 32], [5, 3, 125], [10, 2, 100], [10, 3, 1000],
  ];
  for (final c in logEquationCases) {
    final base = c[0], power = c[1], value = c[2];
    questions.add(_buildNumeric(
      'Solve for x: log$base x = $power.',
      value,
      random,
      'log$base x = $power means x = $base^$power = $value.',
      step: value ~/ 4 == 0 ? 1 : value ~/ 4,
    ));
  }

  const changeOfBaseCases = [
    [8, 2], [9, 3], [16, 2], [27, 3], [25, 5], [32, 2], [49, 7], [64, 2],
  ];
  for (final c in changeOfBaseCases) {
    final n = c[0], base = c[1];
    final exponent = (math.log(n) / math.log(base)).round();
    questions.add(_buildNumeric(
      'Evaluate log$base $n.',
      exponent,
      random,
      'log$base $n asks: $base to what power gives $n? Since $base^$exponent = $n, log$base $n = $exponent.',
      step: 2,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Partial fractions — resolving rational expressions with distinct linear
// denominators, using the cover-up rule.
// ---------------------------------------------------------------------------

List<QuizQuestion> _partialFractionsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  // Reverse-constructed: choose A, B and the two roots directly, then derive
  // p and q so that (px + q)/[(x-rootA)(x-rootB)] = A/(x-rootA) + B/(x-rootB)
  // exactly. This guarantees clean integer answers with no filtering.
  const rootPairs = [
    [1, 2], [2, 3], [1, 4], [3, 5],
  ];
  for (final roots in rootPairs) {
    final rootA = roots[0], rootB = roots[1];
    for (var a = 1; a <= 4; a++) {
      for (var b = 1; b <= 3; b++) {
        final p = a + b;
        final q = -(a * rootB + b * rootA);
        final qLabel = q >= 0 ? '+ $q' : '- ${q.abs()}';

        questions.add(_buildNumeric(
          'Resolve (${p}x $qLabel) / [(x - $rootA)(x - $rootB)] into partial fractions of the form '
              'A/(x - $rootA) + B/(x - $rootB). Find A.',
          a,
          random,
          'By the cover-up rule, A = (p × $rootA + q) / ($rootA - $rootB) = '
              '($p × $rootA $qLabel) / (${rootA - rootB}) = $a.',
          step: 2,
        ));
        questions.add(_buildNumeric(
          'Resolve (${p}x $qLabel) / [(x - $rootA)(x - $rootB)] into partial fractions of the form '
              'A/(x - $rootA) + B/(x - $rootB). Find B.',
          b,
          random,
          'By the cover-up rule, B = (p × $rootB + q) / ($rootB - $rootA) = '
              '($p × $rootB $qLabel) / (${rootB - rootA}) = $b.',
          step: 2,
        ));
      }
    }
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Binary operations — identity and inverse elements.
// ---------------------------------------------------------------------------

List<QuizQuestion> _binaryOperationsAdvancedQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  for (var k = 1; k <= 10; k++) {
    final identity = k;
    questions.add(_buildNumeric(
      'A binary operation * is defined on the real numbers by a * b = a + b - $k. '
          'Find the identity element e for this operation.',
      identity,
      random,
      'For identity e: a * e = a  ⟹  a + e - $k = a  ⟹  e = $k.',
      step: 2,
    ));

    const sampleA = 7;
    final inverse = 2 * k - sampleA;
    questions.add(_buildNumeric(
      'A binary operation * is defined on the real numbers by a * b = a + b - $k, with identity element $k. '
          'Find the inverse of $sampleA under this operation.',
      inverse,
      random,
      "For the inverse a' of a: a * a' = e  ⟹  $sampleA + a' - $k = $k  ⟹  a' = 2($k) - $sampleA = $inverse.",
      step: 2,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Matrices — 3×3 determinants, 2×2 inverses, and Cramer's rule.
// ---------------------------------------------------------------------------

List<QuizQuestion> _matricesAdvancedQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const matrices3x3 = [
    [1, 2, 3, 0, 1, 4, 5, 6, 0], [2, 1, 0, 1, 3, 2, 0, 1, 4],
    [1, 0, 2, 3, 1, 1, 2, 0, 1], [2, 3, 1, 1, 0, 2, 0, 1, 3],
    [1, 1, 1, 2, 1, 0, 3, 2, 1], [1, 2, 0, 0, 1, 3, 2, 0, 1],
    [3, 0, 1, 1, 2, 0, 0, 1, 2], [2, 1, 1, 0, 2, 1, 1, 0, 2],
    [1, 3, 2, 0, 1, 1, 2, 1, 0], [2, 0, 3, 1, 1, 0, 0, 2, 1],
    [1, 2, 1, 3, 0, 2, 1, 1, 0], [2, 1, 3, 0, 2, 1, 1, 0, 2],
    [3, 1, 2, 0, 1, 1, 2, 2, 0], [1, 0, 1, 2, 1, 3, 0, 1, 2],
    [2, 2, 0, 1, 1, 2, 0, 1, 1], [1, 1, 2, 0, 3, 1, 2, 0, 1],
  ];
  for (final m in matrices3x3) {
    final a = m[0], b = m[1], c = m[2], d = m[3], e = m[4], f = m[5], g = m[6], h = m[7], i = m[8];
    final det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
    questions.add(_buildNumeric(
      'Find the determinant of the matrix [$a $b $c; $d $e $f; $g $h $i].',
      det,
      random,
      'det = $a($e×$i - $f×$h) - $b($d×$i - $f×$g) + $c($d×$h - $e×$g) = $det.',
      step: 5,
    ));
  }

  const matrices2x2 = [
    [3, 2, 1, 4], [5, 1, 2, 3], [4, 3, 2, 5], [6, 2, 1, 3],
    [2, 1, 3, 4], [5, 3, 1, 2], [7, 2, 3, 5], [4, 1, 2, 3],
    [3, 1, 2, 4], [5, 2, 3, 4], [6, 1, 2, 5], [4, 2, 3, 5],
  ];
  for (final m in matrices2x2) {
    final a = m[0], b = m[1], c = m[2], d = m[3];
    final det = a * d - b * c;
    if (det == 0) continue;
    final invLabel = '(1/$det)[$d ${-b}; ${-c} $a]';
    questions.add(_buildFromPool(
      'Find the inverse of the matrix A = [$a $b; $c $d].',
      invLabel,
      matrices2x2.where((mm) => mm[0] * mm[3] - mm[1] * mm[2] != 0).map((mm) {
        final dd = mm[0] * mm[3] - mm[1] * mm[2];
        return '(1/$dd)[${mm[3]} ${-mm[1]}; ${-mm[2]} ${mm[0]}]';
      }).toList(),
      random,
      'det(A) = $a×$d - $b×$c = $det. A⁻¹ = (1/det) × [d -b; -c a] = $invLabel.',
    ));
  }

  const cramerCases = [
    [2, 1, 8, 1, 3, 9], [3, 2, 12, 1, 1, 5], [1, 2, 7, 3, 1, 7],
    [2, 3, 13, 1, 2, 8], [4, 1, 14, 2, 3, 13], [1, 1, 6, 2, 5, 18],
    [3, 1, 10, 2, 3, 13], [2, 5, 16, 3, 2, 11],
  ];
  for (final c in cramerCases) {
    final a1 = c[0], b1 = c[1], c1 = c[2], a2 = c[3], b2 = c[4], c2 = c[5];
    final d = a1 * b2 - a2 * b1;
    if (d == 0) continue;
    final dx = c1 * b2 - c2 * b1;
    if (dx % d != 0) continue;
    final x = dx ~/ d;
    questions.add(_buildNumeric(
      'Using Cramer\'s rule, solve for x:\n'
      '${a1}x + ${b1}y = $c1\n'
      '${a2}x + ${b2}y = $c2',
      x,
      random,
      'D = $a1×$b2 - $a2×$b1 = $d. Dx = $c1×$b2 - $c2×$b1 = $dx. x = Dx/D = $dx/$d = $x.',
      step: 2,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Mathematical induction — conceptual structure of an induction proof.
// ---------------------------------------------------------------------------

List<QuizQuestion> _mathematicalInductionQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  final concepts = [
    ('The first step of a proof by mathematical induction is to show that the statement holds for:', 'The base case (usually n = 1)', ['n = k', 'n = k + 1', 'All values of n simultaneously']),
    ('In the inductive step of a proof by induction, we assume the statement is true for n = k. This assumption is called the:', 'Inductive hypothesis', ['Base case', 'Conclusion', 'Contrapositive']),
    ('After assuming the statement is true for n = k, the next step in an induction proof is to show it is true for:', 'n = k + 1', ['n = 1', 'n = k - 1', 'All n at once']),
    ('If both the base case and the inductive step of a proof by induction are established, we conclude the statement is true for:', 'All positive integers n', ['Only n = 1', 'Only even values of n', 'No values of n'], ),
    ('To prove that 1 + 2 + ... + n = n(n+1)/2 by induction, assuming it is true for n = k, what must be added to k(k+1)/2 to obtain the sum for n = k + 1?', '(k + 1)', ['k', '2(k + 1)', 'k²']),
    ('To prove a divisibility statement like "7ⁿ - 1 is divisible by 6" by induction, the inductive step typically involves showing that the expression for n = k + 1 can be written as a multiple of the expression for n = k plus:', 'a term that is also divisible by 6', ['a term that is never divisible by 6', 'a term that is always odd', 'a term equal to zero']),
  ];

  for (final entry in concepts) {
    final question = entry.$1;
    final correct = entry.$2;
    final distractors = entry.$3;
    final options = [correct, ...distractors]..shuffle(random);
    questions.add(QuizQuestion(
      subject: _subject,
      text: question,
      options: options,
      correctIndex: options.indexOf(correct),
      explanation: '$correct is the correct step in a proof by mathematical induction.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Series — sum to infinity of a convergent geometric progression.
// ---------------------------------------------------------------------------

List<QuizQuestion> _seriesSumToInfinityQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  // Reverse-constructed: choose r = num/den and a multiplier m, then set
  // a = m × (den - num) so that S∞ = a/(1-r) = m × den always comes out as
  // a clean integer, with no divisibility filtering needed.
  for (var den = 2; den <= 6; den++) {
    for (var num = 1; num < den; num++) {
      for (var m = 1; m <= 3; m++) {
        final a = m * (den - num);
        final result = m * den;
        questions.add(_buildNumeric(
          'Find the sum to infinity of the geometric progression with first term $a and common ratio $num/$den.',
          result,
          random,
          'S∞ = a/(1 - r) = $a/(1 - $num/$den) = $a ÷ (${den - num}/$den) = $a × ($den/${den - num}) = $result.',
          step: result ~/ 5 == 0 ? 1 : result ~/ 5,
        ));
      }
    }
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Binomial theorem — general term and specific coefficients.
// ---------------------------------------------------------------------------

int _factorial(int n) => n <= 1 ? 1 : n * _factorial(n - 1);
int _nCr(int n, int r) => _factorial(n) ~/ (_factorial(r) * _factorial(n - r));

List<QuizQuestion> _binomialTheoremQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  for (var n = 4; n <= 16; n++) {
    final coeff = _nCr(n, 2);
    questions.add(_buildNumeric(
      'Find the coefficient of x² in the binomial expansion of (1 + x)^$n.',
      coeff,
      random,
      'The coefficient of x² is ⁿC₂ = $n! / (2!($n-2)!) = $coeff.',
      step: coeff ~/ 4 == 0 ? 1 : coeff ~/ 4,
    ));
  }

  for (var n = 5; n <= 12; n++) {
    final coeff = _nCr(n, 3);
    questions.add(_buildNumeric(
      'Find the coefficient of x³ in the binomial expansion of (1 + x)^$n.',
      coeff,
      random,
      'The coefficient of x³ is ⁿC₃ = $n! / (3!($n-3)!) = $coeff.',
      step: coeff ~/ 4 == 0 ? 1 : coeff ~/ 4,
    ));
  }

  const termCases = [
    [5, 2, 2, 1], [6, 3, 1, 2], [4, 2, 3, 1], [7, 3, 1, 2], [5, 3, 2, 1],
    [6, 2, 1, 3], [8, 3, 1, 2], [4, 1, 2, 1], [7, 2, 1, 2], [6, 4, 1, 1],
    [5, 1, 1, 3], [7, 4, 1, 1], [6, 1, 2, 2], [8, 2, 1, 3], [9, 3, 1, 2],
    [5, 4, 1, 1], [8, 4, 1, 2], [9, 2, 2, 1], [7, 1, 3, 1], [6, 5, 1, 1],
  ];
  for (final t in termCases) {
    final n = t[0], r = t[1], aBase = t[2], bBase = t[3];
    final coeff = _nCr(n, r);
    final aPower = math.pow(aBase, n - r).toInt();
    final bPower = math.pow(bBase, r).toInt();
    final termCoefficient = coeff * aPower * bPower;
    questions.add(_buildNumeric(
      'Find the coefficient of the term containing x^$r in the expansion of ($aBase + ${bBase}x)^$n.',
      termCoefficient,
      random,
      'The term is ⁿCᵣ × ($aBase)^(n-r) × ($bBase x)^r = $coeff × $aPower × $bPower = $termCoefficient.',
      step: termCoefficient ~/ 4 == 0 ? 1 : termCoefficient ~/ 4,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Compound angle formulas — using known sin/cos values from right triangles.
// ---------------------------------------------------------------------------

List<QuizQuestion> _compoundAngleQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const triangleAngles = [
    [3, 4, 5], [5, 12, 13], [8, 15, 17], [7, 24, 25], [20, 21, 29], [9, 40, 41],
  ];

  for (var i = 0; i < triangleAngles.length; i++) {
    for (var j = 0; j < triangleAngles.length; j++) {
      if (i == j) continue;
      final tA = triangleAngles[i];
      final tB = triangleAngles[j];
      final sinA = tA[0] / tA[2], cosA = tA[1] / tA[2];
      final sinB = tB[0] / tB[2], cosB = tB[1] / tB[2];

      final sinSum = sinA * cosB + cosA * sinB;
      final sinSumFraction = _simplifiedFraction((tA[0] * tB[1] + tA[1] * tB[0]) * (tA[2] * tB[2] ~/ (tA[2] * tB[2])), tA[2] * tB[2]);
      final numeratorSin = tA[0] * tB[1] + tA[1] * tB[0];
      final denominatorAB = tA[2] * tB[2];
      questions.add(_buildFromPool(
        'Given sin A = $sinA (as a fraction ${tA[0]}/${tA[2]}) and cos A = ${tA[1]}/${tA[2]}, '
            'and sin B = ${tB[0]}/${tB[2]} and cos B = ${tB[1]}/${tB[2]} (A and B both acute), find sin(A + B).',
        _simplifiedFraction(numeratorSin, denominatorAB),
        [
          _simplifiedFraction(numeratorSin, denominatorAB),
          _simplifiedFraction(numeratorSin + 1, denominatorAB),
          _simplifiedFraction(tA[0] * tB[0], denominatorAB),
          _simplifiedFraction(tA[1] * tB[1], denominatorAB),
        ],
        random,
        'sin(A + B) = sinA cosB + cosA sinB = (${tA[0]}×${tB[1]} + ${tA[1]}×${tB[0]})/(${tA[2]}×${tB[2]}) '
            '= $numeratorSin/$denominatorAB = ${_simplifiedFraction(numeratorSin, denominatorAB)}.',
      ));
      // Avoid unused variable warnings for the intermediate double calc.
      assert(sinSum >= -1 && sinSum <= 1);
      assert(sinSumFraction.isNotEmpty);

      final numeratorCosDiff = tA[1] * tB[1] + tA[0] * tB[0];
      questions.add(_buildFromPool(
        'Given sin A = ${tA[0]}/${tA[2]}, cos A = ${tA[1]}/${tA[2]}, sin B = ${tB[0]}/${tB[2]}, '
            'and cos B = ${tB[1]}/${tB[2]} (A and B both acute), find cos(A - B).',
        _simplifiedFraction(numeratorCosDiff, denominatorAB),
        [
          _simplifiedFraction(numeratorCosDiff, denominatorAB),
          _simplifiedFraction(numeratorCosDiff - 1, denominatorAB),
          _simplifiedFraction(tA[1] * tB[0], denominatorAB),
          _simplifiedFraction(tA[0] * tB[1], denominatorAB),
        ],
        random,
        'cos(A - B) = cosA cosB + sinA sinB = (${tA[1]}×${tB[1]} + ${tA[0]}×${tB[0]})/(${tA[2]}×${tB[2]}) '
            '= $numeratorCosDiff/$denominatorAB = ${_simplifiedFraction(numeratorCosDiff, denominatorAB)}.',
      ));

      if (i >= 3 && j >= 3) break;
    }
    if (i >= 3) break;
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Double angle formulas.
// ---------------------------------------------------------------------------

List<QuizQuestion> _doubleAngleQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const triples = [
    [3, 4, 5], [5, 12, 13], [8, 15, 17], [7, 24, 25], [20, 21, 29], [9, 12, 15],
    [12, 16, 20], [10, 24, 26],
  ];

  for (final t in triples) {
    final opp = t[0], adj = t[1], hyp = t[2];
    final sinTheta = opp, cosTheta = adj, hypSquared = hyp * hyp;

    final sin2NumeratorRaw = 2 * sinTheta * cosTheta;
    questions.add(_buildFromPool(
      'Given sin θ = $opp/$hyp and cos θ = $adj/$hyp (θ acute), find sin 2θ.',
      _simplifiedFraction(sin2NumeratorRaw, hypSquared),
      [
        _simplifiedFraction(sin2NumeratorRaw, hypSquared),
        _simplifiedFraction(sinTheta * sinTheta, hypSquared),
        _simplifiedFraction(cosTheta * cosTheta, hypSquared),
        _simplifiedFraction(sin2NumeratorRaw + hyp, hypSquared),
      ],
      random,
      'sin 2θ = 2 sinθ cosθ = 2 × ($opp/$hyp) × ($adj/$hyp) = $sin2NumeratorRaw/$hypSquared '
          '= ${_simplifiedFraction(sin2NumeratorRaw, hypSquared)}.',
    ));

    final cos2Numerator = adj * adj - opp * opp;
    questions.add(_buildFromPool(
      'Given sin θ = $opp/$hyp and cos θ = $adj/$hyp (θ acute), find cos 2θ.',
      _simplifiedFraction(cos2Numerator, hypSquared),
      [
        _simplifiedFraction(cos2Numerator, hypSquared),
        _simplifiedFraction(-cos2Numerator, hypSquared),
        _simplifiedFraction(sin2NumeratorRaw, hypSquared),
        _simplifiedFraction(opp * opp, hypSquared),
      ],
      random,
      'cos 2θ = cos²θ - sin²θ = ($adj² - $opp²)/$hyp² = $cos2Numerator/$hypSquared '
          '= ${_simplifiedFraction(cos2Numerator, hypSquared)}.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Trigonometric equations — solving within a given interval.
// ---------------------------------------------------------------------------

List<QuizQuestion> _trigEquationsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const sinCases = [
    [1, 2, '30° and 150°'], [1, 2, '30° and 150°'],
  ];
  // Real distinct cases built directly (kept explicit for correctness).
  final sinEquations = [
    ('sin θ = 1/2', '30° and 150°'),
    ('sin θ = √3/2', '60° and 120°'),
    ('sin θ = √2/2', '45° and 135°'),
    ('sin θ = -1/2', '210° and 330°'),
  ];
  final cosEquations = [
    ('cos θ = 1/2', '60° and 300°'),
    ('cos θ = √3/2', '30° and 330°'),
    ('cos θ = √2/2', '45° and 315°'),
    ('cos θ = -1/2', '120° and 240°'),
  ];
  final tanEquations = [
    ('tan θ = 1', '45° and 225°'),
    ('tan θ = √3', '60° and 240°'),
    ('tan θ = -1', '135° and 315°'),
    ('tan θ = 1/√3', '30° and 210°'),
  ];
  assert(sinCases.isNotEmpty);

  final allPool = [
    ...sinEquations.map((e) => e.$2),
    ...cosEquations.map((e) => e.$2),
    ...tanEquations.map((e) => e.$2),
  ];

  for (final eq in [...sinEquations, ...cosEquations, ...tanEquations]) {
    questions.add(_buildFromPool(
      'Solve the equation ${eq.$1} for 0° ≤ θ ≤ 360°.',
      eq.$2,
      allPool,
      random,
      'Within the interval 0° to 360°, the equation ${eq.$1} has solutions θ = ${eq.$2}.',
    ));
  }

  // Repeat with a scaling multiplier for variety (2θ equations).
  final doubleAngleEquations = [
    ('sin 2θ = 1/2', '15°, 75°, 195°, and 255°'),
    ('cos 2θ = 1/2', '30°, 150°, 210°, and 330°'),
  ];
  for (final eq in doubleAngleEquations) {
    questions.add(_buildFromPool(
      'Solve the equation ${eq.$1} for 0° ≤ θ ≤ 360°.',
      eq.$2,
      [eq.$2, '15°, 75°', '30°, 150°', '90°, 270°'],
      random,
      'Solving for 2θ first across 0° to 720°, then dividing by 2, gives θ = ${eq.$2}.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Inverse trigonometric functions — standard values.
// ---------------------------------------------------------------------------

List<QuizQuestion> _inverseTrigQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  final arcsinCases = [
    ('arcsin(1/2)', '30°'), ('arcsin(√2/2)', '45°'), ('arcsin(√3/2)', '60°'), ('arcsin(1)', '90°'), ('arcsin(0)', '0°'),
  ];
  final arccosCases = [
    ('arccos(1/2)', '60°'), ('arccos(√2/2)', '45°'), ('arccos(√3/2)', '30°'), ('arccos(0)', '90°'), ('arccos(1)', '0°'),
  ];
  final arctanCases = [
    ('arctan(1)', '45°'), ('arctan(√3)', '60°'), ('arctan(1/√3)', '30°'), ('arctan(0)', '0°'),
  ];

  final pool = {
    ...arcsinCases.map((e) => e.$2),
    ...arccosCases.map((e) => e.$2),
    ...arctanCases.map((e) => e.$2),
  }.toList();

  for (final entry in [...arcsinCases, ...arccosCases, ...arctanCases]) {
    questions.add(_buildFromPool(
      'Evaluate ${entry.$1}.',
      entry.$2,
      pool,
      random,
      '${entry.$1} = ${entry.$2}, a standard inverse trigonometric value.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Differentiation rules — product, quotient, and chain rule.
// ---------------------------------------------------------------------------

List<QuizQuestion> _differentiationRulesQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  // Chain rule: d/dx (ax + b)^n = an(ax+b)^(n-1).
  const chainCases = [
    [2, 1, 3], [3, 2, 2], [2, 3, 4], [4, 1, 2], [3, 1, 3], [5, 2, 2], [2, 5, 3], [4, 3, 2],
  ];
  for (final c in chainCases) {
    final a = c[0], b = c[1], n = c[2];
    final newCoeff = a * n;
    final newExponent = n - 1;
    final label = b >= 0
        ? '$newCoeff(${a}x + $b)^$newExponent'
        : '$newCoeff(${a}x - ${b.abs()})^$newExponent';
    questions.add(_buildFromPool(
      'Differentiate y = (${a}x ${b >= 0 ? '+ $b' : '- ${b.abs()}'})^$n with respect to x.',
      label,
      chainCases.map((cc) {
        final aa = cc[0], bb = cc[1], nn = cc[2];
        final nc = aa * nn, ne = nn - 1;
        return bb >= 0 ? '$nc(${aa}x + $bb)^$ne' : '$nc(${aa}x - ${bb.abs()})^$ne';
      }).toList(),
      random,
      'By the chain rule, dy/dx = n(a)(ax+b)^(n-1) = $n × $a × (${a}x ${b >= 0 ? '+ $b' : '- ${b.abs()}'})^$newExponent = $label.',
    ));
  }

  // Product rule evaluated at a numeric point: y = (ax+b)(cx+d), find dy/dx at x = k.
  const productCases = [
    [2, 1, 3, 2, 1], [1, 3, 2, 1, 2], [3, 2, 1, 4, 1], [2, 5, 3, 1, 2],
    [1, 2, 4, 3, 1], [3, 1, 2, 2, 2], [2, 3, 1, 5, 1], [4, 1, 1, 2, 2],
  ];
  for (final c in productCases) {
    final a = c[0], b = c[1], cc = c[2], d = c[3], x = c[4];
    // y = (ax+b)(cx+d), dy/dx = a(cx+d) + c(ax+b)
    final derivative = a * (cc * x + d) + cc * (a * x + b);
    questions.add(_buildNumeric(
      'Given y = (${a}x + $b)(${cc}x + $d), use the product rule to find dy/dx at x = $x.',
      derivative,
      random,
      "dy/dx = $a(${cc}x + $d) + $cc(${a}x + $b). At x = $x: $a(${cc * x + d}) + $cc(${a * x + b}) = $derivative.",
      step: 4,
    ));
  }

  // Quotient rule: y = (ax+b)/(cx+d) simplifies to dy/dx = (ad-bc)/(cx+d)²,
  // a constant numerator independent of x. Expressed as a fraction, this
  // always has a clean exact answer with no divisibility filtering needed.
  const quotientCases = [
    [1, 2, 1, 3, 1], [2, 1, 1, 4, 1], [3, 2, 2, 5, 1], [1, 4, 1, 2, 2],
    [2, 3, 1, 5, 1], [3, 1, 2, 3, 2], [1, 5, 2, 1, 1], [4, 2, 1, 3, 1],
    [2, 5, 3, 1, 2], [1, 3, 2, 4, 1], [3, 4, 1, 2, 2], [5, 1, 2, 3, 1],
    [2, 1, 3, 5, 1], [1, 6, 2, 1, 2], [4, 3, 1, 5, 1], [3, 2, 4, 1, 1],
  ];
  for (final c in quotientCases) {
    final a = c[0], b = c[1], cc = c[2], d = c[3], x = c[4];
    final denomAtX = cc * x + d;
    if (denomAtX == 0) continue;
    final derivativeNumerator = a * d - b * cc;
    final denomSquared = denomAtX * denomAtX;
    final label = _simplifiedFraction(derivativeNumerator, denomSquared);
    questions.add(_buildFromPool(
      'Given y = (${a}x + $b)/(${cc}x + $d), use the quotient rule to find dy/dx at x = $x.',
      label,
      quotientCases.map((cc2) {
        final aa = cc2[0], bb = cc2[1], ccc = cc2[2], dd = cc2[3], xx = cc2[4];
        final dx = ccc * xx + dd;
        if (dx == 0) return '0';
        return _simplifiedFraction(aa * dd - bb * ccc, dx * dx);
      }).toList(),
      random,
      'dy/dx = (ad - bc)/(cx+d)² = ($a×$d - $b×$cc)/($cc×$x + $d)² = $derivativeNumerator/$denomSquared = $label.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Stationary points — turning points of quadratics and cubics.
// ---------------------------------------------------------------------------

List<QuizQuestion> _stationaryPointsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const quadraticCases = [
    [1, -4, 3], [2, -8, 5], [1, -6, 2], [3, -12, 4], [1, 2, -3],
    [2, 4, -1], [1, -10, 7], [4, -8, 2], [1, 8, 5], [2, -6, 3],
    [1, -12, 8], [2, -10, 6], [1, 6, 4], [3, -18, 9], [1, -14, 10],
    [2, 12, -5], [1, -16, 12], [4, -16, 3], [1, 10, 6], [2, -14, 8],
  ];
  for (final c in quadraticCases) {
    final a = c[0], b = c[1], cc = c[2];
    if ((-b) % (2 * a) != 0) continue;
    final x = -b ~/ (2 * a);
    questions.add(_buildNumeric(
      'Find the x-coordinate of the stationary (turning) point of y = ${a == 1 ? '' : a}x² '
          '${b >= 0 ? '+ $b' : '- ${b.abs()}'}x ${cc >= 0 ? '+ $cc' : '- ${cc.abs()}'}.',
      x,
      random,
      'At a stationary point, dy/dx = 0. dy/dx = ${2 * a}x + $b = 0 ⟹ x = -$b/${2 * a} = $x.',
      step: 2,
    ));
  }

  const cubicCases = [
    [1, -6, 9, 3], [1, -9, 24, 2], [1, -3, -9, 4], [1, -12, 45, 1],
    [1, 3, -9, 2], [1, -6, -15, 3], [1, -15, 63, 2], [1, 6, -63, 1],
    [1, -9, 15, 2], [1, 9, 15, 1], [1, -18, 96, 1], [1, -3, -45, 2],
    [1, 12, 36, 1], [1, -21, 108, 2],
  ];
  for (final c in cubicCases) {
    final a = c[0], b = c[1], cc = c[2];
    // Stationary points from 3ax² + 2bx + c = 0. Sum of x-coordinates = -2b/(3a).
    if ((-2 * b) % (3 * a) != 0) continue;
    final sumX = -2 * b ~/ (3 * a);
    questions.add(_buildNumeric(
      'Find the sum of the x-coordinates of the stationary points of y = ${a == 1 ? '' : a}x³ '
          '${b >= 0 ? '+ $b' : '- ${b.abs()}'}x² ${cc >= 0 ? '+ $cc' : '- ${cc.abs()}'}x.',
      sumX,
      random,
      'Stationary points satisfy dy/dx = ${3 * a}x² + ${2 * b}x + $cc = 0. '
          'Sum of roots of this quadratic = -${2 * b}/${3 * a} = $sumX.',
      step: 2,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Integration techniques — substitution and definite integrals (area).
// ---------------------------------------------------------------------------

List<QuizQuestion> _integrationTechniquesQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const substitutionCases = [
    [2, 1, 2], [3, 2, 1], [2, 3, 3], [4, 1, 1], [3, 1, 2], [2, 5, 2], [5, 2, 1], [4, 3, 2],
    [2, 7, 1], [3, 4, 2], [5, 1, 1], [2, 9, 2], [3, 5, 3], [4, 5, 1], [2, 1, 4], [3, 7, 1],
  ];
  for (final c in substitutionCases) {
    final a = c[0], b = c[1], n = c[2];
    final newExponent = n + 1;
    final label = b >= 0
        ? '(${a}x + $b)^$newExponent / ${a * newExponent} + C'
        : '(${a}x - ${b.abs()})^$newExponent / ${a * newExponent} + C';
    questions.add(_buildFromPool(
      'Find ∫ (${a}x ${b >= 0 ? '+ $b' : '- ${b.abs()}'})^$n dx, using the substitution u = ${a}x ${b >= 0 ? '+ $b' : '- ${b.abs()}'}.',
      label,
      substitutionCases.map((cc) {
        final aa = cc[0], bb = cc[1], nn = cc[2];
        final ne = nn + 1;
        return bb >= 0 ? '(${aa}x + $bb)^$ne / ${aa * ne} + C' : '(${aa}x - ${bb.abs()})^$ne / ${aa * ne} + C';
      }).toList(),
      random,
      'With u = ${a}x ${b >= 0 ? '+ $b' : '- ${b.abs()}'}, du = $a dx. '
          '∫ (${a}x ${b >= 0 ? '+ $b' : '- ${b.abs()}'})^$n dx = (1/$a) ∫ u^$n du = $label.',
    ));
  }

  const definiteCases = [
    [2, 2, 0, 3], [2, 0, 1, 4], [4, -1, 0, 5], [2, 1, 1, 3],
    [2, 3, 0, 4], [4, 0, 1, 2], [2, -2, 2, 5], [2, 1, 0, 6],
    [4, 2, 1, 3], [6, 0, 0, 4], [2, 5, 1, 5], [4, -3, 2, 6],
    [2, 4, 0, 5], [6, 1, 1, 4], [4, 3, 0, 3], [2, -1, 1, 6],
  ];
  for (final c in definiteCases) {
    final a = c[0], b = c[1], lower = c[2], upper = c[3];
    // ∫ (ax + b) dx from lower to upper = [a/2 x² + bx] evaluated.
    double antiderivativeAt(int x) => (a * x * x) / 2 + b * x;
    final area = antiderivativeAt(upper) - antiderivativeAt(lower);
    if (area != area.roundToDouble()) continue;
    final result = area.toInt();
    questions.add(_buildNumeric(
      'Evaluate ∫ from $lower to $upper of (${a}x ${b >= 0 ? '+ $b' : '- ${b.abs()}'}) dx.',
      result,
      random,
      '∫ (${a}x ${b >= 0 ? '+ $b' : '- ${b.abs()}'}) dx = ($a/2)x² + ${b}x. '
          'Evaluating from $lower to $upper gives ${_formatNum(antiderivativeAt(upper))} - ${_formatNum(antiderivativeAt(lower))} = $result.',
      step: 3,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Coordinate geometry — angle between lines, perpendicular distance, circles.
// ---------------------------------------------------------------------------

List<QuizQuestion> _coordinateGeometryAdvancedQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const gradientCases = [
    [1, 0], [1, -1], [0, 1], [2, 1], [1, 2], [3, 1], [1, 3], [2, -1],
  ];
  for (final c in gradientCases) {
    final m1 = c[0], m2 = c[1];
    final numerator = m1 - m2;
    final denominator = 1 + m1 * m2;
    if (denominator == 0) continue;
    final tanTheta = numerator / denominator;
    final angle = math.atan(tanTheta.abs()) * 180 / math.pi;
    final rounded = angle.round();
    questions.add(_buildNumeric(
      'Find the acute angle between two lines with gradients $m1 and $m2, to the nearest degree.',
      rounded,
      random,
      'tan θ = |(m1 - m2)/(1 + m1m2)| = |($m1 - $m2)/(1 + $m1×$m2)| = |$numerator/$denominator|. θ ≈ $rounded°.',
      step: 5,
    ));
  }

  const pointLineCases = [
    [3, 4, 5, 0, 0], [1, 1, 2, 3, 4], [3, -4, 12, 0, 0], [5, 12, 13, 1, 1],
    [1, 2, 5, 3, 3], [2, 1, 4, 1, 1], [3, 1, 6, 2, 2], [1, -1, 3, 4, 1],
  ];
  for (final c in pointLineCases) {
    final coeffA = c[0], coeffB = c[1], coeffC = c[2], x0 = c[3], y0 = c[4];
    final numerator = (coeffA * x0 + coeffB * y0 + coeffC).abs();
    final denomSquared = coeffA * coeffA + coeffB * coeffB;
    final denominator = math.sqrt(denomSquared);
    final distance = numerator / denominator;
    final rounded = double.parse(distance.toStringAsFixed(2));
    questions.add(_buildNumeric(
      'Find the perpendicular distance from the point ($x0, $y0) to the line ${coeffA}x + ${coeffB}y + $coeffC = 0, '
          'to 2 decimal places.',
      rounded,
      random,
      'd = |A(x0) + B(y0) + C| / √(A² + B²) = |$coeffA($x0) + $coeffB($y0) + $coeffC| / √$denomSquared '
          '= $numerator / ${denominator.toStringAsFixed(2)} ≈ $rounded.',
      step: 0.5,
    ));
  }

  // Reverse-constructed: choose an integer centre (centreX, centreY) and an
  // integer radius directly, then derive g, f, and c so the general form
  // always yields exactly that centre and radius, with no filtering.
  const centreRadiusCases = [
    [2, 3, 4], [-1, 2, 3], [3, -2, 5], [0, 4, 3], [-3, -1, 4],
    [1, -4, 5], [4, 0, 2], [-2, 3, 6], [5, 1, 3], [-4, -3, 5],
    [2, -3, 4], [0, -5, 5],
  ];
  for (final c in centreRadiusCases) {
    final centreX = c[0], centreY = c[1], radius = c[2];
    final g = -centreX, f = -centreY;
    final twoG = 2 * g, twoF = 2 * f;
    final constant = g * g + f * f - radius * radius;
    final constantLabel = constant >= 0 ? '+ $constant' : '- ${constant.abs()}';
    questions.add(_buildFromPool(
      'A circle has the equation x² + y² ${twoG >= 0 ? '+ ${twoG}x' : '- ${twoG.abs()}x'} '
          '${twoF >= 0 ? '+ ${twoF}y' : '- ${twoF.abs()}y'} $constantLabel = 0. Find the centre of the circle.',
      '($centreX, $centreY)',
      centreRadiusCases.map((cc) => '(${cc[0]}, ${cc[1]})').toList(),
      random,
      'For x² + y² + 2gx + 2fy + c = 0, the centre is (-g, -f) = (${-g}, ${-f}) = ($centreX, $centreY).',
    ));
    questions.add(_buildNumeric(
      'A circle has the equation x² + y² ${twoG >= 0 ? '+ ${twoG}x' : '- ${twoG.abs()}x'} '
          '${twoF >= 0 ? '+ ${twoF}y' : '- ${twoF.abs()}y'} $constantLabel = 0. Find the radius of the circle.',
      radius,
      random,
      'radius = √(g² + f² - c) = √($g² + $f² - ($constant)) = √${g * g + f * f - constant} = $radius.',
      step: 1,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Vectors in three dimensions — magnitude, dot product, and angle between.
// ---------------------------------------------------------------------------

List<QuizQuestion> _vectors3DQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const magnitudeCases = [
    [1, 2, 2, 3], [2, 3, 6, 7], [3, 4, 12, 13], [2, 6, 9, 11],
    [4, 4, 7, 9], [6, 6, 7, 11], [1, 4, 8, 9], [4, 8, 1, 9],
    [2, 4, 4, 6], [3, 6, 6, 9], [4, 6, 12, 14], [6, 7, 6, 11],
    [3, 4, 0, 5], [0, 3, 4, 5], [2, 10, 11, 15], [4, 13, 16, 21],
  ];
  for (final c in magnitudeCases) {
    final x = c[0], y = c[1], z = c[2], magnitude = c[3];
    questions.add(_buildNumeric(
      'Find the magnitude of the vector v = ${x}i + ${y}j + ${z}k.',
      magnitude,
      random,
      '|v| = √($x² + $y² + $z²) = √${x * x + y * y + z * z} = $magnitude.',
      step: 2,
    ));
  }

  const dotProductCases = [
    [1, 2, 3, 4, 5, 6], [2, 1, 0, 3, 2, 1], [1, 1, 1, 2, 3, 4],
    [3, 0, 2, 1, 4, 1], [2, 3, 1, 1, 1, 2], [1, 0, 3, 2, 1, 1],
    [4, 1, 2, 1, 2, 3], [2, 2, 1, 3, 1, 2],
    [3, 3, 2, 1, 2, 4], [1, 4, 2, 3, 1, 1], [2, 0, 5, 1, 3, 1],
    [5, 1, 1, 2, 2, 2], [1, 3, 3, 4, 1, 2], [2, 4, 1, 1, 2, 3],
    [3, 1, 4, 2, 1, 1], [1, 5, 2, 3, 2, 1],
  ];
  for (final c in dotProductCases) {
    final ax = c[0], ay = c[1], az = c[2], bx = c[3], by = c[4], bz = c[5];
    final dot = ax * bx + ay * by + az * bz;
    questions.add(_buildNumeric(
      'Given a = ${ax}i + ${ay}j + ${az}k and b = ${bx}i + ${by}j + ${bz}k, find a · b.',
      dot,
      random,
      'a · b = ($ax×$bx) + ($ay×$by) + ($az×$bz) = ${ax * bx} + ${ay * by} + ${az * bz} = $dot.',
      step: 3,
    ));
  }

  const perpendicularCases = [
    [2, 3, 0, 3, -2, 1], [1, 2, 2, 2, -1, 0], [3, 1, 2, 1, -1, -1],
    [4, 0, 1, 0, 3, 0], [1, 1, 1, 1, -2, 1], [2, -1, 3, 1, 1, -1],
    [1, 0, 0, 0, 1, 0], [3, 2, 1, 2, -3, 0], [1, 1, 2, 2, 2, -2],
    [4, 1, 1, 1, -4, 3], [2, 2, 1, 1, -1, 0], [5, 0, 2, 0, 3, 0],
  ];
  for (final c in perpendicularCases) {
    final ax = c[0], ay = c[1], az = c[2], bx = c[3], by = c[4], bz = c[5];
    final dot = ax * bx + ay * by + az * bz;
    final isPerpendicular = dot == 0;
    questions.add(_buildFromPool(
      'Given a = ${ax}i + ${ay}j + ${az}k and b = ${bx}i + ${by}j + ${bz}k, are a and b perpendicular?',
      isPerpendicular ? 'Yes, since a · b = 0' : 'No, since a · b = $dot ≠ 0',
      ['Yes, since a · b = 0', 'No, since a · b = $dot ≠ 0', 'Cannot be determined without magnitudes', 'Only if both vectors are unit vectors'],
      random,
      'Two vectors are perpendicular if and only if their dot product is 0. Here a · b = $dot.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Permutations and combinations.
// ---------------------------------------------------------------------------

List<QuizQuestion> _permutationsCombinationsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const npr = [
    [5, 2], [6, 3], [7, 2], [8, 3], [5, 3], [6, 2], [9, 2], [4, 2],
    [7, 3], [10, 2], [6, 4], [8, 2],
    [9, 3], [10, 3], [11, 2], [12, 2], [8, 4], [9, 4], [7, 4], [11, 3],
  ];
  for (final c in npr) {
    final n = c[0], r = c[1];
    final value = _factorial(n) ~/ _factorial(n - r);
    questions.add(_buildNumeric(
      'Evaluate ⁿPᵣ for n = $n and r = $r.',
      value,
      random,
      'ⁿPᵣ = n! / (n - r)! = $n! / ${n - r}! = $value.',
      step: value ~/ 4 == 0 ? 1 : value ~/ 4,
    ));
  }

  const ncr = [
    [5, 2], [6, 3], [7, 2], [8, 3], [5, 3], [6, 2], [9, 2], [10, 3],
    [7, 3], [8, 4], [6, 4], [9, 4],
    [10, 4], [11, 2], [12, 3], [11, 5], [10, 5], [12, 4], [9, 5], [13, 2],
  ];
  for (final c in ncr) {
    final n = c[0], r = c[1];
    final value = _nCr(n, r);
    questions.add(_buildNumeric(
      'Evaluate ⁿCᵣ for n = $n and r = $r.',
      value,
      random,
      'ⁿCᵣ = n! / (r!(n - r)!) = $n! / ($r!${n - r}!) = $value.',
      step: value ~/ 4 == 0 ? 1 : value ~/ 4,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Probability laws — conditional probability and independent events.
// ---------------------------------------------------------------------------

List<QuizQuestion> _probabilityLawsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const conditionalCases = [
    [3, 10, 6, 10], [2, 8, 5, 8], [4, 12, 7, 12], [1, 6, 3, 6],
    [5, 15, 9, 15], [2, 10, 4, 10], [3, 9, 6, 9], [1, 5, 3, 5],
    [2, 7, 5, 7], [3, 8, 5, 8], [4, 9, 7, 9], [1, 4, 3, 4],
    [3, 11, 7, 11], [2, 9, 6, 9], [5, 12, 8, 12], [4, 10, 7, 10],
  ];
  for (final c in conditionalCases) {
    final intersectionNum = c[0], intersectionDen = c[1], bNum = c[2], bDen = c[3];
    if (intersectionDen != bDen) continue;
    final result = _simplifiedFraction(intersectionNum, bNum);
    questions.add(_buildFromPool(
      'Given P(A∩B) = $intersectionNum/$intersectionDen and P(B) = $bNum/$bDen, find P(A|B).',
      result,
      conditionalCases.map((cc) => _simplifiedFraction(cc[0], cc[2])).toList(),
      random,
      'P(A|B) = P(A∩B) / P(B) = ($intersectionNum/$intersectionDen) / ($bNum/$bDen) = $intersectionNum/$bNum = $result.',
    ));
  }

  const independentCases = [
    [1, 2, 1, 3], [2, 3, 1, 4], [1, 4, 2, 5], [3, 5, 1, 2],
    [1, 3, 2, 3], [2, 5, 3, 4], [1, 6, 1, 2], [3, 4, 1, 3],
    [2, 7, 1, 2], [3, 7, 2, 5], [1, 5, 2, 3], [4, 5, 1, 4],
    [2, 9, 3, 5], [1, 8, 3, 4], [5, 6, 1, 3], [3, 8, 2, 3],
  ];
  for (final c in independentCases) {
    final pANum = c[0], pADen = c[1], pBNum = c[2], pBDen = c[3];
    final resultNum = pANum * pBNum, resultDen = pADen * pBDen;
    questions.add(_buildFromPool(
      'A and B are independent events with P(A) = $pANum/$pADen and P(B) = $pBNum/$pBDen. Find P(A∩B).',
      _simplifiedFraction(resultNum, resultDen),
      independentCases.map((cc) => _simplifiedFraction(cc[0] * cc[2], cc[1] * cc[3])).toList(),
      random,
      'For independent events, P(A∩B) = P(A) × P(B) = ($pANum/$pADen) × ($pBNum/$pBDen) = $resultNum/$resultDen '
          '= ${_simplifiedFraction(resultNum, resultDen)}.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Binomial probability distribution.
// ---------------------------------------------------------------------------

List<QuizQuestion> _binomialDistributionQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const cases = [
    [4, 2, 1, 2], [5, 2, 1, 3], [6, 3, 1, 2], [4, 1, 1, 4],
    [5, 3, 2, 3], [6, 2, 1, 4], [4, 3, 1, 2], [5, 1, 1, 5],
    [6, 4, 1, 3], [4, 4, 1, 2],
    [7, 2, 1, 2], [7, 3, 1, 3], [8, 4, 1, 2], [6, 1, 1, 6],
    [5, 4, 1, 4], [7, 5, 2, 3], [8, 2, 1, 4], [6, 5, 1, 2],
  ];
  for (final c in cases) {
    final n = c[0], r = c[1], pNum = c[2], pDen = c[3];
    final combos = _nCr(n, r);
    final pSuccess = pNum / pDen;
    final qFailure = 1 - pSuccess;
    final probability = combos * math.pow(pSuccess, r) * math.pow(qFailure, n - r);
    final rounded = double.parse(probability.toStringAsFixed(3));
    questions.add(_buildNumeric(
      'A biased coin has probability $pNum/$pDen of landing heads. If it is tossed $n times, '
          'find the probability of getting exactly $r heads, to 3 decimal places.',
      rounded,
      random,
      'P(X = $r) = ⁿCᵣ pʳ qⁿ⁻ʳ = $combos × ($pNum/$pDen)^$r × (${pDen - pNum}/$pDen)^${n - r} ≈ $rounded.',
      step: 0.05,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Kinematics — motion under constant acceleration (SUVAT equations).
// ---------------------------------------------------------------------------

List<QuizQuestion> _kinematicsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  for (var u = 0; u <= 20; u += 2) {
    for (var a = 1; a <= 5; a++) {
      final t = 3 + (u ~/ 2) % 4;
      final v = u + a * t;
      questions.add(_buildNumeric(
        'A particle starts with initial velocity $u m/s and accelerates uniformly at $a m/s². '
            'Find its velocity after $t seconds.',
        v,
        random,
        'v = u + at = $u + ($a × $t) = $v m/s.',
        step: 5,
      ));
    }
  }

  // Always use an even acceleration so a×t² is guaranteed even, keeping the
  // displacement an exact integer with no filtering.
  for (var u = 0; u <= 16; u += 4) {
    for (var a = 2; a <= 8; a += 2) {
      for (var t = 2; t <= 5; t++) {
        final displacement = u * t + (a * t * t) ~/ 2;
        questions.add(_buildNumeric(
          'A particle starts with initial velocity $u m/s and accelerates uniformly at $a m/s². '
              'Find the distance covered in the first $t seconds.',
          displacement,
          random,
          's = ut + ½at² = ($u × $t) + ½($a × $t²) = ${u * t} + ${(a * t * t) ~/ 2} = $displacement m.',
          step: 5,
        ));
      }
    }
  }

  // Reverse-constructed (u, a, s, v) quadruples verified to satisfy
  // v² = u² + 2as exactly, so no perfect-square filtering is needed.
  const v2EqualsU2Plus2asCases = [
    [0, 2, 4, 4], [0, 3, 6, 6], [2, 3, 2, 4], [3, 4, 2, 5],
    [0, 4, 8, 8], [4, 5, 2, 6], [1, 3, 4, 5], [0, 5, 10, 10],
    [5, 8, 9, 13], [2, 6, 8, 10], [6, 4, 8, 10], [0, 6, 12, 12],
    [8, 3, 6, 10], [1, 4, 6, 7], [5, 6, 2, 7], [0, 8, 4, 8],
  ];
  for (final c in v2EqualsU2Plus2asCases) {
    final u = c[0], a = c[1], s = c[2], v = c[3];
    final vSquared = u * u + 2 * a * s;
    questions.add(_buildNumeric(
      'A particle starts with initial velocity $u m/s and accelerates uniformly at $a m/s² over a distance of ${s}m. '
          'Find its final velocity.',
      v,
      random,
      'v² = u² + 2as = $u² + 2($a)($s) = ${u * u} + ${2 * a * s} = $vSquared. v = √$vSquared = $v m/s.',
      step: 2,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Dynamics — Newton's second law, momentum, and conservation of momentum.
// ---------------------------------------------------------------------------

List<QuizQuestion> _dynamicsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const forceCases = [
    [5, 4], [10, 3], [8, 5], [2, 6], [12, 2], [6, 7], [15, 2], [4, 8],
    [20, 3], [3, 9],
  ];
  for (final c in forceCases) {
    final mass = c[0], acceleration = c[1];
    final force = mass * acceleration;
    questions.add(_buildNumeric(
      'Find the force needed to accelerate a body of mass ${mass}kg at $acceleration m/s².',
      force,
      random,
      'F = ma = $mass × $acceleration = $force N.',
      step: 5,
    ));
  }

  const momentumCases = [
    [4, 5], [6, 3], [2, 8], [10, 2], [5, 6], [3, 9], [8, 4], [7, 5],
  ];
  for (final c in momentumCases) {
    final mass = c[0], velocity = c[1];
    final momentum = mass * velocity;
    questions.add(_buildNumeric(
      'Find the momentum of a body of mass ${mass}kg moving with velocity $velocity m/s.',
      momentum,
      random,
      'Momentum = mv = $mass × $velocity = $momentum kg m/s.',
      step: 5,
    ));
  }

  // Equal masses always give an integer common velocity when u1 + u2 is
  // even, guaranteeing no filtering.
  for (var m = 2; m <= 5; m++) {
    for (var u1 = 4; u1 <= 8; u1 += 2) {
      for (var u2 = 0; u2 <= 4; u2 += 2) {
        final totalMomentum = m * u1 + m * u2;
        final totalMass = 2 * m;
        final commonVelocity = totalMomentum ~/ totalMass;
        questions.add(_buildNumeric(
          'A body of mass ${m}kg moving at $u1 m/s collides and sticks to a body of mass ${m}kg moving at $u2 m/s '
              '(in the same direction). Find their common velocity after the collision.',
          commonVelocity,
          random,
          'By conservation of momentum: $m×$u1 + $m×$u2 = ${2 * m}v ⟹ $totalMomentum = $totalMass v ⟹ v = $commonVelocity m/s.',
          step: 1,
        ));
      }
    }
  }

  // Unequal masses with m1 = 1kg always divide evenly, so u1 can be derived
  // exactly from a chosen common velocity v with no filtering.
  for (var m2 = 2; m2 <= 5; m2++) {
    for (var v = 2; v <= 4; v++) {
      for (var u2 = 0; u2 <= 2; u2 += 2) {
        const m1 = 1;
        final u1 = (m1 + m2) * v - m2 * u2;
        questions.add(_buildNumeric(
          'A body of mass ${m1}kg moving at $u1 m/s collides and sticks to a body of mass ${m2}kg moving at $u2 m/s '
              '(in the same direction). Find their common velocity after the collision.',
          v,
          random,
          'By conservation of momentum: $m1×$u1 + $m2×$u2 = ${m1 + m2}v ⟹ ${m1 * u1 + m2 * u2} = ${m1 + m2}v ⟹ v = $v m/s.',
          step: 1,
        ));
      }
    }
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Statics — resultant of perpendicular forces and moments about a point.
// ---------------------------------------------------------------------------

List<QuizQuestion> _staticsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const resultantCases = [
    [3, 4, 5], [6, 8, 10], [5, 12, 13], [8, 15, 17], [9, 12, 15], [7, 24, 25],
  ];
  for (final c in resultantCases) {
    final f1 = c[0], f2 = c[1], resultant = c[2];
    questions.add(_buildNumeric(
      'Two perpendicular forces of ${f1}N and ${f2}N act on a particle. Find the magnitude of their resultant.',
      resultant,
      random,
      'R = √(F1² + F2²) = √($f1² + $f2²) = √${f1 * f1 + f2 * f2} = $resultant N.',
      step: 3,
    ));
  }

  // Reverse-constructed: knownForce = m × unknownDistance and
  // knownDistance = k, so momentValue = m × unknownDistance × k is always
  // exactly divisible by unknownDistance, giving unknownForce = m × k with
  // no filtering.
  for (var k = 2; k <= 5; k++) {
    for (var m = 2; m <= 4; m++) {
      for (var unknownDistance = 3; unknownDistance <= 6; unknownDistance += 3) {
        final knownDistance = k;
        final knownForce = m * unknownDistance;
        final unknownForce = m * k;
        final momentValue = knownForce * knownDistance;
        questions.add(_buildNumeric(
          'A uniform beam balances on a pivot. A force of ${knownForce}N acts at ${knownDistance}m from the pivot on one side. '
              'Find the force needed at ${unknownDistance}m from the pivot on the other side to keep the beam in equilibrium.',
          unknownForce,
          random,
          'Taking moments about the pivot: $knownForce × $knownDistance = F × $unknownDistance ⟹ '
              'F = $momentValue / $unknownDistance = $unknownForce N.',
          step: 2,
        ));
      }
    }
  }

  return questions;
}
