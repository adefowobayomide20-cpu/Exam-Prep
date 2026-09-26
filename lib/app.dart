import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'data/app_data_store.dart';
import 'data/onboarding_store.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/loading_screen.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/legal/account_deletion_request_page.dart';
import 'navigation/root_navigator.dart';
import 'theme/app_theme.dart';
import 'widgets/pwa_install_overlay.dart';

/// Shows the first-run onboarding slides once per install, then the main
/// app. Entirely local (SharedPreferences-backed) and independent of
/// sign-in state.
class _AppEntryPoint extends StatefulWidget {
  const _AppEntryPoint();

  @override
  State<_AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<_AppEntryPoint> {
  bool? _needsOnboarding;

  @override
  void initState() {
    super.initState();
    OnboardingStore.instance.hasCompletedOnboarding().then((done) {
      if (mounted) setState(() => _needsOnboarding = !done);
    });
  }

  Future<void> _finishOnboarding() async {
    await OnboardingStore.instance.markCompleted();
    if (mounted) setState(() => _needsOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsOnboarding == null) return const LoadingScreen();
    if (_needsOnboarding!) return OnboardingPage(onDone: _finishOnboarding);
    return const AuthGate();
  }
}

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
    final isAccountDeletionRequest = kIsWeb && Uri.base.path == '/account-deletion-request';
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Exam Coach',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: isAccountDeletionRequest ? const AccountDeletionRequestPage() : const _AppEntryPoint(),
      builder: (context, child) => PwaInstallOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
