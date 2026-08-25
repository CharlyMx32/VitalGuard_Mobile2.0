import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/vital_header.dart';
import '../../services/caregiver_service.dart';
import '../../services/sos_service.dart';
import '../../services/auth_service.dart';
import '../../services/patient_current_service.dart';
import '../../services/patient_service.dart';
import '../../models/caregiver.dart';
import '../../models/sos_event.dart';
import '../../models/enums.dart';

class SosEmergencyScreen extends StatefulWidget {
  const SosEmergencyScreen({super.key});
  @override
  State<SosEmergencyScreen> createState() => _SosEmergencyScreenState();
}

class _SosEmergencyScreenState extends State<SosEmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  List<Caregiver> _contacts = [];
  List<SosEvent> _active = [];
  List<SosEvent> _recent = [];
  bool _loading = true;
  String? _patientName;
  bool _isSelfCare = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final auth = context.read<AuthService>();
      _isSelfCare = auth.isSelfCare;
      final patientCurrent = context.read<PatientCurrentService>();
      final patientId = ModalRoute.of(context)?.settings.arguments as int? ?? patientCurrent.patientId ?? auth.patientId;
      if (patientId == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      String? name;
      try {
        final patient = await context.read<PatientService>().getPatient(patientId);
        name = patient?.fullName;
      } catch (_) {}
      final caregiverService = context.read<CaregiverService>();
      final sosService = context.read<SosService>();
      List<Caregiver> contacts = [];
      List<SosEvent> active = [];
      List<SosEvent> recent = [];
      try { contacts = await caregiverService.getCaregivers(patientId); } catch (_) {}
      try { active = await sosService.getActiveSosEvents(patientId); } catch (_) {}
      try { recent = await sosService.getRecentSosEvents(patientId); } catch (_) {}
      if (mounted) setState(() { _contacts = contacts; _active = active; _recent = recent; _patientName = name; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resolve(int id, SosStatus status) async {
    final sosService = context.read<SosService>();
    await sosService.updateSosStatus(id, status);
    await _loadAll();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == SosStatus.atendido ? 'Marcado como atendido' : 'Marcado como falsa alarma'), backgroundColor: AppColors.accent));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCaregiver = !_isSelfCare;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(
            title: isCaregiver
                ? (_patientName != null ? 'Centro SOS · $_patientName' : 'Centro SOS')
                : 'Emergencia SOS',
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSelfCare) ...[
                          _buildSelfCareActivate(),
                          const SizedBox(height: 16),
                        ],
                        _buildStatusHero(),
                        const SizedBox(height: 16),
                        _buildQuickStats(),
                        const SizedBox(height: 16),
                        _buildGuideCard(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Contactos de emergencia'),
                        const SizedBox(height: 10),
                        _buildContacts(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Historial reciente'),
                        const SizedBox(height: 10),
                        _buildHistory(),
                        const SizedBox(height: 16),
                        _buildLocationCard(),
                        if (isCaregiver) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.15))),
                            child: Row(children: [
                              Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(LucideIcons.info, size: 16, color: AppColors.primary)),
                              const SizedBox(width: 10),
                              const Expanded(child: Text('Esta pantalla es informativa para cuidadores. El paciente activa el SOS desde el pastillero físico o en modo autocuidado.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4))),
                            ]),
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

  // ── Self-care activate (solo autocuidado) ──
  Widget _buildSelfCareActivate() {
    return GestureDetector(
      onTap: () async {
        final auth = context.read<AuthService>();
        final pid = context.read<PatientCurrentService>().patientId ?? auth.patientId;
        if (pid == null) return;
        await context.read<SosService>().createSosEvent(pid);
        await _loadAll();
      },
      child: Container(
        width: double.infinity, height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.dangerDark, Color(0xFFFF8A65)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.dangerDark.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.phone, size: 22, color: Colors.white),
          SizedBox(width: 10),
          Text('Activar SOS', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _buildStatusHero() {
    final hasActive = _active.isNotEmpty;
    if (hasActive) {
      final ev = _active.first;
      return AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          final scale = 1.0 + _pulse.value * 0.06;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.dangerDark, Color(0xFFFF6B6B)]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: AppColors.dangerDark.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              Transform.scale(
                scale: scale,
                child: Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(LucideIcons.siren, size: 28, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              const Text('Alerta SOS activa', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Evento #${ev.id} · ${_formatTime(ev.createdAt)} · Requiere atención', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _heroAction('Atendido', AppColors.accent, () => _resolve(ev.id, SosStatus.atendido))),
                const SizedBox(width: 10),
                Expanded(child: _heroAction('Falsa alarma', Colors.white24, () => _resolve(ev.id, SosStatus.falsaAlarma), fg: Colors.white, border: true)),
              ]),
            ]),
          );
        },
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppDimensions.cardShadow, border: Border.all(color: AppColors.accent.withValues(alpha: 0.15))),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle), child: const Icon(LucideIcons.shieldCheck, size: 24, color: AppColors.accent)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sin alertas activas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(_recent.isEmpty ? 'No hay eventos recientes. El sistema monitorea 24/7.' : 'Último evento ${_formatTime(_recent.first.createdAt)} · ${_statusLabel(_recent.first.status)}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3)),
        ])),
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
      ]),
    );
  }

  Widget _heroAction(String label, Color bg, VoidCallback onTap, {Color fg = Colors.white, bool border = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: border ? Border.all(color: Colors.white.withValues(alpha: 0.5)) : null),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg))),
      ),
    );
  }

  Widget _buildQuickStats() {
    final activeCount = _active.length;
    final last = _recent.isNotEmpty ? _formatTime(_recent.first.createdAt) : '--:--';
    return Row(children: [
      Expanded(child: _miniStat(LucideIcons.siren, '$activeCount', 'Activas', activeCount > 0 ? AppColors.dangerDark : AppColors.textMuted, activeCount > 0 ? AppColors.dangerBg : AppColors.bg)),
      const SizedBox(width: 10),
      Expanded(child: _miniStat(LucideIcons.clock, last, 'Último evento', AppColors.primary, AppColors.primaryLight)),
      const SizedBox(width: 10),
      Expanded(child: _miniStat(LucideIcons.users, '${_contacts.length}', 'Cuidadores', AppColors.textDark, AppColors.bg)),
    ]);
  }

  Widget _miniStat(IconData icon, String value, String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppDimensions.cardShadow),
      child: Column(children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 14, color: fg)),
        const SizedBox(height: 6),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)), child: const Icon(LucideIcons.lifeBuoy, size: 16, color: AppColors.primary)),
          const SizedBox(width: 10),
          const Text('Qué hacer si recibes una alerta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ]),
        const SizedBox(height: 14),
        _guideStep('1', 'Verifica', 'Abre la notificación y confirma la hora del SOS.'),
        _guideStep('2', 'Llama', 'Contacta al paciente y a tu red de apoyo.'),
        _guideStep('3', 'Acude o coordina', 'Si no responde, acude al domicilio o avisa a emergencias.'),
        _guideStep('4', 'Registra', 'Marca como Atendido o Falsa alarma para cerrar el evento.', isLast: true),
      ]),
    );
  }

  Widget _guideStep(String n, String title, String desc, {bool isLast = false}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 24, height: 24, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Center(child: Text(n, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)))),
        if (!isLast) Container(width: 1.5, height: 18, color: AppColors.borderLight),
      ]),
      const SizedBox(width: 10),
      Expanded(child: Padding(padding: EdgeInsets.only(bottom: isLast ? 0 : 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3)),
      ]))),
    ]);
  }

  Widget _buildContacts() {
    if (_contacts.isEmpty) {
      return const VitalEmptyState(icon: LucideIcons.phoneOff, title: 'Sin contactos', description: 'No hay cuidadores vinculados.\nInvita a familiares desde la ficha del paciente.');
    }
    return Column(
      children: _contacts.map((c) {
        final label = (c.displayName?.isNotEmpty == true ? c.displayName! : 'Cuidador #${c.id}');
        final kin = c.kinshipDisplay ?? c.kinship;
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppDimensions.cardShadow),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle), child: Center(child: Text(label.trim().isNotEmpty ? label.trim()[0].toUpperCase() : 'C', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(kin != null ? '$label ($kin)' : label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text('Prioridad: ${c.emergencyCallPriority ?? 'Normal'}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ])),
            Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle), child: const Icon(LucideIcons.phone, size: 14, color: AppColors.accent)),
          ]),
        );
      }).toList(),
    );
  }

  Widget _buildHistory() {
    if (_recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppDimensions.cardShadow),
        child: const Row(children: [
          Icon(LucideIcons.history, size: 16, color: AppColors.textMuted),
          SizedBox(width: 8),
          Text('Sin historial reciente', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ]),
      );
    }
    return Column(
      children: _recent.take(5).map((e) {
        final isActivo = e.status == SosStatus.activo;
        final isAtendido = e.status == SosStatus.atendido;
        final color = isActivo ? AppColors.dangerDark : isAtendido ? AppColors.accent : AppColors.textMuted;
        final bg = isActivo ? AppColors.dangerBg : isAtendido ? AppColors.accentLight : AppColors.bg;
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppDimensions.cardShadow),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Icon(isActivo ? LucideIcons.siren : LucideIcons.shieldCheck, size: 16, color: color)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Evento #${e.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(_statusLabel(e.status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color))),
              ]),
              const SizedBox(height: 2),
              Text(_formatTime(e.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ])),
            if (isActivo) Row(children: [
              _smallAction('Atendido', AppColors.accent, () => _resolve(e.id, SosStatus.atendido)),
              const SizedBox(width: 6),
              _smallAction('Falsa', AppColors.textMuted, () => _resolve(e.id, SosStatus.falsaAlarma)),
            ]),
          ]),
        );
      }).toList(),
    );
  }

  Widget _smallAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.2))), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
    );
  }

  String _statusLabel(SosStatus? s) {
    switch (s) {
      case SosStatus.activo: return 'Activo';
      case SosStatus.atendido: return 'Atendido';
      case SosStatus.falsaAlarma: return 'Falsa alarma';
      default: return '—';
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'ahora';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m · ${dt.day}/${dt.month}';
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark));
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppDimensions.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ubicación y dispositivo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 10),
        _infoRow(LucideIcons.mapPin, 'Domicilio', 'Registrado en la ficha del paciente'),
        const Divider(height: 1, color: AppColors.borderLight),
        _infoRow(LucideIcons.wifi, 'Pastillero', 'Estado en Mi VitalGuard'),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 15, color: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        ])),
      ]),
    );
  }
}
