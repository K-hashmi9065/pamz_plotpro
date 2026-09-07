import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography rules for Land Investment System using Inter font.
/// Strict size and weight scale matching section 5 of UI/UX Specifications.
abstract class AppTypography {
  static TextStyle get pageTitle => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get secondary => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get tableHeader => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      );

  static TextStyle get tableCell => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get input => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get helperError => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.dangerText,
      );

  /// Currency figures must visually dominate metadata.
  /// Use [amountLarge] for primary screen totals / hero numbers.
  static TextStyle get amountLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// Currency figures for cards, rows, and summary tables.
  static TextStyle get amountMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );
}

