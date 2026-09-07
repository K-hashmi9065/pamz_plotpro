/// App-wide constants, enums, and default strings.
abstract class AppConstants {
  static const String appName = 'PAMZ PlotPro';
  static const String appVersion = '1.0.0';
  static const String appDataFolder = 'LandInvestmentSystem';

  // Statutory Cash Limits (Section 269ST)
  static const double cashTransactionLimit = 200000.0; // ₹2,00,000 threshold

  // TDS Section 194-IA Threshold
  static const double tdsPropertyThreshold = 5000000.0; // ₹50,00,000 threshold
  static const double tdsRate = 0.01; // 1% TDS

  // Design standard resolution
  static const double designWidth = 1440.0;
  static const double designHeight = 900.0;
  static const double minWindowWidth = 1024.0;
  static const double minWindowHeight = 700.0;
}

/// User Roles in the System (Exactly two)
enum UserRole {
  admin,
  member,
}

extension UserRoleX on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.member:
        return 'Member';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isMember => this == UserRole.member;
}

/// Project Status Lifecycle
enum ProjectStatus {
  draft,
  negotiation,
  purchasePending,
  purchased,
  funding,
  active,
  maintenance,
  salePending,
  sold,
  profitCalculated,
  distribution,
  closed,
  cancelled,
}

/// Plot Status Lifecycle
enum PlotStatus {
  available,
  reserved,
  booked,
  saleAgreement,
  partiallyPaid,
  fullyPaid,
  sold,
  cancelled,
}

/// Cost Categories for Expenses
enum ExpenseCategory {
  purchase,
  acquisition,
  financing,
  registration,
  legal,
  brokerage,
  development,
  maintenance,
  tax,
  marketing,
  administration,
  other,
}

/// Ownership Method for Investors
enum OwnershipMethod {
  capitalBased,
  manual,
}

/// Sale Types
enum SaleType {
  wholeLand,
  plotWise,
  multiplePlots,
  mixed,
}

/// Installment Status
enum InstallmentStatus {
  pending,
  partiallyPaid,
  paid,
  overdue,
  cancelled,
}

/// Transaction Methods
enum PaymentMethod {
  bankTransfer,
  cheque,
  cash,
  dd,
  online,
}
