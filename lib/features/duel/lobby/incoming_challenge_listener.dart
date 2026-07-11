import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/app_data_store.dart';
import '../../../data/auth_service.dart';
import '../../../data/duel_service.dart';
import '../../../data/lobby_service.dart';
import '../../../data/models/challenge.dart';
import '../../../widgets/slide_up_route.dart';
import '../../exam/quiz/question_bank/question_bank_registry.dart';
import '../duel_session_page.dart';

const _duelQuestionCount = 10;
const _duelDuration = Duration(minutes: 5);
const _challengeTimeout = Duration(seconds: 15);

/// Mounted once near the app root: watches for incoming duel challenges
/// (gated by [ProfileSettings.duelAlerts]) and pops a full-screen dialog
/// with a 15-second accept/decline countdown when one arrives.
class IncomingChallengeListener extends StatefulWidget {
  const IncomingChallengeListener({super.key, required this.child});

  final Widget child;

  @override
  State<IncomingChallengeListener> createState() => _IncomingChallengeListenerState();
}

class _IncomingChallengeListenerState extends State<IncomingChallengeListener> {
  StreamSubscription<List<Challenge>>? _sub;
  final _handled = <String>{};
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _subscribe());
  }

  void _subscribe() {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    _sub = LobbyService.instance.watchIncomingChallenges(user.uid).listen((challenges) {
      if (!AppDataStore.instance.profile.duelAlerts) return;
      for (final challenge in challenges) {
        if (_handled.contains(challenge.id) || _dialogOpen) continue;
        _handled.add(challenge.id);
        _showChallengeDialog(challenge);
        break;
      }
    });
  }

  Future<void> _showChallengeDialog(Challenge challenge) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    _dialogOpen = true;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChallengeDialog(challenge: challenge, timeout: _challengeTimeout),
    );
    _dialogOpen = false;

    if (accepted == true) {
      await _acceptChallenge(challenge, navigator);
    } else {
      await LobbyService.instance.respond(challengeId: challenge.id, status: ChallengeStatus.declined);
    }
  }

  Future<void> _acceptChallenge(Challenge challenge, NavigatorState navigator) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      final questions = questionsForSubject(
        challenge.subject,
        sampleSize: _duelQuestionCount,
        examCategory: challenge.examCategory,
      );
      final duel = await DuelService.instance.createDirect(
        subject: challenge.subject,
        questions: questions,
        duration: _duelDuration,
        hostUid: user.uid,
        hostName: AppDataStore.instance.profile.name,
        guestUid: challenge.fromUid,
        guestName: challenge.fromName,
      );
      await LobbyService.instance.respond(
        challengeId: challenge.id,
        status: ChallengeStatus.accepted,
        duelId: duel.id,
      );
      navigator.push(SlideUpRoute(builder: (_) => DuelSessionPage(duelId: duel.id)));
    } on DuelException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ChallengeDialog extends StatefulWidget {
  const _ChallengeDialog({required this.challenge, required this.timeout});

  final Challenge challenge;
  final Duration timeout;

  @override
  State<_ChallengeDialog> createState() => _ChallengeDialogState();
}

class _ChallengeDialogState extends State<_ChallengeDialog> {
  late int _secondsLeft = widget.timeout.inSeconds;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _ticker?.cancel();
        Navigator.of(context).pop(false);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog.fullscreen(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_kabaddi, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                '${widget.challenge.fromName} is challenging you!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.challenge.subject} · ${widget.challenge.school}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text('$_secondsLeft', style: theme.textTheme.displayMedium),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Accept ⚔️'),
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
