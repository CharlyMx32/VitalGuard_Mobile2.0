import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/vital_error_widget.dart';
import '../../routes/app_routes.dart';

class ErrorServerScreen extends StatelessWidget {
  const ErrorServerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: VitalErrorWidget(
          type: ErrorType.danger,
          title: 'Ha ocurrido un error',
          description: 'El servidor está temporalmente fuera de servicio. Nuestro equipo ya está trabajando para solucionarlo.',
          code: 'SYS-001 / SYS-002',
          icon: LucideIcons.cloudOff,
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
