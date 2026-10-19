import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../../services/firestore_service.dart';
import '../../data/repositories/firebase_auth_repository_impl.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/session_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

/// Provider for raw Firebase Auth service
final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Provider for secure session storage service
final sessionServiceProvider = Provider<SessionService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SessionService(secureStorage);
});

/// Production Authentication Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepositoryImpl(
    authService: ref.watch(authServiceProvider),
    sessionService: ref.watch(sessionServiceProvider),
  );
});

/// Stream of auth state changes directly from Firebase
@riverpod
Stream<AppUser?> authState(AuthStateRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

/// Synchronously and reactively access currently authenticated user from live auth stream
final currentUserProvider = Provider<AppUser?>((ref) {
  final authStreamAsync = ref.watch(authStateProvider);
  return authStreamAsync.asData?.value ?? ref.watch(authRepositoryProvider).currentUser;
});

/// Auth mutation notifier for performing real backend authentication
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<AppUser?> build() {
    final user = ref.watch(authRepositoryProvider).currentUser;
    return AsyncValue.data(user);
  }

  /// Sign in with Google (Native Mobile or Web Popup)
  /// Returns null on success, or an error message string on failure
  Future<String?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithGoogle();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = AsyncValue.data(user);
        // Persist/sync user document to Firestore
        final firestoreService = ref.read(firestoreServiceProvider);
        firestoreService.syncUserOnAuth(
          uid: user.id,
          email: user.email,
          name: user.displayName,
          photoUrl: user.photoUrl,
        );
        return null;
      },
    );
  }

  /// Sign in with Email and Password
  /// Returns null on success, or an error message string on failure
  Future<String?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithEmailPassword(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = AsyncValue.data(user);
        // Sync user document to Firestore
        final firestoreService = ref.read(firestoreServiceProvider);
        firestoreService.syncUserOnAuth(
          uid: user.id,
          email: user.email,
          name: user.displayName,
          photoUrl: user.photoUrl,
        );
        return null;
      },
    );
  }

  /// Register with Email and Password
  /// Returns null on success, or an error message string on failure
  Future<String?> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.registerWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName ?? (email.contains('@') ? email.split('@').first : 'Student'),
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = AsyncValue.data(user);
        // Sync user document to Firestore
        final firestoreService = ref.read(firestoreServiceProvider);
        firestoreService.syncUserOnAuth(
          uid: user.id,
          email: user.email,
          name: user.displayName,
          photoUrl: user.photoUrl,
        );
        return null;
      },
    );
  }

  /// Send password reset link to given email
  /// Returns null on success, or an error message string on failure
  Future<String?> sendPasswordResetEmail(String email) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.sendPasswordResetEmail(email);

    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }

  /// Send email verification to current user
  /// Returns null on success, or an error message string on failure
  Future<String?> sendEmailVerification() async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.sendEmailVerification();

    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }

  /// Reload user details
  Future<void> reloadUser() async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.reloadUser();
    result.fold(
      (_) {},
      (user) {
        if (user != null) {
          state = AsyncValue.data(user);
        }
      },
    );
  }

  /// Sign out completely, clearing Firebase Auth and secure session storage
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    state = const AsyncValue.data(null);
  }
}
