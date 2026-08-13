import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_service.dart';
import '../../services/auth_service.dart';
import '../../models/patient.dart';
import '../../models/enums.dart';
import '../../widgets/vital_modal.dart';
import '../../widgets/vital_form_field.dart';
import '../../utils/vital_validator.dart';

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
  KinshipType _kinship = KinshipType.otro;
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

  bool get _isProfileComplete => context.read<AuthService>().isProfileComplete;

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
        Expanded(
          child: VitalFormField(
            label: 'Nombre',
            controller: _nameController,
            hint: 'Nombre',
            validator: VitalValidator.firstName,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VitalFormField(
            label: 'Apellido paterno',
            controller: _lastNameController,
            hint: 'Apellido',
            validator: VitalValidator.paternalLastName,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ]),
      const SizedBox(height: 14),
      VitalFormField(
        label: 'Apellido materno (opcional)',
        controller: _maternalLastNameController,
        hint: 'Apellido materno',
        validator: VitalValidator.maternalLastName,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _buildDateField()),
        const SizedBox(width: 12),
        Expanded(child: _buildGenderField()),
      ]),
      const SizedBox(height: 14),
      VitalFormField(
        label: 'Telefono (opcional)',
        controller: _phoneController,
        hint: '10 digitos',
        inputType: VitalInputType.phone,
        validator: VitalValidator.phone,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      VitalFormField(
        label: 'Direccion (opcional)',
        controller: _addressController,
        hint: 'Calle y numero',
        validator: VitalValidator.address,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      _buildBloodTypeField(),
      const SizedBox(height: 14),
      _buildKinshipField(),
      const SizedBox(height: 14),
      VitalFormField(
        label: 'Notas medicas (opcional)',
        controller: _medicalNotesController,
        hint: 'Enfermedades cronicas, alergias...',
        validator: VitalValidator.doseInfo,
        onChanged: (_) => setState(() {}),
      ),
    ]);
  }

  Widget _buildDateField() {
    return VitalFormField(
      label: 'Fecha nacimiento',
      inputType: VitalInputType.date,
      displayValue: _birthDate != null
          ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
          : null,
      hint: 'DD/MM/AAAA',
      validator: VitalValidator.birthDate,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthDate ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _birthDate = picked);
        }
      },
    );
  }

  Widget _buildGenderField() {
    return VitalFormField(
      label: 'Genero',
      inputType: VitalInputType.dropdown,
      displayValue: _gender == GenderType.m ? 'Masculino' : 'Femenino',
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Masculino'),
                  onTap: () { setState(() => _gender = GenderType.m); Navigator.pop(context); },
                ),
                ListTile(
                  title: const Text('Femenino'),
                  onTap: () { setState(() => _gender = GenderType.f); Navigator.pop(context); },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBloodTypeField() {
    return VitalFormField(
      label: 'Tipo de sangre (opcional)',
      inputType: VitalInputType.dropdown,
      displayValue: _bloodType?.displayValue,
      hint: 'Seleccionar',
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: BloodType.values.map((bt) => ListTile(
                title: Text(bt.displayValue),
                onTap: () { setState(() => _bloodType = bt); Navigator.pop(context); },
              )).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKinshipField() {
    return VitalFormField(
      label: 'Parentesco',
      inputType: VitalInputType.dropdown,
      displayValue: _kinship.displayValue,
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: KinshipType.values.map((k) => ListTile(
                title: Text(k.displayValue),
                onTap: () { setState(() => _kinship = k); Navigator.pop(context); },
              )).toList(),
            ),
          ),
        );
      },
    );
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
        if (!_isProfileComplete) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Completar despues', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
        ],
      ]),
    );
  }

  Future<void> _onSave() async {
    // Run all validators
    final nameErr = VitalValidator.firstName(_nameController.text);
    final lastErr = VitalValidator.paternalLastName(_lastNameController.text);
    final birthErr = VitalValidator.birthDate(
      _birthDate != null ? _birthDate!.toIso8601String().split('T')[0] : null,
    );
    final phoneErr = VitalValidator.phone(_phoneController.text);

    if (nameErr != null || lastErr != null || birthErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios'), backgroundColor: AppColors.warning),
      );
      return;
    }
    if (phoneErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneErr), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isSaving = true);

    final patientService = context.read<PatientService>();
    final auth = context.read<AuthService>();
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final patient = Patient(
      id: 0,
      firstName: _nameController.text.trim(),
      paternalLastName: _lastNameController.text.trim(),
      maternalLastName: _maternalLastNameController.text.trim().isEmpty ? null : _maternalLastNameController.text.trim(),
      birthDate: _birthDate!,
      gender: _gender,
      phone: phoneDigits.isEmpty ? null : phoneDigits,
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      bloodType: _bloodType,
      medicalNotes: _medicalNotesController.text.trim().isEmpty ? null : _medicalNotesController.text.trim(),
    );

    try {
      final saved = await patientService.createPatient(patient, kinship: _kinship);
      await auth.setPatientId(saved.id);

      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments;
      final returnToDashboard = args is Map ? (args['returnToDashboard'] as bool? ?? false) : false;
      VitalFeedback.success(
        context,
        code: 'PATIENT_CREATED',
        message: 'Paciente ${saved.fullName} registrado correctamente',
        onAction: () => returnToDashboard
            ? Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false)
            : Navigator.pop(context),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
