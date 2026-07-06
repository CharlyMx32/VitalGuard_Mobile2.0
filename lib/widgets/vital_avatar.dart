import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class VitalAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool showBorder;
  final Color borderColor;

  const VitalAvatar({
    super.key,
    required this.initials,
    this.size = AppDimensions.avatarMedium,
    this.backgroundColor,
    this.gradient,
    this.showBorder = false,
    this.borderColor = Colors.white,
  });

  const VitalAvatar.small({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.gradient,
  })  : size = AppDimensions.avatarSmall,
        showBorder = false,
        borderColor = Colors.white;

  const VitalAvatar.large({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.gradient,
  })  : size = AppDimensions.avatarLarge,
        showBorder = false,
        borderColor = Colors.white;

  const VitalAvatar.xlarge({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.gradient,
  })  : size = AppDimensions.avatarXLarge,
        showBorder = true,
        borderColor = Colors.white;

  const VitalAvatar.network({
    super.key,
    required String imageUrl,
    this.size = AppDimensions.avatarMedium,
    this.showBorder = false,
    this.borderColor = Colors.white,
  })  : initials = '',
        backgroundColor = AppColors.primary,
        gradient = null;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = gradient != null
        ? null
        : (backgroundColor ?? AppColors.primary);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        color: effectiveBg,
        border: showBorder
            ? Border.all(
                color: borderColor.withValues(alpha: 0.3),
                width: 3,
              )
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.375,
          ),
        ),
      ),
    );
  }
}
