import '../quiz_question.dart';
import 'waec_physics_fields_bank.dart';
import 'waec_physics_mechanics_bank.dart';

/// WAEC Physics question bank, merging Mechanics/Properties of
/// Matter/Thermal Physics with Waves (Optics & Sound)/Electricity &
/// Magnetism/Modern Physics.
List<QuizQuestion> buildWaecPhysicsQuestions() {
  return [
    ...buildWaecPhysicsMechanicsQuestions(),
    ...buildWaecPhysicsFieldsQuestions(),
  ];
}
