import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _base({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ── Dashboard ──
  static TextStyle get dashboardGreeting => _base(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: const Color(0xCCFFFFFF),
  );

  static TextStyle get dashboardName => _base(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get statValue => _base(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get statLabel => _base(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: const Color(0xCCFFFFFF),
  );

  // ── Headers ──
  static TextStyle get headerTitle => _base(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get headerTitleWhite => _base(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ── Sections ──
  static TextStyle get sectionTitle => _base(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle get sectionLabel => _base(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle get seeAll => _base(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // ── Body ──
  static TextStyle get bodyMedium => _base(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyMuted => _base(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // ── Cards ──
  static TextStyle get patientName => _base(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get medicationName => _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get doseTime => _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get adherenceValue => _base(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );

  // ── Buttons ──
  static TextStyle get buttonPrimary => _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get buttonOutline => _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get buttonGhost => _base(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  // ── Nav ──
  static TextStyle get navActive => _base(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get navInactive => _base(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );

  // ── Badges ──
  static TextStyle get badge => _base(
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get badgeSmall => _base(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  // ── Settings ──
  static TextStyle get settingsLabel => _base(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static TextStyle get settingsDesc => _base(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle get settingsValue => _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  // ── Forms ──
  static TextStyle get formLabel => _base(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static TextStyle get formInput => _base(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static TextStyle get formPlaceholder => _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPlaceholder,
  );

  // ── Error screens ──
  static TextStyle get errorTitle => _base(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle get errorDesc => _base(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static TextStyle get errorCode => _base(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  ).copyWith(fontFamily: 'monospace');

  // ── Modal ──
  static TextStyle get modalTitle => _base(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle get modalDesc => _base(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  // ── Toast ──
  static TextStyle get toast => _base(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // ── Profile ──
  static TextStyle get profileName => _base(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get profileEmail => _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xCCFFFFFF),
  );

  static TextStyle get profileRole => _base(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // ── Misc ──
  static TextStyle get link => _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get subtitle => _base(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get title => _base(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
