import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_input.dart';
import '../../widgets/vital_button.dart';

class EditPatientScreen extends StatefulWidget {
  const EditPatientScreen({super.key});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _nombreController = TextEditingController(text: 'Juan');
  final _apellidoPaternoController = TextEditingController(text: 'Pérez');
  final _apellidoMaternoController = TextEditingController(text: 'García');
  final _telefonoController = TextEditingController(text: '8711514690');
  final _fechaNacimientoController = TextEditingController(text: '1958-05-15');
  final _notasController = TextEditingController(
    text: 'Alérgico a la penicilina. Hipertensión arterial controlada.',
  );
  String _tipoSangre = 'O+';

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingHorizontal,
              ) + const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  _buildAvatarHeader(),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(
                LucideIcons.chevronLeft,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(
                LucideIcons.trash2,
                size: 20,
                color: AppColors.dangerDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight,
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
          ),
          child: const Center(
            child: Text(
              'JG',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Editar Paciente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Modifica la información del paciente',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        VitalInput(
          label: 'NOMBRE',
          controller: _nombreController,
          hintText: 'Nombre del paciente',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: VitalInput(
                label: 'APELLIDO PATERNO',
                controller: _apellidoPaternoController,
                hintText: 'Apellido paterno',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalInput(
                label: 'APELLIDO MATERNO',
                controller: _apellidoMaternoController,
                hintText: 'Apellido materno',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: VitalInput(
                label: 'TELÉFONO',
                controller: _telefonoController,
                hintText: 'Teléfono',
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalInput(
                label: 'FECHA NACIMIENTO',
                controller: _fechaNacimientoController,
                hintText: 'Fecha',
                readOnly: true,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TIPO DE SANGRE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: AppDimensions.inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                border: Border.all(
                  width: 1.33,
                  color: AppColors.borderLight,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _tipoSangre,
                  isExpanded: true,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'A+', child: Text('A+')),
                    DropdownMenuItem(value: 'A-', child: Text('A-')),
                    DropdownMenuItem(value: 'B+', child: Text('B+')),
                    DropdownMenuItem(value: 'B-', child: Text('B-')),
                    DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                    DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                    DropdownMenuItem(value: 'O+', child: Text('O+')),
                    DropdownMenuItem(value: 'O-', child: Text('O-')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _tipoSangre = value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NOTAS MÉDICAS (OPCIONAL)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notasController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Alergias, condiciones médicas, etc.',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPlaceholder,
                ),
                filled: true,
                fillColor: AppColors.bgInput,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                  borderSide: const BorderSide(
                    width: 1.33,
                    color: AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                  borderSide: const BorderSide(
                    width: 1.33,
                    color: AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                  borderSide: const BorderSide(
                    width: 1.33,
                    color: AppColors.primary,
                  ),
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ) + const EdgeInsets.only(top: 12, bottom: 32),
      child: Column(
        children: [
          VitalButton(
            label: 'Guardar cambios',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12),
          VitalButton.ghost(
            label: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Text(
              'Eliminar paciente',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.dangerDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
