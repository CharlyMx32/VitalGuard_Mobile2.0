import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

enum VitalButtonType { primary, outline, ghost, danger }

class VitalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VitalButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const VitalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = VitalButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  const VitalButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : type = VitalButtonType.primary;

  const VitalButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : type = VitalButtonType.outline;

  const VitalButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : type = VitalButtonType.ghost;

  const VitalButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : type = VitalButtonType.danger;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: AppDimensions.buttonHeight,
      child: switch (type) {
        VitalButtonType.primary => _buildPrimary(),
        VitalButtonType.outline => _buildOutline(),
        VitalButtonType.ghost => _buildGhost(),
        VitalButtonType.danger => _buildDanger(),
      },
    );
  }

  Widget _buildPrimary() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
      ),
      child: _buildChild(Colors.white),
    );
  }

  Widget _buildOutline() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
      ),
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildGhost() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
      ),
      child: _buildChild(AppColors.textMuted),
    );
  }

  Widget _buildDanger() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dangerBg,
        foregroundColor: AppColors.dangerDark,
        elevation: 0,
        side: const BorderSide(color: AppColors.dangerDark, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
      ),
      child: _buildChild(AppColors.dangerDark),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
        ],
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
