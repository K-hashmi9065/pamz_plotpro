import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/auth/data/auth_repository_impl.dart';
import 'package:land_investment_and_sales_management/features/auth/domain/auth_repository.dart';
import 'package:land_investment_and_sales_management/features/auth/domain/member_type.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';

/// In-memory test database helper
AppDatabase _testDb() =>
    AppDatabase(NativeDatabase.memory());

void main() {
  group('AuthRepositoryImpl', () {
    late AppDatabase db;
    late AuthRepositoryImpl repo;

    setUp(() {
      db = _testDb();
      repo = AuthRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    // ── Sign Up ───────────────────────────────────────────────────────────────

    test('signUpAdmin creates admin user and returns AuthSuccess', () async {
      final result = await repo.signUpAdmin(
        name: 'Ahsan Admin',
        mobileNo: '9876543210',
        password: 'SecurePass123',
      );

      expect(result, isA<AuthSuccess>());
      final user = (result as AuthSuccess).user;
      expect(user.name, 'Ahsan Admin');
      expect(user.mobileNo, '9876543210');
      expect(user.role, UserRole.admin);
      expect(user.memberType, isNull);
    });

    test('signUpMember creates buyer and linked Buyers entity', () async {
      final result = await repo.signUpMember(
        name: 'Ravi Buyer',
        mobileNo: '9000001111',
        password: 'pass1234',
        memberType: MemberType.customerBuyer,
      );

      expect(result, isA<AuthSuccess>());
      final user = (result as AuthSuccess).user;
      expect(user.memberType, MemberType.customerBuyer);
      expect(user.linkedEntityId, isNotNull);

      // Verify the Buyers row was created
      final buyers = await db.select(db.buyers).get();
      expect(buyers.any((b) => b.id == user.linkedEntityId), isTrue);
    });

    test('signUpMember creates investor and linked Investors entity', () async {
      final result = await repo.signUpMember(
        name: 'Suresh Investor',
        mobileNo: '9000002222',
        password: 'pass1234',
        memberType: MemberType.investor,
      );

      expect(result, isA<AuthSuccess>());
      final user = (result as AuthSuccess).user;
      expect(user.memberType, MemberType.investor);

      final investors = await db.select(db.investors).get();
      expect(investors.any((i) => i.id == user.linkedEntityId), isTrue);
    });

    test('signUpMember creates landowner and linked Landowners entity',
        () async {
      final result = await repo.signUpMember(
        name: 'Ramesh Landowner',
        mobileNo: '9000003333',
        password: 'pass1234',
        memberType: MemberType.landowner,
      );

      expect(result, isA<AuthSuccess>());
      final user = (result as AuthSuccess).user;
      expect(user.memberType, MemberType.landowner);

      final landowners = await db.select(db.landowners).get();
      expect(landowners.any((l) => l.id == user.linkedEntityId), isTrue);
    });

    test('duplicate mobile number returns AuthFailure', () async {
      await repo.signUpAdmin(
        name: 'Admin One',
        mobileNo: '9111111111',
        password: 'pass1234',
      );

      final result = await repo.signUpAdmin(
        name: 'Admin Two',
        mobileNo: '9111111111',
        password: 'pass5678',
      );

      expect(result, isA<AuthFailure>());
      expect((result as AuthFailure).message,
          contains('already exists'));
    });

    test('short password returns AuthFailure', () async {
      final result = await repo.signUpAdmin(
        name: 'Admin',
        mobileNo: '9222222222',
        password: '123',
      );

      expect(result, isA<AuthFailure>());
    });

    // ── Login ─────────────────────────────────────────────────────────────────

    test('login with correct credentials returns AuthSuccess', () async {
      await repo.signUpAdmin(
        name: 'Test Admin',
        mobileNo: '9333333333',
        password: 'correct_password',
      );

      final result = await repo.login(
        mobileNo: '9333333333',
        password: 'correct_password',
      );

      expect(result, isA<AuthSuccess>());
      expect((result as AuthSuccess).user.mobileNo, '9333333333');
    });

    test('login with wrong password returns AuthFailure', () async {
      await repo.signUpAdmin(
        name: 'Test Admin',
        mobileNo: '9444444444',
        password: 'right_password',
      );

      final result = await repo.login(
        mobileNo: '9444444444',
        password: 'wrong_password',
      );

      expect(result, isA<AuthFailure>());
      expect((result as AuthFailure).message, contains('Incorrect password'));
    });

    test('login with unknown mobile returns AuthFailure', () async {
      final result = await repo.login(
        mobileNo: '0000000000',
        password: 'anything',
      );

      expect(result, isA<AuthFailure>());
      expect((result as AuthFailure).message, contains('No account found'));
    });

    // ── Password Reset ────────────────────────────────────────────────────────

    test('resetPassword changes password and allows new login', () async {
      await repo.signUpAdmin(
        name: 'Reset User',
        mobileNo: '9555555555',
        password: 'old_password',
      );

      final resetResult = await repo.resetPassword(
        mobileNo: '9555555555',
        newPassword: 'new_password',
      );
      expect(resetResult, isA<AuthSuccess>());

      // Old password should fail
      final oldLogin = await repo.login(
        mobileNo: '9555555555',
        password: 'old_password',
      );
      expect(oldLogin, isA<AuthFailure>());

      // New password should work
      final newLogin = await repo.login(
        mobileNo: '9555555555',
        password: 'new_password',
      );
      expect(newLogin, isA<AuthSuccess>());
    });

    test('resetPassword with unknown mobile returns AuthFailure', () async {
      final result = await repo.resetPassword(
        mobileNo: '0000000000',
        newPassword: 'newpass',
      );
      expect(result, isA<AuthFailure>());
    });

    // ── hasAnyAdmin ───────────────────────────────────────────────────────────

    test('hasAnyAdmin returns false on empty db', () async {
      final result = await repo.hasAnyAdmin();
      expect(result, isFalse);
    });

    test('hasAnyAdmin returns true after admin signup', () async {
      await repo.signUpAdmin(
          name: 'Admin', mobileNo: '9666666666', password: 'pass1234');
      expect(await repo.hasAnyAdmin(), isTrue);
    });

    // ── getUserById ───────────────────────────────────────────────────────────

    test('getUserById returns user after signup', () async {
      final signup = await repo.signUpAdmin(
          name: 'Get Me', mobileNo: '9777777777', password: 'pass1234');
      final userId = (signup as AuthSuccess).user.id;

      final fetched = await repo.getUserById(userId);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Get Me');
    });

    test('getUserById returns null for unknown id', () async {
      final result = await repo.getUserById('nonexistent-uuid');
      expect(result, isNull);
    });
  });
}
