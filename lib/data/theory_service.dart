import 'package:cloud_functions/cloud_functions.dart';

import '../features/exam/theory/theory_questions.dart';

/// Result of grading a WAEC theory answer.
class TheoryGradeResult {
  const TheoryGradeResult({required this.correct, required this.feedback});

  final bool correct;
  final String feedback;
}

/// Calls the `generateTheoryQuestion` / `gradeTheoryAnswer` Cloud Functions
/// backing WAEC Theory mode. Grading is always done by Gemini, since it has
/// to work out the correct answer and compare it against whatever the
/// student submits — but the question itself now comes from a hand-authored
/// bank (`theory_questions.dart`) when one exists for the subject, falling
/// back to generating a fresh question on demand for subjects without a
/// ready-made bank yet.
class TheoryService {
  TheoryService._();

  static final TheoryService instance = TheoryService._();

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  Future<String> generateQuestion(String subject) async {
    final readyMade = readyMadeTheoryQuestion(subject);
    if (readyMade != null) return readyMade.question;

    final result = await _functions.httpsCallable('generateTheoryQuestion').call<Map<String, dynamic>>({
      'subject': subject,
    });
    return result.data['question'] as String? ?? '';
  }

  Future<TheoryGradeResult> gradeAnswer({
    required String subject,
    required String question,
    String? answerText,
    String? answerImageBase64,
    String? mimeType,
  }) async {
    final result = await _functions.httpsCallable('gradeTheoryAnswer').call<Map<String, dynamic>>({
      'subject': subject,
      'question': question,
      'answerText': answerText,
      'answerImageBase64': answerImageBase64,
      'mimeType': mimeType,
    });
    return TheoryGradeResult(
      correct: result.data['correct'] as bool? ?? false,
      feedback: result.data['feedback'] as String? ?? "Sorry, I couldn't grade that.",
    );
  }
}
