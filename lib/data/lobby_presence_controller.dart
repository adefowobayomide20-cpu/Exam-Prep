import 'dart:async';

import '../features/exam/post_jamb_schools.dart';
import 'app_data_store.dart';
import 'lobby_service.dart';

/// Keeps the signed-in user's presence heartbeat alive in their home school
/// lobby (`AppDataStore.profile.school`, defaulting to the first Post-UTME
/// school if unset) for as long as the app is open — not just while they
/// have the School Lobby screen open. This is what lets anyone who opens
/// "Find an Opponent" see every online student from that school, whether or
/// not the other person has ever opened the lobby themselves.
///
/// Paused (and presence removed) while the user is inside an active duel
/// session — see [enterDuel]/[exitDuel], called from DuelSessionPage — so
/// students mid-duel don't show up as available to challenge.
class LobbyPresenceController {
  LobbyPresenceController._();

  static final LobbyPresenceController instance = LobbyPresenceController._();

  static const _heartbeatInterval = Duration(seconds: 20);

  String? _uid;
  String? _school;
  Timer? _timer;
  bool _inDuel = false;

  void bindToUser(String uid) {
    _uid = uid;
    AppDataStore.instance.addListener(_onProfileChanged);
    _onProfileChanged();
  }

  void unbind() {
    AppDataStore.instance.removeListener(_onProfileChanged);
    _stopHeartbeat(leave: true);
    _uid = null;
    _school = null;
  }

  /// Suppresses presence for the duration of an active duel.
  void enterDuel() {
    _inDuel = true;
    _stopHeartbeat(leave: true);
  }

  void exitDuel() {
    _inDuel = false;
    _restart();
  }

  void _onProfileChanged() {
    final resolved = AppDataStore.instance.profile.school ?? postJambSchools.first.shortName;
    if (resolved == _school) return;
    final uid = _uid;
    final previousSchool = _school;
    _school = resolved;
    if (uid != null && previousSchool != null && !_inDuel) {
      LobbyService.instance.leave(school: previousSchool, uid: uid);
    }
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    _timer = null;
    if (_uid == null || _school == null || _inDuel) return;
    _beat();
    _timer = Timer.periodic(_heartbeatInterval, (_) => _beat());
  }

  void _beat() {
    final uid = _uid;
    final school = _school;
    if (uid == null || school == null) return;
    LobbyService.instance.heartbeat(school: school, uid: uid, name: AppDataStore.instance.profile.name);
  }

  void _stopHeartbeat({bool leave = false}) {
    _timer?.cancel();
    _timer = null;
    final uid = _uid;
    final school = _school;
    if (leave && uid != null && school != null) {
      LobbyService.instance.leave(school: school, uid: uid);
    }
  }
}
