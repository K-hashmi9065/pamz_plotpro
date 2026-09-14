import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/audit_log/presentation/audit_log_screen.dart';
import '../../features/buyers_sales/presentation/buyers_sales_list_screen.dart';
import '../../features/dashboard/presentation/executive_dashboard_screen.dart';
import '../../features/expenses/presentation/expenses_list_screen.dart';
import '../../features/help_user_guide/presentation/help_guide_screen.dart';
import '../../features/installments_payments/presentation/installments_list_screen.dart';
import '../../features/investors/presentation/investors_list_screen.dart';
import '../../features/landowners/presentation/landowners_list_screen.dart';
import '../../features/member_dashboard/presentation/buyer_dashboard_screen.dart';
import '../../features/member_dashboard/presentation/investor_dashboard_screen.dart';
import '../../features/member_dashboard/presentation/landowner_dashboard_screen.dart';
import '../../features/plots/presentation/plots_list_screen.dart';
import '../../features/projects/presentation/projects_list_screen.dart';
import '../../features/profit_loss_settlement/presentation/profit_loss_screen.dart';
import '../../features/receivables_payables/presentation/receivables_payables_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'app_routes.dart';
import 'route_guard.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    // Listen to auth state changes
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final _routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>();

/// Central GoRouter with auth-aware redirect and role-based access.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(_routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider).valueOrNull;
      final targetPath = state.uri.path;

      // Auth routes that don't require login
      final authRoutes = [
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.forgotPassword,
      ];
      final isAuthRoute = authRoutes.any((r) => targetPath.startsWith(r));

      // Still loading
      if (authState == null || authState is AuthLoading) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // First run — force signup to create first admin
      if (authState is AuthFirstRun) {
        if (targetPath == AppRoutes.signup) return null;
        return AppRoutes.signup;
      }

      // Not authenticated
      if (authState is AuthUnauthenticated || authState is AuthError) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // Authenticated — don't show auth screens
      if (authState is AuthAuthenticated) {
          if (isAuthRoute) {
          final user = authState.user;
          if (user.isMember) {
            return _memberDefaultRoute(user.memberType?.dbValue);
          }
          return AppRoutes.dashboard;
        }

        // Role-based access guard
        final user = authState.user;
        final isAllowed =
            RouteGuard.isAllowed(user.role, targetPath, user.memberType);
        if (!isAllowed) {
          if (user.isMember) {
            return _memberDefaultRoute(user.memberType?.dbValue);
          }
          return AppRoutes.dashboard;
        }
      }

      return null;
    },
    routes: [
      // ── Standalone Auth Routes ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Main App Shell ────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) =>
                    const ExecutiveDashboardScreen(),
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
                builder: (context, state) =>
                    const LandownersListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.investors, // Admin Only
                builder: (context, state) =>
                    const InvestorsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expenses,
                builder: (context, state) =>
                    const ExpensesListScreen(),
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
                builder: (context, state) =>
                    const BuyersSalesListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.installments,
                builder: (context, state) =>
                    const InstallmentsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.receivablesPayables,
                builder: (context, state) =>
                    const ReceivablesPayablesScreen(),
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
                path: AppRoutes.helpGuide,
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.resetPassword,
                builder: (context, state) =>
                    const ResetPasswordScreen(),
              ),
            ],
          ),
          // Member dashboards
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.memberDashboardBuyer,
                builder: (context, state) =>
                    const BuyerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.memberDashboardLandowner,
                builder: (context, state) =>
                    const LandownerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.memberDashboardInvestor,
                builder: (context, state) =>
                    const InvestorDashboardScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String _memberDefaultRoute(String? memberType) {
  switch (memberType) {
    case 'customerBuyer':
      return AppRoutes.memberDashboardBuyer;
    case 'investor':
      return AppRoutes.memberDashboardInvestor;
    case 'landowner':
      return AppRoutes.memberDashboardLandowner;
    case 'ca':
      return AppRoutes.dashboard;
    default:
      return AppRoutes.dashboard;
  }
}
