import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDimensions {
  AppDimensions._();

  // ── Screen ──
  static const double screenWidth = 360;
  static const double screenHeight = 800;

  // ── Spacing ──
  static const double paddingHorizontal = 20;
  static const double paddingContentTop = 16;
  static const double paddingContentBottom = 80;
  static const double paddingHeaderTop = 40;
  static const double paddingHeaderBottom = 24;
  static const double gapSmall = 8;
  static const double gapMedium = 12;
  static const double gapLarge = 16;
  static const double gapXLarge = 20;

  // ── Border Radius ──
  static const double radiusButton = 12;
  static const double radiusCard = 16;
  static const double radiusBadge = 20;
  static const double radiusInput = 12;
  static const double radiusToggle = 14;
  static const double radiusIcon = 10;
  static const double radiusAvatar = 50;
  static const double radiusHeaderBottom = 24;
  static const double radiusModal = 16;
  static const double radiusSmall = 8;
  static const double radiusMedium = 14;

  // ── Card ──
  static const double cardPadding = 16;
  static const double cardMarginBottom = 12;
  static const double cardMarginHorizontal = 20;

  // ── Button ──
  static const double buttonHeight = 48;
  static const double buttonRadius = 12;

  // ── Icon Container ──
  static const double iconContainerSize = 36;
  static const double iconContainerRadius = 10;
  static const double iconLargeSize = 48;
  static const double iconLargeRadius = 14;

  // ── Avatar ──
  static const double avatarSmall = 40;
  static const double avatarMedium = 48;
  static const double avatarLarge = 60;
  static const double avatarXLarge = 80;

  // ── Toggle ──
  static const double toggleWidth = 48;
  static const double toggleHeight = 28;
  static const double toggleKnob = 22;

  // ── Bottom Nav ──
  static const double bottomNavHeight = 64;
  static const double navIconSize = 24;

  // ── Input ──
  static const double inputHeight = 44;

  // ── Badge ──
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
  static const EdgeInsets badgePaddingLarge = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 6,
  );

  // ── Error Icon ──
  static const double errorIconSize = 80;
  static const double modalIconSize = 56;

  // ── Shadows ──
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0x0A000000),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(0x0A000000),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0x0F000000),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get toggleShadow => [
    BoxShadow(
      color: const Color(0x26000000),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get modalShadow => [
    BoxShadow(
      color: const Color(0x40000000),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get toastShadow => [
    BoxShadow(
      color: const Color(0x26000000),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get settingsGroupShadow => [
    BoxShadow(
      color: const Color(0x0A000000),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ── Dividers ──
  static const BorderSide settingsDivider = BorderSide(
    width: 1.33,
    color: AppColors.borderLight,
  );
}
