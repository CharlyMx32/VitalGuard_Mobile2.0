import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/vital_error_widget.dart';


class ErrorTreatmentScreen extends StatelessWidget {
  const ErrorTreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: VitalErrorWidget(
          type: ErrorType.warning,
          title: 'No se pudo guardar el tratamiento',
          description: 'Hay un error en los datos ingresados. Verifica que el compartimento esté libre y que las fechas sean correctas.',
          code: 'TREAT-001 / TREAT-002 / TREAT-003',
          icon: LucideIcons.fileText,
          retryLabel: 'Intentar de nuevo',
          onRetry: () {},
          secondaryLabel: 'Volver a tratamientos',
          onSecondaryAction: () => Navigator.of(context).pop(),
          helpText: 'Contactar soporte',
        ),
      ),
    );
  }
}
