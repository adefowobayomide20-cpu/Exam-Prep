import 'package:flutter/material.dart';

import 'data/app_data_store.dart';
import 'features/auth/auth_gate.dart';
import 'navigation/root_navigator.dart';
import 'theme/app_theme.dart';
import 'widgets/pwa_install_overlay.dart';

class ExamCoachApp extends StatefulWidget {
  const ExamCoachApp({super.key});

  @override
  State<ExamCoachApp> createState() => _ExamCoachAppState();
}

class _ExamCoachAppState extends State<ExamCoachApp> {
  late ThemeMode _themeMode = _themeModeFor(AppDataStore.instance.profile.themeMode);

  @override
  void initState() {
    super.initState();
    // AppDataStore is one broad ChangeNotifier covering profile, quiz
    // progress, streaks, reminders, etc. — listening to it directly (as
    // this used to via a ListenableBuilder around the whole MaterialApp)
    // meant every unrelated change anywhere in the app rebuilt the entire
    // MaterialApp shell. Comparing before setState so only an actual
    // themeMode change triggers a rebuild here.
    AppDataStore.instance.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    AppDataStore.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    final next = _themeModeFor(AppDataStore.instance.profile.themeMode);
    if (next != _themeMode) setState(() => _themeMode = next);
  }

  static ThemeMode _themeModeFor(String preference) {
    switch (preference) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Exam Coach',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: const AuthGate(),
      builder: (context, child) => PwaInstallOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
