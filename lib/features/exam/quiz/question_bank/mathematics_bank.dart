import 'dart:math' as math;

import '../quiz_question.dart';

const _subject = 'Mathematics';

/// All answers in this bank are computed arithmetically by the generator
/// functions themselves (not typed in by hand), so correctness follows from
/// the formulas being correct rather than from manual review of each
/// question. Topics follow the WAEC core Mathematics syllabus across its six
/// thematic areas: Number & Numeration, Algebraic Processes, Geometry &
/// Mensuration, Trigonometry, Statistics/Probability/Vectors, and
/// Introductory Calculus.
List<QuizQuestion> buildMathematicsQuestions() {
  final random = math.Random(11);
  final questions = <QuizQuestion>[];

  // Number and Numeration
  questions.addAll(_numberBaseConversionQuestions(random));
  questions.addAll(_numberBaseArithmeticQuestions(random));
  questions.addAll(_modularArithmeticQuestions(random));
  questions.addAll(_fractionQuestions(random));
  questions.addAll(_approximationQuestions(random));
  questions.addAll(_percentageRatioQuestions(random));
  questions.addAll(_financialArithmeticQuestions(random));
  questions.addAll(_indicesQuestions(random));
  questions.addAll(_logarithmQuestions(random));
  questions.addAll(_surdQuestions(random));
  questions.addAll(_setsQuestions(random));

  // Algebraic Processes
  questions.addAll(_algebraExpansionFactorizationQuestions(random));
  questions.addAll(_changeOfSubjectQuestions(random));
  questions.addAll(_simpleEquationQuestions(random));
  questions.addAll(_simultaneousEquationQuestions(random));
  questions.addAll(_quadraticEquationQuestions(random));
  questions.addAll(_inequalityQuestions(random));
  questions.addAll(_progressionQuestions(random));
  questions.addAll(_variationQuestions(random));
  questions.addAll(_binaryOperationQuestions(random));
  questions.addAll(_matrixQuestions(random));

  // Geometry & Mensuration
  questions.addAll(_planeGeometryAngleQuestions(random));
  questions.addAll(_circleTheoremQuestions(random));
  questions.addAll(_mensurationQuestions(random));
  questions.addAll(_coordinateGeometryQuestions(random));

  // Trigonometry
  questions.addAll(_trigonometryRatioQuestions(random));
  questions.addAll(_elevationDepressionQuestions(random));
  questions.addAll(_bearingQuestions(random));
  questions.addAll(_sineCosineRuleQuestions(random));
  questions.addAll(_longitudeLatitudeQuestions(random));

  // Geometric Constructions and Loci
  questions.addAll(_geometricConstructionQuestions(random));
  questions.addAll(_locusQuestions(random));

  // Statistics, Probability and Vectors
  questions.addAll(_statisticsQuestions(random));
  questions.addAll(_probabilityQuestions(random));
  questions.addAll(_vectorQuestions(random));
  questions.addAll(_transformationQuestions(random));

  // Introductory Calculus
  questions.addAll(_calculusDifferentiationQuestions(random));
  questions.addAll(_calculusIntegrationQuestions(random));

  return questions;
}

// ---------------------------------------------------------------------------
// Shared helpers
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

/// Builds options as numeric "near misses" around the correct value, which
/// reads more naturally for arithmetic answers than unrelated pooled values.
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
  final divisor = _gcd(numerator, denominator);
  final n = numerator ~/ divisor;
  final d = denominator ~/ divisor;
  if (d == 1) return '$n';
  return '$n/$d';
}

/// Finds the largest perfect-square factor of [radicand] so that
/// √radicand = outside × √inside, with `inside` left square-free.
(int, int) _simplifySurd(int radicand) {
  var outside = 1;
  var inside = radicand;
  for (var i = 2; i * i <= inside; i++) {
    while (inside % (i * i) == 0) {
      inside ~/= (i * i);
      outside *= i;
    }
  }
  return (outside, inside);
}

// ---------------------------------------------------------------------------
// Number bases — conversion and arithmetic.
// ---------------------------------------------------------------------------

List<QuizQuestion> _numberBaseConversionQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const bases = [2, 5, 8, 16];
  final allLabels = <String>[];
  final entries = <(int, int, String)>[];

  for (final base in bases) {
    for (var n = 10; n <= 90; n += 10) {
      final label = n.toRadixString(base).toUpperCase();
      entries.add((n, base, label));
      allLabels.add(label);
    }
  }

  for (final entry in entries) {
    final (n, base, label) = entry;
    questions.add(
      _buildFromPool(
        'Convert $n (base 10) to base $base.',
        label,
        allLabels,
        random,
        '$n in base 10 equals $label in base $base.',
      ),
    );
  }
  return questions;
}

