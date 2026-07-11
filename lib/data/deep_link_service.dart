import 'dart:async';

import 'package:app_links/app_links.dart';

/// The public host used for shareable links (e.g. duel invites).
const duelLinkHost = 'www.examcoach.com.ng';

/// Listens for incoming https://www.examcoach.com.ng/duel/<code> links
/// (Android App Links / iOS Universal Links) and surfaces the duel code
/// to whoever is listening, whether the app was already running or was
/// cold-started from the link.
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  final _appLinks = AppLinks();
  final _duelCodeController = StreamController<String>.broadcast();
  StreamSubscription<Uri>? _subscription;

  /// The most recently received duel code, if any. Consumers that mount
  /// after the link arrived (e.g. because the user wasn't signed in yet)
  /// should check this in addition to [duelCodeStream].
  String? pendingCode;

  /// Emits a duel code every time a duel invite link is opened.
  Stream<String> get duelCodeStream => _duelCodeController.stream;

  Future<void> init() async {
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);
  }

  /// Clears the pending code once it's been consumed, so it isn't replayed
  /// (e.g. re-joining the same duel after signing out and back in).
  void consumePendingCode() => pendingCode = null;

  void _handleUri(Uri uri) {
    final code = duelCodeFromUri(uri);
    if (code != null) {
      pendingCode = code;
      _duelCodeController.add(code);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _duelCodeController.close();
  }
}

/// Extracts the duel code from a URI shaped like
/// https://www.examcoach.com.ng/duel/<code>, or null if it doesn't match.
String? duelCodeFromUri(Uri uri) {
  final segments = uri.pathSegments;
  if (segments.length != 2 || segments[0] != 'duel') return null;
  final code = segments[1].trim();
  return code.isEmpty ? null : code.toUpperCase();
}
