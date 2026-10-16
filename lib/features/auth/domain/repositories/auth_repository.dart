import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Stream of auth state changes
  Stream<AppUser?> get authStateChanges;

  /// Current signed-in user (null if not authenticated)
  AppUser? get currentUser;

  /// Sign in with Google
  Future<Either<Failure, AppUser>> signInWithGoogle();

  /// Sign in with email & password
  Future<Either<Failure, AppUser>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Register with email & password
  Future<Either<Failure, AppUser>> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign out
  Future<Either<Failure, Unit>> signOut();

  /// Update user profile
  Future<Either<Failure, AppUser>> updateProfile(AppUser user);

  /// Send password reset email
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);

  /// Send email verification to current user
  Future<Either<Failure, Unit>> sendEmailVerification();

  /// Reload user details from auth provider
  Future<Either<Failure, AppUser?>> reloadUser();

  /// Delete account and all data
  Future<Either<Failure, Unit>> deleteAccount();
}
