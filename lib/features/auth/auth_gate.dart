import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../navigation/main_nav_shell.dart';
import '../duel/duel_deep_link_listener.dart';
import '../duel/lobby/incoming_challenge_listener.dart';

/// There is no login screen. This always shows the main app immediately
/// and quietly signs the device in anonymously in the background (retrying
/// on failure) so Firestore-backed features (Duel, Tutor, profile sync)
/// come online once that succeeds — the student never sees or waits on it.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<User?>? _authSub;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    if (AuthService.instance.currentUser == null) {
      _ensureSignedIn();
    }
    // Signs back in if the account is ever deleted (e.g. "Delete all data"
    // in Profile) so the app is never left without a uid to key data off.
    _authSub = AuthService.instance.authStateChanges.listen((user) {
      if (user == null) _ensureSignedIn();
    });
  }

  Future<void> _ensureSignedIn() async {
    if (_signingIn) return;
    _signingIn = true;
    try {
      await AuthService.instance.signInAnonymously();
    } catch (error, stackTrace) {
      debugPrint('Anonymous sign-in failed, retrying in 5s: $error\n$stackTrace');
      await Future.delayed(const Duration(seconds: 5));
      _signingIn = false;
      if (mounted) _ensureSignedIn();
      return;
    }
    _signingIn = false;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const DuelDeepLinkListener(
      child: IncomingChallengeListener(child: MainNavShell()),
    );
  }
}
