import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/storage/hive_service.dart';
import '../domain/auth_repository.dart';
import '../domain/member_type.dart';
import '../domain/user_entity.dart';

/// Drift + Hive backed implementation of [AuthRepository].
/// Security: SHA-256(salt + password) with per-user 32-byte random salt.
class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  AuthRepositoryImpl(this._db);

  // ── Password Hashing ────────────────────────────────────────────────────────

  /// Generates a cryptographically random 32-byte hex salt.
  static String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Hashes [password] with [salt] using SHA-256.
  static String _hashPassword(String password, String salt) {
    final combined = utf8.encode('$salt$password');
    return sha256.convert(combined).toString();
  }

  // ── Row → Entity mapping ────────────────────────────────────────────────────

  UserEntity _rowToEntity(User row) {
    final role = row.role == 'admin' ? UserRole.admin : UserRole.member;
    MemberType? memberType;
    if (row.memberType != null) {
      try {
        memberType = MemberTypeX.fromDb(row.memberType!);
      } catch (_) {}
    }
    return UserEntity(
      id: row.id,
      name: row.name,
      mobileNo: row.mobileNo,
      username: row.username,
      role: role,
      isActive: row.isActive,
      createdAt: row.createdAt,
      memberType: memberType,
      linkedEntityId: row.linkedEntityId,
    );
  }

  // ── Auth Operations ─────────────────────────────────────────────────────────

  @override
  Future<AuthResult> login({
    required String mobileNo,
    required String password,
  }) async {
    try {
      final trimmed = mobileNo.trim();
      final row = await (_db.select(_db.users)
            ..where((u) => u.mobileNo.equals(trimmed))
            ..where((u) => u.isActive.equals(true)))
          .getSingleOrNull();

      if (row == null) {
        return const AuthFailure('No account found with this mobile number.');
      }

      final hash = _hashPassword(password, row.salt);
      if (hash != row.passwordHash) {
        return const AuthFailure('Incorrect password. Please try again.');
      }

      final entity = _rowToEntity(row);

      // Persist session to Hive
      await HiveService.saveUserSession(
        userId: entity.id,
        username: entity.name,
        role: entity.role.name,
        memberType: entity.memberType?.dbValue,
      );

      return AuthSuccess(entity);
    } catch (e) {
      return AuthFailure('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> signUpAdmin({
    required String name,
    required String mobileNo,
    required String password,
  }) async {
    return _createUser(
      name: name,
      mobileNo: mobileNo,
      password: password,
      role: UserRole.admin,
      memberType: null,
    );
  }

  @override
  Future<AuthResult> signUpMember({
    required String name,
    required String mobileNo,
    required String password,
    required MemberType memberType,
  }) async {
    return _createUser(
      name: name,
      mobileNo: mobileNo,
      password: password,
      role: UserRole.member,
      memberType: memberType,
    );
  }

  @override
  Future<AuthResult> adminCreateMember({
    required String name,
    required String mobileNo,
    required String password,
    required MemberType memberType,
  }) async {
    return _createUser(
      name: name,
      mobileNo: mobileNo,
      password: password,
      role: UserRole.member,
      memberType: memberType,
    );
  }

  Future<AuthResult> _createUser({
    required String name,
    required String mobileNo,
    required String password,
    required UserRole role,
    required MemberType? memberType,
  }) async {
    try {
      final trimmedMobile = mobileNo.trim();
      final trimmedName = name.trim();

      if (trimmedMobile.isEmpty) {
        return const AuthFailure('Mobile number is required.');
      }
      if (trimmedName.isEmpty) {
        return const AuthFailure('Name is required.');
      }
      if (password.length < 6) {
        return const AuthFailure('Password must be at least 6 characters.');
      }

      // Check mobile uniqueness
      final existing = await (_db.select(_db.users)
            ..where((u) => u.mobileNo.equals(trimmedMobile)))
          .getSingleOrNull();
      if (existing != null) {
        return const AuthFailure(
            'An account with this mobile number already exists.');
      }

      final id = _uuid.v4();
      final salt = _generateSalt();
      final hash = _hashPassword(password, salt);

      // Create linked entity record for members
      String? linkedEntityId;
      if (role == UserRole.member && memberType != null) {
        linkedEntityId = await _createLinkedEntity(
          id: _uuid.v4(),
          name: trimmedName,
          phone: trimmedMobile,
          memberType: memberType,
        );
      }

      await _db.into(_db.users).insert(
            UsersCompanion.insert(
              id: id,
              name: Value(trimmedName),
              mobileNo: Value(trimmedMobile),
              username: Value(trimmedMobile),
              email: const Value(''),
              passwordHash: hash,
              salt: Value(salt),
              role: role.name,
              memberType: Value(memberType?.dbValue),
              linkedEntityId: Value(linkedEntityId),
            ),
          );

      final row = await (_db.select(_db.users)
            ..where((u) => u.id.equals(id)))
          .getSingle();

      return AuthSuccess(_rowToEntity(row));
    } on Exception catch (e) {
      return AuthFailure('Sign-up failed: ${e.toString()}');
    }
  }

  /// Creates or links the entity (Buyer/Investor/Landowner) row and returns its id.
  Future<String> _createLinkedEntity({
    required String id,
    required String name,
    required String phone,
    required MemberType memberType,
  }) async {
    final trimmedName = name.trim().toLowerCase();
    switch (memberType) {
      case MemberType.customerBuyer:
        final allBuyers = await _db.select(_db.buyers).get();
        for (final b in allBuyers) {
          if (_phoneMatches(b.phone, phone) ||
              b.name.trim().toLowerCase() == trimmedName) {
            return b.id;
          }
        }
        await _db.into(_db.buyers).insert(
              BuyersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
              ),
            );
      case MemberType.investor:
        final allInvestors = await _db.select(_db.investors).get();
        for (final i in allInvestors) {
          if (_phoneMatches(i.phone, phone) ||
              i.name.trim().toLowerCase() == trimmedName) {
            return i.id;
          }
        }
        await _db.into(_db.investors).insert(
              InvestorsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
              ),
            );
      case MemberType.landowner:
        final allLandowners = await _db.select(_db.landowners).get();
        for (final l in allLandowners) {
          if (_phoneMatches(l.phone, phone) ||
              l.name.trim().toLowerCase() == trimmedName) {
            return l.id;
          }
        }
        await _db.into(_db.landowners).insert(
              LandownersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
              ),
            );
    }
    return id;
  }

  bool _phoneMatches(String? p1, String? p2) {
    if (p1 == null || p2 == null) return false;
    final d1 = p1.replaceAll(RegExp(r'\D'), '');
    final d2 = p2.replaceAll(RegExp(r'\D'), '');
    if (d1.isEmpty || d2.isEmpty) return false;
    if (d1 == d2) return true;
    if (d1.length >= 10 && d2.length >= 10) {
      return d1.substring(d1.length - 10) == d2.substring(d2.length - 10);
    }
    return false;
  }

  @override
  Future<AuthResult> resetPassword({
    required String mobileNo,
    required String newPassword,
  }) async {
    try {
      final trimmed = mobileNo.trim();
      final row = await (_db.select(_db.users)
            ..where((u) => u.mobileNo.equals(trimmed)))
          .getSingleOrNull();

      if (row == null) {
        return const AuthFailure(
            'No account found with this mobile number.');
      }
      return _doChangePassword(row.id, newPassword);
    } catch (e) {
      return AuthFailure('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> changePassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      return _doChangePassword(userId, newPassword);
    } catch (e) {
      return AuthFailure('Password change failed: ${e.toString()}');
    }
  }

  Future<AuthResult> _doChangePassword(
      String userId, String newPassword) async {
    if (newPassword.length < 6) {
      return const AuthFailure('Password must be at least 6 characters.');
    }
    final newSalt = _generateSalt();
    final newHash = _hashPassword(newPassword, newSalt);
    await (_db.update(_db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        passwordHash: Value(newHash),
        salt: Value(newSalt),
      ),
    );
    final row = await (_db.select(_db.users)
          ..where((u) => u.id.equals(userId)))
        .getSingle();
    return AuthSuccess(_rowToEntity(row));
  }

  @override
  Future<void> logout() async {
    await HiveService.clearUserSession();
  }

  @override
  Future<UserEntity?> restoreSession() async {
    try {
      final session = HiveService.getUserSession();
      if (session == null) return null;
      final userId = session['userId'] as String?;
      if (userId == null || userId.isEmpty) return null;
      return getUserById(userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasAnyAdmin() async {
    final count = await (_db.select(_db.users)
          ..where((u) => u.role.equals('admin')))
        .get();
    return count.isNotEmpty;
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    final row = await (_db.select(_db.users)
          ..where((u) => u.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _rowToEntity(row);
  }

  @override
  Future<List<UserEntity>> getMembers({
    UserRole role = UserRole.member,
    MemberType? memberType,
  }) async {
    final query = _db.select(_db.users)
      ..where((u) => u.role.equals(role.name));
    if (memberType != null) {
      query.where((u) => u.memberType.equals(memberType.dbValue));
    }
    final rows = await query.get();
    return rows.map(_rowToEntity).toList();
  }
}
