import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Loads and shows a rewarded ad for the paywall's "watch an ad for one
/// more today" button.
class RewardedAdController {
  RewardedAdController._();
  static final RewardedAdController instance = RewardedAdController._();

  // TODO: replace with your real AdMob rewarded ad unit ID once you've
  // created one (see the setup walkthrough). This is Google's shared test
  // unit ID — it only ever shows test ads, but is safe to ship until then
  // (using a real ad unit ID before it's approved risks a policy strike).
  static const _adUnitId = 'ca-app-pub-3940256099942544/5224354917';

  /// Loads a rewarded ad and shows it, returning true if the user watched
  /// it through to completion and earned the reward, false otherwise
  /// (closed early, failed to load, or failed to show).
  Future<bool> show() async {
    final loadCompleter = Completer<RewardedAd?>();
    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: loadCompleter.complete,
        onAdFailedToLoad: (error) => loadCompleter.complete(null),
      ),
    );
    final ad = await loadCompleter.future;
    if (ad == null) return false;

    final earnedCompleter = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!earnedCompleter.isCompleted) earnedCompleter.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!earnedCompleter.isCompleted) earnedCompleter.complete(false);
      },
    );
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        if (!earnedCompleter.isCompleted) earnedCompleter.complete(true);
      },
    );
    return earnedCompleter.future;
  }
}
