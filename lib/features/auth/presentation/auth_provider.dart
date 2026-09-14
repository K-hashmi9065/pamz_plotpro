import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/hive_service.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/member_type.dart';
import '../domain/user_entity.dart';

export '../../../core/database/database_provider.dart';
import '../../../core/database/database_provider.dart';

// ── Repository Provider ──────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AuthRepositoryImpl(db);
});

// ── Auth State ───────────────────────────────────────────────────────────────

/// The authentication state of the app.
sealed class AuthState {
  const AuthState();
}

/// Initial loading state — restoring session from Hive.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// No authenticated user — show login screen.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// First-run — no admin exists yet.
class AuthFirstRun extends AuthState {
  const AuthFirstRun();
}

/// A user is authenticated.
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

/// Error state with message.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ── Auth Notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<AuthState> build() async {
    // Ensure HiveService is initialized
    await HiveService.init();

    // Check for first-run (no admin yet)
    final hasAdmin = await _repo.hasAnyAdmin();
    if (!hasAdmin) {
      return const AuthFirstRun();
    }

    // Try to restore session
    final user = await _repo.restoreSession();
    if (user != null && user.isActive) {
      return AuthAuthenticated(user);
    }

    return const AuthUnauthenticated();
  }

  /// Log in with mobile + password.
  Future<String?> login({
    required String mobileNo,
    required String password,
  }) async {
    state = const AsyncData(AuthLoading());
    final result = await _repo.login(mobileNo: mobileNo, password: password);
    switch (result) {
      case AuthSuccess(:final user):
        state = AsyncData(AuthAuthenticated(user));
        return null;
      case AuthFailure(:final message):
        state = AsyncData(AuthError(message));
        return message;
    }
  }

  /// Sign up admin account.
  Future<String?> signUpAdmin({
    required String name,
    required String mobileNo,
    required String password,
  }) async {
    state = const AsyncData(AuthLoading());
    final result = await _repo.signUpAdmin(
        name: name, mobileNo: mobileNo, password: password);
    switch (result) {
      case AuthSuccess(:final user):
        state = AsyncData(AuthAuthenticated(user));
        return null;
      case AuthFailure(:final message):
        state = const AsyncData(AuthUnauthenticated());
        return message;
    }
  }

  /// Sign up member account.
  Future<String?> signUpMember({
    required String name,
    required String mobileNo,
    required String password,
    required MemberType memberType,
  }) async {
    state = const AsyncData(AuthLoading());
    final result = await _repo.signUpMember(
      name: name,
      mobileNo: mobileNo,
      password: password,
      memberType: memberType,
    );
    switch (result) {
      case AuthSuccess(:final user):
        state = AsyncData(AuthAuthenticated(user));
        return null;
      case AuthFailure(:final message):
        state = const AsyncData(AuthUnauthenticated());
        return message;
    }
  }

  /// Admin creates a member account (does not change current auth state).
  Future<String?> adminCreateMember({
    required String name,
    required String mobileNo,
    required String password,
    required MemberType memberType,
  }) async {
    final result = await _repo.adminCreateMember(
      name: name,
      mobileNo: mobileNo,
      password: password,
      memberType: memberType,
    );
    switch (result) {
      case AuthSuccess():
        return null;
      case AuthFailure(:final message):
        return message;
    }
  }

  /// Reset password by mobile number (forgot password flow).
  Future<String?> resetPasswordByMobile({
    required String mobileNo,
    required String newPassword,
  }) async {
    final result =
        await _repo.resetPassword(mobileNo: mobileNo, newPassword: newPassword);
    switch (result) {
      case AuthSuccess():
        return null;
      case AuthFailure(:final message):
        return message;
    }
  }

  /// Change password for currently logged-in user.
  Future<String?> changePasswordForCurrentUser({
    required String newPassword,
  }) async {
    final current = state.valueOrNull;
    if (current is! AuthAuthenticated) {
      return 'Not logged in.';
    }
    final result = await _repo.changePassword(
      userId: current.user.id,
      newPassword: newPassword,
    );
    switch (result) {
      case AuthSuccess(:final user):
        state = AsyncData(AuthAuthenticated(user));
        return null;
      case AuthFailure(:final message):
        return message;
    }
  }

  /// Log out the current user.
  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(AuthUnauthenticated());
  }

  /// Clear error and go back to unauthenticated.
  void clearError() {
    state = const AsyncData(AuthUnauthenticated());
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Convenience derived provider — the currently authenticated user (or null).
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authProvider).valueOrNull;
  if (authState is AuthAuthenticated) return authState.user;
  return null;
});

/// Derived provider for the current user's role (falls back to member if not logged in).
final currentUserRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(currentUserProvider)?.role ?? UserRole.member;
});
