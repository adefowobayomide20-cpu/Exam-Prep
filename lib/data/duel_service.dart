import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/exam/quiz/quiz_question.dart';
import 'models/duel.dart';

class DuelException implements Exception {
  DuelException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Creates, joins, and streams head-to-head duels stored as top-level
/// `duels/{code}` documents (not per-user) so both players can read/write
/// the same doc. The doc id doubles as the short, shareable join code.
class DuelService {
  DuelService._();

  static final DuelService instance = DuelService._();

  static const _codeChars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const _codeLength = 6;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection('duels');

  String _generateCode() {
    final random = Random();
    return List.generate(_codeLength, (_) => _codeChars[random.nextInt(_codeChars.length)]).join();
  }

  Future<Duel> create({
    required String subject,
    required List<QuizQuestion> questions,
    required Duration duration,
    required String hostUid,
    required String hostName,
  }) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode();
      final doc = _collection.doc(code);
      final existing = await doc.get();
      if (existing.exists) continue;

      final duel = Duel(
        id: code,
        subject: subject,
        questions: questions,
        durationSeconds: duration.inSeconds,
        status: DuelStatus.waiting,
        createdAt: DateTime.now(),
        host: DuelPlayerState(uid: hostUid, name: hostName),
      );
      await doc.set(duel.toJson());
      return duel;
    }
    throw DuelException('Could not create a duel right now. Try again.');
  }

  /// Creates a duel with both players already seated — used when a lobby
  /// challenge is accepted, skipping the code-join waiting step.
  Future<Duel> createDirect({
    required String subject,
    required List<QuizQuestion> questions,
    required Duration duration,
    required String hostUid,
    required String hostName,
    required String guestUid,
    required String guestName,
  }) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode();
      final doc = _collection.doc(code);
      final existing = await doc.get();
      if (existing.exists) continue;

      final now = DateTime.now();
      final duel = Duel(
        id: code,
        subject: subject,
        questions: questions,
        durationSeconds: duration.inSeconds,
        status: DuelStatus.active,
        createdAt: now,
        startedAt: now,
        host: DuelPlayerState(uid: hostUid, name: hostName),
        guest: DuelPlayerState(uid: guestUid, name: guestName),
      );
      await doc.set(duel.toJson());
      return duel;
    }
    throw DuelException('Could not create a duel right now. Try again.');
  }

  Stream<Duel?> watch(String code) {
    return _collection.doc(code.toUpperCase()).snapshots().map(
          (snapshot) => snapshot.exists ? Duel.fromJson(snapshot.data()!) : null,
        );
  }

  Future<void> join({
    required String code,
    required String uid,
    required String name,
  }) async {
    final doc = _collection.doc(code.toUpperCase());
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (!snapshot.exists) {
        throw DuelException('No duel found with that code.');
      }
      final duel = Duel.fromJson(snapshot.data()!);
      if (duel.host.uid == uid) {
        throw DuelException("You can't join your own duel.");
      }
      if (duel.guest != null) {
        throw DuelException('This duel already has two players.');
      }
      transaction.update(doc, {
        'guestUid': uid,
        'guestName': name,
        'status': DuelStatus.active.name,
        'startedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> recordProgress({
    required String duelId,
    required bool isHost,
    required int answered,
    required int correct,
    required int points,
  }) {
    final prefix = isHost ? 'host' : 'guest';
    return _collection.doc(duelId).update({
      '${prefix}Answered': answered,
      '${prefix}Correct': correct,
      '${prefix}Points': points,
    });
  }

  /// "Freeze" lifeline: knocks [seconds] off the *opponent's* remaining time.
  /// [isHost] refers to the caller — the penalty is applied to the other side.
  Future<void> freezeOpponent({
    required String duelId,
    required bool isHost,
    int seconds = 10,
  }) {
    final targetPrefix = isHost ? 'guest' : 'host';
    return _collection.doc(duelId).update({
      '${targetPrefix}PenaltySeconds': FieldValue.increment(seconds),
    });
  }

  Future<void> finish({
    required String duelId,
    required bool isHost,
  }) async {
    final doc = _collection.doc(duelId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (!snapshot.exists) return;
      final duel = Duel.fromJson(snapshot.data()!);
      final prefix = isHost ? 'host' : 'guest';
      final update = <String, dynamic>{'${prefix}FinishedAt': DateTime.now().toIso8601String()};

      final otherFinished = isHost ? duel.guest?.isFinished ?? false : duel.host.isFinished;
      if (otherFinished) {
        update['status'] = DuelStatus.finished.name;
      }
      transaction.update(doc, update);
    });
  }
}
