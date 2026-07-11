import 'dart:math';

import '../../exam_types.dart';
import '../quiz_question.dart';
import 'biology_bank.dart';
import 'further_mathematics_bank.dart';
import 'jamb_accounts_bank.dart';
import 'jamb_agricultural_science_bank.dart';
import 'jamb_arabic_bank.dart';
import 'jamb_biology_bank.dart';
import 'jamb_chemistry_bank.dart';
import 'jamb_commerce_bank.dart';
import 'jamb_computer_studies_bank.dart';
import 'jamb_crs_bank.dart';
import 'jamb_economics_bank.dart';
import 'jamb_fine_art_bank.dart';
import 'jamb_french_bank.dart';
import 'jamb_geography_bank.dart';
import 'jamb_government_bank.dart';
import 'jamb_hausa_bank.dart';
import 'jamb_history_bank.dart';
import 'jamb_igbo_bank.dart';
import 'jamb_islamic_studies_bank.dart';
import 'jamb_literature_bank.dart';
import 'jamb_music_bank.dart';
import 'jamb_phe_bank.dart';
import 'jamb_physics_bank.dart';
import 'jamb_use_of_english_bank.dart';
import 'jamb_yoruba_bank.dart';
import 'mathematics_bank.dart';
import 'waec_agricultural_science_bank.dart';
import 'waec_arabic_bank.dart';
import 'waec_auto_mechanics_bank.dart';
import 'waec_basic_electricity_bank.dart';
import 'waec_basic_electronics_bank.dart';
import 'waec_building_construction_bank.dart';
import 'waec_chemistry_bank.dart';
import 'waec_civic_education_bank.dart';
import 'waec_clothing_and_textiles_bank.dart';
import 'waec_commerce_bank.dart';
import 'waec_crs_bank.dart';
import 'waec_economics_bank.dart';
import 'waec_english_language_bank.dart';
import 'waec_financial_accounting_bank.dart';
import 'waec_foods_and_nutrition_bank.dart';
import 'waec_french_bank.dart';
import 'waec_geography_bank.dart';
import 'waec_government_bank.dart';
import 'waec_hausa_bank.dart';
import 'waec_health_education_bank.dart';
import 'waec_history_bank.dart';
import 'waec_home_management_bank.dart';
import 'waec_igbo_bank.dart';
import 'waec_islamic_studies_bank.dart';
import 'waec_literature_bank.dart';
import 'waec_metalwork_bank.dart';
import 'waec_music_bank.dart';
import 'waec_physical_education_bank.dart';
import 'waec_physics_bank.dart';
import 'waec_technical_drawing_bank.dart';
import 'waec_visual_arts_bank.dart';
import 'waec_woodwork_bank.dart';
import 'waec_yoruba_bank.dart';

