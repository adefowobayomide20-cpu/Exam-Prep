import 'futa_post_utme_bank.dart';
import 'lautech_post_utme_bank.dart';
import 'oau_accounts_bank.dart';
import 'oau_agricultural_science_bank.dart';
import 'oau_arabic_bank.dart';
import 'oau_biology_bank.dart';
import 'oau_chemistry_bank.dart';
import 'oau_commerce_bank.dart';
import 'oau_crs_bank.dart';
import 'oau_economics_bank.dart';
import 'oau_french_bank.dart';
import 'oau_geography_bank.dart';
import 'oau_government_bank.dart';
import 'oau_hausa_bank.dart';
import 'oau_history_bank.dart';
import 'oau_igbo_bank.dart';
import 'oau_islamic_studies_bank.dart';
import 'oau_literature_bank.dart';
import 'oau_physics_bank.dart';
import 'oau_post_utme_bank.dart';
import 'oau_yoruba_bank.dart';
import '../quiz_question.dart' show QuizQuestion;
import 'ui_accounts_bank.dart';
import 'ui_agricultural_science_bank.dart';
import 'ui_arabic_bank.dart';
import 'ui_biology_bank.dart';
import 'ui_chemistry_bank.dart';
import 'ui_commerce_bank.dart';
import 'ui_crs_bank.dart';
import 'ui_economics_bank.dart';
import 'ui_french_bank.dart';
import 'ui_geography_bank.dart';
import 'ui_government_bank.dart';
import 'ui_hausa_bank.dart';
import 'ui_history_bank.dart';
import 'ui_igbo_bank.dart';
import 'ui_islamic_studies_bank.dart';
import 'ui_literature_bank.dart';
import 'ui_physics_bank.dart';
import 'ui_post_utme_bank.dart';
import 'uniben_post_utme_bank.dart';
import 'unn_post_utme_bank.dart';

/// A school's own curated question pools for the three subjects its
/// Post-UTME practice bank covers. Used by the Post-UTME subject picker so
/// that English Language, Mathematics, and General Knowledge stay
/// school-flavoured even though the student is choosing subjects one at a
/// time rather than sitting the full mixed bank.
class PostUtmeSchoolSubjectBank {
  const PostUtmeSchoolSubjectBank({
    required this.englishLanguage,
    required this.mathematics,
    required this.generalKnowledge,
    this.electives = const {},
  });

  final List<QuizQuestion> Function() englishLanguage;
  final List<QuizQuestion> Function() mathematics;
  final List<QuizQuestion> Function() generalKnowledge;

  /// Extra elective subjects this school curates its own questions for,
  /// keyed by the exact subject string from `subjects.dart`, beyond the
  /// three core subjects above. Any elective not present here falls back
  /// to the shared JAMB bank — see `PostUtmeSubjectPickerPage._questionsFor`.
  final Map<String, List<QuizQuestion> Function()> electives;
}

/// Schools whose Post-UTME test uses the JAMB-style subject picker (English
/// Language compulsory, then 3 more subjects). UNILAG and UNILORIN are
/// intentionally excluded — they keep their original single fixed test.
final Map<String, PostUtmeSchoolSubjectBank> postUtmeSchoolSubjectBanks = {
  'UI': PostUtmeSchoolSubjectBank(
    englishLanguage: buildUiEnglishLanguageQuestions,
    mathematics: buildUiMathematicsQuestions,
    generalKnowledge: buildUiGeneralKnowledgeQuestions,
    electives: {
      'Biology': buildUiBiologyQuestions,
      'Chemistry': buildUiChemistryQuestions,
      'Physics': buildUiPhysicsQuestions,
      'Agricultural Science': buildUiAgriculturalScienceQuestions,
      'Economics': buildUiEconomicsQuestions,
      'Commerce': buildUiCommerceQuestions,
      'Principles of Accounts': buildUiAccountsQuestions,
      'Government': buildUiGovernmentQuestions,
      'Literature in English': buildUiLiteratureQuestions,
      'Christian Religious Studies': buildUiCrsQuestions,
      'Islamic Studies': buildUiIslamicStudiesQuestions,
      'Geography': buildUiGeographyQuestions,
      'History': buildUiHistoryQuestions,
      'French': buildUiFrenchQuestions,
      'Arabic': buildUiArabicQuestions,
      'Hausa': buildUiHausaQuestions,
      'Igbo': buildUiIgboQuestions,
      // Yoruba, Music, Fine Art, Computer Studies, and Physical and Health
      // Education don't have a UI-specific bank yet — they fall back to the
      // shared JAMB bank via PostUtmeSubjectPickerPage._questionsFor.
    },
  ),
  'OAU': PostUtmeSchoolSubjectBank(
    englishLanguage: buildOauEnglishLanguageQuestions,
    mathematics: buildOauMathematicsQuestions,
    generalKnowledge: buildOauGeneralKnowledgeQuestions,
    electives: {
      'Biology': buildOauBiologyQuestions,
      'Chemistry': buildOauChemistryQuestions,
      'Physics': buildOauPhysicsQuestions,
      'Agricultural Science': buildOauAgriculturalScienceQuestions,
      'Economics': buildOauEconomicsQuestions,
      'Commerce': buildOauCommerceQuestions,
      'Principles of Accounts': buildOauAccountsQuestions,
      'Government': buildOauGovernmentQuestions,
      'Literature in English': buildOauLiteratureQuestions,
      'Christian Religious Studies': buildOauCrsQuestions,
      'Islamic Studies': buildOauIslamicStudiesQuestions,
      'Geography': buildOauGeographyQuestions,
      'History': buildOauHistoryQuestions,
      'French': buildOauFrenchQuestions,
      'Arabic': buildOauArabicQuestions,
      'Hausa': buildOauHausaQuestions,
      'Igbo': buildOauIgboQuestions,
      'Yoruba': buildOauYorubaQuestions,
      // Music, Fine Art, Computer Studies, and Physical and Health
      // Education don't have an OAU-specific bank yet — they fall back to
      // the shared JAMB bank via PostUtmeSubjectPickerPage._questionsFor.
    },
  ),
  'UNIBEN': PostUtmeSchoolSubjectBank(
    englishLanguage: buildUnibenEnglishLanguageQuestions,
    mathematics: buildUnibenMathematicsQuestions,
    generalKnowledge: buildUnibenGeneralKnowledgeQuestions,
  ),
  'UNN': PostUtmeSchoolSubjectBank(
    englishLanguage: buildUnnEnglishLanguageQuestions,
    mathematics: buildUnnMathematicsQuestions,
    generalKnowledge: buildUnnGeneralKnowledgeQuestions,
  ),
  'FUTA': PostUtmeSchoolSubjectBank(
    englishLanguage: buildFutaEnglishLanguageQuestions,
    mathematics: buildFutaMathematicsQuestions,
    generalKnowledge: buildFutaGeneralKnowledgeQuestions,
  ),
  'LAUTECH': PostUtmeSchoolSubjectBank(
    englishLanguage: buildLautechEnglishLanguageQuestions,
    mathematics: buildLautechMathematicsQuestions,
    generalKnowledge: buildLautechGeneralKnowledgeQuestions,
  ),
};
