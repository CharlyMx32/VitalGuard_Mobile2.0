import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/patient_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/vital_modal.dart';
import '../../models/patient.dart';
import '../../widgets/vital_header.dart';

class SendRequestsScreen extends StatefulWidget {
  const SendRequestsScreen({super.key});

  @override
  State<SendRequestsScreen> createState() => _SendRequestsScreenState();
}

class _SendRequestsScreenState extends State<SendRequestsScreen> {
  Patient? _selectedPatient;
  List<Patient> _patients = [];
  bool _loadingPatients = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patientService = context.read<PatientService>();
    final patients = await patientService.getPatients();
    if (mounted) setState(() { _patients = patients; _loadingPatients = false; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isSelfCare = auth.isSelfCare;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Enviar Solicitudes'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSelfCare)
                    const Text('Selecciona el tipo de solicitud que deseas enviar. Se compartirá un enlace seguro.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5))
                  else ...[
                    const Text('Selecciona el paciente y luego el tipo de solicitud.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
                    const SizedBox(height: 16),
                    _buildPatientSelector(),
                  ],
                  const SizedBox(height: 20),
                  if (_selectedPatient != null || isSelfCare) ...[
                    _buildRequestCard(context, LucideIcons.users, AppColors.accentLight, AppColors.primary, 'Solicitud de Cuidador',
                      'Invita a otro cuidador a unirse', slug: 'cuidador'),
                    const SizedBox(height: 12),
                    _buildRequestCard(context, LucideIcons.userCheck, AppColors.accentLight, AppColors.accent, 'Autocuidado',
                      'El paciente gestiona sus propios medicamentos', slug: 'autocuidado'),
                    const SizedBox(height: 12),
                    _buildRequestCard(context, LucideIcons.activity, const Color(0xFFF3E8FF), const Color(0xFF9B59B6), 'Vincular Médico',
                      'Invita a un médico tratante', slug: 'medico'),
                  ] else if (!isSelfCare && !_loadingPatients) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Icon(LucideIcons.userCheck, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('Selecciona un paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          const Text('Elige para qué paciente quieres enviar la solicitud', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSelector() {
    if (_loadingPatients) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_patients.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Paciente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedPatient?.id,
              hint: const Text('Seleccionar paciente', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
              items: _patients.map((p) => DropdownMenuItem(
                value: p.id,
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(p.initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
                    ),
                    const SizedBox(width: 10),
                    Text(p.fullName, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                  ],
                ),
              )).toList(),
              onChanged: (id) {
                final patient = _patients.firstWhere((p) => p.id == id);
                setState(() => _selectedPatient = patient);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, IconData icon, Color bg, Color fg, String title, String desc, {required String slug}) {
    return GestureDetector(
      onTap: () => _shareRequest(context, title, slug),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)), child: Icon(icon, size: 28, color: fg)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
          ])),
          const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
        ]),
      ),
    );
  }

  Future<void> _shareRequest(BuildContext context, String title, String slug) async {
    final auth = context.read<AuthService>();
    final isSelfCare = auth.isSelfCare;
    final patientName = isSelfCare ? (auth.firstName ?? '') : (_selectedPatient?.fullName ?? '');
    final link = 'https://vitalguard.app/invite/$slug';
    await SharePlus.instance.share(
      ShareParams(
        text: 'Te invito a unirte a VitalGuard como $title para $patientName.\n$link',
        subject: 'Invitación a VitalGuard - $title',
      ),
    );
    if (context.mounted) {
      VitalFeedback.success(
        context,
        code: 'SHARE_SUCCESS',
        message: 'Invitación de $title para $patientName compartida correctamente.',
      );
    }
  }
}
