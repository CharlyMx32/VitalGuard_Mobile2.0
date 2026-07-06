import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class VitalHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? child;
  final bool colored;
  final Widget? leading;
  final List<Widget>? actions;
  final double? height;
  final Gradient? gradient;

  const VitalHeader({
    super.key,
    this.title,
    this.child,
    this.colored = false,
    this.leading,
    this.actions,
    this.height,
    this.gradient,
  });

  const VitalHeader.colored({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.actions,
    this.height,
    this.gradient,
  }) : colored = true;

  const VitalHeader.white({
    super.key,
    required this.title,
    this.child,
    this.leading,
    this.actions,
    this.height,
  })  : colored = false,
        gradient = null;

  @override
  Size get preferredSize => Size.fromHeight(height ?? (colored ? 160 : 100));

  @override
  Widget build(BuildContext context) {
    if (colored) {
      return _buildColoredHeader(context);
    }
    return _buildWhiteHeader(context);
  }

  Widget _buildColoredHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.gradientPrimary,
        color: gradient == null ? AppColors.primary : null,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusHeaderBottom),
          bottomRight: Radius.circular(AppDimensions.radiusHeaderBottom),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: AppDimensions.paddingHeaderBottom,
      ),
      child: child,
    );
  }

  Widget _buildWhiteHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ] else ...[
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Center(
              child: Text(
                title ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (actions != null) ...actions!,
          if (actions == null) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
