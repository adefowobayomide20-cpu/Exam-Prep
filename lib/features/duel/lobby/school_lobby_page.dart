import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/app_data_store.dart';
import '../../../data/auth_service.dart';
import '../../../data/lobby_service.dart';
import '../../../data/models/challenge.dart';
import '../../../data/models/lobby_presence.dart';
import '../../../widgets/slide_up_route.dart';
import '../../exam/post_jamb_schools.dart';
import '../duel_exam_category.dart';
import '../duel_session_page.dart';

// Slightly longer than the 15s the recipient's IncomingChallengeListener
// dialog waits before auto-declining, so that decline reaches Firestore
// before this side gives up and reports "no response" instead.
const _challengeResponseTimeout = Duration(seconds: 16);

/// Live "who's online" lobby for a school: tapping "Challenge" on another
/// student sends them a duel invite that surfaces via
/// [IncomingChallengeListener]. Presence itself is kept alive globally by
/// [LobbyPresenceController] for as long as the app is open (see main.dart),
/// not just while this screen is mounted — so students show up here as
/// soon as they're signed in, whether or not they've ever opened this
/// screen themselves. Picking a different lobby below only changes which
/// school's list you're viewing, not your own presence.
class SchoolLobbyPage extends StatefulWidget {
  const SchoolLobbyPage({super.key, required this.initialSchool});

  final String? initialSchool;

  @override
  State<SchoolLobbyPage> createState() => _SchoolLobbyPageState();
}

class _SchoolLobbyPageState extends State<SchoolLobbyPage> {
  late String _school = widget.initialSchool ?? postJambSchools.first.shortName;

  void _switchSchool(String school) {
    setState(() => _school = school);
  }

  Future<void> _pickSchool() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (sheetContext, scrollController) => RadioGroup<String>(
          groupValue: _school,
          onChanged: (value) => Navigator.of(sheetContext).pop(value),
          child: ListView(
            controller: scrollController,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Choose a lobby', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...postJambSchools.map(
                (s) => RadioListTile<String>(value: s.shortName, title: Text(s.name)),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && selected != _school) {
      _switchSchool(selected);
    }
  }

  Future<void> _pickSubjectAndChallenge(LobbyPresence opponent) async {
    final examCategory = await pickDuelExamCategory(context);
    if (examCategory == null || !mounted) return;

    final subjects = subjectsForDuelExamCategory(examCategory);
    final subject = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (sheetContext, scrollController) => ListView(
          controller: scrollController,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Challenge ${opponent.name} in…',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...subjects.map(
              (s) => ListTile(title: Text(s), onTap: () => Navigator.of(sheetContext).pop(s)),
            ),
          ],
        ),
      ),
    );
    if (subject == null || !mounted) return;

    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      final challengeId = await LobbyService.instance.sendChallenge(
        fromUid: user.uid,
        fromName: AppDataStore.instance.profile.name,
        toUid: opponent.uid,
        toName: opponent.name,
        school: _school,
        subject: subject,
        examCategory: examCategory,
      );
      if (!mounted) return;

      final challenge = await showDialog<Challenge>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _WaitingForResponseDialog(
          challengeId: challengeId,
          opponentName: opponent.name,
        ),
      );
      if (!mounted || challenge == null) return;

      if (challenge.status == ChallengeStatus.accepted && challenge.duelId != null) {
        Navigator.of(context).push(
          SlideUpRoute(builder: (_) => DuelSessionPage(duelId: challenge.duelId!)),
        );
      } else if (challenge.status == ChallengeStatus.declined) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${opponent.name} declined the challenge.')),
        );
      } else if (challenge.status == ChallengeStatus.expired) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${opponent.name} didn't respond in time.")),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send the challenge. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService.instance.currentUser;
    final schoolName =
        postJambSchools.firstWhere((s) => s.shortName == _school, orElse: () => postJambSchools.first).name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Lobby'),
        actions: [
          TextButton.icon(
            onPressed: _pickSchool,
            icon: const Icon(Icons.location_city_outlined),
            label: Text(_school),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<LobbyPresence>>(
              stream: LobbyService.instance.watchOnline(school: _school, selfUid: user.uid),
              builder: (context, snapshot) {
                final members = snapshot.data ?? const <LobbyPresence>[];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '$schoolName aspirants online',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (members.isEmpty)
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No one else is online in this lobby right now.\n'
                              'Share the app with friends from $schoolName to duel them here.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: members.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final member = members[index];
                            return Card(
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    const CircleAvatar(child: Icon(Icons.person)),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: theme.colorScheme.surface, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(member.name),
                                subtitle: const Text('Online now'),
                                trailing: FilledButton(
                                  onPressed: () => _pickSubjectAndChallenge(member),
                                  child: const Text('Challenge'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

/// Shown to the challenger while waiting for the other side to respond.
/// Watches the challenge doc directly (mirrors [DuelCreatePage]'s
/// `_WaitingRoom`) since [LobbyService.watchIncomingChallenges] only ever
/// surfaces challenges to the recipient — without this, accepting a
/// challenge previously left the sender stuck on the lobby screen forever.
class _WaitingForResponseDialog extends StatefulWidget {
  const _WaitingForResponseDialog({required this.challengeId, required this.opponentName});

  final String challengeId;
  final String opponentName;

  @override
  State<_WaitingForResponseDialog> createState() => _WaitingForResponseDialogState();
}

class _WaitingForResponseDialogState extends State<_WaitingForResponseDialog> {
  StreamSubscription<Challenge?>? _sub;
  Timer? _timeoutTimer;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _sub = LobbyService.instance.watchChallenge(widget.challengeId).listen(_onChallenge);
    _timeoutTimer = Timer(_challengeResponseTimeout, _onTimeout);
  }

  void _onChallenge(Challenge? challenge) {
    if (challenge == null || challenge.status == ChallengeStatus.pending) return;
    _resolve(challenge);
  }

  void _onTimeout() {
    LobbyService.instance.respond(challengeId: widget.challengeId, status: ChallengeStatus.expired);
    _resolve(null);
  }

  void _cancel() {
    LobbyService.instance.respond(challengeId: widget.challengeId, status: ChallengeStatus.expired);
    _resolve(null);
  }

  void _resolve(Challenge? challenge) {
    if (_resolved || !mounted) return;
    _resolved = true;
    Navigator.of(context).pop(challenge);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Waiting for ${widget.opponentName}'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text("Waiting for ${widget.opponentName} to accept…")),
        ],
      ),
      actions: [
        TextButton(onPressed: _cancel, child: const Text('Cancel')),
      ],
    );
  }
}
