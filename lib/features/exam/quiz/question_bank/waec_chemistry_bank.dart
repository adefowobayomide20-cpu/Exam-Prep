import '../quiz_question.dart';
import 'waec_chemistry_advanced_bank.dart';
import 'waec_chemistry_intro_bank.dart';

/// WAEC Chemistry question bank, merging the intro/foundational topics
/// (measurement, atomic structure, separation techniques, periodic
/// chemistry, bonding, stoichiometry, states of matter) with the advanced
/// topics (energy changes, acids/bases/salts, solubility/kinetics,
/// electrochemistry, organic chemistry, quantitative/qualitative analysis).
List<QuizQuestion> buildWaecChemistryQuestions() {
  return [
    ...buildWaecChemistryIntroQuestions(),
    ...buildWaecChemistryAdvancedQuestions(),
  ];
}
