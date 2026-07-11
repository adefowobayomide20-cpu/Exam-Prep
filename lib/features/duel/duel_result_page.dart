import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../data/app_data_store.dart';
import '../../data/auth_service.dart';
import '../../data/duel_service.dart';
import '../../data/eli5_service.dart';
import '../../data/models/duel.dart';
import '../../navigation/main_nav_shell.dart';
import '../../widgets/slide_up_route.dart';
import '../exam/quiz/question_bank/question_bank_registry.dart';
import '../exam/quiz/quiz_question.dart';
import '../services/whatsapp_contact.dart';
import 'duel_session_page.dart';

const _duelQuestionCount = 10;
const _duelDuration = Duration(minutes: 5);

class DuelResultPage extends StatefulWidget {
  const DuelResultPage({super.key, required this.duelId, this.selfAnswers = const {}});

  final String duelId;

  /// This player's local answer choices, keyed by question index — used to
  /// find missed questions for the ELI5 explanation button. Not persisted
  /// to the Duel document, so it's only available when navigating straight
  /// from [DuelSessionPage].
  final Map<int, int> selfAnswers;

  @override
  State<DuelResultPage> createState() => _DuelResultPageState();
}

class _DuelResultPageState extends State<DuelResultPage> {
  bool _recorded = false;
  bool _rematching = false;
  bool _addedBuddy = false;

  void _recordHistoryIfNeeded(Duel duel) {
    if (_recorded || duel.status != DuelStatus.finished) return;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final self = duel.selfOf(user.uid);
    final opponent = duel.opponentOf(user.uid);
    if (self == null || opponent == null) return;
    _recorded = true;
    AppDataStore.instance.recordDuelResult(
      duelId: duel.id,
      subject: duel.subject,
      won: self.points > opponent.points,
      selfScore: self.correct,
      opponentScore: opponent.correct,
    );
  }

  Future<void> _rematch(Duel duel, String opponentUid, String opponentName) async {
    if (_rematching) return;
    setState(() => _rematching = true);
    final user = AuthService.instance.currentUser;
    try {
      if (user == null) return;
      final questions = questionsForSubject(duel.subject, sampleSize: _duelQuestionCount);
      final rematch = await DuelService.instance.createDirect(
        subject: duel.subject,
        questions: questions,
        duration: _duelDuration,
        hostUid: user.uid,
        hostName: AppDataStore.instance.profile.name,
        guestUid: opponentUid,
        guestName: opponentName,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          SlideUpRoute(builder: (_) => DuelSessionPage(duelId: rematch.id)),
        );
      }
    } on DuelException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _rematching = false);
    }
  }

  Future<void> _addStudyBuddy(String uid, String name) async {
    await AppDataStore.instance.addStudyBuddy(uid: uid, name: name);
    if (mounted) {
      setState(() => _addedBuddy = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added as a study buddy!')),
      );
    }
  }

  void _shareResult(Duel duel, bool won, String opponentName) {
    final school = AppDataStore.instance.profile.school;
    final schoolTag = school != null ? ' $school' : '';
    final message = won
        ? "I just defeated $opponentName in a$schoolTag ${duel.subject} duel on Exam Coach! "
            'Who wants to challenge me next?'
        : "Just had a tight ${duel.subject} duel against $opponentName on Exam Coach — "
            'rematch incoming. Think you can beat me?';
    shareToWhatsApp(context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Duel Result')),
      body: StreamBuilder<Duel?>(
        stream: DuelService.instance.watch(widget.duelId),
        builder: (context, snapshot) {
          final duel = snapshot.data;
          if (duel == null || user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (duel.status != DuelStatus.finished) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('Waiting for your opponent to finish…', style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            );
          }

          _recordHistoryIfNeeded(duel);

          final self = duel.selfOf(user.uid);
          final opponent = duel.opponentOf(user.uid);
          if (self == null || opponent == null) {
            return const Center(child: Text('Could not load the result.'));
          }
          final won = self.points > opponent.points;
          final tied = self.points == opponent.points;

          final missedIndexes = [
            for (var i = 0; i < duel.questions.length; i++)
              if (widget.selfAnswers[i] != duel.questions[i].correctIndex) i,
          ];

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Column(
                children: [
                  Icon(
                    tied ? Icons.handshake_outlined : (won ? Icons.emoji_events : Icons.sentiment_neutral),
                    size: 64,
                    color: won ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tied ? "It's a tie!" : (won ? 'You won!' : 'You lost this one'),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      name: 'You',
                      score: self.points,
                      total: duel.questions.length,
                      highlight: won,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreCard(
                      name: opponent.name,
                      score: opponent.points,
                      total: duel.questions.length,
                      highlight: !won && !tied,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _rematching ? null : () => _rematch(duel, opponent.uid, opponent.name),
                      icon: const Icon(Icons.replay),
                      label: Text(_rematching ? 'Starting…' : 'Rematch'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addedBuddy ? null : () => _addStudyBuddy(opponent.uid, opponent.name),
                      icon: Icon(_addedBuddy ? Icons.check : Icons.person_add_alt_outlined),
                      label: Text(_addedBuddy ? 'Buddy added' : 'Add Study Buddy'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _shareResult(duel, won, opponent.name),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Share to WhatsApp'),
                ),
              ),
              if (missedIndexes.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('Questions you missed', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...missedIndexes.map(
                  (index) => _MissedQuestionCard(
                    question: duel.questions[index],
                    userAnswerIndex: widget.selfAnswers[index],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  MainNavShell.goToHomeTab();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.name,
    required this.score,
    required this.total,
    required this.highlight,
    required this.theme,
  });

  final String name;
  final int score;
  final int total;
  final bool highlight;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight ? theme.colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: highlight ? theme.colorScheme.onPrimaryContainer : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score pts',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: highlight ? theme.colorScheme.onPrimaryContainer : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissedQuestionCard extends StatefulWidget {
  const _MissedQuestionCard({required this.question, required this.userAnswerIndex});

  final QuizQuestion question;
  final int? userAnswerIndex;

  @override
  State<_MissedQuestionCard> createState() => _MissedQuestionCardState();
}

class _MissedQuestionCardState extends State<_MissedQuestionCard> {
  bool _loading = false;
  String? _explanation;
  String? _error;

  Future<void> _explainLikeImFive() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final text = await Eli5Service.instance.explain(
        question: widget.question,
        userAnswerIndex: widget.userAnswerIndex,
      );
      if (mounted) setState(() => _explanation = text);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Could not get an explanation.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not get an explanation. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.question;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Correct answer: ${question.options[question.correctIndex]}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            if (_explanation == null)
              OutlinedButton.icon(
                onPressed: _loading ? null : _explainLikeImFive,
                icon: const Icon(Icons.emoji_people_outlined, size: 18),
                label: Text(_loading ? 'Thinking…' : "Explain like I'm 5 🗣️"),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_explanation!, style: theme.textTheme.bodyMedium),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        ),
      ),
    );
  }
}
