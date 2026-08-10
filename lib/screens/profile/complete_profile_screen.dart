import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../widgets/vital_form_field.dart';
import '../../utils/vital_validator.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _nameController.text = auth.firstName ?? '';
    _lastNameController.text = auth.paternalLastName ?? '';
    _phoneController.text = auth.phone ?? '';
    final birth = auth.birthDate;
    if (birth != null) {
      final d = DateTime.tryParse(birth);
      if (d != null) {
        _birthDateController.text =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String? _parseBirthDate() {
    final text = _birthDateController.text.trim();
    if (text.isEmpty) return null;
    final parts = text.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _buildPatientData() {
    final auth = context.read<AuthService>();
    final birthDate = _parseBirthDate() ?? auth.birthDate;
    return {
      'firstName': _nameController.text.trim(),
      'paternalLastName': _lastNameController.text.trim(),
      'maternalLastName': ?(auth.maternalLastName?.isNotEmpty == true ? auth.maternalLastName : null),
      'birthDate': ?birthDate,
      'gender': ?auth.gender,
      if (_phoneController.text.trim().isNotEmpty)
        'phone': _phoneController.text.trim(),
      'email': ?auth.email,    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 100),
              child: Column(
                children: [
                  _buildWelcomeBanner(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('INFORMACIÓN PERSONAL'),
                  const SizedBox(height: 8),
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: GestureDetector(
        onTap: () async {
          final name = _nameController.text.trim();
          final lastName = _lastNameController.text.trim();
          if (name.isEmpty || lastName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ingresa tu nombre y apellido'), backgroundColor: AppColors.warning),
            );
            return;
          }
          final auth = context.read<AuthService>();
          final apiClient = context.read<ApiClient>();
          final isSelfCare = auth.isSelfCare;
          int? patientId;
          try {
            final birthDate = _parseBirthDate();
            debugPrint('[Onboarding] Sending POST /app-profiles/onboarding with role: ${isSelfCare ? "PATIENT" : "CAREGIVER"}');
            final response = await apiClient.post('/app-profiles/onboarding', data: {
              'role': isSelfCare ? 'PATIENT' : 'CAREGIVER',
              if (isSelfCare)
                'patientData': {
                  ..._buildPatientData(),
                  'birthDate': ?birthDate,
                },
            });
            debugPrint('[Onboarding] Response: ${response.statusCode} ${response.data}');
            final data = (response.data as Map<String, dynamic>?) ?? {};
            patientId = data['patientId'] is int ? data['patientId'] as int : null;
            if (patientId is int) await auth.setPatientId(patientId);
          } on DioException catch (e) {
            if (e.response?.statusCode == 409) {
              debugPrint('[Onboarding] Profile already exists (409), continuing...');
            } else {
              debugPrint('[Onboarding] DioException: ${e.response?.statusCode} ${e.message}');
            }
          } catch (e) {
            debugPrint('[Onboarding] Unexpected error: $e');
          }
          auth.completeProfile(isSelfCare: isSelfCare);
          if (!context.mounted) return;
          final nextRoute = isSelfCare ? AppRoutes.selfCareProfile : AppRoutes.firstPatient;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.linkDevice,
            (route) => false,
            arguments: {
              'next': nextRoute,
              'patientId': patientId,
              ..._buildPatientData(),
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal, vertical: 16),
          color: AppColors.bg,
          child: Container(
            width: double.infinity, height: 48,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LucideIcons.check, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text('Continuar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(children: [
        Row(children: [
          const SizedBox(width: 32),
          const Expanded(child: Text('Completa tu Perfil', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ]),
        const SizedBox(height: 4),
        const Text('Necesitamos algunos datos para continuar', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(LucideIcons.user, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bienvenido a VitalGuard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 2),
          Text('Completa tus datos para continuar', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
        ]),
        ),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)));
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(children: [
        Row(children: [
          Expanded(child: VitalFormField(
            label: 'Nombre',
            controller: _nameController,
            hint: 'Nombre',
            validator: VitalValidator.firstName,
            onChanged: (_) => setState(() {}),
          )),
          const SizedBox(width: 12),
          Expanded(child: VitalFormField(
            label: 'Apellido',
            controller: _lastNameController,
            hint: 'Apellido',
            validator: VitalValidator.paternalLastName,
            onChanged: (_) => setState(() {}),
          )),
        ]),
        const SizedBox(height: 14),
        VitalFormField(
          label: 'Telefono',
          controller: _phoneController,
          hint: '10 digitos',
          inputType: VitalInputType.phone,
          validator: VitalValidator.phone,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        VitalFormField(
          label: 'Fecha de nacimiento',
          inputType: VitalInputType.date,
          displayValue: _birthDateController.text.isNotEmpty ? _birthDateController.text : null,
          hint: 'DD/MM/AAAA',
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime(1985, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _birthDateController.text =
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
              });
            }
          },
        ),
      ]),
    );
  }
}
