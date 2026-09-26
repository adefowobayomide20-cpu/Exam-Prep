// Standalone script (NOT part of the Flutter app) that exports Post-UTME
// school-specific question content to static JSON files under
// web-next/public/content/questions/post-utme-schools/<school-slug>/<subject-slug>.json
// so the Next.js school-first Post-UTME flow can read real per-school
// content without depending on Dart/Flutter at runtime.
//
// Mirrors the established convention in tool/export_question_banks.dart:
// plain top-level imports (not `deferred`), calls builder functions
// directly, uses `QuizQuestion.toJson()`, slugifies names.
//
// Sources:
//  - lib/features/exam/quiz/question_bank/post_utme_school_subject_banks.dart
//    — UI, OAU, UNIBEN, UNN, FUTA, LAUTECH each have their own dedicated
//    English Language / Mathematics / General Knowledge builders, plus
//    (for UI and OAU) elective subject builders.
//  - lib/features/exam/quiz/question_bank/unilag_post_utme_bank.dart and
//    unilorin_post_utme_bank.dart — these two schools only expose a single
//    combined `build*PostUtmeQuestions()` function that randomly samples
//    10 questions per subject from a pool of (this school's own private
//    question list + the shared common pool) on every call. There is no
//    public per-subject accessor, and this script must not modify lib/ to
//    add one. So this script calls that function many times and unions the
//    (subject, text)-deduplicated results — with enough calls this
//    reconstructs the *entire* underlying pool with overwhelming
//    probability (coupon-collector argument: pool size is on the order of
//    ~130 questions per subject, each call samples 10 without replacement,
//    so the chance any single question is still missing after 500 calls is
//    astronomically small). This is intentionally the *combined* pool
//    (own + shared), matching exactly what a real UNILAG/UNILORIN
//    Post-UTME practice attempt draws from.
//  - lib/features/exam/quiz/question_bank/post_utme_common_bank.dart — the
//    shared 100-question-per-subject pool, exported separately to
//    `_common/<subject>.json` for reuse as fallback content by schools that
//    have no dedicated bank at all.
//
// Run from the Flutter project root: dart run tool/export_post_utme_schools.dart

import 'dart:convert';
import 'dart:io';

import 'package:exam_prep/features/exam/quiz/quiz_question.dart';
import 'package:exam_prep/features/exam/quiz/question_bank/post_utme_common_bank.dart'
    as common;
import 'package:exam_prep/features/exam/quiz/question_bank/post_utme_school_subject_banks.dart'
    as school_banks;
import 'package:exam_prep/features/exam/quiz/question_bank/unilag_post_utme_bank.dart'
    as unilag;
import 'package:exam_prep/features/exam/quiz/question_bank/unilorin_post_utme_bank.dart'
    as unilorin;

String slugify(String input) {
  final lower = input.toLowerCase();
  final hyphenated = lower.replaceAll(RegExp(r"[^a-z0-9]+"), '-');
  return hyphenated.replaceAll(RegExp(r"^-+|-+$"), '');
}

class SubjectFile {
  SubjectFile(this.subject, this.questions);
  final String subject;
  final List<QuizQuestion> questions;
}

/// Reconstructs the full deduplicated question pool a `build*PostUtmeQuestions`
/// function draws from, bucketed by subject, by calling it repeatedly and
/// unioning results keyed on (subject, text).
Map<String, Map<String, QuizQuestion>> reconstructPool(
  List<QuizQuestion> Function() build, {
  int iterations = 500,
}) {
  final bySubject = <String, Map<String, QuizQuestion>>{};
  for (var i = 0; i < iterations; i++) {
    for (final q in build()) {
      final bucket = bySubject.putIfAbsent(q.subject, () => {});
      bucket[q.text] = q;
    }
  }
  return bySubject;
}

void writeSubjectFile(
  String outDir,
  String subject,
  List<QuizQuestion> questions,
) {
  final dir = Directory(outDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final slug = slugify(subject);
  final file = File('${dir.path}/$slug.json');
  final json = {
    'subject': subject,
    'examCategory': 'post-utme',
    'questions': questions.map((q) => q.toJson()).toList(),
  };
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
  stdout.writeln('Wrote ${file.path} (${questions.length} questions)');
}

void main() async {
  const outRoot = 'web-next/public/content/questions/post-utme-schools';
  var totalFiles = 0;
  var totalQuestions = 0;

  void write(String schoolSlug, String subject, List<QuizQuestion> questions) {
    writeSubjectFile('$outRoot/$schoolSlug', subject, questions);
    totalFiles++;
    totalQuestions += questions.length;
  }

  // --- Shared common pool (English Language / Mathematics / General
  // Knowledge) — exported standalone as the fallback source for any school
  // without its own dedicated bank. ---
  write('_common', 'English Language', common.sharedEnglishLanguage);
  write('_common', 'Mathematics', common.sharedMathematics);
  write('_common', 'General Knowledge', common.sharedGeneralKnowledge);

  // --- UNILAG & UNILORIN: reconstruct the full (own + shared) pool per
  // subject via repeated sampling (see reconstructPool doc above). ---
  final unilagPool = reconstructPool(unilag.buildUnilagPostUtmeQuestions);
  for (final entry in unilagPool.entries) {
    write('unilag', entry.key, entry.value.values.toList());
  }

  final unilorinPool = reconstructPool(unilorin.buildUnilorinPostUtmeQuestions);
  for (final entry in unilorinPool.entries) {
    write('unilorin', entry.key, entry.value.values.toList());
  }

  // --- UI, OAU, UNIBEN, UNN, FUTA, LAUTECH: each has its own
  // PostUtmeSchoolSubjectBank (core 3 subjects + optional electives). ---
  final schoolSlugs = {
    'UI': 'ui',
    'OAU': 'oau',
    'UNIBEN': 'uniben',
    'UNN': 'unn',
    'FUTA': 'futa',
    'LAUTECH': 'lautech',
  };

  for (final shortName in schoolSlugs.keys) {
    final bank = school_banks.postUtmeSchoolSubjectBanks[shortName]!;
    final slug = schoolSlugs[shortName]!;
    write(slug, 'English Language', bank.englishLanguage());
    write(slug, 'Mathematics', bank.mathematics());
    write(slug, 'General Knowledge', bank.generalKnowledge());
    for (final electiveEntry in bank.electives.entries) {
      write(slug, electiveEntry.key, electiveEntry.value());
    }
  }

  stdout.writeln('');
  stdout.writeln('Done: $totalFiles files, $totalQuestions total questions.');
}
