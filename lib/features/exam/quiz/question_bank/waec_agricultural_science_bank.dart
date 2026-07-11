import '../quiz_question.dart';
import 'waec_agric_land_bank.dart';
import 'waec_agric_production_bank.dart';

/// WAEC Agricultural Science question bank, merging Basic Agriculture &
/// Ecology/Soil Science & Land Management/Agricultural Engineering &
/// Mechanization with Crop Production & Management/Animal Production &
/// Health/Agricultural Economics, Agribusiness & Extension.
List<QuizQuestion> buildWaecAgriculturalScienceQuestions() {
  return [
    ...buildWaecAgricLandQuestions(),
    ...buildWaecAgricProductionQuestions(),
  ];
}
