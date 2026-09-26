// Standalone script (NOT part of the Flutter app) that exports every
// hardcoded question bank in lib/features/exam/quiz/question_bank/ to static
// JSON files under web-next/public/content/questions/<examCategory>/<subject>.json
// so the Next.js rewrite of examcoah.com.ng can read question content without
// depending on Dart/Flutter at runtime. Lives under public/, not src/,
// because Firebase's Next.js Hosting integration only reliably bundles
// public/ into the deployed Cloud Function at runtime — see the CONTENT_ROOT
// comment in web-next/src/lib/exam-content.ts for the full story.
//
// This mirrors the (subject, examCategory) -> builder function switch table
// in lib/features/exam/quiz/question_bank/question_bank_registry.dart
// exactly. If that registry changes, update this script to match and re-run:
//   dart run tool/export_question_banks.dart
//
// Unlike the registry, imports here are plain top-level imports rather than
// `deferred` ones — deferred loading is a Flutter-web bundle-splitting
// optimization that doesn't apply to a one-off CLI script.

import 'dart:convert';
import 'dart:io';

import 'package:exam_prep/features/exam/quiz/quiz_question.dart';

import 'package:exam_prep/features/exam/quiz/question_bank/biology_bank.dart'
    as biology_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/further_mathematics_bank.dart'
    as further_mathematics_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_accounts_bank.dart'
    as jamb_accounts_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_agricultural_science_bank.dart'
    as jamb_agricultural_science_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_arabic_bank.dart'
    as jamb_arabic_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_biology_bank.dart'
    as jamb_biology_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_chemistry_bank.dart'
    as jamb_chemistry_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_commerce_bank.dart'
    as jamb_commerce_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_computer_studies_bank.dart'
    as jamb_computer_studies_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_crs_bank.dart'
    as jamb_crs_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_economics_bank.dart'
    as jamb_economics_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_fine_art_bank.dart'
    as jamb_fine_art_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_french_bank.dart'
    as jamb_french_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_geography_bank.dart'
    as jamb_geography_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_government_bank.dart'
    as jamb_government_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_hausa_bank.dart'
    as jamb_hausa_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_history_bank.dart'
    as jamb_history_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_igbo_bank.dart'
    as jamb_igbo_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_islamic_studies_bank.dart'
    as jamb_islamic_studies_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_literature_bank.dart'
    as jamb_literature_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_music_bank.dart'
    as jamb_music_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_phe_bank.dart'
    as jamb_phe_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_physics_bank.dart'
    as jamb_physics_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_use_of_english_bank.dart'
    as jamb_use_of_english_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/jamb_yoruba_bank.dart'
    as jamb_yoruba_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/mathematics_bank.dart'
    as mathematics_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_agricultural_science_bank.dart'
    as waec_agricultural_science_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_arabic_bank.dart'
    as waec_arabic_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_auto_mechanics_bank.dart'
    as waec_auto_mechanics_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_basic_electricity_bank.dart'
    as waec_basic_electricity_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_basic_electronics_bank.dart'
    as waec_basic_electronics_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_building_construction_bank.dart'
    as waec_building_construction_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_chemistry_bank.dart'
    as waec_chemistry_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_civic_education_bank.dart'
    as waec_civic_education_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_clothing_and_textiles_bank.dart'
    as waec_clothing_and_textiles_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_commerce_bank.dart'
    as waec_commerce_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_crs_bank.dart'
    as waec_crs_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_economics_bank.dart'
    as waec_economics_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_english_language_bank.dart'
    as waec_english_language_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_financial_accounting_bank.dart'
    as waec_financial_accounting_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_foods_and_nutrition_bank.dart'
    as waec_foods_and_nutrition_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_french_bank.dart'
    as waec_french_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_geography_bank.dart'
    as waec_geography_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_government_bank.dart'
    as waec_government_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_hausa_bank.dart'
    as waec_hausa_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_health_education_bank.dart'
    as waec_health_education_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_history_bank.dart'
    as waec_history_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_home_management_bank.dart'
    as waec_home_management_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_igbo_bank.dart'
    as waec_igbo_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_islamic_studies_bank.dart'
    as waec_islamic_studies_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_literature_bank.dart'
    as waec_literature_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_metalwork_bank.dart'
    as waec_metalwork_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_music_bank.dart'
    as waec_music_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_physical_education_bank.dart'
    as waec_physical_education_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_physics_bank.dart'
    as waec_physics_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_technical_drawing_bank.dart'
    as waec_technical_drawing_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_visual_arts_bank.dart'
    as waec_visual_arts_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_woodwork_bank.dart'
    as waec_woodwork_bank_lib;
import 'package:exam_prep/features/exam/quiz/question_bank/waec_yoruba_bank.dart'
    as waec_yoruba_bank_lib;

