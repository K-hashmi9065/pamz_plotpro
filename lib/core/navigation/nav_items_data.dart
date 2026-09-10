import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'nav_item.dart';

/// Centralized data tree for sidebar navigation items.
abstract class NavItemsData {
  static const List<NavItem> allNavItems = [
    NavItem(
      id: 'dashboard',
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      routePath: '/dashboard',
    ),
    NavItem(
      id: 'projects',
      title: 'Projects',
      icon: Icons.business_outlined,
      routePath: '/projects',
    ),
    NavItem(
      id: 'landowners',
      title: 'Landowners',
      icon: Icons.landscape_outlined,
      routePath: '/landowners',
    ),
    NavItem(
      id: 'investors',
      title: 'Investors',
      icon: Icons.pie_chart_outline,
      routePath: '/investors',
      adminOnly: true, // STRICT REQUIREMENT: Admin-only, absent for Member
    ),
    NavItem(
      id: 'expenses',
      title: 'Expenses',
      icon: Icons.receipt_long_outlined,
      routePath: '/expenses',
    ),
    NavItem(
      id: 'plots',
      title: 'Plots',
      icon: Icons.grid_view_outlined,
      routePath: '/plots',
    ),
    NavItem(
      id: 'buyers_sales',
      title: 'Customers',
      icon: Icons.people_outline,
      routePath: '/buyers-sales',
    ),
    NavItem(
      id: 'installments',
      title: 'Installments & Payments',
      icon: Icons.account_balance_wallet_outlined,
      routePath: '/installments',
    ),
    NavItem(
      id: 'receivables_payables',
      title: 'Receivables & Payables',
      icon: Icons.compare_arrows_outlined,
      routePath: '/receivables-payables',
    ),
    NavItem(
      id: 'profit_loss',
      title: 'Profit & Loss / Payouts',
      icon: Icons.trending_up_outlined,
      routePath: '/profit-loss',
    ),
    NavItem(
      id: 'audit_log',
      title: 'Audit Log',
      icon: Icons.history_edu_outlined,
      routePath: '/audit-log',
      adminOnly: true,
    ),
    NavItem(
      id: 'help_user_guide',
      title: 'Help / User Guide',
      icon: Icons.help_outline,
      routePath: '/help-guide', // Permanent Help item
    ),
    NavItem(
      id: 'settings',
      title: 'Settings',
      icon: Icons.settings_outlined,
      routePath: '/settings',
      adminOnly: true,
    ),
  ];

  /// Returns filtered nav items based on user role.
  /// For Member, [adminOnly] items (Investors, Audit Log, Settings) are COMPLETELY ABSENT.
  static List<NavItem> getNavItemsForRole(UserRole role) {
    if (role.isAdmin) {
      return allNavItems;
    }
    return allNavItems.where((item) => !item.adminOnly).toList();
  }
}
