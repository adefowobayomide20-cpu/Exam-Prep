import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'models/app_notification.dart';

/// In-app notification center: keeps a per-user history of news alerts,
/// study-reminder pings, and system messages, synced with Firestore under
/// `users/{uid}/notifications`. Bound/unbound alongside [AppDataStore] in
/// response to auth state (see main.dart).
class NotificationStore extends ChangeNotifier {
  NotificationStore._();

  static final NotificationStore instance = NotificationStore._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? _uid;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.read).length;

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _uid == null ? null : _firestore.collection('users').doc(_uid).collection('notifications');

  void bindToUser(String uid) {
    if (_uid == uid) return;
    unbind();
    _uid = uid;

    _sub = _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) => AppNotification.fromJson(doc.data())).toList();
      notifyListeners();
    });
  }

  void unbind() {
    _sub?.cancel();
    _sub = null;
    _uid = null;
    _notifications = [];
    notifyListeners();
  }

  Future<void> add(AppNotification notification) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(notification.id).set(notification.toJson());
  }

  Future<void> markRead(String id) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(id).set({'read': true}, SetOptions(merge: true));
  }

  Future<void> markAllRead() async {
    final collection = _collection;
    if (collection == null) return;
    final batch = _firestore.batch();
    for (final notification in _notifications.where((n) => !n.read)) {
      batch.set(collection.doc(notification.id), {'read': true}, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
