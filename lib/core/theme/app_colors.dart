import 'package:flutter/material.dart';

/// Semantic and enterprise color palette for Land Investment System.
/// Strictly light-theme oriented with clear semantic indicators and SaaS aesthetic.
abstract class AppColors {
  // Brand / Core Accent Colors
  static const Color primary = Color(0xFF0F172A); // Slate 900 (Primary Brand Dark Accent)
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color primarySubtle = Color(0xFF334155); // Slate 700
  static const Color accent = Color(0xFF2563EB); // Royal Blue 600 (Actions / Selection / Focus)
  static const Color accentHover = Color(0xFF1D4ED8); // Blue 700
  static const Color accentPressed = Color(0xFF1E40AF); // Blue 800
  static const Color accentLight = Color(0xFFEEF2FF); // Indigo/Blue 50 (Active background tint)
  static const Color accentSubtle = Color(0xFFDBEAFE); // Blue 100

  // Background & Surface Tokens
  static const Color background = Color(0xFFF8FAFC); // Slate 50 (App Background)
  static const Color surface = Color(0xFFFFFFFF); // Pure White Surfaces / Cards
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100 (Secondary Surface / Row Hover)
  static const Color surfaceSubtle = Color(0xFFF8FAFC); // Slate 50 (Header / Table header)
  static const Color surfaceHover = Color(0xFFF8FAFC); // Hover state for clean cards

  // Sidebar Palette (Clean Light SaaS Theme)
  static const Color sidebarBackground = Color(0xFFFFFFFF); // Clean Crisp White or Soft Neutral
  static const Color sidebarHover = Color(0xFFF1F5F9); // Slate 100 Hover
  static const Color sidebarActive = Color(0xFFEFF6FF); // Soft Accent Tint Background
  static const Color sidebarActiveText = Color(0xFF2563EB); // Primary Accent Active Text
  static const Color sidebarText = Color(0xFF475569); // Slate 600 Normal Nav Text
  static const Color sidebarTextHover = Color(0xFF0F172A); // Slate 900 Hover Text
  static const Color sidebarBorder = Color(0xFFE2E8F0); // Slate 200 Right Border

  // Text Hierarchy Tokens
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 (High contrast body / titles)
  static const Color textSecondary = Color(0xFF475569); // Slate 600 (Subtitles / Labels)
  static const Color textMuted = Color(0xFF64748B); // Slate 500 (Captions / Table Headers)
  static const Color textDisabled = Color(0xFFCBD5E1); // Slate 300 (Disabled states)
  static const Color textOnDark = Color(0xFFFFFFFF); // Light text on dark badges
  static const Color textOnDarkSecondary = Color(0xFF94A3B8); // Muted text on dark

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderStrong = Color(0xFFCBD5E1); // Slate 300
  static const Color divider = Color(0xFFE2E8F0);

  // Semantic Status Colors (Restrained - only for state communication)
  // Success / Completed / Positive
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successBg = Color(0xFFF0FDF4); // Green 50
  static const Color successBorder = Color(0xFFBBF7D0); // Green 200
  static const Color successText = Color(0xFF15803D); // Green 700

  // Warning / Pending / Attention
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningBg = Color(0xFFFFFBEB); // Amber 50
  static const Color warningBorder = Color(0xFFFDE68A); // Amber 200
  static const Color warningText = Color(0xFFB45309); // Amber 700

  // Orange / Revenue Accent
  static const Color orange = Color(0xFFEA580C); // Orange 600
  static const Color orangeBg = Color(0xFFFFF7ED); // Orange 50
  static const Color orangeBorder = Color(0xFFFFEDD5); // Orange 200
  static const Color orangeText = Color(0xFFC2410C); // Orange 700

  // Danger / Overdue / Error / Critical
  static const Color danger = Color(0xFFDC2626); // Red 600
  static const Color dangerBg = Color(0xFFFEF2F2); // Red 50
  static const Color dangerBorder = Color(0xFFFECACA); // Red 200
  static const Color dangerText = Color(0xFFB91C1C); // Red 700

  // Info / Active / Draft
  static const Color info = Color(0xFF2563EB); // Blue 600
  static const Color infoBg = Color(0xFFEFF6FF); // Blue 50
  static const Color infoBorder = Color(0xFFBFDBFE); // Blue 200
  static const Color infoText = Color(0xFF1D4ED8); // Blue 700

  // Role Badge Colors
  static const Color adminRoleBg = Color(0xFFF3E8FF); // Purple 100
  static const Color adminRoleBorder = Color(0xFFE9D5FF); // Purple 200
  static const Color adminRoleText = Color(0xFF6B21A8); // Purple 800
  static const Color memberRoleBg = Color(0xFFE0E7FF); // Indigo 100
  static const Color memberRoleBorder = Color(0xFFC7D2FE); // Indigo 200
  static const Color memberRoleText = Color(0xFF3730A3); // Indigo 800
}

/// Standard reusable BoxShadow design tokens
abstract class AppShadows {
  /// Subtle elevation for clean cards and table containers
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x08000000), // 3% opacity black
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevation for interactive hovered items and small dropdowns
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x0C000000), // 5% opacity black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Floating popups, modals, and search overlay
  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: Color(0x18000000), // ~10% opacity black
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}

/// Standard border radius tokens
abstract class AppRadius {
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double full = 999.0;

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
}


