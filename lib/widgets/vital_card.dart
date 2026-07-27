import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'vital_tap.dart';

class VitalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? borderColor;

  const VitalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.cardMarginHorizontal,
      ) + const EdgeInsets.only(bottom: AppDimensions.cardMarginBottom),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppDimensions.radiusCard,
        ),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppDimensions.radiusCard,
        ),
        child: borderColor != null
            ? _BorderedCard(borderColor: borderColor!, child: child)
            : Padding(
                padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
                child: child,
              ),
      ),
    );

    if (onTap != null) {
      return VitalTap(onTap: onTap, child: card);
    }
    return card;
  }
}

class _BorderedCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  const _BorderedCard({required this.child, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusCard),
                bottomLeft: Radius.circular(AppDimensions.radiusCard),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class VitalCompactCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const VitalCompactCard({
    super.key,
    required this.child,
    this.margin,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ) + const EdgeInsets.only(bottom: AppDimensions.gapSmall),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        boxShadow: AppDimensions.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: child,
    );

    if (onTap != null) {
      return VitalTap(onTap: onTap, child: card);
    }
    return card;
  }
}
