import '../../../core/constants/app_constants.dart';
import 'member_type.dart';
import 'user_entity.dart';

/// Result type for auth operations (avoids throwing exceptions into UI).
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final UserEntity user;
  const AuthSuccess(this.user);
}

class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}

/// Abstract auth repository — defines the contract for auth operations.
abstract interface class AuthRepository {
  /// Log in with [mobileNo] + [password].
  /// Returns [AuthSuccess] or [AuthFailure].
  Future<AuthResult> login({
    required String mobileNo,
    required String password,
  });

  /// Sign up a new Admin.
  /// Returns [AuthSuccess] or [AuthFailure].
  Future<AuthResult> signUpAdmin({
    required String name,
    required String mobileNo,
    required String password,
  });

  /// Sign up a new Member (Customer/Buyer, Investor, or Landowner).
  /// Automatically creates the linked entity record.
  /// Returns [AuthSuccess] or [AuthFailure].
  Future<AuthResult> signUpMember({
    required String name,
    required String mobileNo,
    required String password,
    required MemberType memberType,
  });

  /// Admin creates a member account directly (same as signUpMember but called by admin).
  Future<AuthResult> adminCreateMember({
    required String name,
    required String mobileNo,
    required String password,
    required MemberType memberType,
  });

  /// Reset password for a user identified by [mobileNo].
  Future<AuthResult> resetPassword({
    required String mobileNo,
    required String newPassword,
  });

  /// Change password for a currently-logged-in user.
  Future<AuthResult> changePassword({
    required String userId,
    required String newPassword,
  });

  /// Log out — clears local session.
  Future<void> logout();

  /// Attempt to restore session from local storage.
  /// Returns [UserEntity] if session is valid, null otherwise.
  Future<UserEntity?> restoreSession();

  /// Checks if any admin account exists (for first-run setup).
  Future<bool> hasAnyAdmin();

  /// Fetch user by id.
  Future<UserEntity?> getUserById(String id);

  /// Fetch all members of a given [role] and optional [memberType].
  Future<List<UserEntity>> getMembers({
    UserRole role = UserRole.member,
    MemberType? memberType,
  });
}
