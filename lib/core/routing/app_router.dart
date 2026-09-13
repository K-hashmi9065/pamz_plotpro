import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/audit_log/presentation/audit_log_screen.dart';
import '../../features/buyers_sales/presentation/buyers_sales_list_screen.dart';
import '../../features/dashboard/presentation/executive_dashboard_screen.dart';
import '../../features/expenses/presentation/expenses_list_screen.dart';
import '../../features/help_user_guide/presentation/help_guide_screen.dart';
import '../../features/installments_payments/presentation/installments_list_screen.dart';
import '../../features/investors/presentation/investors_list_screen.dart';
import '../../features/landowners/presentation/landowners_list_screen.dart';
import '../../features/plots/presentation/plots_list_screen.dart';
import '../../features/projects/presentation/projects_list_screen.dart';
import '../../features/profit_loss_settlement/presentation/profit_loss_screen.dart';
import '../../features/receivables_payables/presentation/receivables_payables_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/providers/navigation_providers.dart';
import '../../shared/widgets/app_shell.dart';
import 'app_routes.dart';
import 'route_guard.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(currentRoleProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final _routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Central GoRouter configuration with StatefulShellRoute and Role Guard.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(_routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: notifier,
    redirect: (context, state) {
      final currentRole = ref.read(currentRoleProvider);
      final targetPath = state.uri.path;
      final isAllowed = RouteGuard.isAllowed(currentRole, targetPath);

      if (!isAllowed) {
        // STRICT ROLE BOUNDARY: Redirect Member away from Admin-only routes
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const ExecutiveDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.projects,
                builder: (context, state) => const ProjectsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.landowners,
                builder: (context, state) => const LandownersListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.investors, // Admin Only
                builder: (context, state) => const InvestorsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expenses,
                builder: (context, state) => const ExpensesListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.plots,
                builder: (context, state) => const PlotsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.buyersSales,
                builder: (context, state) => const BuyersSalesListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.installments,
                builder: (context, state) => const InstallmentsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.receivablesPayables,
                builder: (context, state) => const ReceivablesPayablesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profitLoss,
                builder: (context, state) => const ProfitLossScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.auditLog, // Admin Only
                builder: (context, state) => const AuditLogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.helpGuide, // Permanent Help / User Guide
                builder: (context, state) => const HelpGuideScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings, // Admin Only
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
