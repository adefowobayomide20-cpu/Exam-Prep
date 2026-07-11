import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../data/app_data_store.dart';
import '../../../data/models/quiz_attempt.dart';
import '../../../navigation/main_nav_shell.dart';
import '../../../widgets/count_up_text.dart';
import '../../../widgets/fade_slide_in.dart';
import 'quiz_question.dart';

/// Score at or above this fraction triggers the confetti celebration.
const _celebrationThreshold = 0.7;

class QuizResultPage extends StatefulWidget {
  const QuizResultPage({
    super.key,
    required this.title,
    required this.questions,
    required this.answers,
  });

  final String title;
  final List<QuizQuestion> questions;
  final Map<int, int> answers;

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    final questions = widget.questions;
    final answers = widget.answers;
    final subjects = questions.map((q) => q.subject).toSet().toList();
    AppDataStore.instance.addQuizAttempt(
      QuizAttempt(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: widget.title,
        score: _scoreFor(questions, answers),
        totalQuestions: questions.length,
        subjectScores: subjects.map((subject) {
          final subjectQuestions = questions.where((q) => q.subject == subject).toList();
          final subjectAnswers =
              _answersFor(questions, subjectQuestions, answers);
          return SubjectScore(
            subject: subject,
            correct: _scoreFor(subjectQuestions, subjectAnswers),
            total: subjectQuestions.length,
          );
        }).toList(),
        takenAt: DateTime.now(),
      ),
    );

    if (questions.isNotEmpty &&
        _scoreFor(questions, answers) / questions.length >= _celebrationThreshold) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _confettiController.play());
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final questions = widget.questions;
    final answers = widget.answers;
    final theme = Theme.of(context);
    final score = _scoreFor(questions, answers);
    final percent = questions.isEmpty ? 0.0 : score / questions.length;
    final subjects = questions.map((q) => q.subject).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: Text('$title · Result')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FadeSlideIn(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text('Your Score', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            CountUpText(
                              value: score,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              ' / ${questions.length}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CountUpPercentText(
                              value: percent,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              ' correct',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (subjects.length > 1) ...[
                const SizedBox(height: 20),
                Text('By subject', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...subjects.indexed.map((entry) {
                  final (index, subject) = entry;
                  final subjectQuestions = questions.where((q) => q.subject == subject).toList();
                  final subjectScore =
                      _scoreFor(subjectQuestions, _answersFor(questions, subjectQuestions, answers));
                  return FadeSlideIn(
                    delay: Duration(milliseconds: 60 * index),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(subject),
                        trailing: Text('$subjectScore / ${subjectQuestions.length}'),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              Text('Review Answers', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...List.generate(questions.length, (index) {
                final question = questions[index];
                final selectedIndex = answers[index];
                final isCorrect = selectedIndex == question.correctIndex;
                return FadeSlideIn(
                  delay: Duration(milliseconds: 30 * min(index, 12)),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      leading: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : theme.colorScheme.error,
                      ),
                      title: Text(
                        'Question ${index + 1}',
                        style: theme.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        question.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(question.text, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 12),
                              Text(
                                selectedIndex == null
                                    ? 'Your answer: (not answered)'
                                    : 'Your answer: ${question.options[selectedIndex]}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isCorrect ? Colors.green : theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!isCorrect) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Correct answer: ${question.options[question.correctIndex]}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Text(
                                question.explanation ?? 'No explanation available for this question.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  MainNavShell.goToHomeTab();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Done'),
              ),
            ],
          ),
          IgnorePointer(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              maxBlastForce: 18,
              minBlastForce: 8,
              gravity: 0.25,
              shouldLoop: false,
              colors: [
                theme.colorScheme.secondary,
                theme.colorScheme.primary,
                theme.colorScheme.tertiary,
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _scoreFor(List<QuizQuestion> qs, Map<int, int> answers) {
    var score = 0;
    for (var i = 0; i < qs.length; i++) {
      if (answers[i] == qs[i].correctIndex) score++;
    }
    return score;
  }

  static Map<int, int> _answersFor(
    List<QuizQuestion> all,
    List<QuizQuestion> subset,
    Map<int, int> answers,
  ) {
    final result = <int, int>{};
    for (var i = 0; i < subset.length; i++) {
      final globalIndex = all.indexOf(subset[i]);
      if (answers.containsKey(globalIndex)) {
        result[i] = answers[globalIndex]!;
      }
    }
    return result;
  }
}
