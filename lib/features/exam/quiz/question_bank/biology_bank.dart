import '../quiz_question.dart';
import 'biology_continuity_bank.dart';
import 'biology_ecology_bank.dart';
import 'biology_form_function_bank.dart';
import 'biology_living_things_bank.dart';

/// WAEC/NECO Biology question bank, covering all four syllabus sections:
/// Concept of Living Things, Form and Function, Ecology, and Continuity of
/// Life (reproduction, heredity, and evolution).
List<QuizQuestion> buildBiologyQuestions() {
  return [
    ...buildBiologyLivingThingsQuestions(),
    ...buildBiologyFormFunctionQuestions(),
    ...buildBiologyEcologyQuestions(),
    ...buildBiologyContinuityQuestions(),
  ];
}
