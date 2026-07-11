import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../navigation/main_nav_shell.dart';
import '../duel/duel_deep_link_listener.dart';
import '../duel/lobby/incoming_challenge_listener.dart';
import 'loading_screen.dart';
import 'login_page.dart';

/// Shows [LoginPage] until a user is signed in, then shows the main app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        final Widget child;
        if (snapshot.connectionState == ConnectionState.waiting) {
          child = const LoadingScreen(key: ValueKey('loading'));
        } else if (snapshot.data == null) {
          child = const LoginPage(key: ValueKey('login'));
        } else {
          child = const DuelDeepLinkListener(
            key: ValueKey('main'),
            child: IncomingChallengeListener(child: MainNavShell()),
          );
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: child,
        );
      },
    );
  }
}
