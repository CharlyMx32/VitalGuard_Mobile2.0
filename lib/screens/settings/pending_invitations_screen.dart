import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/invitation_service.dart';
import '../../services/notification_service.dart';
import '../../models/invitation.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/vital_header.dart';
import '../../widgets/vital_modal.dart';
import '../../widgets/vital_button.dart';

class PendingInvitationsScreen extends StatefulWidget {
  const PendingInvitationsScreen({super.key, this.initialToken});

  final String? initialToken;

  @override
  State<PendingInvitationsScreen> createState() => _PendingInvitationsScreenState();
}

class _PendingInvitationsScreenState extends State<PendingInvitationsScreen> {
  List<Invitation> _invitations = [];
  bool _loading = true;
  int? _busyId;

  bool _showCodeEntry = false;
  final TextEditingController _codeController = TextEditingController();
  bool _acceptingCode = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _showCodeEntry = true;
      _codeController.text = widget.initialToken!;
    }
    _load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final invitationService = context.read<InvitationService>();
    final notificationService = context.read<NotificationService>();
    try {
      final invitations = await invitationService.getPending();
      if (mounted) setState(() { _invitations = invitations; _loading = false; });
      // Al consultar pendientes se crean las filas notifications en el backend (lazy) — refresca badge
      try { await notificationService.refresh(); } catch (_) {}
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(int id, bool accept, {String? token}) async {
    setState(() => _busyId = id);
    final service = context.read<InvitationService>();
    try {
      if (accept) {
        await service.accept(id, token: token);
        if (!mounted) return;
        Navigator.of(context).pop();
        VitalFeedback.success(
          context,
          code: 'INVITATION_ACCEPTED',
          message: 'Invitación aceptada. El paciente se agregó a tu lista.',
        );
      } else {
        await service.reject(id, token: token);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitación rechazada'), backgroundColor: AppColors.textMuted),
        );
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _acceptByCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el código de tu invitación'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _acceptingCode = true);
    try {
      final invitation = await context.read<InvitationService>().acceptByToken(code);
      if (!mounted) return;
      setState(() { _codeController.clear(); _showCodeEntry = false; });
      Navigator.of(context).pop();
      final patientName = invitation.patientName ?? 'el paciente';
      VitalFeedback.success(
        context,
        code: 'INVITATION_ACCEPTED',
        message: 'Invitación aceptada. ${patientName} se agregó a tu lista.',
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _acceptingCode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Invitaciones'),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCodeEntry(),
          if (_invitations.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Pendientes para ti', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                  child: Text('${_invitations.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._invitations.map(_buildCard),
          ] else ...[
            const SizedBox(height: 16),
            const VitalEmptyState(
              icon: LucideIcons.inbox,
              title: 'Sin invitaciones pendientes',
              description: 'Cuando alguien te invite a cuidar a un paciente, la verás aquí.\nTambién puedes aceptar una invitación con su código.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeEntry() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.keyRound, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(child: Text('¿Recibiste una invitación por correo?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))),
              GestureDetector(
                onTap: () => setState(() => _showCodeEntry = !_showCodeEntry),
                child: const Text('Más', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
          if (_showCodeEntry) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Escribe el código que aparece en el correo', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(fontSize: 14, letterSpacing: 1.2, color: AppColors.textDark),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    hintText: 'Ej. AB12CD34-EF56GH78',
                    hintStyle: const TextStyle(fontSize: 13, letterSpacing: 0.5, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 10),
                VitalButton(
                  label: 'Aceptar invitación',
                  icon: LucideIcons.check,
                  isLoading: _acceptingCode,
                  onPressed: _acceptingCode ? null : _acceptByCode,
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text('Se acepta desde la app con el código incluido en el correo', style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(Invitation inv) {
    final patientName = inv.patientName ?? 'Paciente';
    final isBusy = _busyId == inv.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Icon(LucideIcons.heartPulse, size: 22, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(
                      inv.role == InvitationRole.doctor
                          ? 'Te invitan a atender a este paciente'
                          : 'Quiere que cuides de él/ella',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(inv.role.displayValue, AppColors.primary),
              if (inv.kinship != null) _buildChip(inv.kinship!.displayValue, AppColors.accent),
              if (inv.inviteeEmail != null) _buildChip('${inv.inviteeEmail}', AppColors.textMuted),
            ],
          ),
          if (inv.createdAt != null) ...[
            const SizedBox(height: 12),
            Text('Invitada el ${_formatDate(inv.createdAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: VitalButton.outline(
                  label: 'Rechazar',
                  icon: LucideIcons.x,
                  onPressed: isBusy ? null : () => _respond(inv.id, false, token: inv.token),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VitalButton.primary(
                  label: 'Aceptar',
                  icon: LucideIcons.check,
                  isLoading: isBusy,
                  onPressed: isBusy ? null : () => _respond(inv.id, true, token: inv.token),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}