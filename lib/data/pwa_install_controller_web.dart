import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

@JS('pwaInstallAvailable')
external bool _pwaInstallAvailable();

@JS('pwaIsStandalone')
external bool _pwaIsStandalone();

@JS('pwaIsIosSafari')
external bool _pwaIsIosSafari();

@JS('pwaTriggerInstall')
external JSPromise<JSString> _pwaTriggerInstall();

/// Talks to `web/pwa_install.js`, which captures the browser's
/// `beforeinstallprompt` event. Reflects two things the Flutter side can't
/// otherwise see: whether the browser currently has an install prompt ready,
/// and whether this page is already running as the installed app (so the
/// button should never appear there).
class PwaInstallController extends ChangeNotifier {
  PwaInstallController._() {
    _standalone = _pwaIsStandalone();
    _installAvailable = _pwaInstallAvailable();

    web.window.addEventListener(
      'pwa-install-available',
      (web.Event _) {
        _installAvailable = true;
        notifyListeners();
      }.toJS,
    );
    web.window.addEventListener(
      'pwa-installed',
      (web.Event _) {
        _installAvailable = false;
        _standalone = true;
        notifyListeners();
      }.toJS,
    );
  }

  static final instance = PwaInstallController._();

  bool _standalone = false;
  bool _installAvailable = false;
  final bool _iosSafari = _pwaIsIosSafari();

  bool get isStandalone => _standalone;
  bool get installAvailable => _installAvailable;
  bool get isIosSafari => _iosSafari;

  Future<void> promptInstall() async {
    if (!_installAvailable) return;
    await _pwaTriggerInstall().toDart;
    _installAvailable = _pwaInstallAvailable();
    notifyListeners();
  }
}
