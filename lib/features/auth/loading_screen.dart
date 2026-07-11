import 'dart:async';

import 'package:flutter/material.dart';

/// Bridges the gap between the native splash screen and the first real
/// screen. A bare spinner here reads as a stall right after the branded
/// native splash disappears, so this keeps the same navy/logo look and adds
/// rotating tips to give the wait a sense of progress.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  static const _tips = [
    'Tip: review your weak topics first — the app tracks them for you.',
    'Tip: WAEC and NECO share most subjects, but English syllabuses differ.',
    'Tip: timed practice tests build the exam-day pacing habit.',
    'Tip: Post-UTME cut-off marks vary a lot by school — check yours.',
    "Did you know? JAMB's CBT format rewards speed as much as accuracy.",
  ];

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final Timer _tipTimer;
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    _tipTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _tipIndex = (_tipIndex + 1) % LoadingScreen._tips.length);
    });
  }

  @override
  void dispose() {
    _tipTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12203D),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo/logo_mark.png', width: 96, height: 96),
                const SizedBox(height: 24),
                const Text(
                  'Exam Coach',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8932A)),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    LoadingScreen._tips[_tipIndex],
                    key: ValueKey(_tipIndex),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
