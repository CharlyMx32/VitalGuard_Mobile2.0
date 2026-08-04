import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'vital_button.dart';

enum ModalIconType { success, danger, warning, info, none }

/// Modal único de feedback del backend.
///
/// Mapea un `code` devuelto por la API a un tipo visual
/// (éxito / error / advertencia / info) y muestra el `message`
/// textual que envía el servidor.
class VitalFeedback {
  VitalFeedback._();

  static Future<void> show(
    BuildContext context, {
    String? code,
    String? message,
    String? title,
    String actionLabel = 'Entendido',
    VoidCallback? onAction,
  }) {
    final type = _typeFromCode(code);
    return VitalModal.show<void>(
      context: context,
      title: title ?? _defaultTitle(type),
      description: message,
      code: code,
      iconType: type,
      icon: _defaultIcon(type),
      actions: [
        VitalButton(
          label: actionLabel,
          onPressed: () {
            Navigator.of(context).pop();
            onAction?.call();
          },
        ),
      ],
    );
  }

  static Future<void> success(
    BuildContext context, {
    String? code,
    required String message,
    String? title,
    VoidCallback? onAction,
  }) {
    return show(
      context,
      code: code ?? 'SUCCESS',
      message: message,
      title: title,
      onAction: onAction,
    );
  }

  static Future<void> error(
    BuildContext context, {
    String? code,
    required String message,
    String? title,
    VoidCallback? onAction,
  }) {
    return show(
      context,
      code: code ?? 'ERROR',
      message: message,
      title: title,
      onAction: onAction,
    );
  }

  static Future<void> warning(
    BuildContext context, {
    String? code,
    required String message,
    String? title,
    VoidCallback? onAction,
  }) {
    return show(
      context,
      code: code ?? 'WARNING',
      message: message,
      title: title,
      onAction: onAction,
    );
  }

  static Future<void> info(
    BuildContext context, {
    String? code,
    required String message,
    String? title,
    VoidCallback? onAction,
  }) {
    return show(
      context,
      code: code ?? 'INFO',
      message: message,
      title: title,
      onAction: onAction,
    );
  }

  static ModalIconType _typeFromCode(String? code) {
    if (code == null || code.isEmpty) return ModalIconType.info;
    final c = code.toUpperCase();
    if (c.contains('SUCCESS') ||
        c.contains('OK') ||
        c.contains('CREATED') ||
        c.startsWith('2')) {
      return ModalIconType.success;
    }
    if (c.contains('ERROR') ||
        c.contains('FAIL') ||
        c.contains('INVALID') ||
        c.startsWith('4') ||
        c.startsWith('5')) {
      return ModalIconType.danger;
    }
    if (c.contains('WARN')) return ModalIconType.warning;
    return ModalIconType.info;
  }

  static String _defaultTitle(ModalIconType type) {
    switch (type) {
      case ModalIconType.success: return 'Operación exitosa';
      case ModalIconType.danger: return 'Ocurrió un error';
      case ModalIconType.warning: return 'Atención';
      case ModalIconType.info: return 'Información';
      case ModalIconType.none: return 'Aviso';
    }
  }

  static IconData _defaultIcon(ModalIconType type) {
    switch (type) {
      case ModalIconType.success: return LucideIcons.checkCircle;
      case ModalIconType.danger: return LucideIcons.alertCircle;
      case ModalIconType.warning: return LucideIcons.alertTriangle;
      case ModalIconType.info: return LucideIcons.info;
      case ModalIconType.none: return LucideIcons.info;
    }
  }
}

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
      ModalIconType.success => (AppColors.accentLight, AppColors.accent),
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
