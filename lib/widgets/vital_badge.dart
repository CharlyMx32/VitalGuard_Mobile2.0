import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeType { pending, completed, info, danger, warning, neutral }

class VitalBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final bool showDot;
  final bool small;

  const VitalBadge({
    super.key,
    required this.label,
    this.type = BadgeType.info,
    this.showDot = false,
    this.small = false,
  });

  const VitalBadge.pending({
    super.key,
    required this.label,
    this.showDot = false,
    this.small = false,
  }) : type = BadgeType.pending;

  const VitalBadge.completed({
    super.key,
    required this.label,
    this.showDot = false,
    this.small = false,
  }) : type = BadgeType.completed;

  const VitalBadge.info({
    super.key,
    required this.label,
    this.showDot = false,
    this.small = false,
  }) : type = BadgeType.info;

  const VitalBadge.danger({
    super.key,
    required this.label,
    this.showDot = false,
    this.small = false,
  }) : type = BadgeType.danger;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _getColors();
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    final fontSize = small ? 9.0 : 10.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getColors() {
    return switch (type) {
      BadgeType.pending => (AppColors.warningBg, AppColors.warning),
      BadgeType.completed => (AppColors.accentLight, AppColors.accent),
      BadgeType.info => (AppColors.primaryLight, AppColors.primary),
      BadgeType.danger => (AppColors.dangerBg, AppColors.dangerDark),
      BadgeType.warning => (AppColors.warningBg, AppColors.warning),
      BadgeType.neutral => (AppColors.bg, AppColors.textMuted),
    };
  }
}
