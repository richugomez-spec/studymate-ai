import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/services.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/session_service.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final SessionService _sessionService;

  FirebaseAuthRepositoryImpl({
    required FirebaseAuthService authService,
    required SessionService sessionService,
  })  : _authService = authService,
        _sessionService = sessionService;

  @override
  Stream<AppUser?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((fbUser) async {
      if (fbUser == null) {
        await _sessionService.clearSession();
        return null;
      }
      final appUser = _mapFirebaseUser(fbUser);
      final token = await fbUser.getIdToken();
      await _sessionService.saveSession(appUser, token: token);
      return appUser;
    });
  }

  @override
  AppUser? get currentUser {
    final fbUser = _authService.currentUser;
    if (fbUser == null) return null;
    return _mapFirebaseUser(fbUser);
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      final fbUser = credential.user;
      if (fbUser == null) {
        return const Left(Failure.auth(
          message: 'Google Sign-In failed: User profile not retrieved.',
        ));
      }
      final appUser = _mapFirebaseUser(fbUser);
      final token = await fbUser.getIdToken();
      await _sessionService.saveSession(appUser, token: token);
      return Right(appUser);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseCode(e.code, e.message));
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseCode(e.code, e.message));
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' || e.code == '12501') {
        return const Left(Failure.auth(
          code: 'sign_in_canceled',
          message: 'Google Sign-In was cancelled.',
        ));
      }
      return Left(Failure.auth(
        code: e.code,
        message: e.message ?? 'Platform authentication error.',
      ));
    } on SocketException catch (_) {
      return const Left(Failure.network(
        message: 'Network failure. Please check your internet connection.',
      ));
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (str.contains('operation-not-allowed')) {
        return Left(_mapFirebaseCode('operation-not-allowed'));
      }
      if (str.contains('popup-blocked') || str.contains('popup_blocked')) {
        return Left(_mapFirebaseCode('popup-blocked'));
      }
      if (str.contains('unauthorized-domain')) {
        return Left(_mapFirebaseCode('unauthorized-domain'));
      }
      if (str.contains('network') || str.contains('socket') || str.contains('failed host lookup')) {
        return const Left(Failure.network(
          message: 'Network error. Please check your internet connection.',
        ));
      }
      if (str.contains('cancel') || str.contains('aborted') || str.contains('popup_closed') || str.contains('popup-closed')) {
        return const Left(Failure.auth(
          code: 'sign_in_canceled',
          message: 'Google Sign-In was cancelled.',
        ));
      }
      return Left(Failure.auth(
        message: e.toString().replaceAll('Exception: ', '').replaceAll('[firebase_auth/', '').replaceAll(']', ''),
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        return const Left(Failure.auth(
          message: 'Sign in failed. Could not retrieve user account.',
        ));
      }
      final appUser = _mapFirebaseUser(fbUser);
      final token = await fbUser.getIdToken();
      await _sessionService.saveSession(appUser, token: token);
      return Right(appUser);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseCode(e.code, e.message));
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseCode(e.code, e.message));
    } on SocketException catch (_) {
      return const Left(Failure.network(
        message: 'Network connection failure. You appear to be offline.',
      ));
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (str.contains('network') || str.contains('socket') || str.contains('failed host lookup')) {
        return const Left(Failure.network(
          message: 'Network error. Please check your connection.',
        ));
      }
      return Left(Failure.auth(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _authService.createUserWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        return const Left(Failure.auth(
          message: 'Registration failed. User profile could not be created.',
        ));
      }
      final appUser = _mapFirebaseUser(fbUser);
      final token = await fbUser.getIdToken();
      await _sessionService.saveSession(appUser, token: token);
      return Right(appUser);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseCode(e.code, e.message));
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseCode(e.code, e.message));
    } on SocketException catch (_) {
      return const Left(Failure.network(
        message: 'Network connection failure. You appear to be offline.',
      ));
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (str.contains('network') || str.contains('socket') || str.contains('failed host lookup')) {
        return const Left(Failure.network(
          message: 'Network error. Please check your connection.',
        ));
      }
      return Left(Failure.auth(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return const Right(unit);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } on SocketException catch (_) {
      return const Left(Failure.network(
        message: 'Network connection failure. Check your connection.',
      ));
    } catch (e) {
      return Left(Failure.auth(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return const Right(unit);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e) {
      return Left(Failure.auth(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> reloadUser() async {
    try {
      await _authService.reloadUser();
      final updated = currentUser;
      return Right(updated);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e) {
      return Left(Failure.auth(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _authService.signOut();
      await _sessionService.clearSession();
      return const Right(unit);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e) {
      // Still ensure session is cleared locally
      await _sessionService.clearSession();
      return Left(Failure.auth(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> updateProfile(AppUser user) async {
    try {
      final fbUser = _authService.currentUser;
      if (fbUser != null) {
        if (user.displayName != null) {
          await fbUser.updateDisplayName(user.displayName);
        }
        if (user.photoUrl != null) {
          await fbUser.updatePhotoURL(user.photoUrl);
        }
      }
      await _sessionService.saveSession(user);
      return Right(user);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e) {
      return Left(Failure.auth(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      await _authService.deleteAccount();
      await _sessionService.clearSession();
      return const Right(unit);
    } on fb.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e) {
      return Left(Failure.auth(message: e.toString()));
    }
  }

  AppUser _mapFirebaseUser(fb.User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? (user.email != null && user.email!.contains('@') ? user.email!.split('@').first : 'Student'),
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime,
    );
  }

  Failure _mapFirebaseAuthException(fb.FirebaseAuthException e) =>
      _mapFirebaseCode(e.code, e.message);

  Failure _mapFirebaseCode(String rawCode, [String? fallbackMessage]) {
    final code = rawCode
        .replaceAll('auth/', '')
        .replaceAll('firebase_auth/', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim()
        .toLowerCase();

    return switch (code) {
      'api-key-not-valid' || 'api-key-not-valid.-please-pass-a-valid-api-key.' =>
        const Failure.auth(
          code: 'api-key-not-valid',
          message: 'Firebase API key is invalid. Please verify firebase_options.dart.',
        ),
      'invalid-email' => const Failure.auth(
          code: 'invalid-email',
          message: 'The email address format is invalid.',
        ),
      'user-not-found' => const Failure.auth(
          code: 'user-not-found',
          message: 'No account found with this email address.',
        ),
      'wrong-password' => const Failure.auth(
          code: 'wrong-password',
          message: 'Incorrect password. Please try again.',
        ),
      'invalid-credential' => const Failure.auth(
          code: 'invalid-credential',
          message: 'Invalid email or password. Please verify your credentials.',
        ),
      'email-already-in-use' => const Failure.auth(
          code: 'email-already-in-use',
          message: 'An account already exists with this email address.',
        ),
      'weak-password' => const Failure.auth(
          code: 'weak-password',
          message: 'Password is too weak. Please use at least 6 characters.',
        ),
      'user-disabled' => const Failure.auth(
          code: 'user-disabled',
          message: 'This user account has been disabled. Please contact support.',
        ),
      'operation-not-allowed' => const Failure.auth(
          code: 'operation-not-allowed',
          message:
              'Google Sign-In is not enabled yet in your Firebase Console. Make sure you clicked Save in the Google provider setup.',
        ),
      'too-many-requests' => const Failure.auth(
          code: 'too-many-requests',
          message: 'Too many unsuccessful attempts. Please try again later.',
        ),
      'network-request-failed' => const Failure.network(
          message: 'Network error. Please check your internet connection and try again.',
        ),
      'sign_in_canceled' || 'error_aborted_by_user' || 'popup-closed-by-user' =>
        const Failure.auth(
          code: 'sign_in_canceled',
          message: 'Google Sign-In was cancelled.',
        ),
      'popup-blocked' => const Failure.auth(
          code: 'popup-blocked',
          message:
              'The popup was blocked by your browser. Please click the popup icon in your address bar and allow popups for localhost.',
        ),
      'unauthorized-domain' => const Failure.auth(
          code: 'unauthorized-domain',
          message:
              'This domain is not authorized. In Firebase Console → Authentication → Settings, add your current domain.',
        ),
      _ => Failure.auth(
          code: code,
          message: fallbackMessage ?? 'Authentication error occurred ($code).',
        ),
    };
  }
}
