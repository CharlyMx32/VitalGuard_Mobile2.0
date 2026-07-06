import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class VitalIconContainer extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double? radius;

  const VitalIconContainer({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = AppDimensions.iconContainerSize,
    this.radius,
  });

  const VitalIconContainer.blue({
    super.key,
    required this.icon,
  })  : backgroundColor = AppColors.iconBlueBg,
        iconColor = AppColors.iconBlueFg,
        size = AppDimensions.iconContainerSize,
        radius = null;

  const VitalIconContainer.green({
    super.key,
    required this.icon,
  })  : backgroundColor = AppColors.iconGreenBg,
        iconColor = AppColors.iconGreenFg,
        size = AppDimensions.iconContainerSize,
        radius = null;

  const VitalIconContainer.orange({
    super.key,
    required this.icon,
  })  : backgroundColor = AppColors.iconOrangeBg,
        iconColor = AppColors.iconOrangeFg,
        size = AppDimensions.iconContainerSize,
        radius = null;

  const VitalIconContainer.red({
    super.key,
    required this.icon,
  })  : backgroundColor = AppColors.iconRedBg,
        iconColor = AppColors.iconRedFg,
        size = AppDimensions.iconContainerSize,
        radius = null;

  const VitalIconContainer.purple({
    super.key,
    required this.icon,
  })  : backgroundColor = AppColors.iconPurpleBg,
        iconColor = AppColors.iconPurpleFg,
        size = AppDimensions.iconContainerSize,
        radius = null;

  const VitalIconContainer.gray({
    super.key,
    required this.icon,
  })  : backgroundColor = AppColors.iconGrayBg,
        iconColor = AppColors.iconGrayFg,
        size = AppDimensions.iconContainerSize,
        radius = null;

  const VitalIconContainer.large({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  })  : size = AppDimensions.iconLargeSize,
        radius = AppDimensions.iconLargeRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(
          radius ?? AppDimensions.iconContainerRadius,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.5,
          color: iconColor ?? AppColors.primary,
        ),
      ),
    );
  }
}
