import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

enum ModalIconType { danger, warning, info, none }

class VitalModal extends StatelessWidget {
  final String title;
  final String? description;
  final String? code;
  final ModalIconType iconType;
  final IconData? icon;
  final List<Widget> actions;

  const VitalModal({
    super.key,
    required this.title,
    this.description,
    this.code,
    this.iconType = ModalIconType.none,
    this.icon,
    required this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    String? code,
    ModalIconType iconType = ModalIconType.none,
    IconData? icon,
    required List<Widget> actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (context) => VitalModal(
        title: title,
        description: description,
        code: code,
        iconType: iconType,
        icon: icon,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconType != ModalIconType.none) ...[
              _buildIcon(),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (code != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  code!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ...actions,
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final (bgColor, fgColor) = switch (iconType) {
      ModalIconType.danger => (AppColors.dangerBg, AppColors.dangerDark),
      ModalIconType.warning => (AppColors.warningBg, AppColors.warning),
      ModalIconType.info => (AppColors.primaryLight, AppColors.primary),
      ModalIconType.none => (Colors.transparent, Colors.transparent),
    };

    return Container(
      width: AppDimensions.modalIconSize,
      height: AppDimensions.modalIconSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? LucideIcons.info,
        size: 24,
        color: fgColor,
      ),
    );
  }
}
