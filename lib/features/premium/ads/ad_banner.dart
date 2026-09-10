// See ads_init.dart for why this needs a compile-time conditional export
// rather than a runtime kIsWeb check. Both branches export a widget named
// AdBannerWidget with the same no-argument constructor, so call sites don't
// need to know which platform they're on. Web (the default/fallback branch)
// gets a real ad too — an embedded AdSense unit — not a no-op stub, unlike
// the rewarded-ad case.
export 'ad_banner_web.dart' if (dart.library.io) 'ad_banner_mobile.dart';
