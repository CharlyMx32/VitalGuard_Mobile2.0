import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/vital_error_widget.dart';
import '../../routes/app_routes.dart';

class ErrorNetworkScreen extends StatelessWidget {
  const ErrorNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: VitalErrorWidget(
          type: ErrorType.info,
          title: 'Sin conexión a internet',
          description: 'No se pudo establecer conexión con el servidor. Verifica tu conexión WiFi o datos móviles e intenta de nuevo.',
          code: 'SYS-003 / DEV-003',
          icon: LucideIcons.wifiOff,
          retryLabel: 'Reintentar conexión',
          onRetry: () {},
          secondaryLabel: 'Volver al inicio',
          onSecondaryAction: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (_) => false),
          helpText: 'Contactar soporte',
        ),
      ),
    );
  }
}
