// See ads_init.dart for why this needs a compile-time conditional export
// rather than a runtime kIsWeb check.
export 'rewarded_ad_stub.dart' if (dart.library.io) 'rewarded_ad_mobile.dart';
