import 'package:flutter/material.dart';

import '../features/exam/exam_page.dart';
import '../features/home/home_page.dart';
import '../features/news/news_page.dart';
import '../features/profile/profile_page.dart';
import '../features/services/services_page.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});

  /// Switches to the Home tab from anywhere in the app (e.g. after a quiz
  /// finishes), so the student lands on their updated streak/stats rather
  /// than wherever they started the quiz from. No-op if no [MainNavShell]
  /// is currently mounted.
  static void goToHomeTab() => _MainNavShellState._instance?._onItemTapped(_homeTabIndex);

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

const _homeTabIndex = 0;

class _MainNavShellState extends State<MainNavShell> {
  static const _examTabIndex = 1;
  static const _newsTabIndex = 2;
  static const _profileTabIndex = 4;

  static _MainNavShellState? _instance;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  @override
  void dispose() {
    if (identical(_instance, this)) _instance = null;
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _goToExamTab() => _onItemTapped(_examTabIndex);
  void _goToNewsTab() => _onItemTapped(_newsTabIndex);
  void _goToProfileTab() => _onItemTapped(_profileTabIndex);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onSeeAllNews: _goToNewsTab,
        onProfileTap: _goToProfileTab,
        onStartQuiz: _goToExamTab,
      ),
      const ExamPage(),
      const NewsPage(),
      const ServicesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Exam',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.miscellaneous_services_outlined),
            selectedIcon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
