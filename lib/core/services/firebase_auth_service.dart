import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ─── Firebase Auth Service ─────────────────────────────────────────────────
/// Wraps FirebaseAuth for sign-up and login with email/password.
/// Throws [FirebaseAuthException] on failure — the caller (AuthController)
/// converts these into user-friendly error messages.

class FirebaseAuthService {
  FirebaseAuthService(this._auth);
  final FirebaseAuth _auth;

  /// Create a new account. Returns [UserCredential] with the Firebase UID.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign in an existing user.
  Future<UserCredential> logInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// The currently signed-in user (or null).
  User? get currentUser => _auth.currentUser;
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(FirebaseAuth.instance);
});
