import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/patient_service.dart';
import '../../services/auth_service.dart';
import '../../models/patient.dart';
import '../../models/enums.dart';
import '../../widgets/vital_modal.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _maternalLastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  DateTime? _birthDate;
  GenderType _gender = GenderType.m;
  BloodType? _bloodType;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _maternalLastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24) + const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 16),
                  const Text('Datos del paciente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  const Text('Completa la informacion medica del paciente',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.primary))),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentLight,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: const Icon(LucideIcons.user, size: 36, color: AppColors.primary),
    );
  }

  Widget _buildForm() {
    return Column(children: [
      Row(children: [
        Expanded(child: _buildField('Nombre', _nameController, 'Nombre')),
        const SizedBox(width: 12),
        Expanded(child: _buildField('Apellido paterno', _lastNameController, 'Apellido')),
      ]),
      const SizedBox(height: 14),
      _buildField('Apellido materno (opcional)', _maternalLastNameController, 'Apellido materno'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _buildDateField()),
        const SizedBox(width: 12),
        Expanded(child: _buildGenderField()),
      ]),
      const SizedBox(height: 14),
      _buildField('Telefono (opcional)', _phoneController, 'Ej: +52 55 1234 5678'),
      const SizedBox(height: 14),
      _buildField('Direccion (opcional)', _addressController, 'Calle y numero'),
      const SizedBox(height: 14),
      _buildBloodTypeField(),
      const SizedBox(height: 14),
      _buildField('Notas medicas (opcional)', _medicalNotesController, 'Enfermedades cronicas, alergias...'),
    ]);
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
      const SizedBox(height: 5),
      Container(
        height: 48,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14), hintText: hint, hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ),
      ),
    ]);
  }

  Widget _buildDateField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('FECHA NACIMIENTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
      const SizedBox(height: 5),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: _birthDate ?? DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now());
          if (picked != null) setState(() => _birthDate = picked);
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
          child: Row(children: [
            const SizedBox(width: 14),
            Expanded(child: Text(
              _birthDate != null ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}' : 'DD/MM/AAAA',
              style: TextStyle(fontSize: 14, color: _birthDate != null ? AppColors.textDark : AppColors.textMuted),
            )),
            const Icon(LucideIcons.calendar, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 14),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildGenderField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('GENERO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
      const SizedBox(height: 5),
      Container(
        height: 48,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: Row(children: [
          const SizedBox(width: 14),
          Expanded(child: Text(_gender == GenderType.m ? 'Masculino' : 'Femenino', style: const TextStyle(fontSize: 14, color: AppColors.textDark))),
          PopupMenuButton<GenderType>(
            icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
            onSelected: (v) => setState(() => _gender = v),
            itemBuilder: (context) => [
              const PopupMenuItem(value: GenderType.m, child: Text('Masculino')),
              const PopupMenuItem(value: GenderType.f, child: Text('Femenino')),
            ],
          ),
        ]),
      ),
    ]);
  }

  Widget _buildBloodTypeField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('TIPO DE SANGRE (OPCIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
      const SizedBox(height: 5),
      Container(
        height: 48,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: Row(children: [
          const SizedBox(width: 14),
          Expanded(child: Text(_bloodType?.displayValue ?? 'Seleccionar', style: TextStyle(fontSize: 14, color: _bloodType != null ? AppColors.textDark : AppColors.textMuted))),
          PopupMenuButton<BloodType>(
            icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
            onSelected: (v) => setState(() => _bloodType = v),
            itemBuilder: (context) => BloodType.values.map((bt) => PopupMenuItem(value: bt, child: Text(bt.displayValue))).toList(),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(children: [
        GestureDetector(
          onTap: _isSaving ? null : _onSave,
          child: Container(
            width: double.infinity, height: 48,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text('Completar despues', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
      ]),
    );
  }

  Future<void> _onSave() async {
    if (_nameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y apellido son obligatorios'), backgroundColor: AppColors.warning),
      );
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de nacimiento es obligatoria'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isSaving = true);

    final patientService = context.read<PatientService>();
    final auth = context.read<AuthService>();

    final patient = Patient(
      id: DateTime.now().millisecondsSinceEpoch,
      firstName: _nameController.text.trim(),
      paternalLastName: _lastNameController.text.trim(),
      maternalLastName: _maternalLastNameController.text.trim().isEmpty ? null : _maternalLastNameController.text.trim(),
      birthDate: _birthDate!,
      gender: _gender,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      bloodType: _bloodType,
      medicalNotes: _medicalNotesController.text.trim().isEmpty ? null : _medicalNotesController.text.trim(),
    );

    final saved = await patientService.createPatient(patient);
    await auth.setPatientId(saved.id);

    if (mounted) {
      VitalFeedback.success(
        context,
        code: 'PATIENT_CREATED',
        message: 'Paciente ${saved.fullName} registrado correctamente',
        onAction: () => Navigator.pop(context),
      );
    }
  }
}
