import '../constants/app_constants.dart';
import 'app_routes.dart';

/// Business logic layer permission guard for route access.
abstract class RouteGuard {
  static const List<String> _adminOnlyRoutes = [
    AppRoutes.investors,
    AppRoutes.auditLog,
    AppRoutes.settings,
  ];

  /// Checks if [role] is allowed to navigate to [path].
  static bool isAllowed(UserRole role, String path) {
    if (role.isAdmin) return true;

    for (final adminRoute in _adminOnlyRoutes) {
      if (path.startsWith(adminRoute)) {
        return false;
      }
    }
    return true;
  }
}
