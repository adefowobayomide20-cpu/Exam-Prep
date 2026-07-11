import 'package:flutter/foundation.dart';

/// No-op controller for non-web builds (Android/iOS/desktop). The install
/// button is web-only — native builds are already "installed" by
/// definition — so this never reports availability.
class PwaInstallController extends ChangeNotifier {
  PwaInstallController._();

  static final instance = PwaInstallController._();

  bool get isStandalone => false;
  bool get installAvailable => false;
  bool get isIosSafari => false;

  Future<void> promptInstall() async {}
}
