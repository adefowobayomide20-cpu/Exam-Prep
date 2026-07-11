import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/exam/exam_types.dart';
import 'models/challenge.dart';
import 'models/lobby_presence.dart';

/// Presence and challenge matchmaking for school-scoped duel lobbies.
/// Presence lives at `lobbies/{school}/members/{uid}`; challenges are
/// top-level at `challenges/{id}` so both sender and recipient can read them.
class LobbyService {
  LobbyService._();

  static final LobbyService instance = LobbyService._();

  /// A member's heartbeat older than this is treated as offline rather than
  /// deleted outright — avoids a write on every tab close/crash.
  static const onlineWindow = Duration(seconds: 45);

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _members(String school) =>
      _firestore.collection('lobbies').doc(school).collection('members');

  CollectionReference<Map<String, dynamic>> get _challenges => _firestore.collection('challenges');

  Future<void> heartbeat({required String school, required String uid, required String name}) {
    final presence = LobbyPresence(uid: uid, name: name, school: school, lastActiveAt: DateTime.now());
    return _members(school).doc(uid).set(presence.toJson());
  }

  Future<void> leave({required String school, required String uid}) {
    return _members(school).doc(uid).delete();
  }

  Stream<List<LobbyPresence>> watchOnline({required String school, required String selfUid}) {
    return _members(school).snapshots().map((snapshot) {
      final cutoff = DateTime.now().subtract(onlineWindow);
      return snapshot.docs
          .map((doc) => LobbyPresence.fromJson(doc.data()))
          .where((member) => member.uid != selfUid && member.lastActiveAt.isAfter(cutoff))
          .toList();
    });
  }

  Future<String> sendChallenge({
    required String fromUid,
    required String fromName,
    required String toUid,
    required String toName,
    required String school,
    required String subject,
    required ExamCategory examCategory,
  }) async {
    final doc = _challenges.doc();
    final challenge = Challenge(
      id: doc.id,
      fromUid: fromUid,
      fromName: fromName,
      toUid: toUid,
      toName: toName,
      school: school,
      subject: subject,
      examCategory: examCategory,
      status: ChallengeStatus.pending,
      createdAt: DateTime.now(),
    );
    await doc.set(challenge.toJson());
    return doc.id;
  }

  /// Incoming pending challenges for [uid], newest first.
  Stream<List<Challenge>> watchIncomingChallenges(String uid) {
    return _challenges
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: ChallengeStatus.pending.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => Challenge.fromJson(doc.data())).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<void> respond({required String challengeId, required ChallengeStatus status, String? duelId}) {
    return _challenges.doc(challengeId).update({
      'status': status.name,
      if (duelId != null) 'duelId': duelId,
    });
  }

  /// Watches a single challenge (used by the sender to notice when the
  /// recipient accepts/declines, since [watchIncomingChallenges] only
  /// surfaces challenges to the recipient).
  Stream<Challenge?> watchChallenge(String challengeId) {
    return _challenges.doc(challengeId).snapshots().map(
          (doc) => doc.exists ? Challenge.fromJson(doc.data()!) : null,
        );
  }
}
