import 'package:flutter/material.dart';

/// Navigation item definition for sidebar.
class NavItem {
  final String id;
  final String title;
  final IconData icon;
  final String routePath;
  final bool adminOnly;
  final List<NavItem>? children;

  const NavItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.routePath,
    this.adminOnly = false,
    this.children,
  });
}
