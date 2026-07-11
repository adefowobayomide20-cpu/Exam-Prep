import 'package:cloud_functions/cloud_functions.dart';

import '../features/exam/quiz/quiz_question.dart';

/// Calls the `explainLikeImFive` Cloud Function backing the "Explain like
/// I'm 5" button on missed questions — a street-smart, Pidgin-flavoured
/// take on [QuizQuestion.explanation].
class Eli5Service {
  Eli5Service._();

  static final Eli5Service instance = Eli5Service._();

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  Future<String> explain({
    required QuizQuestion question,
    int? userAnswerIndex,
  }) async {
    final result = await _functions.httpsCallable('explainLikeImFive').call<Map<String, dynamic>>({
      'subject': question.subject,
      'questionText': question.text,
      'options': question.options,
      'correctIndex': question.correctIndex,
      'userAnswerIndex': userAnswerIndex,
    });
    return result.data['text'] as String? ?? "Couldn't get an explanation right now.";
  }
}
