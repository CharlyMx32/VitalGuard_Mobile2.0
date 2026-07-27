import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum VitalSnackType { success, error, warning, info }

class VitalSnack {
  VitalSnack._();

  static void show(
    BuildContext context, {
    required String message,
    VitalSnackType type = VitalSnackType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: config.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: config.shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: config.iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(config.icon, size: 16, color: config.iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: config.textColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Icon(
                  LucideIcons.x,
                  size: 16,
                  color: config.textColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _SnackConfig _getConfig(VitalSnackType type) {
    switch (type) {
      case VitalSnackType.success:
        return _SnackConfig(
          backgroundColor: const Color(0xFFF0FDF4),
          shadowColor: const Color(0x1A22C55E),
          iconBgColor: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          icon: LucideIcons.checkCircle,
          textColor: const Color(0xFF166534),
        );
      case VitalSnackType.error:
        return _SnackConfig(
          backgroundColor: const Color(0xFFFEF2F2),
          shadowColor: const Color(0x1AEF4444),
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          icon: LucideIcons.alertCircle,
          textColor: const Color(0xFF991B1B),
        );
      case VitalSnackType.warning:
        return _SnackConfig(
          backgroundColor: const Color(0xFFFFFBEB),
          shadowColor: const Color(0x1AF59E0B),
          iconBgColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          icon: LucideIcons.alertTriangle,
          textColor: const Color(0xFF92400E),
        );
      case VitalSnackType.info:
        return _SnackConfig(
          backgroundColor: const Color(0xFFEFF6FF),
          shadowColor: const Color(0x1A3B82F6),
          iconBgColor: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          icon: LucideIcons.info,
          textColor: const Color(0xFF1E40AF),
        );
    }
  }
}

class _SnackConfig {
  final Color backgroundColor;
  final Color shadowColor;
  final Color iconBgColor;
  final Color iconColor;
  final IconData icon;
  final Color textColor;

  const _SnackConfig({
    required this.backgroundColor,
    required this.shadowColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.icon,
    required this.textColor,
  });
}
