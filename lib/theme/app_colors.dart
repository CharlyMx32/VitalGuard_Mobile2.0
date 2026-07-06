import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryLight = Color(0xFFE8F0FE);
  static const Color primaryDark = Color(0xFF2563EB);

  // ── Accent / Success ──
  static const Color accent = Color(0xFF34C759);
  static const Color accentLight = Color(0xFFE8F8EF);

  // ── Danger / Error ──
  static const Color danger = Color(0xFFFF6B6B);
  static const Color dangerBg = Color(0xFFFFE5E5);
  static const Color dangerDark = Color(0xFFEB5757);

  // ── Warning ──
  static const Color warning = Color(0xFFB78F00);
  static const Color warningBg = Color(0xFFFEF7E0);

  // ── Backgrounds ──
  static const Color bg = Color(0xFFF8FAFC);
  static const Color bgInput = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFF7F7F7);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFFCCCCCC);
  static const Color textPlaceholder = Color(0xFFCCCCCC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // ── Borders ──
  static const Color border = Color(0xFFEAEAEA);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ── Semantic icon container colors ──
  static const Color iconBlueBg = Color(0xFFE8F0FE);
  static const Color iconBlueFg = Color(0xFF4A7CFF);
  static const Color iconGreenBg = Color(0xFFE8F8EF);
  static const Color iconGreenFg = Color(0xFF27AE60);
  static const Color iconOrangeBg = Color(0xFFFEF7E0);
  static const Color iconOrangeFg = Color(0xFFB78F00);
  static const Color iconRedBg = Color(0xFFFFE5E5);
  static const Color iconRedFg = Color(0xFFEB5757);
  static const Color iconPurpleBg = Color(0xFFF3E8FF);
  static const Color iconPurpleFg = Color(0xFF9B59B6);
  static const Color iconGrayBg = Color(0xFFF8FAFC);
  static const Color iconGrayFg = Color(0xFF64748B);

  // ── Avatar colors ──
  static const Color avatarRed = Color(0xFFFF6B6B);
  static const Color avatarBlue = Color(0xFF4A7CFF);
  static const Color avatarGreen = Color(0xFF34C759);
  static const Color avatarPurple = Color(0xFF9B59B6);
  static const Color avatarOrange = Color(0xFFFF9500);

  // ── Toggle ──
  static const Color toggleActive = Color(0xFF34C759);
  static const Color toggleInactive = Color(0xFFD1D1D6);
  static const Color toggleActiveBlue = Color(0xFF4A90E2);

  // ── Toast ──
  static const Color toastSuccess = Color(0xFF27AE60);
  static const Color toastError = Color(0xFFEB5757);
  static const Color toastWarning = Color(0xFFB78F00);

  // ── Gradient ──
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment(0.87, -0.50),
    end: Alignment(-0.87, 0.50),
    colors: [Color(0xFF4A90E2), Color(0xFF6FCF97)],
  );

  static const LinearGradient gradientProfile = LinearGradient(
    begin: Alignment(0.20, -0.98),
    end: Alignment(-0.20, 0.98),
    colors: [Color(0xFF4A90E2), Color(0xFF6FCF97)],
  );

  static const LinearGradient gradientVoice = LinearGradient(
    begin: Alignment(1.0, 0.0),
    end: Alignment(0.0, 1.0),
    colors: [Color(0xFF4A7CFF), Color(0xFF6C5CE7)],
  );

  // ── Overlay ──
  static const Color overlay = Color(0xA6000000); // rgba(0,0,0,0.65)

  // ── Vital ID ──
  static const Color vitalGreen = Color(0xFF0A8E5A);
  static const Color vitalDark = Color(0xFF1A2B4C);
}
