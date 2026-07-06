import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class VitalInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? errorText;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const VitalInput({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.errorText,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: maxLines == 1 ? AppDimensions.inputHeight : null,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefix,
              suffixIcon: suffix,
              errorText: errorText,
              filled: true,
              fillColor: enabled ? AppColors.bg : AppColors.bgCard,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: const BorderSide(
                  width: 1.33,
                  color: AppColors.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: const BorderSide(
                  width: 1.33,
                  color: AppColors.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: const BorderSide(
                  width: 1.33,
                  color: AppColors.primary,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: const BorderSide(
                  width: 1.33,
                  color: AppColors.dangerDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
