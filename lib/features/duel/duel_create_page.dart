import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_data_store.dart';
import '../../data/auth_service.dart';
import '../../data/deep_link_service.dart';
import '../../data/duel_service.dart';
import '../../data/models/duel.dart';
import '../../widgets/slide_up_route.dart';
import '../exam/exam_types.dart';
import '../exam/quiz/question_bank/question_bank_registry.dart';
import '../services/whatsapp_contact.dart';
import 'duel_exam_category.dart';
import 'duel_session_page.dart';

const _duelQuestionCount = 10;
const _duelDuration = Duration(minutes: 5);

/// Pick a subject, create the duel, then wait for a friend to join with
/// the generated code.
class DuelCreatePage extends StatefulWidget {
  const DuelCreatePage({super.key});

  @override
  State<DuelCreatePage> createState() => _DuelCreatePageState();
}

class _DuelCreatePageState extends State<DuelCreatePage> {
  final _searchController = TextEditingController();
  String _query = '';
  ExamCategory? _examCategory;
  Duel? _duel;
  bool _creating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createDuel(String subject, ExamCategory examCategory) async {
    final user = AuthService.instance.currentUser;
    if (user == null || _creating) return;

    setState(() => _creating = true);
    try {
      final questions = questionsForSubject(
        subject,
        sampleSize: _duelQuestionCount,
        examCategory: examCategory,
      );
      final duel = await DuelService.instance.create(
        subject: subject,
        questions: questions,
        duration: _duelDuration,
        hostUid: user.uid,
        hostName: AppDataStore.instance.profile.name,
      );
      if (mounted) setState(() => _duel = duel);
    } on DuelException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duel = _duel;
    if (duel != null) {
      return _WaitingRoom(duel: duel);
    }

    final examCategory = _examCategory;
    if (examCategory == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Duel a Friend')),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: duelExamCategories.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final type = examTypes.firstWhere((t) => t.category == duelExamCategories[index]);
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(child: Icon(type.icon)),
                title: Text(type.shortLabel),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => setState(() => _examCategory = type.category),
              ),
            );
          },
        ),
      );
    }

    final filteredSubjects = subjectsForDuelExamCategory(examCategory)
        .where((subject) => subject.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => setState(() => _examCategory = null)),
        title: const Text('Choose a Subject'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search subjects',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (_creating) const LinearProgressIndicator(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: filteredSubjects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subject = filteredSubjects[index];
                return Card(
                  child: ListTile(
                    title: Text(subject),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _creating ? null : () => _createDuel(subject, examCategory),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingRoom extends StatelessWidget {
  const _WaitingRoom({required this.duel});

  final Duel duel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting for opponent')),
      body: StreamBuilder<Duel?>(
        stream: DuelService.instance.watch(duel.id),
        builder: (context, snapshot) {
          final live = snapshot.data;
          if (live != null && live.status == DuelStatus.active) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  SlideUpRoute(builder: (_) => DuelSessionPage(duelId: duel.id)),
                );
              }
            });
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Share the link below, or give your friend this code',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          duel.id,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            letterSpacing: 6,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: duel.id));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Code copied!')),
                              );
                            }
                          },
                          icon: Icon(Icons.copy, color: theme.colorScheme.onPrimaryContainer),
                          tooltip: 'Copy code',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${duel.subject} · ${duel.questions.length} questions · '
                    '${duel.durationSeconds ~/ 60} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => shareToWhatsApp(
                      context,
                      message: 'Duel me on Exam Coach! Tap to join my ${duel.subject} quiz duel: '
                          '${Uri.https(duelLinkHost, '/duel/${duel.id}')}\n'
                          "(If the link doesn't open the app, enter code ${duel.id} instead.)",
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Share via WhatsApp'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
