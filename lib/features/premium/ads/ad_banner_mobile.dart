import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// TODO: replace with your real AdMob banner ad unit ID once you've created
// one (see the setup walkthrough). This is Google's shared test unit ID —
// safe to ship until then, but only ever shows test ads.
const _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

/// Standard AdMob banner, shown to non-Premium users. See ad_banner.dart for
/// why this file is only ever compiled into native (Android/iOS) builds.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    final ad = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _ad = ad as BannerAd),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
