class SubjectScore {
  const SubjectScore({required this.subject, required this.correct, required this.total});

  final String subject;
  final int correct;
  final int total;

  Map<String, dynamic> toJson() => {'subject': subject, 'correct': correct, 'total': total};

  factory SubjectScore.fromJson(Map<String, dynamic> json) => SubjectScore(
        subject: json['subject'] as String,
        correct: json['correct'] as int,
        total: json['total'] as int,
      );
}

class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.subjectScores,
    required this.takenAt,
  });

  final String id;
  final String title;
  final int score;
  final int totalQuestions;
  final List<SubjectScore> subjectScores;
  final DateTime takenAt;

  double get percent => totalQuestions == 0 ? 0 : score / totalQuestions;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'score': score,
        'totalQuestions': totalQuestions,
        'subjectScores': subjectScores.map((s) => s.toJson()).toList(),
        'takenAt': takenAt.toIso8601String(),
      };

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        id: json['id'] as String,
        title: json['title'] as String,
        score: json['score'] as int,
        totalQuestions: json['totalQuestions'] as int,
        subjectScores: (json['subjectScores'] as List)
            .map((e) => SubjectScore.fromJson(e as Map<String, dynamic>))
            .toList(),
        takenAt: DateTime.parse(json['takenAt'] as String),
      );
}
