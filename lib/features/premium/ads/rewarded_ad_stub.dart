/// Web build: rewarded video ads aren't available (the paywall UI hides
/// this option on web already) — returns false as a safe fallback if ever
/// called anyway.
class RewardedAdController {
  RewardedAdController._();
  static final RewardedAdController instance = RewardedAdController._();

  Future<bool> show() async => false;
}
