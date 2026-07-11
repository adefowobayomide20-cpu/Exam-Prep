import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../widgets/lifeline_button.dart';
import '../../../widgets/slide_up_route.dart';
import 'quiz_question.dart';
import 'quiz_result_page.dart';

const _lifelineUses = 2;

class QuizSessionPage extends StatefulWidget {
  const QuizSessionPage({
    super.key,
    required this.title,
    required this.questions,
    required this.duration,
  });

  final String title;
  final List<QuizQuestion> questions;
  final Duration duration;

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> with SingleTickerProviderStateMixin {
  late Duration _remaining = widget.duration;
  Timer? _timer;
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  int _fiftyFiftyLeft = _lifelineUses;
  int _hintLeft = _lifelineUses;
  final Map<int, Set<int>> _eliminated = {};
  final _random = Random();

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining -= const Duration(seconds: 1));
      if (_remaining <= Duration.zero) {
        _timer?.cancel();
        _submit();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _submit() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      SlideUpRoute(
        builder: (_) => QuizResultPage(
          title: widget.title,
          questions: widget.questions,
          answers: Map.of(_answers),
        ),
      ),
    );
  }

  Future<bool> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave test?'),
        content: const Text('Your progress on this test will be lost.'),
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
    return confirmed ?? false;
  }

  /// At most `options.length - 2` wrong options can ever be eliminated for a
  /// question, so the correct answer plus at least one wrong option always
  /// remain — no lifeline combination can give the answer away outright.
  int _maxEliminable(int optionCount) => optionCount - 2;

  void _eliminateWrongOptions(int count) {
    final question = widget.questions[_currentIndex];
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

  String _formatRemaining() {
    final clamped = _remaining.isNegative ? Duration.zero : _remaining;
    final minutes = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.questions[_currentIndex];
    final isLast = _currentIndex == widget.questions.length - 1;
    final isLowTime = _remaining <= const Duration(minutes: 1);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmExit() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = isLowTime ? 1 + (_pulseController.value * 0.08) : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Chip(
                    avatar: Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: isLowTime ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                    label: Text(
                      _formatRemaining(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isLowTime ? theme.colorScheme.error : theme.colorScheme.onSurface,
                      ),
                    ),
                    backgroundColor: isLowTime
                        ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                        : theme.colorScheme.surfaceContainerLowest,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: (_currentIndex + 1) / widget.questions.length,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${_currentIndex + 1} of ${widget.questions.length} · ${question.subject}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
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
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: ListView(
                    key: ValueKey(_currentIndex),
                    children: [
                      Text(question.text, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      ...List.generate(question.options.length, (optionIndex) {
                        final selected = _answers[_currentIndex] == optionIndex;
                        final eliminated = _eliminated[_currentIndex]?.contains(optionIndex) ?? false;
                        if (eliminated) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _answers[_currentIndex] = optionIndex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant,
                                  width: selected ? 2 : 1,
                                ),
                                color: selected
                                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  AnimatedScale(
                                    scale: selected ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutBack,
                                    child: Icon(
                                      selected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline,
                                    ),
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
              ),
              Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentIndex -= 1),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isLast ? _submit : () => setState(() => _currentIndex += 1),
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
  }
}
