class QuizQuestion {
  const QuizQuestion({
    required this.subject,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  final String subject;
  final String text;
  final List<String> options;
  final int correctIndex;

  /// Why [options][correctIndex] is the right answer. Shown during the
  /// post-test review regardless of whether the student got it right.
  final String? explanation;

  /// Used when embedding a fixed question set in a Duel document, so both
  /// players see the exact same questions.
  Map<String, dynamic> toJson() => {
        'subject': subject,
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        subject: json['subject'] as String,
        text: json['text'] as String,
        options: (json['options'] as List).cast<String>(),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String?,
      );
}

/// Placeholder question bank. There is no real question content/backend
/// yet, so each subject gets a deterministic set of sample questions just
/// to exercise the quiz-taking flow end to end.
List<QuizQuestion> generateSampleQuestions(String subject, {int count = 10}) {
  return List.generate(count, (index) {
    final questionNumber = index + 1;
    return QuizQuestion(
      subject: subject,
      text: 'Sample $subject question $questionNumber of $count.',
      options: [
        'Option A for question $questionNumber',
        'Option B for question $questionNumber',
        'Option C for question $questionNumber',
        'Option D for question $questionNumber',
      ],
      correctIndex: index % 4,
      explanation: 'This is placeholder content — a real $subject question bank has not been built yet.',
    );
  });
}
