import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'models/tutor_message.dart';

/// Backs the "Snap & Solve" tutor chat: a single ongoing conversation per
/// user, persisted under `users/{uid}/tutorMessages`. Sending a message
/// calls the `solveQuestion` Cloud Function, which forwards the photo and
/// recent history to Claude and returns an explanation.
class TutorChatStore extends ChangeNotifier {
  TutorChatStore._();

  static final TutorChatStore instance = TutorChatStore._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  String? _uid;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  List<TutorMessage> _messages = [];
  bool _sending = false;
  String? _error;

  List<TutorMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;
  String? get error => _error;

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _uid == null ? null : _firestore.collection('users').doc(_uid).collection('tutorMessages');

  void bindToUser(String uid) {
    if (_uid == uid) return;
    unbind();
    _uid = uid;

    _sub = _firestore
        .collection('users')
        .doc(uid)
        .collection('tutorMessages')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs.map((doc) => TutorMessage.fromJson(doc.data())).toList();
      notifyListeners();
    });
  }

  void unbind() {
    _sub?.cancel();
    _sub = null;
    _uid = null;
    _messages = [];
    _sending = false;
    _error = null;
    notifyListeners();
  }

  Future<void> sendPhoto({
    required String imageBase64,
    required String mimeType,
    String? question,
  }) async {
    final collection = _collection;
    if (collection == null) return;

    _sending = true;
    _error = null;
    notifyListeners();

    final studentMessage = TutorMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: TutorSender.student,
      text: (question == null || question.trim().isEmpty)
          ? 'Please solve and explain this question.'
          : question.trim(),
      createdAt: DateTime.now(),
      imageBytesBase64: imageBase64,
    );

    try {
      await collection.doc(studentMessage.id).set(studentMessage.toJson());

      final history = _messages
          .take(10)
          .map((m) => {
                'role': m.sender == TutorSender.student ? 'user' : 'assistant',
                'text': m.text,
              })
          .toList();

      final result = await _functions.httpsCallable('solveQuestion').call<Map<String, dynamic>>({
        'imageBase64': imageBase64,
        'mimeType': mimeType,
        'question': question,
        'history': history,
      });

      final replyText = result.data['text'] as String? ?? "Sorry, I couldn't process that.";
      final tutorMessage = TutorMessage(
        id: '${studentMessage.id}_reply',
        sender: TutorSender.tutor,
        text: replyText,
        createdAt: DateTime.now(),
      );
      await collection.doc(tutorMessage.id).set(tutorMessage.toJson());
    } catch (e) {
      _error = 'Could not get a response. Check your connection and try again.';
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
