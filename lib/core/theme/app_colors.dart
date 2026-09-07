import 'package:flutter/material.dart';

/// Semantic and enterprise color palette for Land Investment System.
/// Strictly light-theme oriented with clear semantic indicators and SaaS aesthetic.
abstract class AppColors {
  // Brand / Core Accent Colors
  static const Color primary = Color(0xFF0F172A); // Slate 900 (Primary Brand Dark Accent)
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFF2563EB); // Royal Blue 600 (Actions / Selection / Focus)
  static const Color accentHover = Color(0xFF1D4ED8); // Blue 700
  static const Color accentPressed = Color(0xFF1E40AF); // Blue 800
  static const Color accentLight = Color(0xFFEFF6FF); // Blue 50 (Active background tint)

  // Background & Surface Tokens
  static const Color background = Color(0xFFF8FAFC); // Slate 50 (App Background)
  static const Color surface = Color(0xFFFFFFFF); // Pure White Surfaces / Cards
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100 (Secondary Surface)
  static const Color surfaceSubtle = Color(0xFFF8FAFC); // Slate 50 (Header / Table header)

  // Sidebar Palette (Clean Light SaaS Theme)
  static const Color sidebarBackground = Color(0xFFFAFAFA); // Soft Light Neutral Background
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
  static const Color divider = Color(0xFFE2E8F0);

  // Semantic Status Colors (Restrained - only for state communication)
  // Success / Completed / Positive
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successBg = Color(0xFFF0FDF4); // Green 50
  static const Color successText = Color(0xFF15803D); // Green 700

  // Warning / Pending / Attention
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningBg = Color(0xFFFFFBEB); // Amber 50
  static const Color warningText = Color(0xFFB45309); // Amber 700

  // Danger / Overdue / Error / Critical
  static const Color danger = Color(0xFFDC2626); // Red 600
  static const Color dangerBg = Color(0xFFFEF2F2); // Red 50
  static const Color dangerBorder = Color(0xFFFCA5A5); // Red 300
  static const Color dangerText = Color(0xFFB91C1C); // Red 700

  // Info / Active / Draft
  static const Color info = Color(0xFF2563EB); // Blue 600
  static const Color infoBg = Color(0xFFEFF6FF); // Blue 50
  static const Color infoText = Color(0xFF1D4ED8); // Blue 700

  // Role Badge Colors
  static const Color adminRoleBg = Color(0xFFF3E8FF); // Purple 100
  static const Color adminRoleText = Color(0xFF6B21A8); // Purple 800
  static const Color memberRoleBg = Color(0xFFE0E7FF); // Indigo 100
  static const Color memberRoleText = Color(0xFF3730A3); // Indigo 800
}

