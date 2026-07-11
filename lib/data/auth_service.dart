import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] so the rest of the app depends on a
/// single seam rather than the Firebase SDK directly.
class AuthService {
  AuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  /// Mutable so tests can swap in a fake [FirebaseAuth] before first use.
  static AuthService instance = AuthService();

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> signUp({required String email, required String password, String? name}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (name != null && name.isNotEmpty) {
      await credential.user?.updateDisplayName(name);
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  /// Firebase requires a recent sign-in before password/email changes or
  /// account deletion; re-authenticating with the current password
  /// satisfies that without forcing a full logout/login cycle.
  Future<void> reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(code: 'no-current-user', message: 'No signed-in account.');
    }
    final credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  /// Sends a verification link to [newEmail]; the address only changes once
  /// the student clicks it, so there is no immediate return value to check.
  Future<void> changeEmail(String newEmail) async {
    await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail.trim());
  }

  /// Deletes the Firebase Auth account. A Cloud Function trigger cleans up
  /// the corresponding Firestore data (see functions/cleanup.js).
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Maps a [FirebaseAuthException] code to a short, user-facing message.
  static String messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'network-request-failed':
        return 'Network error — check your connection and try again.';
      case 'requires-recent-login':
        return 'Please re-enter your password to confirm this change.';
      case 'no-current-user':
        return 'No signed-in account.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
}
