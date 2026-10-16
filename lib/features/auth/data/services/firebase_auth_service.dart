import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Real backend authentication service communicating directly with Firebase Authentication
/// and Google Sign-In.
class FirebaseAuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
            );

  /// Real-time stream of Firebase user authentication changes
  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Currently authenticated Firebase user
  fb.User? get currentUser => _firebaseAuth.currentUser;

  /// Sign in using Email and Password
  Future<fb.UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Register new user using Email and Password
  Future<fb.UserCredential> createUserWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (displayName != null && displayName.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(displayName.trim());
    }

    // Automatically trigger email verification for new registrations
    await credential.user?.sendEmailVerification();

    return credential;
  }

  /// Authenticate with Google (supports both Web popup and Mobile native sign-in)
  Future<fb.UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = fb.GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      try {
        return await _firebaseAuth.signInWithPopup(googleProvider);
      } catch (e) {
        debugPrint('[FirebaseAuthService] Google Sign-In error: $e');
        rethrow;
      }
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw fb.FirebaseAuthException(
          code: 'sign_in_canceled',
          message: 'Google Sign In was cancelled.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    }
  }

  /// Send password reset link to user's registered email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  /// Send verification email to currently signed-in user
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw fb.FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user to verify.',
      );
    }
    await user.sendEmailVerification();
  }

  /// Refresh user token and verification status from Firebase
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  /// Sign out completely from Firebase and Google Sign-In
  Future<void> signOut() async {
    try {
      if (!kIsWeb && await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Ignore Google Sign-In cleanup errors during sign out
    }
    await _firebaseAuth.signOut();
  }

  /// Delete current user account from Firebase Authentication
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw fb.FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user found.',
      );
    }
    await user.delete();
  }
}
