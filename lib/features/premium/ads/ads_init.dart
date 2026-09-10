// google_mobile_ads has no web platform support at all (its pubspec only
// declares android/ios), so the mobile implementation must never even be
// compiled into a web build — a runtime `if (kIsWeb)` guard isn't enough,
// since the import itself would still need to compile for web. This
// conditional export resolves at compile time per target instead: native
// builds (`dart.library.io` is true) get the real google_mobile_ads-backed
// file, web gets a no-op stub.
export 'ads_init_stub.dart' if (dart.library.io) 'ads_init_mobile.dart';
