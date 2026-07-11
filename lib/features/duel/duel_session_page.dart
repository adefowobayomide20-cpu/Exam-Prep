import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../data/duel_service.dart';
import '../../data/lobby_presence_controller.dart';
import '../../data/models/duel.dart';
import '../../widgets/lifeline_button.dart';
import '../../widgets/slide_up_route.dart';
import 'duel_result_page.dart';

const _lifelineUses = 2;
const _freezeSeconds = 10;

/// The live head-to-head quiz: both players see the same questions and
/// timer, and each other's live progress, synced through the Duel document.
class DuelSessionPage extends StatefulWidget {
  const DuelSessionPage({super.key, required this.duelId});

  final String duelId;

  @override
  State<DuelSessionPage> createState() => _DuelSessionPageState();
}

class _DuelSessionPageState extends State<DuelSessionPage> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  final Map<int, int> _pointsEarned = {};
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  bool _finished = false;
  Duel? _lastKnownDuel;
  DateTime _questionStartedAt = DateTime.now();

  /// Briefly non-null right after an answer is tapped: colors that option
  /// green/red and reveals the correct one, then clears itself.
  int? _revealedQuestionIndex;

  int _fiftyFiftyLeft = _lifelineUses;
  int _hintLeft = _lifelineUses;
  int _freezeLeft = _lifelineUses;
  final Map<int, Set<int>> _eliminated = {};
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    LobbyPresenceController.instance.enterDuel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    LobbyPresenceController.instance.exitDuel();
    super.dispose();
  }

  void _tick() {
    final duel = _lastKnownDuel;
    final user = AuthService.instance.currentUser;
    if (duel?.startedAt == null || _finished || user == null) return;
    final penalty = duel!.selfOf(user.uid)?.penaltySeconds ?? 0;
    final elapsed = DateTime.now().difference(duel.startedAt!);
    final remaining = Duration(seconds: duel.durationSeconds) - elapsed - Duration(seconds: penalty);
    setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
    if (remaining <= Duration.zero) {
      _submit(duel);
    }
  }

  /// At most `options.length - 2` wrong options can ever be eliminated for a
  /// question, so the correct answer plus at least one wrong option always
  /// remain — no lifeline combination can give the answer away outright.
  int _maxEliminable(int optionCount) => optionCount - 2;

  void _eliminateWrongOptions(int count) {
    final question = _lastKnownDuel!.questions[_currentIndex];
    final eliminated = _eliminated.putIfAbsent(_currentIndex, () => {});
    final cap = _maxEliminable(question.options.length);
    final wrongIndexes = [
      for (var i = 0; i < question.options.length; i++)
        if (i != question.correctIndex && !eliminated.contains(i)) i,
    ]..shuffle(_random);

    final room = cap - eliminated.length;
    if (room <= 0) return;
    final toEliminate = min(count, min(room, wrongIndexes.length));
    setState(() {
      eliminated.addAll(wrongIndexes.take(toEliminate));
    });
  }

  void _useFiftyFifty() {
    if (_fiftyFiftyLeft <= 0) return;
    setState(() => _fiftyFiftyLeft -= 1);
    _eliminateWrongOptions(2);
  }

  void _useHint() {
    if (_hintLeft <= 0) return;
    setState(() => _hintLeft -= 1);
    _eliminateWrongOptions(1);
  }

  Future<void> _useFreeze(Duel duel, String uid) async {
    if (_freezeLeft <= 0) return;
    setState(() => _freezeLeft -= 1);
    final isHost = duel.isHost(uid);
    await DuelService.instance.freezeOpponent(duelId: duel.id, isHost: isHost);
    final opponentName = duel.opponentOf(uid)?.name ?? 'your opponent';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Froze $opponentName\'s timer for $_freezeSeconds seconds!')),
      );
    }
  }

  int _scoreFor(List questions, Map<int, int> answers) {
    var score = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].correctIndex) score++;
    }
    return score;
  }

  int get _totalPoints => _pointsEarned.values.fold(0, (sum, p) => sum + p);

  /// Correct answers earn more the faster they're submitted, with a floor
  /// so a slow-but-correct answer still beats a wrong one.
  int _pointsFor(bool correct, Duration timeTaken) {
    if (!correct) return 0;
    return (20 - 1.5 * timeTaken.inSeconds).round().clamp(5, 20);
  }

  void _selectAnswer(int optionIndex) {
    final question = _lastKnownDuel!.questions[_currentIndex];
    final correct = optionIndex == question.correctIndex;
    final points = _pointsFor(correct, DateTime.now().difference(_questionStartedAt));
    setState(() {
      _answers[_currentIndex] = optionIndex;
      _pointsEarned[_currentIndex] = points;
      _revealedQuestionIndex = _currentIndex;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _revealedQuestionIndex == _currentIndex) {
        setState(() => _revealedQuestionIndex = null);
      }
    });
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentIndex = index;
      _revealedQuestionIndex = null;
      _questionStartedAt = DateTime.now();
    });
  }

  Future<void> _recordProgress(Duel duel, String uid) async {
    final isHost = duel.isHost(uid);
    await DuelService.instance.recordProgress(
      duelId: duel.id,
      isHost: isHost,
      answered: _answers.length,
      correct: _scoreFor(duel.questions, _answers),
      points: _totalPoints,
    );
  }

  Future<void> _submit(Duel duel) async {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();

    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final isHost = duel.isHost(user.uid);

    await DuelService.instance.recordProgress(
      duelId: duel.id,
      isHost: isHost,
      answered: _answers.length,
      correct: _scoreFor(duel.questions, _answers),
      points: _totalPoints,
    );
    await DuelService.instance.finish(duelId: duel.id, isHost: isHost);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        SlideUpRoute(
          builder: (_) => DuelResultPage(duelId: duel.id, selfAnswers: Map<int, int>.from(_answers)),
        ),
      );
    }
  }

  String _formatRemaining(Duration duration) {
    final clamped = duration.isNegative ? Duration.zero : duration;
    final minutes = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService.instance.currentUser;

    return Scaffold(
      body: StreamBuilder<Duel?>(
        stream: DuelService.instance.watch(widget.duelId),
        builder: (context, snapshot) {
          final duel = snapshot.data;
          if (duel == null || user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _lastKnownDuel = duel;
          final opponent = duel.opponentOf(user.uid);
          final question = duel.questions[_currentIndex];
          final isLast = _currentIndex == duel.questions.length - 1;
          final isLowTime = _remaining <= const Duration(seconds: 30);

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final leave = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Leave the duel?'),
                  content: const Text('Leaving now counts as a loss — your opponent keeps playing.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Stay'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Leave'),
                    ),
                  ],
                ),
              );
              if (leave == true && context.mounted) {
                await _submit(duel);
              }
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(duel.subject, style: theme.textTheme.titleMedium),
                        Chip(
                          avatar: Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: isLowTime ? theme.colorScheme.error : theme.colorScheme.primary,
                          ),
                          label: Text(
                            _formatRemaining(_remaining),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isLowTime ? theme.colorScheme.error : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (opponent != null)
                      Text(
                        '${opponent.name}: ${opponent.answered}/${duel.questions.length} answered'
                        '${opponent.isFinished ? ' · done' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: (_currentIndex + 1) / duel.questions.length),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        LifelineButton(
                          icon: Icons.filter_2,
                          label: '50-50',
                          usesLeft: _fiftyFiftyLeft,
                          onPressed: _fiftyFiftyLeft > 0 ? _useFiftyFifty : null,
                        ),
                        const SizedBox(width: 8),
                        LifelineButton(
                          icon: Icons.lightbulb_outline,
                          label: 'Hint',
                          usesLeft: _hintLeft,
                          onPressed: _hintLeft > 0 ? _useHint : null,
                        ),
                        const SizedBox(width: 8),
                        LifelineButton(
                          icon: Icons.ac_unit,
                          label: 'Freeze',
                          usesLeft: _freezeLeft,
                          onPressed: _freezeLeft > 0 ? () => _useFreeze(duel, user.uid) : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: [
                          Text(question.text, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 16),
                          ...List.generate(question.options.length, (optionIndex) {
                            final selected = _answers[_currentIndex] == optionIndex;
                            final eliminated = _eliminated[_currentIndex]?.contains(optionIndex) ?? false;
                            if (eliminated) {
                              return const SizedBox.shrink();
                            }
                            final revealed = _revealedQuestionIndex == _currentIndex;
                            final isCorrectOption = optionIndex == question.correctIndex;
                            Color? tileColor;
                            Color borderColor = selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant;
                            if (revealed) {
                              if (selected && isCorrectOption) {
                                tileColor = Colors.green.withValues(alpha: 0.18);
                                borderColor = Colors.green;
                              } else if (selected && !isCorrectOption) {
                                tileColor = Colors.red.withValues(alpha: 0.18);
                                borderColor = Colors.red;
                              } else if (isCorrectOption) {
                                tileColor = Colors.green.withValues(alpha: 0.10);
                                borderColor = Colors.green;
                              }
                            } else if (selected) {
                              tileColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: revealed
                                    ? null
                                    : () {
                                        _selectAnswer(optionIndex);
                                        _recordProgress(duel, user.uid);
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: borderColor,
                                      width: selected || (revealed && isCorrectOption) ? 2 : 1,
                                    ),
                                    color: tileColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        revealed && isCorrectOption
                                            ? Icons.check_circle
                                            : (selected
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_unchecked),
                                        color: revealed
                                            ? borderColor
                                            : (selected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.outline),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(question.options[optionIndex])),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (_currentIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _goToQuestion(_currentIndex - 1),
                              child: const Text('Previous'),
                            ),
                          ),
                        if (_currentIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: isLast
                                ? () => _submit(duel)
                                : () => _goToQuestion(_currentIndex + 1),
                            child: Text(isLast ? 'Submit' : 'Next'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
