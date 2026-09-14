import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/routing/app_routes.dart';
import 'package:land_investment_and_sales_management/core/routing/route_guard.dart';
import 'package:land_investment_and_sales_management/features/auth/domain/member_type.dart';

void main() {
  group('RouteGuard', () {
    // ── Admin Access ──────────────────────────────────────────────────────────

    test('Admin can access dashboard', () {
      expect(RouteGuard.isAllowed(UserRole.admin, AppRoutes.dashboard), isTrue);
    });

    test('Admin can access investors route', () {
      expect(RouteGuard.isAllowed(UserRole.admin, AppRoutes.investors), isTrue);
    });

    test('Admin can access audit log', () {
      expect(RouteGuard.isAllowed(UserRole.admin, AppRoutes.auditLog), isTrue);
    });

    test('Admin can access settings', () {
      expect(RouteGuard.isAllowed(UserRole.admin, AppRoutes.settings), isTrue);
    });

    test('Admin CANNOT access member-only buyer route', () {
      expect(
        RouteGuard.isAllowed(UserRole.admin, AppRoutes.memberDashboardBuyer),
        isFalse,
      );
    });

    test('Admin CANNOT access member-only investor route', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.admin, AppRoutes.memberDashboardInvestor),
        isFalse,
      );
    });

    test('Admin CANNOT access member-only landowner route', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.admin, AppRoutes.memberDashboardLandowner),
        isFalse,
      );
    });

    // ── Member Access ─────────────────────────────────────────────────────────

    test('Member CANNOT access investors route', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.investors, MemberType.customerBuyer),
        isFalse,
      );
    });

    test('Member CANNOT access audit log', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.auditLog, MemberType.investor),
        isFalse,
      );
    });

    test('Member CANNOT access settings', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.settings, MemberType.landowner),
        isFalse,
      );
    });

    // ── Member Type Specific Routes ───────────────────────────────────────────

    test('Buyer member can access buyer dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member,
            AppRoutes.memberDashboardBuyer,
            MemberType.customerBuyer),
        isTrue,
      );
    });

    test('Buyer member CANNOT access investor dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member,
            AppRoutes.memberDashboardInvestor,
            MemberType.customerBuyer),
        isFalse,
      );
    });

    test('Buyer member CANNOT access landowner dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member,
            AppRoutes.memberDashboardLandowner,
            MemberType.customerBuyer),
        isFalse,
      );
    });

    test('Investor member can access investor dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member,
            AppRoutes.memberDashboardInvestor,
            MemberType.investor),
        isTrue,
      );
    });

    test('Investor member CANNOT access buyer dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member,
            AppRoutes.memberDashboardBuyer,
            MemberType.investor),
        isFalse,
      );
    });

    test('Landowner member can access landowner dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member,
            AppRoutes.memberDashboardLandowner,
            MemberType.landowner),
        isTrue,
      );
    });

    test('Landowner member CANNOT access buyer dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member,
            AppRoutes.memberDashboardBuyer,
            MemberType.landowner),
        isFalse,
      );
    });

    // ── Null member type ──────────────────────────────────────────────────────

    test('Member with null memberType cannot access any member dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.memberDashboardBuyer, null),
        isFalse,
      );
    });

    // ── General routes for members ────────────────────────────────────────────

    test('Standard member CANNOT access admin dashboard', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.dashboard, MemberType.customerBuyer),
        isFalse,
      );
    });

    test('CA member CAN access admin dashboard and operational routes', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.dashboard, MemberType.ca),
        isTrue,
      );
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.projects, MemberType.ca),
        isTrue,
      );
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.profitLoss, MemberType.ca),
        isTrue,
      );
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.memberDashboardBuyer, MemberType.ca),
        isFalse,
      );
    });

    test('Member can access help guide', () {
      expect(
        RouteGuard.isAllowed(
            UserRole.member, AppRoutes.helpGuide, MemberType.investor),
        isTrue,
      );
    });
  });

  group('MemberType', () {
    test('fromDb correctly parses all values', () {
      expect(
          MemberTypeX.fromDb('customerBuyer'), MemberType.customerBuyer);
      expect(MemberTypeX.fromDb('investor'), MemberType.investor);
      expect(MemberTypeX.fromDb('landowner'), MemberType.landowner);
      expect(MemberTypeX.fromDb('ca'), MemberType.ca);
    });

    test('fromDb throws on unknown value', () {
      expect(() => MemberTypeX.fromDb('unknown'), throwsArgumentError);
    });

    test('dbValue round-trips correctly', () {
      for (final type in MemberType.values) {
        expect(MemberTypeX.fromDb(type.dbValue), type);
      }
    });

    test('displayName is non-empty for all types', () {
      for (final type in MemberType.values) {
        expect(type.displayName, isNotEmpty);
      }
    });
  });
}
