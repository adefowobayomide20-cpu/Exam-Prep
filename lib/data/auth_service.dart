import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] so the rest of the app depends on a
/// single seam rather than the Firebase SDK directly.
///
/// The app has no login UI — every install signs in anonymously so
/// per-user Firestore data (profile, quiz history, duels) still works
/// without asking the student to create an account.
class AuthService {
  AuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  /// Mutable so tests can swap in a fake [FirebaseAuth] before first use.
  static AuthService instance = AuthService();

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInAnonymously() => _auth.signInAnonymously();

  /// Permanently deletes the anonymous account. A Cloud Function trigger
  /// cleans up the corresponding Firestore data (see functions/cleanup.js).
  /// There's no re-auth path for an anonymous user, so this is attempted
  /// directly; a `requires-recent-login` failure means the session is too
  /// old for Firebase to allow deletion without reauthentication, which
  /// isn't possible for an anonymous account — see [messageFor].
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Maps a [FirebaseAuthException] code to a short, user-facing message.
  static String messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
        return 'Network error — check your connection and try again.';
      case 'requires-recent-login':
        return "This session is too old to delete directly — reinstall the app to start fresh instead.";
      case 'no-current-user':
        return 'No signed-in account.';
      case 'operation-not-allowed':
      case 'admin-restricted-operation':
        return 'Sign-in is temporarily unavailable. Please try again shortly.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
}
