import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_input.dart';
import '../../widgets/vital_button.dart';
import '../../widgets/vital_modal.dart';
import '../../services/patient_service.dart';
import '../../services/auth_service.dart';
import '../../models/patient.dart';
import '../../models/enums.dart';

class EditPatientScreen extends StatefulWidget {
  const EditPatientScreen({super.key});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _notasController = TextEditingController();
  String _tipoSangre = 'O+';
  int? _patientId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _patientId =
        ModalRoute.of(context)?.settings.arguments as int?;
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patientService = context.read<PatientService>();
    final auth = context.read<AuthService>();
    final id = _patientId ?? auth.patientId;
    _patientId = id;
    Patient? patient;
    try {
      patient = await patientService.getPatient(id);
    } catch (_) {
      patient = null;
    }
    if (!mounted) return;
    setState(() {
      _nombreController.text = patient?.firstName ?? '';
      _apellidoPaternoController.text = patient?.paternalLastName ?? '';
      _apellidoMaternoController.text = patient?.maternalLastName ?? '';
      _telefonoController.text = patient?.phone ?? '';
      if (patient != null) {
        final b = patient.birthDate;
        _fechaNacimientoController.text =
            '${b.year}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';
      }
      _notasController.text = patient?.medicalNotes ?? '';
      _tipoSangre = patient?.bloodType?.displayValue ?? 'O+';
      _loading = false;
    });
  }

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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar paciente'),
                  content: const Text('¿Estás seguro de que quieres eliminar este paciente?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Paciente eliminado'), backgroundColor: AppColors.dangerDark),
                        );
                      },
                      child: const Text('Eliminar', style: TextStyle(color: AppColors.dangerDark)),
                    ),
                  ],
                ),
              );
            },
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

  Future<void> _onSave() async {
    final patientService = context.read<PatientService>();
    final auth = context.read<AuthService>();
    final patients = await patientService.getPatients();
    final id = _patientId ?? auth.patientId;
    final existing = patients.where((p) => p.id == id).firstOrNull;
    final bloodType = BloodType.values
        .where((b) => b.displayValue == _tipoSangre)
        .firstOrNull;
    final patient = Patient(
      id: existing?.id ?? id,
      firstName: _nombreController.text.trim().isEmpty
          ? '---'
          : _nombreController.text.trim(),
      paternalLastName: _apellidoPaternoController.text.trim().isEmpty
          ? '---'
          : _apellidoPaternoController.text.trim(),
      maternalLastName: _apellidoMaternoController.text.trim().isEmpty
          ? null
          : _apellidoMaternoController.text.trim(),
      birthDate: DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime(2000),
      gender: existing?.gender ?? GenderType.f,
      phone: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      bloodType: bloodType,
      medicalNotes: _notasController.text.trim().isEmpty
          ? null
          : _notasController.text.trim(),
    );
    await patientService.updatePatient(patient);
    if (mounted) {
      VitalFeedback.success(
        context,
        code: 'PATIENT_UPDATED',
        message: 'Información del paciente actualizada correctamente',
        onAction: () => Navigator.of(context).pop(),
      );
    }
  }

  Widget _buildForm() {    return Column(
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
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1958, 5, 15),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _fechaNacimientoController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
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
            onPressed: _onSave,
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
