import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/patient_service.dart';
import '../../services/auth_service.dart';
import '../../services/invitation_service.dart';
import '../../models/enums.dart';
import '../../models/invitation.dart';
import '../../widgets/vital_modal.dart';
import '../../models/patient.dart';
import '../../widgets/vital_header.dart';
import '../../widgets/vital_form_field.dart';
import '../../widgets/vital_button.dart';
import '../../routes/app_routes.dart';

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
                      'Invita a otro cuidador a unirse por email', onTap: () => _openInviteSheet(context, 'Cuidador', InvitationRole.caregiver)),
                    const SizedBox(height: 12),
                    _buildRequestCard(context, LucideIcons.activity, const Color(0xFFF3E8FF), const Color(0xFF9B59B6), 'Vincular Médico',
                      'Invita a un médico tratante por email', onTap: () => _openInviteSheet(context, 'Médico', InvitationRole.doctor)),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.pendingInvitations),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
                        child: const Row(children: [
                          Icon(LucideIcons.inbox, size: 20, color: AppColors.primary),
                          SizedBox(width: 12),
                          Expanded(child: Text('Ver invitaciones pendientes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark))),
                          Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
                        ]),
                      ),
                    ),
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

  Widget _buildRequestCard(BuildContext context, IconData icon, Color bg, Color fg, String title, String desc,
      {String? slug, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? (slug != null ? () => _shareRequest(context, title, slug) : null),
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

  Future<void> _openInviteSheet(BuildContext context, String roleTitle, InvitationRole role) async {
    final auth = context.read<AuthService>();
    final patientId = isSelfCare(auth) ? auth.patientId : _selectedPatient?.id;
    final patientName = isSelfCare(auth) ? (auth.firstName ?? '') : (_selectedPatient?.fullName ?? '');

    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un paciente para enviar la invitación'), backgroundColor: AppColors.warning),
      );
      return;
    }

    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: _InviteSheet(
          patientId: patientId,
          patientName: patientName,
          roleTitle: roleTitle,
          role: role,
        ),
      ),
    ).then((sent) {
      if (sent == true && mounted && context.mounted) {
        VitalFeedback.success(
          context,
          code: 'INVITATION_CREATED',
          message: 'Invitación de $roleTitle para $patientName enviada correctamente.',
        );
      }
    });
  }

  bool isSelfCare(AuthService auth) => auth.isSelfCare;
}

class _InviteSheet extends StatefulWidget {
  final int patientId;
  final String patientName;
  final String roleTitle;
  final InvitationRole role;

  const _InviteSheet({
    required this.patientId,
    required this.patientName,
    required this.roleTitle,
    required this.role,
  });

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  KinshipType _kinship = KinshipType.otro;
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text('Invitar ${widget.roleTitle}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Para ${widget.patientName}', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          VitalFormField(
            label: 'Email del invitado',
            controller: _emailController,
            hint: 'correo@ejemplo.com',
            validator: _validateEmail,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          if (widget.role == InvitationRole.caregiver) ...[
            VitalFormField(
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
            ),
            const SizedBox(height: 14),
          ],
          VitalFormField(
            label: 'Mensaje (opcional)',
            controller: _messageController,
            hint: 'Escribe un mensaje para el invitado',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          VitalButton(
            label: 'Enviar invitación',
            isLoading: _sending,
            onPressed: _sending ? null : _send,
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'El email es requerido';
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+(\.[\w\-]+)+$');
    if (!regex.hasMatch(email)) return 'Email inválido';
    return null;
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    final emailErr = _validateEmail(email);
    if (emailErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailErr), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _sending = true);
    final service = context.read<InvitationService>();
    try {
      await service.inviteByEmail(
        widget.patientId,
        email: email,
        role: widget.role,
        kinship: widget.role == InvitationRole.caregiver ? _kinship : null,
        message: _messageController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