/// Returns a random sample of [sampleSize] questions for [subject].
///
/// WAEC, NECO, and JAMB do not share one English syllabus — WAEC tests
/// Lexis/Structure/Oral English, NECO's objective paper embeds a
/// Literature section that WAEC and JAMB don't have, and JAMB's Use of
/// English is comprehension-heavy with its own Oral Forms section. So
/// "English Language"/"Use of English" resolve to a different bank per
/// [examCategory] rather than one shared pool.
///
/// NECO shares WAEC's curated bank for every subject except English
/// Language, where the syllabuses genuinely diverge (see above) — that one
/// still falls back to placeholder questions for NECO until a dedicated
/// bank is built. JAMB subjects without their own case also fall back to
/// placeholders.
List<QuizQuestion> questionsForSubject(
  String subject, {
  int sampleSize = 40,
  ExamCategory? examCategory,
}) {
  final bank = switch ((subject, examCategory)) {
    ('English Language', ExamCategory.waec) => buildWaecEnglishLanguageQuestions(),
    ('Chemistry', ExamCategory.waec || ExamCategory.neco) => buildWaecChemistryQuestions(),
    ('Physics', ExamCategory.waec || ExamCategory.neco) => buildWaecPhysicsQuestions(),
    ('Agricultural Science', ExamCategory.waec || ExamCategory.neco) => buildWaecAgriculturalScienceQuestions(),
    ('Civic Education', ExamCategory.waec || ExamCategory.neco) => buildWaecCivicEducationQuestions(),
    ('French', ExamCategory.waec || ExamCategory.neco) => buildWaecFrenchQuestions(),
    ('Arabic', ExamCategory.waec || ExamCategory.neco) => buildWaecArabicQuestions(),
    ('Commerce', ExamCategory.waec || ExamCategory.neco) => buildWaecCommerceQuestions(),
    ('Financial Accounting', ExamCategory.waec || ExamCategory.neco) => buildWaecFinancialAccountingQuestions(),
    ('Economics', ExamCategory.waec || ExamCategory.neco) => buildWaecEconomicsQuestions(),
    ('Government', ExamCategory.waec || ExamCategory.neco) => buildWaecGovernmentQuestions(),
    ('History', ExamCategory.waec || ExamCategory.neco) => buildWaecHistoryQuestions(),
    ('Geography', ExamCategory.waec || ExamCategory.neco) => buildWaecGeographyQuestions(),
    ('Literature in English', ExamCategory.waec || ExamCategory.neco) => buildWaecLiteratureQuestions(),
    ('Christian Religious Studies', ExamCategory.waec || ExamCategory.neco) => buildWaecCrsQuestions(),
    ('Islamic Studies', ExamCategory.waec || ExamCategory.neco) => buildWaecIslamicStudiesQuestions(),
    ('Hausa', ExamCategory.waec || ExamCategory.neco) => buildWaecHausaQuestions(),
    ('Igbo', ExamCategory.waec || ExamCategory.neco) => buildWaecIgboQuestions(),
    ('Yoruba', ExamCategory.waec || ExamCategory.neco) => buildWaecYorubaQuestions(),
    ('Music', ExamCategory.waec || ExamCategory.neco) => buildWaecMusicQuestions(),
    ('Visual Arts', ExamCategory.waec || ExamCategory.neco) => buildWaecVisualArtsQuestions(),
    ('Technical Drawing', ExamCategory.waec || ExamCategory.neco) => buildWaecTechnicalDrawingQuestions(),
    ('Auto Mechanics', ExamCategory.waec || ExamCategory.neco) => buildWaecAutoMechanicsQuestions(),
    ('Building Construction', ExamCategory.waec || ExamCategory.neco) => buildWaecBuildingConstructionQuestions(),
    ('Metal Work', ExamCategory.waec || ExamCategory.neco) => buildWaecMetalworkQuestions(),
    ('Woodwork', ExamCategory.waec || ExamCategory.neco) => buildWaecWoodworkQuestions(),
    ('Basic Electricity', ExamCategory.waec || ExamCategory.neco) => buildWaecBasicElectricityQuestions(),
    ('Basic Electronics', ExamCategory.waec || ExamCategory.neco) => buildWaecBasicElectronicsQuestions(),
    ('Foods and Nutrition', ExamCategory.waec || ExamCategory.neco) => buildWaecFoodsAndNutritionQuestions(),
    ('Home Management', ExamCategory.waec || ExamCategory.neco) => buildWaecHomeManagementQuestions(),
    ('Clothing and Textiles', ExamCategory.waec || ExamCategory.neco) => buildWaecClothingAndTextilesQuestions(),
    ('Health Education', ExamCategory.waec || ExamCategory.neco) => buildWaecHealthEducationQuestions(),
    ('Physical Education', ExamCategory.waec || ExamCategory.neco) => buildWaecPhysicalEducationQuestions(),
    ('Use of English', ExamCategory.jamb) => buildJambUseOfEnglishQuestions(),
    ('Chemistry', ExamCategory.jamb) => buildJambChemistryQuestions(),
    ('Physics', ExamCategory.jamb) => buildJambPhysicsQuestions(),
    ('Agricultural Science', ExamCategory.jamb) => buildJambAgriculturalScienceQuestions(),
    ('Economics', ExamCategory.jamb) => buildJambEconomicsQuestions(),
    ('Commerce', ExamCategory.jamb) => buildJambCommerceQuestions(),
    ('Principles of Accounts', ExamCategory.jamb) => buildJambAccountsQuestions(),
    ('Government', ExamCategory.jamb) => buildJambGovernmentQuestions(),
    ('Literature in English', ExamCategory.jamb) => buildJambLiteratureQuestions(),
    ('Christian Religious Studies', ExamCategory.jamb) => buildJambCrsQuestions(),
    ('Islamic Studies', ExamCategory.jamb) => buildJambIslamicStudiesQuestions(),
    ('History', ExamCategory.jamb) => buildJambHistoryQuestions(),
    ('Geography', ExamCategory.jamb) => buildJambGeographyQuestions(),
    ('French', ExamCategory.jamb) => buildJambFrenchQuestions(),
    ('Hausa', ExamCategory.jamb) => buildJambHausaQuestions(),
    ('Arabic', ExamCategory.jamb) => buildJambArabicQuestions(),
    ('Igbo', ExamCategory.jamb) => buildJambIgboQuestions(),
    ('Yoruba', ExamCategory.jamb) => buildJambYorubaQuestions(),
    ('Music', ExamCategory.jamb) => buildJambMusicQuestions(),
    ('Fine Art', ExamCategory.jamb) => buildJambFineArtQuestions(),
    ('Computer Studies', ExamCategory.jamb) => buildJambComputerStudiesQuestions(),
    ('Physical and Health Education', ExamCategory.jamb) => buildJambPheQuestions(),
    ('Mathematics', _) => buildMathematicsQuestions(),
    ('Further Mathematics', _) => buildFurtherMathematicsQuestions(),
    ('Biology', ExamCategory.jamb) => buildJambBiologyQuestions(),
    ('Biology', _) => buildBiologyQuestions(),
    (_, _) => null,
  };

  if (bank == null) {
    return generateSampleQuestions(subject, count: 10);
  }

  final shuffled = List.of(bank)..shuffle(Random());
  return shuffled.take(sampleSize).toList();
}
