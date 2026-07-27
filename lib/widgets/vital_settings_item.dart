import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class VitalSettingsItem extends StatelessWidget {
  final IconData icon;
  final Color? iconBgColor;
  final Color? iconFgColor;
  final String label;
  final String? description;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;

  const VitalSettingsItem({
    super.key,
    required this.icon,
    this.iconBgColor,
    this.iconFgColor,
    required this.label,
    this.description,
    this.value,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () {
        HapticFeedback.lightImpact();
        onTap!();
      },
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon container
            Container(
              width: AppDimensions.iconContainerSize,
              height: AppDimensions.iconContainerSize,
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimensions.iconContainerRadius),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: iconFgColor ?? AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Label + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Value or trailing or arrow
            if (trailing != null)
              trailing!
            else if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            if (trailing == null)
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.textLight,
              ),
          ],
        ),
      ),
    );
  }
}

class VitalSettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const VitalSettingsGroup({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppDimensions.settingsGroupShadow,
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                thickness: 1.33,
                color: AppColors.borderLight,
              ),
          ],
        ],
      ),
    );
  }
}
