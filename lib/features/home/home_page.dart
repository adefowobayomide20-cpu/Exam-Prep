import 'package:flutter/material.dart';

import '../../data/app_data_store.dart';
import '../../data/notification_store.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/slide_up_route.dart';
import '../duel/duel_hub_page.dart';
import '../exam/exam_types.dart';
import '../exam/quiz/question_bank/question_bank_registry.dart';
import '../exam/quiz/quiz_session_page.dart';
import '../notifications/notification_center_page.dart';
import '../services/whatsapp_contact.dart';
import '../tutor/tutor_chat_page.dart';
import 'widgets/boss_level_card.dart';
import 'widgets/continue_last_session_card.dart';
import 'widgets/exam_type_section.dart';
import 'widgets/invite_friend_card.dart';
import 'widgets/latest_news_section.dart';
import 'widgets/performance_tracker_card.dart';
import 'widgets/snap_and_solve_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/study_reminder_card.dart';

const _bossQuestionsPerSubject = 10;
const _bossSecondsPerQuestion = 45;

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.onSeeAllNews,
    this.onProfileTap,
    this.onStartQuiz,
  });

  final VoidCallback? onSeeAllNews;
  final VoidCallback? onProfileTap;
  final VoidCallback? onStartQuiz;

  void _startBossQuiz(BuildContext context, List<(String subject, double percent)> weakSubjects) {
    final questions = weakSubjects
        .expand(
          (entry) => questionsForSubject(
            entry.$1,
            sampleSize: _bossQuestionsPerSubject,
            examCategory: ExamCategory.waec,
          ),
        )
        .toList();
    Navigator.of(context).push(
      SlideUpRoute(
        builder: (_) => QuizSessionPage(
          title: 'Boss Level',
          questions: questions,
          duration: Duration(seconds: questions.length * _bossSecondsPerQuestion),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo/logo_badge.png', width: 28, height: 28),
            ),
            const SizedBox(width: 10),
            const Text('Exam Coach'),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: NotificationStore.instance,
            builder: (context, _) => IconButton(
              onPressed: () => Navigator.of(context).push(
                SlideUpRoute(builder: (_) => const NotificationCenterPage()),
              ),
              icon: Badge.count(
                count: NotificationStore.instance.unreadCount,
                isLabelVisible: NotificationStore.instance.unreadCount > 0,
                child: const Icon(Icons.notifications_outlined),
              ),
              tooltip: 'Notifications',
            ),
          ),
          IconButton(
            onPressed: onProfileTap,
            icon: const CircleAvatar(child: Icon(Icons.person)),
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          final store = AppDataStore.instance;
          const stagger = Duration(milliseconds: 70);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FadeSlideIn(
                child: StreakCard(
                  currentStreak: store.currentStreak,
                  longestStreak: store.longestStreak,
                  activeToday: store.streakActiveToday,
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: stagger * 1,
                child: ContinueLastSessionCard(
                  lastAttempt: store.lastAttempt,
                  onStartQuiz: onStartQuiz,
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: stagger * 2,
                child: SnapAndSolveCard(
                  onTap: () => Navigator.of(context).push(
                    SlideUpRoute(builder: (_) => const TutorChatPage()),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: stagger * 3,
                child: PerformanceTrackerCard(
                  onTap: onProfileTap,
                  quizzesTaken: store.quizzesTaken,
                  averageScorePercent: store.averageScorePercent,
                  duelsWon: store.duelsWon,
                  currentStreak: store.currentStreak,
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: stagger * 4,
                child: BossLevelCard(
                  weakSubjects: store.weakSubjects,
                  onStart: store.weakSubjects.isEmpty
                      ? null
                      : () => _startBossQuiz(context, store.weakSubjects),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: stagger * 5,
                child: InviteFriendCard(
                  onInvite: () => Navigator.of(context).push(
                    SlideUpRoute(builder: (_) => const DuelHubPage()),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: stagger * 6,
                child: StudyReminderCard(onManage: onProfileTap, nextReminder: store.nextReminder),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(delay: stagger * 7, child: const ExamTypeSection()),
              const SizedBox(height: 20),
              FadeSlideIn(delay: stagger * 8, child: LatestNewsSection(onSeeAll: onSeeAllNews)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_whatsapp_fab',
        onPressed: () => openWhatsAppChat(context),
        tooltip: 'Chat on WhatsApp',
        child: const Icon(Icons.chat_bubble_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
