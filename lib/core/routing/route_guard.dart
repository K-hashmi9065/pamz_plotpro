import '../constants/app_constants.dart';
import '../../features/auth/domain/member_type.dart';
import 'app_routes.dart';

/// Business logic layer permission guard for route access.
abstract class RouteGuard {
  static const List<String> _memberOnlyRoutes = [
    AppRoutes.memberDashboardBuyer,
    AppRoutes.memberDashboardLandowner,
    AppRoutes.memberDashboardInvestor,
  ];

  /// Checks if [role] is allowed to navigate to [path].
  /// For members, strictly restricts access to their designated member dashboard.
  static bool isAllowed(UserRole role, String path,
      [MemberType? memberType]) {
    // Admin and CA (Chartered Accountant) have access to admin dashboard and management routes
    if (role.isAdmin || memberType == MemberType.ca) {
      final isMemberOnly = _memberOnlyRoutes.any((r) => path.startsWith(r));
      return !isMemberOnly;
    }

    // Standard client/partner members (Buyer, Investor, Landowner) are restricted to their personal dashboards
    if (role.isMember) {
      if (memberType == null) return false;
      switch (memberType) {
        case MemberType.customerBuyer:
          return path == AppRoutes.memberDashboardBuyer || path == AppRoutes.helpGuide;
        case MemberType.investor:
          return path == AppRoutes.memberDashboardInvestor || path == AppRoutes.helpGuide;
        case MemberType.landowner:
          return path == AppRoutes.memberDashboardLandowner || path == AppRoutes.helpGuide;
        case MemberType.ca:
          final isMemberOnly = _memberOnlyRoutes.any((r) => path.startsWith(r));
          return !isMemberOnly;
      }
    }

    return false;
  }
}
