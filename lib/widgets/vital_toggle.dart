import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class VitalToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool useBlue;

  const VitalToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.useBlue = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = useBlue ? AppColors.toggleActiveBlue : AppColors.toggleActive;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: AppDimensions.toggleWidth,
        height: AppDimensions.toggleHeight,
        decoration: BoxDecoration(
          color: value ? activeColor : AppColors.toggleInactive,
          borderRadius: BorderRadius.circular(AppDimensions.radiusToggle),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: AppDimensions.toggleKnob,
            height: AppDimensions.toggleKnob,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppDimensions.toggleShadow,
            ),
          ),
        ),
      ),
    );
  }
}