List<QuizQuestion> _numberBaseArithmeticQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const pairsBase2 = [
    [5, 6], [7, 9], [10, 13], [3, 12], [11, 14], [6, 9],
    [4, 15], [8, 17], [9, 20], [13, 18], [2, 21], [16, 19],
  ];
  const pairsBase5 = [
    [8, 14], [10, 17], [6, 13], [9, 16], [12, 19], [7, 15],
    [11, 22], [14, 25], [5, 18], [16, 21], [9, 27], [13, 24],
  ];

  for (final pair in pairsBase2) {
    final sum = pair[0] + pair[1];
    final a = pair[0].toRadixString(2);
    final b = pair[1].toRadixString(2);
    final sumBinary = sum.toRadixString(2);
    questions.add(_buildFromPool(
      'Evaluate $a₂ + $b₂, leaving your answer in base 2.',
      sumBinary,
      pairsBase2.map((p) => (p[0] + p[1]).toRadixString(2)).toList(),
      random,
      '$a (base 2) = ${pair[0]} and $b (base 2) = ${pair[1]} in base 10. '
          '${pair[0]} + ${pair[1]} = $sum = $sumBinary in base 2.',
    ));
  }

  for (final pair in pairsBase5) {
    final sum = pair[0] + pair[1];
    final a = pair[0].toRadixString(5);
    final b = pair[1].toRadixString(5);
    final sumBase5 = sum.toRadixString(5);
    questions.add(_buildFromPool(
      'Evaluate $a₅ + $b₅, leaving your answer in base 5.',
      sumBase5,
      pairsBase5.map((p) => (p[0] + p[1]).toRadixString(5)).toList(),
      random,
      '$a (base 5) = ${pair[0]} and $b (base 5) = ${pair[1]} in base 10. '
          '${pair[0]} + ${pair[1]} = $sum = $sumBase5 in base 5.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Modular arithmetic
// ---------------------------------------------------------------------------

List<QuizQuestion> _modularArithmeticQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const residuePairs = [
    [23, 5], [31, 7], [40, 6], [50, 9], [17, 4], [29, 8], [45, 11], [38, 7],
    [52, 9], [61, 8], [47, 6], [58, 10], [34, 5], [66, 13], [42, 8], [55, 12],
  ];
  for (final pair in residuePairs) {
    final a = pair[0], m = pair[1];
    final n = a % m;
    questions.add(_buildNumeric(
      'Find n, given that $a ≡ n (mod $m) and 0 ≤ n < $m.',
      n,
      random,
      '$a ÷ $m leaves a remainder of $n, so $a ≡ $n (mod $m).',
      step: 1,
    ));
  }

  const additionTriples = [
    [15, 22, 7], [18, 25, 6], [29, 14, 8], [33, 19, 9], [27, 16, 5], [41, 23, 10],
    [19, 28, 6], [24, 31, 9], [36, 17, 7], [22, 39, 11], [30, 26, 8], [44, 21, 12],
  ];
  for (final triple in additionTriples) {
    final a = triple[0], b = triple[1], m = triple[2];
    final result = (a + b) % m;
    questions.add(_buildNumeric(
      'Evaluate ($a + $b) mod $m.',
      result,
      random,
      '$a + $b = ${a + b}. ${a + b} mod $m leaves a remainder of $result.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Fractions — addition of two simple fractions, reduced to lowest terms.
// ---------------------------------------------------------------------------

List<QuizQuestion> _fractionQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const denominatorPairs = [
    [2, 3], [2, 5], [3, 4], [3, 5], [4, 5], [2, 7], [5, 6], [3, 8],
    [4, 7], [5, 8], [2, 9], [6, 7], [3, 10], [4, 9], [5, 9], [7, 8],
    [2, 11], [3, 11], [4, 11], [5, 11], [6, 11], [7, 12], [5, 12], [7, 9],
    [8, 9], [3, 7], [5, 7], [2, 13], [3, 13], [4, 13], [6, 13], [7, 13],
  ];
  final pool = <String>[];
  final entries = <(int, int, int, int)>[];

  for (final pair in denominatorPairs) {
    final d1 = pair[0], d2 = pair[1];
    final n1 = 1 + random.nextInt(d1 - 1).clamp(0, d1 - 1);
    final n2 = 1 + random.nextInt(d2 - 1).clamp(0, d2 - 1);
    entries.add((n1, d1, n2, d2));
    final numerator = n1 * d2 + n2 * d1;
    final denominator = d1 * d2;
    pool.add(_simplifiedFraction(numerator, denominator));
  }

  for (final entry in entries) {
    final (n1, d1, n2, d2) = entry;
    final numerator = n1 * d2 + n2 * d1;
    final denominator = d1 * d2;
    final correct = _simplifiedFraction(numerator, denominator);
    questions.add(_buildFromPool(
      'Evaluate $n1/$d1 + $n2/$d2, giving your answer in its lowest terms.',
      correct,
      pool,
      random,
      '$n1/$d1 + $n2/$d2 = ${n1 * d2}/$denominator + ${n2 * d1}/$denominator '
          '= $numerator/$denominator = $correct.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Approximation — rounding to decimal places and significant figures.
// ---------------------------------------------------------------------------

String _roundToSigFigs(double value, int sigFigs) {
  if (value == 0) return '0';
  final magnitude = (math.log(value.abs()) / math.ln10).floor();
  final factor = math.pow(10, sigFigs - 1 - magnitude);
  final rounded = (value * factor).round() / factor;
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
}

List<QuizQuestion> _approximationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const values = [
    3.14159, 27.482, 156.385, 4.567, 89.234, 0.4567, 12.755, 245.649,
    67.891, 8.2345, 0.06789, 512.34, 33.678, 1.2345, 99.876, 0.9876,
  ];

  for (final value in values) {
    final roundedWhole = value.round();
    questions.add(_buildNumeric(
      'Approximate ${value.toStringAsFixed(4)} to the nearest whole number.',
      roundedWhole,
      random,
      '${value.toStringAsFixed(4)} rounds to $roundedWhole to the nearest whole number.',
    ));

    final threeSf = _roundToSigFigs(value, 3);
    questions.add(_buildFromPool(
      'Approximate ${value.toStringAsFixed(4)} to 3 significant figures.',
      threeSf,
      values.map((v) => _roundToSigFigs(v, 3)).toList(),
      random,
      '${value.toStringAsFixed(4)} rounds to $threeSf to 3 significant figures.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Percentages and ratio sharing.
// ---------------------------------------------------------------------------

List<QuizQuestion> _percentageRatioQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const percentages = [10, 15, 20, 25, 40, 50, 60, 75, 30, 45, 80, 90, 5, 35, 65, 70];
  const amounts = [120, 150, 200, 240, 300, 360, 400, 600, 500, 220, 250, 900, 800, 340, 260, 700];

  var count = 0;
  for (var i = 0; i < percentages.length && count < 16; i++) {
    final pct = percentages[i];
    final amount = amounts[i];
    if ((pct * amount) % 100 != 0) continue;
    final result = (pct * amount) ~/ 100;
    questions.add(_buildNumeric(
      'What is $pct% of $amount?',
      result,
      random,
      '$pct% of $amount = ($pct ÷ 100) × $amount = $result.',
    ));
    count++;
  }

  const ratioProblems = [
    [600, 2, 3], [800, 3, 5], [900, 4, 5], [1000, 2, 3],
    [1200, 5, 7], [1500, 2, 3], [1800, 4, 5], [2400, 5, 7],
    [3000, 3, 7], [2100, 2, 5], [2700, 4, 5], [3300, 5, 6],
    [1600, 3, 5], [2000, 3, 7], [2800, 3, 4], [3600, 5, 7],
  ];
  for (final problem in ratioProblems) {
    final total = problem[0], partA = problem[1], partB = problem[2];
    final shareA = total * partA ~/ (partA + partB);
    questions.add(_buildNumeric(
      'Share ₦$total between two people in the ratio $partA:$partB. '
          'How much does the first person receive?',
      shareA,
      random,
      '₦$total shared in ratio $partA:$partB gives the first person '
          '$partA/${partA + partB} × $total = ₦$shareA.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Financial arithmetic — simple/compound interest, profit & loss, VAT.
// ---------------------------------------------------------------------------

List<QuizQuestion> _financialArithmeticQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const simpleInterestCases = [
    [1000, 5, 2], [2000, 4, 3], [1500, 6, 2], [5000, 3, 4], [4000, 5, 3],
    [3000, 4, 5], [6000, 2, 5], [2500, 8, 2], [3500, 4, 4], [4500, 6, 3],
  ];
  for (final c in simpleInterestCases) {
    final p = c[0], r = c[1], t = c[2];
    final interest = p * r * t ~/ 100;
    questions.add(_buildNumeric(
      'Find the simple interest on ₦$p for $t years at $r% per annum.',
      interest,
      random,
      'Simple Interest = (P × R × T) ÷ 100 = ($p × $r × $t) ÷ 100 = ₦$interest.',
      step: 10,
    ));
  }

  const compoundInterestCases = [
    [100, 10, 2], [200, 10, 2], [400, 5, 2], [1000, 10, 2], [2000, 5, 2],
    [500, 10, 2], [800, 5, 2], [1500, 10, 2], [300, 20, 2], [600, 10, 3],
  ];
  for (final c in compoundInterestCases) {
    final p = c[0], r = c[1], t = c[2];
    final amount = (p * math.pow(1 + r / 100, t)).round();
    questions.add(_buildNumeric(
      'Find the compound amount on ₦$p for $t years at $r% per annum compound interest.',
      amount,
      random,
      'A = P(1 + R/100)^T = $p(1 + $r/100)^$t = ₦$amount.',
      step: 10,
    ));
  }

  const profitLossCases = [
    [200, 250], [500, 400], [800, 1000], [1200, 900], [600, 750],
    [400, 500], [1000, 800], [300, 450], [900, 720], [1500, 1800],
  ];
  for (final c in profitLossCases) {
    final cost = c[0], selling = c[1];
    final isProfit = selling > cost;
    final percent = ((selling - cost).abs() * 100 / cost).round();
    questions.add(_buildNumeric(
      'A trader bought an item for ₦$cost and sold it for ₦$selling. '
          'Find the percentage ${isProfit ? 'profit' : 'loss'}.',
      percent,
      random,
      '${isProfit ? 'Profit' : 'Loss'} = ₦${(selling - cost).abs()}. '
          'Percentage ${isProfit ? 'profit' : 'loss'} = (${(selling - cost).abs()} ÷ $cost) × 100 = $percent%.',
      step: 5,
    ));
  }

  const vatCases = [
    [2000, 5], [5000, 5], [10000, 5], [8000, 5], [15000, 5],
    [3000, 5], [6000, 5], [12000, 5], [9000, 5], [20000, 5],
  ];
  for (final c in vatCases) {
    final price = c[0], rate = c[1];
    final vat = price * rate ~/ 100;
    questions.add(_buildNumeric(
      'Find the VAT charged on goods worth ₦$price at $rate% VAT.',
      vat,
      random,
      'VAT = ($rate ÷ 100) × $price = ₦$vat.',
      step: 10,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Indices — laws of indices with a variable base "a".
// ---------------------------------------------------------------------------

extension on QuizQuestion {
  /// Re-labels a purely-numeric exponent answer (e.g. "8") as "a^8" so the
  /// option reads correctly for an indices question.
  QuizQuestion copyWithLabelSuffix(String prefix) {
    final relabelled = options.map((o) => '$prefix$o').toList();
    return QuizQuestion(
      subject: subject,
      text: text,
      options: relabelled,
      correctIndex: correctIndex,
      explanation: explanation,
    );
  }
}

List<QuizQuestion> _indicesQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const exponentPairs = [
    [2, 3], [3, 4], [2, 5], [4, 5], [3, 6], [2, 6], [5, 6], [4, 6],
    [2, 7], [3, 7], [5, 7], [6, 7], [3, 8], [4, 8], [2, 9], [5, 9],
  ];

  for (final pair in exponentPairs) {
    final m = pair[0], n = pair[1];
    questions.add(_buildNumeric(
      'Simplify a^$m × a^$n.',
      m + n,
      random,
      'a^$m × a^$n = a^($m + $n) = a^${m + n}.',
    ).copyWithLabelSuffix('a^'));
  }

  for (final pair in exponentPairs.take(8)) {
    final m = pair[1] + pair[0], n = pair[0];
    questions.add(_buildNumeric(
      'Simplify a^$m ÷ a^$n.',
      m - n,
      random,
      'a^$m ÷ a^$n = a^($m - $n) = a^${m - n}.',
    ).copyWithLabelSuffix('a^'));
  }

  for (final pair in exponentPairs.take(8)) {
    final m = pair[0], n = pair[1] - pair[0] > 0 ? 2 : 2;
    questions.add(_buildNumeric(
      'Simplify (a^$m)^$n.',
      m * n,
      random,
      '(a^$m)^$n = a^($m × $n) = a^${m * n}.',
    ).copyWithLabelSuffix('a^'));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Logarithms — laws of logarithms (symbolic) and log of powers of 10.
// ---------------------------------------------------------------------------

List<QuizQuestion> _logarithmQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  for (var n = 1; n <= 10; n++) {
    final value = n;
    questions.add(_buildNumeric(
      'Evaluate log₁₀(10^$n).',
      value,
      random,
      'log₁₀(10^$n) = $n, since log₁₀ 10 = 1.',
    ));
  }

  const varPairs = [
    ['p', 'q'], ['x', 'y'], ['m', 'n'], ['a', 'b'], ['c', 'd'], ['s', 't'],
  ];
  for (final pair in varPairs) {
    final p = pair[0], q = pair[1];
    questions.add(_buildFromPool(
      'Simplify log $p + log $q.',
      'log ($p$q)',
      varPairs.map((v) => 'log (${v[0]}${v[1]})').toList(),
      random,
      'By the addition law of logarithms, log $p + log $q = log ($p × $q) = log ($p$q).',
    ));
    questions.add(_buildFromPool(
      'Simplify log $p - log $q.',
      'log ($p/$q)',
      varPairs.map((v) => 'log (${v[0]}/${v[1]})').toList(),
      random,
      'By the subtraction law of logarithms, log $p - log $q = log ($p ÷ $q) = log ($p/$q).',
    ));
  }

  for (var n = 2; n <= 8; n++) {
    questions.add(_buildFromPool(
      'Simplify $n log x.',
      'log (x^$n)',
      List.generate(7, (i) => 'log (x^${i + 2})'),
      random,
      'By the power law of logarithms, $n log x = log (x^$n).',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Surds — simplifying √radicand into outside√inside form.
// ---------------------------------------------------------------------------

List<QuizQuestion> _surdQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const radicands = [
    8, 12, 18, 20, 24, 27, 32, 45, 48, 50, 63, 72, 75, 98,
    28, 44, 52, 68, 76, 80, 84, 90, 99, 108, 112, 128, 147, 162,
  ];

  final pool = radicands.map((r) {
    final (outside, inside) = _simplifySurd(r);
    return outside == 1 ? '√$inside' : '$outside√$inside';
  }).toList();

  for (final radicand in radicands) {
    final (outside, inside) = _simplifySurd(radicand);
    final correct = outside == 1 ? '√$inside' : '$outside√$inside';
    questions.add(_buildFromPool(
      'Simplify √$radicand.',
      correct,
      pool,
      random,
      '√$radicand = √(${outside * outside} × $inside) = $outside√$inside.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Sets — union and set-difference sizes.
// ---------------------------------------------------------------------------

List<QuizQuestion> _setsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const setCases = [
    [12, 9, 5], [15, 10, 4], [20, 14, 6], [18, 12, 5],
    [25, 16, 8], [10, 8, 3], [22, 13, 7],
    [30, 20, 10], [17, 14, 6], [28, 19, 9], [24, 15, 7], [19, 11, 4], [26, 17, 8],
  ];

  for (final c in setCases) {
    final a = c[0], b = c[1], intersection = c[2];
    final union = a + b - intersection;
    questions.add(_buildNumeric(
      'In a class, n(A) = $a, n(B) = $b, and n(A∩B) = $intersection. Find n(A∪B).',
      union,
      random,
      'n(A∪B) = n(A) + n(B) - n(A∩B) = $a + $b - $intersection = $union.',
      step: 2,
    ));

    final onlyA = a - intersection;
    questions.add(_buildNumeric(
      'Given n(A) = $a, n(B) = $b, and n(A∩B) = $intersection, find the number of elements in A only.',
      onlyA,
      random,
      'Elements in A only = n(A) - n(A∩B) = $a - $intersection = $onlyA.',
      step: 1,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Algebra — expansion and factorization of (x+a)(x+b).
// ---------------------------------------------------------------------------

List<QuizQuestion> _algebraExpansionFactorizationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const abPairs = [
    [2, 3], [1, 4], [3, 5], [2, -3], [4, -1], [-2, -3], [5, 2], [3, -4],
    [6, 1], [1, -5], [4, 3], [-3, 5], [2, 7], [-4, 6], [7, -2], [5, -6],
  ];

  String expandedForm(int a, int b) {
    final sum = a + b, product = a * b;
    final sumPart = sum == 0 ? '' : (sum > 0 ? ' + ${sum}x' : ' - ${sum.abs()}x');
    final productPart = product == 0 ? '' : (product > 0 ? ' + $product' : ' - ${product.abs()}');
    return 'x²$sumPart$productPart';
  }

  final expandedPool = abPairs.map((p) => expandedForm(p[0], p[1])).toList();
  for (final pair in abPairs) {
    final a = pair[0], b = pair[1];
    final correct = expandedForm(a, b);
    final bLabel = b >= 0 ? '+ $b' : '- ${b.abs()}';
    questions.add(_buildFromPool(
      'Expand (x + $a)(x $bLabel).',
      correct,
      expandedPool,
      random,
      '(x + $a)(x $bLabel) = x² + ($a + $b)x + ($a × $b) = $correct.',
    ));
  }

  for (final pair in abPairs) {
    final a = pair[0], b = pair[1];
    final expression = expandedForm(a, b);
    final bLabel = b >= 0 ? '+ $b' : '- ${b.abs()}';
    final correct = '(x + $a)(x $bLabel)';
    final factoredPool = abPairs.map((p) {
      final bl = p[1] >= 0 ? '+ ${p[1]}' : '- ${p[1].abs()}';
      return '(x + ${p[0]})(x $bl)';
    }).toList();
    questions.add(_buildFromPool(
      'Factorize $expression.',
      correct,
      factoredPool,
      random,
      '$expression factorizes as (x + $a)(x $bLabel), since $a + $b gives the x-coefficient '
          'and $a × $b gives the constant term.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Change of subject of a formula.
// ---------------------------------------------------------------------------

List<QuizQuestion> _changeOfSubjectQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const speedCases = [
    [20, 5, 4], [30, 6, 6], [15, 5, 5], [40, 8, 8], [18, 6, 6], [24, 4, 8],
    [50, 10, 5], [36, 6, 6], [45, 5, 8], [28, 4, 4], [60, 12, 6], [22, 6, 4],
  ];
  for (final c in speedCases) {
    final v = c[0], u = c[1], t = c[2];
    final a = (v - u) ~/ t;
    if ((v - u) % t != 0) continue;
    questions.add(_buildNumeric(
      'Given v = u + at, find a when v = $v, u = $u, and t = $t.',
      a,
      random,
      'a = (v - u) ÷ t = ($v - $u) ÷ $t = $a.',
    ));
  }

  const perimeterCases = [
    [30, 8], [40, 12], [50, 15], [24, 6], [36, 10], [44, 14],
    [28, 9], [32, 7], [48, 16], [56, 18], [60, 20], [26, 8],
  ];
  for (final c in perimeterCases) {
    final p = c[0], l = c[1];
    if (p % 2 != 0) continue;
    final w = p ~/ 2 - l;
    if (w <= 0) continue;
    questions.add(_buildNumeric(
      'Given P = 2(l + w), find w when P = $p and l = $l.',
      w,
      random,
      'w = P/2 - l = $p/2 - $l = ${p ~/ 2} - $l = $w.',
    ));
  }

  const forceCases = [
    [100, 20], [150, 30], [80, 16], [200, 25], [120, 24], [90, 18],
    [140, 28], [160, 32], [180, 20], [220, 22], [240, 30], [110, 11],
  ];
  for (final c in forceCases) {
    final f = c[0], m = c[1];
    if (f % m != 0) continue;
    final acc = f ~/ m;
    questions.add(_buildNumeric(
      'Given F = ma, find a when F = $f and m = $m.',
      acc,
      random,
      'a = F ÷ m = $f ÷ $m = $acc.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Simple linear equations — ax + b = c, solve for x.
// ---------------------------------------------------------------------------

List<QuizQuestion> _simpleEquationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  for (var a = 2; a <= 7; a++) {
    for (var x = -6; x <= 6; x += 2) {
      if (x == 0) continue;
      final b = (a + x).abs() % 11;
      final c = a * x + b;
      questions.add(_buildNumeric(
        'Solve for x: $a x + $b = $c.',
        x,
        random,
        '$a x + $b = $c  ⟹  $a x = ${c - b}  ⟹  x = ${c - b} ÷ $a = $x.',
      ));
    }
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Simultaneous linear equations — solved via elimination.
// ---------------------------------------------------------------------------

List<QuizQuestion> _simultaneousEquationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const coeffs = [
    [1, 1, 2, 1], [1, 1, 1, -1], [2, 1, 1, 1], [1, 2, 1, 1], [3, 1, 1, 2], [1, 3, 2, 1],
    [2, 3, 1, 1], [3, 2, 2, 1], [1, 4, 3, 1], [4, 1, 1, 3], [2, 5, 3, 2], [5, 2, 2, 3],
  ];
  for (final c in coeffs) {
    final a1 = c[0], b1 = c[1], a2 = c[2], b2 = c[3];
    const x = 5, y = 5;
    final c1 = a1 * x + b1 * y;
    final c2 = a2 * x + b2 * y;
    final det = a1 * b2 - a2 * b1;
    if (det == 0) continue;
    questions.add(_buildNumeric(
      'Solve simultaneously and find x:\n'
      '${a1}x + ${b1}y = $c1\n'
      '${a2}x + ${b2}y = $c2',
      x,
      random,
      'Solving the system gives x = $x and y = $y.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Quadratic equations — built from chosen integer roots.
// ---------------------------------------------------------------------------

List<QuizQuestion> _quadraticEquationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const rootPairs = [
    [-3, 2], [-4, 1], [-2, 5], [-6, 3], [-1, 4], [-5, 2], [-3, 6], [-2, 7],
    [-7, 2], [-4, 5], [-8, 1], [-3, 8], [-6, 4], [-1, 6], [-5, 5], [-9, 2],
  ];
  for (final pair in rootPairs) {
    final p = pair[0], q = pair[1];
    final sum = p + q;
    final product = p * q;
    final bTerm = -sum;
    final equation = 'x² ${bTerm >= 0 ? '+' : '-'} ${bTerm.abs()}x '
        '${product >= 0 ? '+' : '-'} ${product.abs()} = 0';

    questions.add(_buildNumeric(
      'Find the sum of the roots of the equation $equation.',
      sum,
      random,
      'The equation factorises as (x - $p)(x - $q) = 0, so the roots are $p and $q, and their sum is $sum.',
    ));
    questions.add(_buildNumeric(
      'Find the product of the roots of the equation $equation.',
      product,
      random,
      'The equation factorises as (x - $p)(x - $q) = 0, so the roots are $p and $q, and their product is $product.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Inequalities — solve a linear inequality for x.
// ---------------------------------------------------------------------------

List<QuizQuestion> _inequalityQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const cases = [
    [3, 2, 11, false], [2, 5, 13, false], [4, 1, 17, false], [-2, 3, -7, true],
    [5, 4, 24, false], [-3, 2, -7, true], [2, -1, 9, false], [-4, 5, -11, true],
    [6, 3, 27, false], [3, -2, 10, false], [-5, 4, -11, true], [4, 3, 19, false],
    [-2, 5, -3, true], [7, 2, 30, false], [-6, 1, -11, true], [2, 7, 15, false],
  ];
  for (final c in cases) {
    final a = c[0] as int, b = c[1] as int, rhs = c[2] as int, flips = c[3] as bool;
    final boundary = (rhs - b) / a;
    final boundaryLabel = _formatNum(boundary);
    final symbol = flips ? '<' : '>';
    final correct = 'x $symbol $boundaryLabel';
    final pool = [
      'x > $boundaryLabel', 'x < $boundaryLabel',
      'x ≥ $boundaryLabel', 'x ≤ $boundaryLabel',
    ];
    final bLabel = b >= 0 ? '+ $b' : '- ${b.abs()}';
    questions.add(_buildFromPool(
      'Solve the inequality: $a x $bLabel > $rhs.',
      correct,
      pool,
      random,
      '$a x $bLabel > $rhs  ⟹  $a x > ${rhs - b}  ⟹  x ${flips ? '<' : '>'} $boundaryLabel'
          '${flips ? ' (the inequality sign flips because we divide by a negative number, $a).' : '.'}',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Progressions — Arithmetic Progression (AP) and Geometric Progression (GP).
// ---------------------------------------------------------------------------

List<QuizQuestion> _progressionQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const apCases = [
    [2, 3, 10], [5, 4, 8], [1, 5, 12], [3, 2, 15], [4, 6, 9], [7, 3, 11],
    [6, 2, 14], [2, 7, 10], [8, 3, 9], [1, 4, 16], [5, 5, 8], [3, 6, 12],
  ];
  for (final c in apCases) {
    final a = c[0], d = c[1], n = c[2];
    final term = a + (n - 1) * d;
    questions.add(_buildNumeric(
      'Find the $n${_ordinalSuffix(n)} term of the Arithmetic Progression $a, ${a + d}, ${a + 2 * d}, ...',
      term,
      random,
      'Tn = a + (n - 1)d = $a + (${n - 1} × $d) = $term.',
      step: 2,
    ));
    final sum = n * (2 * a + (n - 1) * d) ~/ 2;
    questions.add(_buildNumeric(
      'Find the sum of the first $n terms of the Arithmetic Progression $a, ${a + d}, ${a + 2 * d}, ...',
      sum,
      random,
      'Sn = n/2 × (2a + (n-1)d) = $n/2 × (${2 * a} + ${(n - 1) * d}) = $sum.',
      step: 5,
    ));
  }

  const gpCases = [
    [2, 2, 5], [3, 2, 4], [1, 3, 4], [4, 2, 5], [2, 3, 3], [5, 2, 4],
    [1, 2, 6], [3, 3, 3], [2, 4, 3], [1, 5, 3], [6, 2, 4], [4, 3, 3],
  ];
  for (final c in gpCases) {
    final a = c[0], r = c[1], n = c[2];
    final term = a * math.pow(r, n - 1).toInt();
    questions.add(_buildNumeric(
      'Find the $n${_ordinalSuffix(n)} term of the Geometric Progression $a, ${a * r}, ${a * r * r}, ...',
      term,
      random,
      'Tn = a × r^(n-1) = $a × $r^${n - 1} = $term.',
      step: term ~/ 2 == 0 ? 1 : term ~/ 2,
    ));
    final sum = a * (math.pow(r, n).toInt() - 1) ~/ (r - 1);
    questions.add(_buildNumeric(
      'Find the sum of the first $n terms of the Geometric Progression $a, ${a * r}, ${a * r * r}, ...',
      sum,
      random,
      'Sn = a(r^n - 1)/(r - 1) = $a(${math.pow(r, n).toInt()} - 1)/(${r - 1}) = $sum.',
      step: sum ~/ 4 == 0 ? 1 : sum ~/ 4,
    ));
  }
  return questions;
}

String _ordinalSuffix(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return 'th';
  switch (n % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

// ---------------------------------------------------------------------------
// Variation — direct, inverse and joint variation.
// ---------------------------------------------------------------------------

List<QuizQuestion> _variationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const directCases = [
    [3, 12, 5], [4, 20, 6], [2, 14, 8], [5, 25, 7],
    [6, 18, 4], [3, 21, 9], [4, 32, 5], [2, 22, 6],
  ];
  for (final c in directCases) {
    final x1 = c[0], y1 = c[1], x2 = c[2];
    final k = y1 ~/ x1;
    if (y1 % x1 != 0) continue;
    final y2 = k * x2;
    questions.add(_buildNumeric(
      'y varies directly as x. If y = $y1 when x = $x1, find y when x = $x2.',
      y2,
      random,
      'y = kx. k = $y1 ÷ $x1 = $k. When x = $x2, y = $k × $x2 = $y2.',
      step: k,
    ));
  }

  const inverseCases = [
    [2, 24, 4], [3, 30, 5], [4, 40, 8], [5, 60, 10],
    [6, 36, 4], [2, 20, 5], [4, 48, 6], [3, 45, 9],
  ];
  for (final c in inverseCases) {
    final x1 = c[0], y1 = c[1], x2 = c[2];
    final k = x1 * y1;
    if (k % x2 != 0) continue;
    final y2 = k ~/ x2;
    questions.add(_buildNumeric(
      'y varies inversely as x. If y = $y1 when x = $x1, find y when x = $x2.',
      y2,
      random,
      'y = k/x. k = $x1 × $y1 = $k. When x = $x2, y = $k ÷ $x2 = $y2.',
      step: y2 == 0 ? 1 : y2,
    ));
  }

  const jointCases = [
    [2, 3, 24, 4, 2], [1, 4, 20, 3, 5], [3, 2, 36, 4, 3], [2, 5, 50, 3, 4],
    [4, 2, 40, 3, 5], [2, 2, 16, 5, 3], [1, 6, 30, 4, 2], [3, 3, 54, 2, 4],
  ];
  for (final c in jointCases) {
    final x1 = c[0], z1 = c[1], y1 = c[2], x2 = c[3], z2 = c[4];
    final denom = x1 * z1;
    if (y1 % denom != 0) continue;
    final k = y1 ~/ denom;
    final y2 = k * x2 * z2;
    questions.add(_buildNumeric(
      'y varies jointly as x and z. If y = $y1 when x = $x1 and z = $z1, '
          'find y when x = $x2 and z = $z2.',
      y2,
      random,
      'y = kxz. k = $y1 ÷ ($x1 × $z1) = $k. When x = $x2, z = $z2, y = $k × $x2 × $z2 = $y2.',
      step: k,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Binary operations — a defined operation evaluated on number pairs.
// ---------------------------------------------------------------------------

List<QuizQuestion> _binaryOperationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const pairs = [
    [2, 3], [4, 5], [3, 6], [5, 2], [1, 4], [6, 3], [2, 7], [4, 4],
    [3, 5], [5, 6], [2, 4], [6, 2], [1, 5], [4, 3], [3, 7], [5, 5],
  ];

  for (final pair in pairs.take(8)) {
    final a = pair[0], b = pair[1];
    final result = a + b + (a * b);
    questions.add(_buildNumeric(
      'A binary operation * is defined by a * b = a + b + ab. Evaluate $a * $b.',
      result,
      random,
      '$a * $b = $a + $b + ($a × $b) = ${a + b} + ${a * b} = $result.',
      step: 4,
    ));
  }

  for (final pair in pairs.skip(8)) {
    final a = pair[0], b = pair[1];
    final result = a * a + b * b - (a * b);
    questions.add(_buildNumeric(
      'A binary operation * is defined by a * b = a² + b² - ab. Evaluate $a * $b.',
      result,
      random,
      '$a * $b = $a² + $b² - ($a × $b) = ${a * a} + ${b * b} - ${a * b} = $result.',
      step: 5,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Matrices — addition, subtraction, and determinant of 2x2 matrices.
// ---------------------------------------------------------------------------

List<QuizQuestion> _matrixQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const matrixPairs = [
    [1, 2, 3, 4, 5, 6, 7, 8], [2, 0, 1, 3, 4, 1, 2, 5],
    [3, 1, 2, 4, 1, 2, 3, 1], [5, 2, 1, 3, 2, 1, 4, 2],
    [4, 3, 2, 1, 1, 2, 3, 4], [2, 1, 3, 2, 3, 1, 2, 1],
    [1, 1, 2, 3, 2, 2, 1, 1], [3, 2, 4, 1, 1, 3, 2, 2],
  ];

  for (final m in matrixPairs) {
    final a1 = m[0], b1 = m[1], c1 = m[2], d1 = m[3];
    final a2 = m[4], b2 = m[5], c2 = m[6], d2 = m[7];

    final sum = '[${a1 + a2} ${b1 + b2}; ${c1 + c2} ${d1 + d2}]';
    questions.add(_buildFromPool(
      'Given A = [$a1 $b1; $c1 $d1] and B = [$a2 $b2; $c2 $d2], find A + B.',
      sum,
      matrixPairs.map((mm) => '[${mm[0] + mm[4]} ${mm[1] + mm[5]}; ${mm[2] + mm[6]} ${mm[3] + mm[7]}]').toList(),
      random,
      'Add corresponding entries: [$a1+$a2 $b1+$b2; $c1+$c2 $d1+$d2] = $sum.',
    ));

    final diff = '[${a1 - a2} ${b1 - b2}; ${c1 - c2} ${d1 - d2}]';
    questions.add(_buildFromPool(
      'Given A = [$a1 $b1; $c1 $d1] and B = [$a2 $b2; $c2 $d2], find A - B.',
      diff,
      matrixPairs.map((mm) => '[${mm[0] - mm[4]} ${mm[1] - mm[5]}; ${mm[2] - mm[6]} ${mm[3] - mm[7]}]').toList(),
      random,
      'Subtract corresponding entries: [$a1-$a2 $b1-$b2; $c1-$c2 $d1-$d2] = $diff.',
    ));

    final det1 = a1 * d1 - b1 * c1;
    questions.add(_buildNumeric(
      'Find the determinant of the matrix [$a1 $b1; $c1 $d1].',
      det1,
      random,
      'Determinant = ad - bc = ($a1 × $d1) - ($b1 × $c1) = $det1.',
      step: 3,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Plane geometry — polygon angle sums and angles on a line / around a point.
// ---------------------------------------------------------------------------

const _polygonNames = {
  3: 'triangle', 4: 'quadrilateral', 5: 'pentagon', 6: 'hexagon',
  8: 'octagon', 10: 'decagon',
};

List<QuizQuestion> _planeGeometryAngleQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  for (final entry in _polygonNames.entries) {
    final n = entry.key;
    final name = entry.value;
    final sumOfAngles = (n - 2) * 180;
    questions.add(_buildNumeric(
      'Find the sum of interior angles of a $name (a $n-sided polygon).',
      sumOfAngles,
      random,
      'Sum of interior angles = (n - 2) × 180° = (${n - 2}) × 180° = $sumOfAngles°.',
      step: 10,
    ));

    if (sumOfAngles % n == 0) {
      final eachAngle = sumOfAngles ~/ n;
      questions.add(_buildNumeric(
        'Find the size of each interior angle of a regular $name.',
        eachAngle,
        random,
        'Each interior angle = (n - 2) × 180° ÷ n = $sumOfAngles° ÷ $n = $eachAngle°.',
        step: 5,
      ));
    }
  }

  for (var known = 20; known <= 160; known += 10) {
    questions.add(_buildNumeric(
      'Two angles on a straight line are $known° and y°. Find y.',
      180 - known,
      random,
      'Angles on a straight line sum to 180°, so y = 180° - $known° = ${180 - known}°.',
      step: 10,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Circle theorems.
// ---------------------------------------------------------------------------

List<QuizQuestion> _circleTheoremQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  for (var inscribed = 10; inscribed <= 85; inscribed += 5) {
    final central = inscribed * 2;
    questions.add(_buildNumeric(
      'An inscribed angle subtending an arc is $inscribed°. '
          'Find the central angle subtending the same arc.',
      central,
      random,
      'The angle at the centre is twice the angle at the circumference subtending the same arc: '
          '2 × $inscribed° = $central°.',
      step: 10,
    ));
  }

  for (var angleA = 30; angleA <= 165; angleA += 5) {
    final angleC = 180 - angleA;
    questions.add(_buildNumeric(
      'In a cyclic quadrilateral ABCD, angle A = $angleA°. Find angle C, '
          'given that opposite angles of a cyclic quadrilateral are supplementary.',
      angleC,
      random,
      'Opposite angles in a cyclic quadrilateral sum to 180°, so angle C = 180° - $angleA° = $angleC°.',
      step: 10,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Mensuration — perimeter, area, volume, arcs and sectors.
// ---------------------------------------------------------------------------

List<QuizQuestion> _mensurationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const rectangles = [
    [8, 4], [10, 6], [12, 5], [14, 7], [9, 3], [16, 8], [11, 4], [15, 9],
  ];
  for (final r in rectangles) {
    final length = r[0], width = r[1];
    questions.add(_buildNumeric(
      'Find the area of a rectangle with length ${length}cm and width ${width}cm.',
      length * width,
      random,
      'Area = length × width = $length × $width = ${length * width} cm².',
    ));
    questions.add(_buildNumeric(
      'Find the perimeter of a rectangle with length ${length}cm and width ${width}cm.',
      2 * (length + width),
      random,
      'Perimeter = 2(length + width) = 2($length + $width) = ${2 * (length + width)} cm.',
    ));
  }

  const triangles = [
    [10, 6], [12, 8], [14, 5], [16, 9], [18, 4], [20, 7], [11, 6], [13, 8],
  ];
  for (final t in triangles) {
    final base = t[0], height = t[1];
    final area = base * height / 2;
    questions.add(_buildNumeric(
      'Find the area of a triangle with base ${base}cm and height ${height}cm.',
      area,
      random,
      'Area = ½ × base × height = ½ × $base × $height = $area cm².',
    ));
  }

  for (final radius in [7, 14, 21, 28, 35, 42, 49, 56]) {
    final area = (22 * radius * radius) ~/ 7;
    final circumference = (22 * 2 * radius) ~/ 7;
    questions.add(_buildNumeric(
      'Find the area of a circle of radius ${radius}cm. (Take π = 22/7)',
      area,
      random,
      'Area = π r² = 22/7 × $radius × $radius = $area cm².',
    ));
    questions.add(_buildNumeric(
      'Find the circumference of a circle of radius ${radius}cm. (Take π = 22/7)',
      circumference,
      random,
      'Circumference = 2π r = 2 × 22/7 × $radius = $circumference cm.',
    ));
  }

  const sectorCases = [
    [7, 90], [14, 90], [21, 60], [14, 180], [21, 120], [28, 90], [7, 180], [35, 72],
  ];
  for (final s in sectorCases) {
    final radius = s[0], angle = s[1];
    if ((22 * 2 * radius * angle) % (7 * 360) != 0) continue;
    final arcLength = (22 * 2 * radius * angle) ~/ (7 * 360);
    questions.add(_buildNumeric(
      'Find the length of an arc that subtends an angle of $angle° at the centre of a circle '
          'of radius ${radius}cm. (Take π = 22/7)',
      arcLength,
      random,
      'Arc length = (θ/360) × 2πr = ($angle/360) × 2 × 22/7 × $radius = $arcLength cm.',
    ));
  }

  const cuboids = [
    [4, 4, 4], [6, 5, 4], [8, 5, 3], [10, 4, 5], [5, 5, 5], [9, 6, 4], [7, 4, 6], [12, 3, 5],
  ];
  for (final c in cuboids) {
    final length = c[0], width = c[1], height = c[2];
    questions.add(_buildNumeric(
      'Find the volume of a cuboid with length ${length}cm, width ${width}cm and height ${height}cm.',
      length * width * height,
      random,
      'Volume = length × width × height = $length × $width × $height = ${length * width * height} cm³.',
    ));
  }

  const cylinders = [
    [7, 10], [14, 5], [7, 20], [21, 10], [14, 15], [28, 5], [7, 15], [35, 4],
  ];
  for (final cyl in cylinders) {
    final radius = cyl[0], height = cyl[1];
    final volume = (22 * radius * radius * height) ~/ 7;
    questions.add(_buildNumeric(
      'Find the volume of a cylinder with radius ${radius}cm and height ${height}cm. (Take π = 22/7)',
      volume,
      random,
      'Volume = π r² h = 22/7 × $radius × $radius × $height = $volume cm³.',
    ));
  }

  const cones = [
    [7, 12], [14, 6], [21, 8], [7, 24], [14, 9], [21, 4], [7, 6], [14, 12],
  ];
  for (final cone in cones) {
    final radius = cone[0], height = cone[1];
    if ((22 * radius * radius * height) % (7 * 3) != 0) continue;
    final volume = (22 * radius * radius * height) ~/ (7 * 3);
    questions.add(_buildNumeric(
      'Find the volume of a cone with radius ${radius}cm and height ${height}cm. (Take π = 22/7)',
      volume,
      random,
      'Volume = ⅓ π r² h = ⅓ × 22/7 × $radius × $radius × $height = $volume cm³.',
    ));
  }

  const spheres = [7, 14, 21, 28, 35, 42];
  for (final radius in spheres) {
    if ((4 * 22 * radius * radius * radius) % (7 * 3) != 0) continue;
    final volume = (4 * 22 * radius * radius * radius) ~/ (7 * 3);
    questions.add(_buildNumeric(
      'Find the volume of a sphere of radius ${radius}cm. (Take π = 22/7)',
      volume,
      random,
      'Volume = (4/3) π r³ = (4/3) × 22/7 × $radius³ = $volume cm³.',
    ));
  }

  const pyramids = [
    [6, 6, 9], [8, 8, 6], [10, 10, 9], [12, 6, 6], [9, 9, 6], [6, 9, 8],
  ];
  for (final p in pyramids) {
    final length = p[0], width = p[1], height = p[2];
    final volume = length * width * height ~/ 3;
    if (length * width * height % 3 != 0) continue;
    questions.add(_buildNumeric(
      'Find the volume of a rectangular pyramid with base ${length}cm by ${width}cm and height ${height}cm.',
      volume,
      random,
      'Volume = ⅓ × base area × height = ⅓ × ($length × $width) × $height = $volume cm³.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Coordinate geometry — distance, midpoint and gradient.
// ---------------------------------------------------------------------------

const _pythagoreanOffsets = [
  [3, 4, 5], [6, 8, 10], [5, 12, 13], [8, 15, 17],
  [7, 24, 25], [9, 12, 15], [20, 21, 29], [12, 16, 20],
];

List<QuizQuestion> _coordinateGeometryQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  for (final offset in _pythagoreanOffsets) {
    final dx = offset[0], dy = offset[1], distance = offset[2];
    const x1 = 0, y1 = 0;
    final x2 = x1 + dx;
    final y2 = y1 + dy;

    questions.add(_buildNumeric(
      'Find the distance between points ($x1, $y1) and ($x2, $y2).',
      distance,
      random,
      'Distance = √[($x2 - $x1)² + ($y2 - $y1)²] = √[$dx² + $dy²] = √${dx * dx + dy * dy} = $distance.',
    ));

    final midX = (x1 + x2) / 2;
    final midY = (y1 + y2) / 2;
    questions.add(_buildFromPool(
      'Find the midpoint of the line joining ($x1, $y1) and ($x2, $y2).',
      '(${_formatNum(midX)}, ${_formatNum(midY)})',
      [
        '(${_formatNum(midX)}, ${_formatNum(midY)})',
        '(${_formatNum(midX + 1)}, ${_formatNum(midY)})',
        '(${_formatNum(midX)}, ${_formatNum(midY + 1)})',
        '(${_formatNum(x2.toDouble())}, ${_formatNum(y2.toDouble())})',
      ],
      random,
      'Midpoint = ((x1+x2)/2, (y1+y2)/2) = (($x1+$x2)/2, ($y1+$y2)/2) = (${_formatNum(midX)}, ${_formatNum(midY)}).',
    ));

    questions.add(_buildFromPool(
      'Find the gradient of the line joining ($x1, $y1) and ($x2, $y2).',
      _simplifiedFraction(dy, dx),
      ['1', '2', '3', '1/2', '1/3', '2/3', _simplifiedFraction(dy, dx), _simplifiedFraction(dx, dy)],
      random,
      'Gradient = (y2-y1)/(x2-x1) = $dy/$dx = ${_simplifiedFraction(dy, dx)}.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Trigonometry — right-angled triangle ratios from Pythagorean triples.
// ---------------------------------------------------------------------------

List<QuizQuestion> _trigonometryRatioQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const triples = [
    [3, 4, 5], [5, 12, 13], [8, 15, 17], [7, 24, 25],
    [9, 12, 15], [20, 21, 29], [12, 16, 20], [10, 24, 26],
  ];

  for (final triple in triples) {
    final opposite = triple[0], adjacent = triple[1], hypotenuse = triple[2];
    questions.add(_buildFromPool(
      'In a right-angled triangle, the side opposite angle θ is $opposite cm, '
          'the adjacent side is $adjacent cm, and the hypotenuse is $hypotenuse cm. Find sin θ.',
      _simplifiedFraction(opposite, hypotenuse),
      ['1/2', '3/5', '4/5', '5/13', '12/13', '8/17', '15/17', _simplifiedFraction(opposite, hypotenuse)],
      random,
      'sin θ = opposite/hypotenuse = $opposite/$hypotenuse = ${_simplifiedFraction(opposite, hypotenuse)}.',
    ));
    questions.add(_buildFromPool(
      'In a right-angled triangle, the side opposite angle θ is $opposite cm, '
          'the adjacent side is $adjacent cm, and the hypotenuse is $hypotenuse cm. Find cos θ.',
      _simplifiedFraction(adjacent, hypotenuse),
      ['1/2', '3/5', '4/5', '5/13', '12/13', '8/17', '15/17', _simplifiedFraction(adjacent, hypotenuse)],
      random,
      'cos θ = adjacent/hypotenuse = $adjacent/$hypotenuse = ${_simplifiedFraction(adjacent, hypotenuse)}.',
    ));
    questions.add(_buildFromPool(
      'In a right-angled triangle, the side opposite angle θ is $opposite cm, '
          'the adjacent side is $adjacent cm, and the hypotenuse is $hypotenuse cm. Find tan θ.',
      _simplifiedFraction(opposite, adjacent),
      ['1/2', '3/4', '4/3', '5/12', '12/5', '8/15', '15/8', _simplifiedFraction(opposite, adjacent)],
      random,
      'tan θ = opposite/adjacent = $opposite/$adjacent = ${_simplifiedFraction(opposite, adjacent)}.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Angles of elevation and depression.
// ---------------------------------------------------------------------------

List<QuizQuestion> _elevationDepressionQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const cases = [
    [50, 45], [30, 30], [40, 60], [20, 45], [60, 30], [25, 60], [80, 45], [45, 30], [35, 60], [55, 45],
    [70, 45], [15, 60], [90, 30], [65, 45], [100, 30], [18, 60], [42, 45], [75, 30], [28, 60], [95, 45],
  ];
  for (final c in cases) {
    final distance = c[0], angle = c[1];
    final height = distance * math.tan(angle * math.pi / 180);
    final roundedHeight = height.round();
    questions.add(_buildNumeric(
      'A tower is observed from a point ${distance}m from its base. '
          'The angle of elevation to the top of the tower is $angle°. '
          'Find the height of the tower to the nearest metre.',
      roundedHeight,
      random,
      'Height = distance × tan($angle°) = $distance × tan($angle°) ≈ $roundedHeight m.',
      step: 2,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Bearings.
// ---------------------------------------------------------------------------

List<QuizQuestion> _bearingQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const bearings = [
    40, 70, 100, 130, 160, 200, 230, 260, 290, 320,
    20, 50, 80, 110, 140, 170, 190, 220, 250, 340,
  ];
  for (final bearing in bearings) {
    final reciprocal = (bearing + 180) % 360;
    questions.add(_buildNumeric(
      'The bearing of point A from point B is $bearing°. Find the bearing of B from A.',
      reciprocal,
      random,
      'The reciprocal bearing is found by adding 180° (or subtracting if over 360°): '
          '$bearing° + 180° = ${bearing + 180}°'
          '${bearing + 180 >= 360 ? ' = ${bearing + 180 - 360}° (after subtracting 360°).' : '.'}',
      step: 10,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Sine and cosine rules.
// ---------------------------------------------------------------------------

List<QuizQuestion> _sineCosineRuleQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const cosineCases = [
    [6, 8, 60], [10, 12, 60], [8, 10, 90], [5, 9, 120], [7, 7, 60],
    [9, 11, 45], [6, 10, 120], [12, 15, 90], [8, 8, 60], [10, 14, 45],
  ];
  for (final c in cosineCases) {
    final a = c[0], b = c[1], angle = c[2];
    final cosC = math.cos(angle * math.pi / 180);
    final cSquared = a * a + b * b - 2 * a * b * cosC;
    final side = math.sqrt(cSquared);
    final roundedSide = side.round();
    questions.add(_buildNumeric(
      'In triangle ABC, AB = $a cm, AC = $b cm, and angle A = $angle°. '
          'Find BC to the nearest whole number using the cosine rule.',
      roundedSide,
      random,
      'BC² = AB² + AC² - 2(AB)(AC)cos(A) = $a² + $b² - 2($a)($b)cos($angle°) ≈ $roundedSide cm.',
      step: 2,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Statistics — mean, median, range and standard deviation of small datasets.
// ---------------------------------------------------------------------------

List<QuizQuestion> _statisticsQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const datasets = [
    [4, 8, 6, 5, 7, 8, 9], [12, 15, 12, 18, 20, 12, 14], [3, 7, 7, 9, 11, 13, 7],
    [21, 25, 23, 25, 27, 29, 25], [10, 12, 14, 12, 16, 18, 12],
    [6, 9, 11, 9, 13, 15, 9], [17, 20, 18, 20, 22, 24, 20], [2, 5, 5, 7, 9, 11, 5],
    [30, 33, 31, 33, 35, 37, 33], [8, 10, 12, 10, 14, 16, 10],
  ];

  for (final data in datasets) {
    final sorted = List<int>.of(data)..sort();
    final total = data.reduce((a, b) => a + b);
    final mean = total / data.length;
    final median = sorted[sorted.length ~/ 2];
    final range = sorted.last - sorted.first;
    final variance = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / data.length;
    final stdDev = math.sqrt(variance);

    questions.add(_buildNumeric(
      'Find the mean of the data set: ${data.join(', ')}.',
      mean,
      random,
      'Mean = sum of values ÷ number of values = $total ÷ ${data.length} = ${_formatNum(mean)}.',
      step: 0.5,
    ));
    questions.add(_buildNumeric(
      'Find the median of the data set: ${data.join(', ')}.',
      median,
      random,
      'Arranged in order: ${sorted.join(', ')}. The middle value is $median.',
    ));
    questions.add(_buildNumeric(
      'Find the range of the data set: ${data.join(', ')}.',
      range,
      random,
      'Range = highest value - lowest value = ${sorted.last} - ${sorted.first} = $range.',
    ));
    questions.add(_buildNumeric(
      'Find the standard deviation of the data set: ${data.join(', ')}, to 2 decimal places.',
      double.parse(stdDev.toStringAsFixed(2)),
      random,
      'Variance = Σ(x - mean)² ÷ n = ${variance.toStringAsFixed(2)}. '
          'Standard deviation = √variance ≈ ${stdDev.toStringAsFixed(2)}.',
      step: 0.5,
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Probability — single events and the addition law for mutually exclusive events.
// ---------------------------------------------------------------------------

List<QuizQuestion> _probabilityQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const bags = [
    {'red': 3, 'blue': 5, 'green': 2}, {'red': 4, 'blue': 4, 'green': 4},
    {'red': 6, 'blue': 3, 'green': 1}, {'red': 2, 'blue': 6, 'green': 2},
    {'red': 5, 'blue': 2, 'green': 3}, {'red': 1, 'blue': 5, 'green': 4},
    {'red': 7, 'blue': 2, 'green': 1}, {'red': 3, 'blue': 3, 'green': 4},
  ];

  for (final bag in bags) {
    final total = bag.values.reduce((a, b) => a + b);
    for (final color in bag.keys) {
      final count = bag[color]!;
      if (count == 0) continue;
      final bagDescription = bag.entries.map((e) => '${e.value} ${e.key}').join(', ');
      questions.add(_buildFromPool(
        'A bag contains $bagDescription balls. A ball is picked at random. '
            'Find the probability that it is $color.',
        _simplifiedFraction(count, total),
        ['1/2', '1/3', '1/4', '2/3', '3/4', '1/5', '2/5', _simplifiedFraction(count, total)],
        random,
        'P($color) = number of $color balls ÷ total balls = $count/$total = ${_simplifiedFraction(count, total)}.',
      ));
    }
  }

  const additionLawCases = [
    [1, 6, 1, 6], [1, 4, 1, 4], [2, 5, 1, 5], [3, 8, 1, 8], [1, 3, 1, 6], [2, 7, 2, 7],
    [1, 5, 2, 5], [3, 10, 2, 10], [1, 8, 3, 8], [2, 9, 3, 9], [1, 12, 5, 12], [3, 11, 4, 11],
  ];
  for (final c in additionLawCases) {
    final pANum = c[0], pADen = c[1], pBNum = c[2], pBDen = c[3];
    if (pADen != pBDen) continue;
    final den = pADen;
    final sumNum = pANum + pBNum;
    questions.add(_buildFromPool(
      'Events A and B are mutually exclusive, with P(A) = $pANum/$pADen and P(B) = $pBNum/$pBDen. '
          'Find P(A or B).',
      _simplifiedFraction(sumNum, den),
      ['1/2', '1/3', '2/3', '1/4', '3/4', _simplifiedFraction(sumNum, den)],
      random,
      'For mutually exclusive events, P(A or B) = P(A) + P(B) = $pANum/$pADen + $pBNum/$pBDen '
          '= $sumNum/$den = ${_simplifiedFraction(sumNum, den)}.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Vectors — addition, subtraction, scalar multiplication, magnitude.
// ---------------------------------------------------------------------------

List<QuizQuestion> _vectorQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const vectorPairs = [
    [2, 3, 4, 1], [5, 2, 1, 4], [3, 6, 2, 2], [4, 1, 3, 5],
    [6, 2, 1, 3], [2, 5, 4, 2], [7, 1, 2, 4], [3, 4, 5, 2],
  ];

  for (final v in vectorPairs) {
    final ax = v[0], ay = v[1], bx = v[2], by = v[3];
    questions.add(_buildFromPool(
      'Given vector a = ($ax, $ay) and vector b = ($bx, $by), find a + b.',
      '(${ax + bx}, ${ay + by})',
      vectorPairs.map((p) => '(${p[0] + p[2]}, ${p[1] + p[3]})').toList(),
      random,
      'a + b = ($ax + $bx, $ay + $by) = (${ax + bx}, ${ay + by}).',
    ));
    questions.add(_buildFromPool(
      'Given vector a = ($ax, $ay) and vector b = ($bx, $by), find a - b.',
      '(${ax - bx}, ${ay - by})',
      vectorPairs.map((p) => '(${p[0] - p[2]}, ${p[1] - p[3]})').toList(),
      random,
      'a - b = ($ax - $bx, $ay - $by) = (${ax - bx}, ${ay - by}).',
    ));
  }

  const scalarCases = [
    [2, 3, 3], [4, 1, 2], [3, 5, 4], [1, 6, 5],
    [5, 2, 3], [2, 4, 4], [6, 1, 2], [3, 3, 5],
  ];
  for (final s in scalarCases) {
    final x = s[0], y = s[1], k = s[2];
    questions.add(_buildFromPool(
      'Given vector v = ($x, $y), find $k v.',
      '(${k * x}, ${k * y})',
      scalarCases.map((p) => '(${p[2] * p[0]}, ${p[2] * p[1]})').toList(),
      random,
      '$k v = $k × ($x, $y) = (${k * x}, ${k * y}).',
    ));
  }

  for (final triple in _pythagoreanOffsets) {
    final x = triple[0], y = triple[1], magnitude = triple[2];
    questions.add(_buildNumeric(
      'Find the magnitude of the vector ($x, $y).',
      magnitude,
      random,
      '|v| = √($x² + $y²) = √${x * x + y * y} = $magnitude.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Geometric transformations.
// ---------------------------------------------------------------------------

List<QuizQuestion> _transformationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const points = [
    [3, 5], [4, 2], [6, 1], [2, 7], [5, 3], [1, 6], [7, 4], [8, 2],
  ];

  for (final p in points) {
    final x = p[0], y = p[1];
    questions.add(_buildFromPool(
      'Under a reflection in the x-axis, the point ($x, $y) maps to:',
      '($x, ${-y})',
      points.map((pt) => '(${pt[0]}, ${-pt[1]})').toList(),
      random,
      'Reflection in the x-axis maps (x, y) to (x, -y), so ($x, $y) maps to ($x, ${-y}).',
    ));
    questions.add(_buildFromPool(
      'Under a reflection in the y-axis, the point ($x, $y) maps to:',
      '(${-x}, $y)',
      points.map((pt) => '(${-pt[0]}, ${pt[1]})').toList(),
      random,
      'Reflection in the y-axis maps (x, y) to (-x, y), so ($x, $y) maps to (${-x}, $y).',
    ));
    questions.add(_buildFromPool(
      'Under a rotation of 180° about the origin, the point ($x, $y) maps to:',
      '(${-x}, ${-y})',
      points.map((pt) => '(${-pt[0]}, ${-pt[1]})').toList(),
      random,
      'A 180° rotation about the origin maps (x, y) to (-x, -y), so ($x, $y) maps to (${-x}, ${-y}).',
    ));
  }

  const translationCases = [
    [1, 2, 3, 1], [2, 3, 1, 4], [4, 1, 2, 2], [3, 5, 4, 3],
    [5, 2, 1, 3], [2, 4, 3, 2], [1, 6, 2, 4], [6, 3, 1, 2],
  ];
  for (final t in translationCases) {
    final x = t[0], y = t[1], tx = t[2], ty = t[3];
    questions.add(_buildFromPool(
      'Under a translation by vector ($tx, $ty), the point ($x, $y) maps to:',
      '(${x + tx}, ${y + ty})',
      translationCases.map((tc) => '(${tc[0] + tc[2]}, ${tc[1] + tc[3]})').toList(),
      random,
      'Translation by ($tx, $ty) maps (x, y) to (x + $tx, y + $ty), so ($x, $y) maps to (${x + tx}, ${y + ty}).',
    ));
  }

  const enlargementCases = [
    [2, 3, 2], [3, 1, 3], [1, 4, 2], [2, 5, 4],
    [4, 2, 2], [1, 3, 3], [3, 4, 2], [2, 2, 5],
  ];
  for (final e in enlargementCases) {
    final x = e[0], y = e[1], k = e[2];
    questions.add(_buildFromPool(
      'Under an enlargement with scale factor $k about the origin, the point ($x, $y) maps to:',
      '(${k * x}, ${k * y})',
      enlargementCases.map((ec) => '(${ec[2] * ec[0]}, ${ec[2] * ec[1]})').toList(),
      random,
      'An enlargement of scale factor $k about the origin maps (x, y) to ($k x, $k y), '
          'so ($x, $y) maps to (${k * x}, ${k * y}).',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Introductory calculus — differentiation and integration of polynomial terms.
// ---------------------------------------------------------------------------

List<QuizQuestion> _calculusDifferentiationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  for (var a = 1; a <= 10; a++) {
    for (var n = 2; n <= 4; n++) {
      final newCoefficient = a * n;
      final newExponent = n - 1;
      final answerLabel = newExponent == 1 ? '$newCoefficient x' : '$newCoefficient x^$newExponent';
      final pool = List.generate(8, (i) {
        final altN = 2 + (i % 4);
        final altExp = altN - 1;
        final altCoeff = a * altN;
        return altExp == 1 ? '$altCoeff x' : '$altCoeff x^$altExp';
      });
      questions.add(_buildFromPool(
        'Differentiate $a x^$n with respect to x.',
        answerLabel,
        pool,
        random,
        'd/dx ($a x^$n) = $a × $n × x^($n-1) = $newCoefficient x^$newExponent.',
      ));
    }
  }
  return questions;
}

List<QuizQuestion> _calculusIntegrationQuestions(math.Random random) {
  final questions = <QuizQuestion>[];
  const cases = [
    [6, 2], [8, 3], [12, 2], [9, 2], [10, 4], [15, 2], [16, 3], [20, 4],
    [18, 2], [21, 6], [24, 3], [30, 5],
    [14, 6], [27, 8], [36, 5], [28, 6], [45, 8], [40, 3], [32, 7], [42, 5],
  ];
  for (final c in cases) {
    final a = c[0], n = c[1];
    final newExponent = n + 1;
    if (a % newExponent != 0) continue;
    final newCoefficient = a ~/ newExponent;
    final answerLabel = '$newCoefficient x^$newExponent + C';
    questions.add(_buildFromPool(
      'Find ∫ $a x^$n dx.',
      answerLabel,
      cases.where((cc) => cc[0] % (cc[1] + 1) == 0).map((cc) => '${cc[0] ~/ (cc[1] + 1)} x^${cc[1] + 1} + C').toList(),
      random,
      '∫ $a x^$n dx = $a/($n+1) x^($n+1) + C = $newCoefficient x^$newExponent + C.',
    ));
  }
  return questions;
}

// ---------------------------------------------------------------------------
// Longitude and latitude — great-circle (meridian) and small-circle
// (parallel) distances, and the radius of a parallel of latitude.
// Earth's radius is taken as 6400 km and π as 22/7, per WAEC convention.
// ---------------------------------------------------------------------------

const _earthRadiusKm = 6400;

List<QuizQuestion> _longitudeLatitudeQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  // Distance along a meridian (same longitude, different latitudes, signed
  // with N positive and S negative so the difference handles crossing the
  // equator correctly).
  const meridianCases = [
    [40, 10], [50, 20], [30, -10], [60, 30], [45, -15], [70, 40],
    [25, -25], [55, 25], [35, 5], [65, 35], [20, -20], [48, 18],
  ];
  for (final c in meridianCases) {
    final latA = c[0], latB = c[1];
    final deltaDeg = (latA - latB).abs();
    final distance = (deltaDeg * 2 * 22 * _earthRadiusKm) / (7 * 360);
    final rounded = distance.round();
    questions.add(_buildNumeric(
      'Two towns P (lat $latA°${latA >= 0 ? 'N' : 'S'}) and Q (lat ${latB.abs()}°${latB >= 0 ? 'N' : 'S'}) '
          'lie on the same longitude. Find the distance PQ along the meridian, to the nearest km. '
          '(Take the radius of the Earth = $_earthRadiusKm km and π = 22/7.)',
      rounded,
      random,
      'Distance along a meridian = (Δlat/360) × 2πR = ($deltaDeg/360) × 2 × 22/7 × $_earthRadiusKm ≈ $rounded km.',
      step: 100,
    ));
  }

  // Radius of a parallel of latitude: r = R cos(latitude).
  const parallelLatitudes = [10, 20, 30, 40, 45, 50, 60, 0, 15, 25];
  for (final lat in parallelLatitudes) {
    final radius = (_earthRadiusKm * math.cos(lat * math.pi / 180)).round();
    questions.add(_buildNumeric(
      'Find the radius of the parallel of latitude $lat°N, to the nearest km. '
          '(Take the radius of the Earth = $_earthRadiusKm km.)',
      radius,
      random,
      'Radius of parallel = R cos(latitude) = $_earthRadiusKm × cos($lat°) ≈ $radius km.',
      step: 100,
    ));
  }

  // Distance along a parallel of latitude (same latitude, different
  // longitudes).
  const parallelCases = [
    [30, 40, 20], [45, 20, 50], [0, 60, 90], [20, 30, 40],
    [60, 15, 30], [10, 50, 70], [40, 25, 55], [50, 10, 20],
  ];
  for (final c in parallelCases) {
    final lat = c[0], long1 = c[1], long2 = c[2];
    final deltaLong = (long2 - long1).abs();
    final parallelRadius = _earthRadiusKm * math.cos(lat * math.pi / 180);
    final distance = (deltaLong * 2 * math.pi * parallelRadius) / 360;
    final rounded = distance.round();
    questions.add(_buildNumeric(
      'Two towns on latitude $lat°N are located at longitudes $long1°E and $long2°E. '
          'Find the distance between them along the parallel of latitude, to the nearest km. '
          '(Take the radius of the Earth = $_earthRadiusKm km.)',
      rounded,
      random,
      'Radius of parallel = R cos($lat°) ≈ ${parallelRadius.round()} km. '
          'Distance = (Δlong/360) × 2π × ${parallelRadius.round()} ≈ $rounded km.',
      step: 100,
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Geometric constructions — angle bisection arithmetic and constructible
// angles built from combining/bisecting the standard 60°/90° constructions.
// ---------------------------------------------------------------------------

List<QuizQuestion> _geometricConstructionQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  const bisectionAngles = [30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 20, 44];
  for (final angle in bisectionAngles) {
    questions.add(_buildNumeric(
      'An angle of $angle° is constructed and then bisected using a pair of compasses '
          'and a straight edge. Find the size of each resulting half.',
      angle / 2,
      random,
      'Bisecting an angle divides it exactly in half: $angle° ÷ 2 = ${_formatNum(angle / 2)}°.',
      step: 5,
    ));
  }

  // Combining a constructed 60° angle with a bisected angle to build other
  // standard constructible angles.
  const combinationCases = [
    [60, 30, 90], [90, 60, 150], [60, 15, 75], [90, 45, 135],
    [60, 45, 105], [90, 30, 120], [45, 30, 75], [60, 60, 120],
  ];
  for (final c in combinationCases) {
    final first = c[0], second = c[1], sum = c[2];
    questions.add(_buildNumeric(
      'A constructed angle of $first° is placed adjacent to a constructed angle of $second°. '
          'Find the size of the combined angle.',
      sum,
      random,
      'Adjacent angles placed together are added: $first° + $second° = $sum°.',
      step: 15,
    ));
  }

  // Which angle, from a set of four, cannot be constructed using only a
  // straight edge and compasses (i.e. is not built from repeated bisection
  // of 60°/90°, so is not a multiple of 15°).
  const nonConstructibleSets = [
    [75, 105, 150, 40], [120, 135, 165, 50], [90, 45, 105, 70],
    [60, 30, 150, 80], [75, 120, 165, 100], [45, 135, 150, 130],
  ];
  for (final set in nonConstructibleSets) {
    final nonConstructible = set.last;
    questions.add(_buildFromPool(
      'Using only a pair of compasses and a straight edge (via bisection and combination of 60° '
          'and 90°), which of the following angles CANNOT be constructed?',
      '$nonConstructible°',
      set.map((a) => '$a°').toList(),
      random,
      'Angles constructible this way are always multiples of 15°. '
          '$nonConstructible° is not a multiple of 15°, so it cannot be constructed this way, '
          'unlike the other options.',
    ));
  }

  return questions;
}

// ---------------------------------------------------------------------------
// Loci — standard geometric loci and the circle traced by a point at a
// fixed distance from another point.
// ---------------------------------------------------------------------------

List<QuizQuestion> _locusQuestions(math.Random random) {
  final questions = <QuizQuestion>[];

  final conceptualLoci = [
    (
      'What is the locus of points equidistant from two fixed points A and B?',
      'The perpendicular bisector of the line segment AB',
      ['A circle with AB as diameter', 'The line AB extended', 'A circle centred at A'],
    ),
    (
      'What is the locus of points equidistant from two intersecting straight lines?',
      'The pair of lines bisecting the angles between them',
      ['A circle touching both lines', 'The perpendicular bisector of the lines', 'A single line parallel to both'],
    ),
    (
      'What is the locus of a point that moves so that it is always a fixed distance r from a fixed point O?',
      'A circle of radius r, centred at O',
      ['A straight line through O', 'Two parallel lines at distance r from O', 'A square centred at O'],
    ),
    (
      'What is the locus of points equidistant from two fixed parallel lines?',
      'A straight line midway between and parallel to the two lines',
      ['A circle between the two lines', 'The perpendicular bisector of a line joining the two lines', 'One of the two original lines'],
    ),
    (
      'What is the locus of a point that moves so that it is always a fixed perpendicular distance d from a given straight line?',
      'Two straight lines, one on each side of the given line, parallel to it at distance d',
      ['A single circle of radius d', 'A single straight line through the given line', 'A parabola with the line as its axis'],
    ),
    (
      'What is the locus of the centres of all circles that pass through two fixed points A and B?',
      'The perpendicular bisector of AB',
      ['The line segment AB itself', 'A circle passing through A and B', 'Any line parallel to AB'],
    ),
    (
      'What is the locus of points inside a triangle that are equidistant from all three sides?',
      'The incentre, found where the three angle bisectors of the triangle meet',
      ['The centroid, found where the medians meet', 'The circumcentre, found where the perpendicular bisectors meet', 'The orthocentre, found where the altitudes meet'],
    ),
    (
      'What is the locus of points equidistant from the three vertices of a triangle?',
      'The circumcentre, found where the perpendicular bisectors of the sides meet',
      ['The incentre, found where the angle bisectors meet', 'The centroid, found where the medians meet', 'The midpoint of the longest side'],
    ),
  ];

  for (final (question, correct, distractors) in conceptualLoci) {
    final options = [correct, ...distractors]..shuffle(random);
    questions.add(QuizQuestion(
      subject: _subject,
      text: question,
      options: options,
      correctIndex: options.indexOf(correct),
      explanation: '$correct is the standard locus for this condition.',
    ));
  }

  const radii = [3, 4, 5, 6, 7, 8, 9, 10, 12, 15];
  for (final r in radii) {
    questions.add(_buildFromPool(
      'A point P moves in a plane such that its distance from a fixed point O is always ${r}cm. '
          'Describe the locus of P.',
      'A circle of radius ${r}cm, centred at O',
      radii.map((rr) => 'A circle of radius ${rr}cm, centred at O').toList(),
      random,
      'Since OP = ${r}cm is constant, P traces a circle of radius ${r}cm centred at O.',
    ));
  }

  return questions;
}
