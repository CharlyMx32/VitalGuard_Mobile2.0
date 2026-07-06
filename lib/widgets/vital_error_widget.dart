import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'vital_button.dart';

enum ErrorType { danger, warning, info }

class VitalErrorWidget extends StatelessWidget {
  final ErrorType type;
  final String title;
  final String description;
  final String code;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryLabel;
  final String? helpText;

  const VitalErrorWidget({
    super.key,
    this.type = ErrorType.danger,
    required this.title,
    required this.description,
    required this.code,
    this.icon = LucideIcons.alertCircle,
    this.onRetry,
    this.retryLabel = 'Reintentar',
    this.onSecondaryAction,
    this.secondaryLabel,
    this.helpText,
  });

  const VitalErrorWidget.network({
    super.key,
    this.onRetry,
  })  : type = ErrorType.danger,
        title = 'Sin Conexion',
        description = 'No se pudo conectar al servidor.\nVerifica tu conexion.',
        code = 'AUTH-001',
        icon = LucideIcons.wifiOff,
        retryLabel = 'Reintentar',
        onSecondaryAction = null,
        secondaryLabel = null,
        helpText = null;

  const VitalErrorWidget.server({
    super.key,
    this.onRetry,
  })  : type = ErrorType.danger,
        title = 'Error del Servidor',
        description = 'El servidor no responde.\nIntenta mas tarde.',
        code = 'SYS-002',
        icon = LucideIcons.cloudOff,
        retryLabel = 'Reintentar',
        onSecondaryAction = null,
        secondaryLabel = null,
        helpText = null;

  const VitalErrorWidget.auth({
    super.key,
    this.onRetry,
  })  : type = ErrorType.danger,
        title = 'Sesion Expirada',
        description = 'Tu sesion expiro.\nInicia sesion nuevamente.',
        code = 'AUTH-003',
        icon = LucideIcons.lock,
        retryLabel = 'Ir al Login',
        onSecondaryAction = null,
        secondaryLabel = null,
        helpText = null;

  const VitalErrorWidget.device({
    super.key,
    this.onRetry,
  })  : type = ErrorType.danger,
        title = 'Dispositivo Offline',
        description = 'El dispositivo no responde.\nVerifica WiFi y energia.',
        code = 'DEV-001',
        icon = LucideIcons.monitorOff,
        retryLabel = 'Reintentar',
        onSecondaryAction = null,
        secondaryLabel = null,
        helpText = null;

  const VitalErrorWidget.treatment({
    super.key,
    this.onRetry,
  })  : type = ErrorType.danger,
        title = 'Error Tratamiento',
        description = 'No se pudo guardar el\ntratamiento.',
        code = 'TREAT-002',
        icon = LucideIcons.pill,
        retryLabel = 'Reintentar',
        onSecondaryAction = null,
        secondaryLabel = null,
        helpText = null;

  const VitalErrorWidget.generic({
    super.key,
    this.onRetry,
  })  : type = ErrorType.danger,
        title = 'Error Generico',
        description = 'Algo salio mal.\nIntenta de nuevo\no contacta soporte.',
        code = 'SYS-001',
        icon = LucideIcons.alertCircle,
        retryLabel = 'Reintentar',
        onSecondaryAction = null,
        secondaryLabel = null,
        helpText = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingHorizontal,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            _buildIcon(),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Code badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Actions
            if (onRetry != null)
              VitalButton.primary(
                label: retryLabel,
                onPressed: onRetry,
              ),
            if (onSecondaryAction != null && secondaryLabel != null) ...[
              const SizedBox(height: 12),
              VitalButton.ghost(
                label: secondaryLabel!,
                onPressed: onSecondaryAction,
              ),
            ],
            // Help
            if (helpText != null) ...[
              const SizedBox(height: 24),
              Text(
                helpText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final (bgColor, fgColor) = switch (type) {
      ErrorType.danger => (AppColors.dangerBg, AppColors.dangerDark),
      ErrorType.warning => (AppColors.warningBg, AppColors.warning),
      ErrorType.info => (AppColors.primaryLight, AppColors.primary),
    };

    return Container(
      width: AppDimensions.errorIconSize,
      height: AppDimensions.errorIconSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 36,
        color: fgColor,
      ),
    );
  }
}
