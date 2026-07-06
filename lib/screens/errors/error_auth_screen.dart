import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/vital_error_widget.dart';
import '../../routes/app_routes.dart';

class ErrorAuthScreen extends StatelessWidget {
  const ErrorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: VitalErrorWidget(
          type: ErrorType.danger,
          title: 'Tu sesión ha expirado',
          description: 'Por seguridad, tu sesión ha caducado. Por favor, inicia sesión de nuevo para continuar.',
          code: 'AUTH-002',
          icon: LucideIcons.lock,
          retryLabel: 'Iniciar Sesión con Vital ID',
          onRetry: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
          secondaryLabel: 'Volver al inicio',
          onSecondaryAction: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (_) => false),
          helpText: 'Contactar soporte',
        ),
      ),
    );
  }
}
