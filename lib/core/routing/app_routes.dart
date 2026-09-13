/// Centralized route names and path definitions.
abstract class AppRoutes {
  // Auth routes (standalone — no shell)
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main app routes (inside shell)
  static const String dashboard = '/dashboard';
  static const String resetPassword = '/reset-password';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String landowners = '/landowners';
  static const String investors = '/investors'; // Admin only
  static const String expenses = '/expenses';
  static const String plots = '/plots';
  static const String buyersSales = '/buyers-sales';
  static const String installments = '/installments';
  static const String receivablesPayables = '/receivables-payables';
  static const String profitLoss = '/profit-loss';
  static const String auditLog = '/audit-log'; // Admin only
  static const String helpGuide = '/help-guide';
  static const String settings = '/settings'; // Admin only

  // Member dashboards (inside shell, member only)
  static const String memberDashboardBuyer = '/my/buyer';
  static const String memberDashboardLandowner = '/my/landowner';
  static const String memberDashboardInvestor = '/my/investor';
}
