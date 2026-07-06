import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/vital_error_widget.dart';
import '../../routes/app_routes.dart';

class ErrorGenericScreen extends StatelessWidget {
  const ErrorGenericScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: VitalErrorWidget(
          type: ErrorType.info,
          title: 'Ha ocurrido un error inesperado',
          description: 'No pudimos procesar tu solicitud. Si el problema persiste, contacta a nuestro equipo de soporte con el código de error.',
          code: 'SYS-001',
          icon: LucideIcons.alertCircle,
          retryLabel: 'Reintentar',
          onRetry: () {},
          secondaryLabel: 'Volver al inicio',
          onSecondaryAction: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (_) => false),
          helpText: 'Contactar soporte',
        ),
      ),
    );
  }
}
