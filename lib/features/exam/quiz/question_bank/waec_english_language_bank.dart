import '../quiz_question.dart';
import 'waec_english_comprehension_bank.dart';
import 'waec_english_lexis_bank.dart';
import 'waec_english_oral_bank.dart';
import 'waec_english_structure_bank.dart';

/// WAEC's English Language question bank, covering all three papers:
/// Lexis and Structure (Paper 1), Reading Comprehension (Paper 2, Section B),
/// and Oral English (Paper 3). Essay Writing and Summary Writing are
/// free-response tasks and are handled separately through Theory mode
/// rather than as objective questions here.
List<QuizQuestion> buildWaecEnglishLanguageQuestions() {
  return [
    ...buildWaecEnglishLexisQuestions(),
    ...buildWaecEnglishStructureQuestions(),
    ...buildWaecEnglishOralQuestions(),
    ...buildWaecEnglishComprehensionQuestions(),
  ];
}