/// Mirrors `ExamCategory` from lib/features/exam/exam_types.dart, expressed
/// as plain strings so this script has zero dependency on Flutter itself
/// (exam_types.dart imports package:flutter/material.dart, which a bare
/// `dart run` cannot resolve without the Flutter SDK's package config; the
/// question bank files themselves have no such dependency).
const waec = 'waec';
const neco = 'neco';
const jamb = 'jamb';
const postJamb = 'post-jamb';

class Entry {
  Entry(this.subject, this.examCategory, this.questions);
  final String subject;
  final String examCategory;
  final List<QuizQuestion> questions;
}

String slugify(String input) {
  final lower = input.toLowerCase();
  final hyphenated = lower.replaceAll(RegExp(r"[^a-z0-9]+"), '-');
  return hyphenated.replaceAll(RegExp(r"^-+|-+$"), '');
}

void main() async {
  final entries = <Entry>[];

  // --- WAEC-only ---
  entries.add(
    Entry(
      'English Language',
      waec,
      waec_english_language_bank_lib.buildWaecEnglishLanguageQuestions(),
    ),
  );

  // --- WAEC + NECO share the same bank ---
  void addWaecNeco(String subject, List<QuizQuestion> Function() build) {
    final qs = build();
    entries.add(Entry(subject, waec, qs));
    entries.add(Entry(subject, neco, qs));
  }

  addWaecNeco('Chemistry', waec_chemistry_bank_lib.buildWaecChemistryQuestions);
  addWaecNeco('Physics', waec_physics_bank_lib.buildWaecPhysicsQuestions);
  addWaecNeco(
    'Agricultural Science',
    waec_agricultural_science_bank_lib.buildWaecAgriculturalScienceQuestions,
  );
  addWaecNeco(
    'Civic Education',
    waec_civic_education_bank_lib.buildWaecCivicEducationQuestions,
  );
  addWaecNeco('French', waec_french_bank_lib.buildWaecFrenchQuestions);
  addWaecNeco('Arabic', waec_arabic_bank_lib.buildWaecArabicQuestions);
  addWaecNeco('Commerce', waec_commerce_bank_lib.buildWaecCommerceQuestions);
  addWaecNeco(
    'Financial Accounting',
    waec_financial_accounting_bank_lib.buildWaecFinancialAccountingQuestions,
  );
  addWaecNeco('Economics', waec_economics_bank_lib.buildWaecEconomicsQuestions);
  addWaecNeco(
    'Government',
    waec_government_bank_lib.buildWaecGovernmentQuestions,
  );
  addWaecNeco('History', waec_history_bank_lib.buildWaecHistoryQuestions);
  addWaecNeco('Geography', waec_geography_bank_lib.buildWaecGeographyQuestions);
  addWaecNeco(
    'Literature in English',
    waec_literature_bank_lib.buildWaecLiteratureQuestions,
  );
  addWaecNeco(
    'Christian Religious Studies',
    waec_crs_bank_lib.buildWaecCrsQuestions,
  );
  addWaecNeco(
    'Islamic Studies',
    waec_islamic_studies_bank_lib.buildWaecIslamicStudiesQuestions,
  );
  addWaecNeco('Hausa', waec_hausa_bank_lib.buildWaecHausaQuestions);
  addWaecNeco('Igbo', waec_igbo_bank_lib.buildWaecIgboQuestions);
  addWaecNeco('Yoruba', waec_yoruba_bank_lib.buildWaecYorubaQuestions);
  addWaecNeco('Music', waec_music_bank_lib.buildWaecMusicQuestions);
  addWaecNeco(
    'Visual Arts',
    waec_visual_arts_bank_lib.buildWaecVisualArtsQuestions,
  );
  addWaecNeco(
    'Technical Drawing',
    waec_technical_drawing_bank_lib.buildWaecTechnicalDrawingQuestions,
  );
  addWaecNeco(
    'Auto Mechanics',
    waec_auto_mechanics_bank_lib.buildWaecAutoMechanicsQuestions,
  );
  addWaecNeco(
    'Building Construction',
    waec_building_construction_bank_lib.buildWaecBuildingConstructionQuestions,
  );
  addWaecNeco(
    'Metal Work',
    waec_metalwork_bank_lib.buildWaecMetalworkQuestions,
  );
  addWaecNeco('Woodwork', waec_woodwork_bank_lib.buildWaecWoodworkQuestions);
  addWaecNeco(
    'Basic Electricity',
    waec_basic_electricity_bank_lib.buildWaecBasicElectricityQuestions,
  );
  addWaecNeco(
    'Basic Electronics',
    waec_basic_electronics_bank_lib.buildWaecBasicElectronicsQuestions,
  );
  addWaecNeco(
    'Foods and Nutrition',
    waec_foods_and_nutrition_bank_lib.buildWaecFoodsAndNutritionQuestions,
  );
  addWaecNeco(
    'Home Management',
    waec_home_management_bank_lib.buildWaecHomeManagementQuestions,
  );
  addWaecNeco(
    'Clothing and Textiles',
    waec_clothing_and_textiles_bank_lib.buildWaecClothingAndTextilesQuestions,
  );
  addWaecNeco(
    'Health Education',
    waec_health_education_bank_lib.buildWaecHealthEducationQuestions,
  );
  addWaecNeco(
    'Physical Education',
    waec_physical_education_bank_lib.buildWaecPhysicalEducationQuestions,
  );

  // --- JAMB-only ---
  void addJamb(String subject, List<QuizQuestion> Function() build) {
    entries.add(Entry(subject, jamb, build()));
  }

  addJamb(
    'Use of English',
    jamb_use_of_english_bank_lib.buildJambUseOfEnglishQuestions,
  );
  addJamb('Chemistry', jamb_chemistry_bank_lib.buildJambChemistryQuestions);
  addJamb('Physics', jamb_physics_bank_lib.buildJambPhysicsQuestions);
  addJamb(
    'Agricultural Science',
    jamb_agricultural_science_bank_lib.buildJambAgriculturalScienceQuestions,
  );
  addJamb('Economics', jamb_economics_bank_lib.buildJambEconomicsQuestions);
  addJamb('Commerce', jamb_commerce_bank_lib.buildJambCommerceQuestions);
  addJamb(
    'Principles of Accounts',
    jamb_accounts_bank_lib.buildJambAccountsQuestions,
  );
  addJamb('Government', jamb_government_bank_lib.buildJambGovernmentQuestions);
  addJamb(
    'Literature in English',
    jamb_literature_bank_lib.buildJambLiteratureQuestions,
  );
  addJamb(
    'Christian Religious Studies',
    jamb_crs_bank_lib.buildJambCrsQuestions,
  );
  addJamb(
    'Islamic Studies',
    jamb_islamic_studies_bank_lib.buildJambIslamicStudiesQuestions,
  );
  addJamb('History', jamb_history_bank_lib.buildJambHistoryQuestions);
  addJamb('Geography', jamb_geography_bank_lib.buildJambGeographyQuestions);
  addJamb('French', jamb_french_bank_lib.buildJambFrenchQuestions);
  addJamb('Hausa', jamb_hausa_bank_lib.buildJambHausaQuestions);
  addJamb('Arabic', jamb_arabic_bank_lib.buildJambArabicQuestions);
  addJamb('Igbo', jamb_igbo_bank_lib.buildJambIgboQuestions);
  addJamb('Yoruba', jamb_yoruba_bank_lib.buildJambYorubaQuestions);
  addJamb('Music', jamb_music_bank_lib.buildJambMusicQuestions);
  addJamb('Fine Art', jamb_fine_art_bank_lib.buildJambFineArtQuestions);
  addJamb(
    'Computer Studies',
    jamb_computer_studies_bank_lib.buildJambComputerStudiesQuestions,
  );
  addJamb(
    'Physical and Health Education',
    jamb_phe_bank_lib.buildJambPheQuestions,
  );
  addJamb('Biology', jamb_biology_bank_lib.buildJambBiologyQuestions);

  // --- Category-agnostic: Mathematics & Further Mathematics apply to all
  // four exam categories (registry matches them against `_`). ---
  final mathQuestions = mathematics_bank_lib.buildMathematicsQuestions();
  final furtherMathQuestions = further_mathematics_bank_lib
      .buildFurtherMathematicsQuestions();
  for (final category in [waec, neco, jamb, postJamb]) {
    entries.add(Entry('Mathematics', category, mathQuestions));
    entries.add(Entry('Further Mathematics', category, furtherMathQuestions));
  }

  // --- Biology: JAMB has its own dedicated bank (added above); every other
  // category (waec, neco, post-jamb) shares the generic biology bank,
  // matching the `('Biology', _)` fallback case in the registry. ---
  final biologyQuestions = biology_bank_lib.buildBiologyQuestions();
  for (final category in [waec, neco, postJamb]) {
    entries.add(Entry('Biology', category, biologyQuestions));
  }

  // --- Write output ---
  final outRoot = Directory('web-next/public/content/questions');
  if (!outRoot.existsSync()) {
    outRoot.createSync(recursive: true);
  }

  var totalQuestions = 0;
  for (final entry in entries) {
    final dir = Directory('${outRoot.path}/${entry.examCategory}');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final slug = slugify(entry.subject);
    final file = File('${dir.path}/$slug.json');
    final json = {
      'subject': entry.subject,
      'examCategory': entry.examCategory,
      'questions': entry.questions.map((q) => q.toJson()).toList(),
    };
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
    totalQuestions += entry.questions.length;
    stdout.writeln('Wrote ${file.path} (${entry.questions.length} questions)');
  }

  stdout.writeln('');
  stdout.writeln(
    'Done: ${entries.length} files, $totalQuestions total questions.',
  );
}
