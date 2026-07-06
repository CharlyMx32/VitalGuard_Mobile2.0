import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/vital_error_widget.dart';
import '../../routes/app_routes.dart';

class ErrorDeviceScreen extends StatelessWidget {
  const ErrorDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: VitalErrorWidget(
          type: ErrorType.warning,
          title: 'Pastillero desconectado',
          description: 'El dispositivo se encuentra offline o no responde. Verifica la conexión a WiFi y la alimentación eléctrica.',
          code: 'DEV-004 / DEV-005',
          icon: LucideIcons.monitorOff,
          retryLabel: 'Reintentar conexión',
          onRetry: () {},
          secondaryLabel: 'Configurar WiFi',
          onSecondaryAction: () => Navigator.of(context).pushNamed(AppRoutes.wifiSetup),
          helpText: 'Contactar soporte',
        ),
      ),
    );
  }
}
