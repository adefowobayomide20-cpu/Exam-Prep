import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/slide_up_route.dart';
import '../services/whatsapp_contact.dart';
import 'post_jamb_schools.dart';
import 'post_utme_subject_picker_page.dart';
import 'quiz/question_bank/post_utme_school_subject_banks.dart';
import 'quiz/question_bank/unilag_post_utme_bank.dart';
import 'quiz/question_bank/unilorin_post_utme_bank.dart';
import 'quiz/quiz_question.dart';
import 'quiz/quiz_session_page.dart';

/// Per-school test duration for the schools below, which keep the original
/// single-button, straight-into-a-test flow instead of going through
/// [PostUtmeSubjectPickerPage] (see `quiz/question_bank/post_utme_school_subject_banks.dart`
/// for how every other school is configured). Both match the 15-minute,
/// 10-questions-per-subject format standard elsewhere in the app.
const _postUtmeTestDurations = {
  'UNILAG': Duration(minutes: 15),
  'UNILORIN': Duration(minutes: 15),
};

/// Maps a school's [PostJambSchool.shortName] to its full, fixed practice
/// question bank.
final Map<String, List<QuizQuestion> Function()> _postUtmeBanks = {
  'UNILAG': buildUnilagPostUtmeQuestions,
  'UNILORIN': buildUnilorinPostUtmeQuestions,
};

class PostJambSchoolDetailPage extends StatelessWidget {
  const PostJambSchoolDetailPage({super.key, required this.school});

  final PostJambSchool school;

  bool get _hasPracticeTest =>
      _postUtmeBanks.containsKey(school.shortName) ||
      postUtmeSchoolSubjectBanks.containsKey(school.shortName);

  Future<void> _startPracticeTest(BuildContext context) async {
    final buildQuestions = _postUtmeBanks[school.shortName];
    if (buildQuestions != null) {
      Navigator.of(context).push(SlideUpRoute(
        builder: (_) => QuizSessionPage(
          title: 'Post-UTME · ${school.shortName}',
          questions: buildQuestions(),
          duration: _postUtmeTestDurations[school.shortName] ?? const Duration(minutes: 60),
        ),
      ));
      return;
    }

    final subjectBank = postUtmeSchoolSubjectBanks[school.shortName];
    if (subjectBank == null) return;
    Navigator.of(context).push(SlideUpRoute(
      builder: (_) => PostUtmeSubjectPickerPage(school: school, subjectBank: subjectBank),
    ));
  }

  Future<void> _openWebsite(BuildContext context) async {
    final uri = Uri.https(school.website);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the website')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(school.shortName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.school_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(school.name, style: theme.textTheme.titleLarge),
                    Text(
                      school.website,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What Post-JAMB screening usually involves', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const _RequirementTile(
                    icon: Icons.assignment_turned_in_outlined,
                    text: 'A UTME score at or above the score the institution sets for your '
                        'course — this changes every admission cycle.',
                  ),
                  const _RequirementTile(
                    icon: Icons.grade_outlined,
                    text: 'O\'Level results (WAEC/NECO) with the required credits, usually '
                        'including English and Mathematics, for your intended course.',
                  ),
                  const _RequirementTile(
                    icon: Icons.how_to_reg_outlined,
                    text: 'Registration on the institution\'s own screening/registration '
                        'portal, separate from your JAMB profile.',
                  ),
                  const _RequirementTile(
                    icon: Icons.edit_note_outlined,
                    text: 'Some institutions add an aptitude test, an interview, or both, '
                        'depending on the course.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Exact cut-off marks, screening dates, and requirements change every '
                      'session — always confirm on the school\'s official website before you act.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_hasPracticeTest) ...[
            FilledButton.icon(
              onPressed: () => _startPracticeTest(context),
              icon: const Icon(Icons.quiz_outlined, size: 18),
              label: const Text('Start Post-UTME Practice Test'),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: () => _openWebsite(context),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text('Visit ${school.shortName} Website'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => openWhatsAppChat(
              context,
              message: 'Hi, I need help with the ${school.name} Post-JAMB screening process.',
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Ask for Help on WhatsApp'),
          ),
        ],
      ),
    );
  }
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
