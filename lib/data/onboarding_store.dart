import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the student has been through the first-run onboarding
/// slides. Local-only and independent of sign-in state — onboarding shows
/// exactly once per install regardless of whether Firebase is reachable.
class OnboardingStore {
  OnboardingStore._();

  static final instance = OnboardingStore._();

  static const _key = 'onboarding_complete';

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
