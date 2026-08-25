import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_service.dart';
import '../../services/caregiver_service.dart';
import '../../services/treatment_service.dart';
import '../../services/sos_service.dart';
import '../../widgets/vital_badge.dart';
import '../../widgets/vital_charts.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_empty_state.dart';
import '../../models/patient.dart';
import '../../models/caregiver.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';
import '../../models/sos_event.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Patient? _patient;
  List<Caregiver> _caregivers = [];
  List<Treatment> _treatments = [];
  List<MedicationLog> _recentLogs = [];
  List<SosEvent> _activeSos = [];
  double _adherence = 0.0;
  List<Schedule> _todaySchedules = [];
  bool _loading = true;
  String? _error;
  int? _patientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patientId == null) {
      _patientId = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
      _loadAll();
    }
  }

  Future<void> _loadAll() async {
    final pid = _patientId;
    if (pid == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final patientService = context.read<PatientService>();
      final treatmentService = context.read<TreatmentService>();
      final caregiverService = context.read<CaregiverService>();
      final sosService = context.read<SosService>();

      final results = await Future.wait([
        patientService.getPatient(pid),
        treatmentService.getTreatments(pid),
        treatmentService.getRecentLogs(pid),
        treatmentService.getAdherence(pid).catchError((_) => 0.0),
        caregiverService.getCaregivers(pid).catchError((_) => <Caregiver>[]),
        sosService.getActiveSosEvents(pid).catchError((_) => <SosEvent>[]),
        treatmentService.getSchedulesForDay(pid, DateTime.now()).catchError((_) => <Schedule>[]),
      ]);

      final patient = results[0] as Patient?;
      final treatments = results[1] as List<Treatment>;
      final logs = results[2] as List<MedicationLog>;
      final adherence = results[3] as double;
      final caregivers = results[4] as List<Caregiver>;
      final sos = results[5] as List<SosEvent>;
      final today = results[6] as List<Schedule>;

      if (!mounted) return;
      setState(() {
        _patient = patient;
        _treatments = treatments;
        _recentLogs = logs;
        _adherence = adherence;
        _caregivers = caregivers;
        _activeSos = sos;
        _todaySchedules = today;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SingleChildScrollView(child: Column(children: [Container(height: 180, color: AppColors.primary), const SkeletonDetail()])),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(children: [
          Container(height: 80, color: AppColors.primary),
          VitalEmptyState(icon: LucideIcons.cloudOff, title: 'Error al cargar', description: _error!),
        ]),
      );
    }
    final patient = _patient;
    if (patient == null) {
      return const Scaffold(backgroundColor: AppColors.bg, body: VitalEmptyState(icon: LucideIcons.userX, title: 'Paciente no encontrado', description: 'No se encontró información del paciente.'));
    }
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(color: AppColors.primary, onRefresh: _loadAll, child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          _buildHeader(context, patient),
          _buildContent(context, patient),
        ]),
      )),
    );
  }

  Widget _buildHeader(BuildContext context, Patient patient) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(AppDimensions.radiusHeaderBottom), bottomRight: Radius.circular(AppDimensions.radiusHeaderBottom)),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 20, right: 20, bottom: 24),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 20, color: Colors.white))),
          Row(children: [
            GestureDetector(onTap: () => Navigator.pushNamed(context, AppRoutes.editPatient, arguments: patient.id), child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(LucideIcons.pencil, size: 16, color: Colors.white))),
            const SizedBox(width: 8),
            Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(LucideIcons.moreVertical, size: 16, color: Colors.white)),
          ]),
        ]),
        const SizedBox(height: 20),
        Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2), border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3)), child: Center(child: Text(patient.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 28)))),
        const SizedBox(height: 12),
        Text(patient.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text('${patient.age} años', style: const TextStyle(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 12),
        VitalBadge.info(label: _activeSos.isNotEmpty ? 'SOS activo' : 'Conectado', showDot: true),
      ]),
    );
  }

  Widget _buildContent(BuildContext context, Patient patient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 20, bottom: 80),
      child: Column(children: [
        _buildStatsGrid(),
        const SizedBox(height: 20),
        _buildQuickActions(context, patient),
        const SizedBox(height: 20),
        _buildFamilySection(context, patient),
        const SizedBox(height: 20),
        _buildWeeklyChart(),
        const SizedBox(height: 20),
        _buildMedicationsSection(context),
      ]),
    );
  }

  Widget _buildStatsGrid() {
    final activeDetails = _treatments.where((t) => t.status == TreatmentStatus.activo).expand((t) => t.details ?? []).where((d) => d.status == MedicationStatus.enCurso).toList();
    final medCount = activeDetails.length;
    final dosesToday = _todaySchedules.length;
    final omited = _recentLogs.where((l) => l.status == LogStatus.omitida).length;
    final alerts = omited + _activeSos.length;
    final adherencePct = (_adherence * 100).round();
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.05,
      children: [
        _StatCard(icon: LucideIcons.checkCircle, iconBg: AppColors.accentLight, iconFg: AppColors.accent, value: '$adherencePct%', label: 'Adherencia', valueColor: _adherence >= 0.8 ? AppColors.accent : _adherence >= 0.5 ? AppColors.warning : AppColors.danger),
        _StatCard(icon: LucideIcons.plusSquare, iconBg: AppColors.primaryLight, iconFg: AppColors.primary, value: '$medCount', label: 'Medicamentos'),
        _StatCard(icon: LucideIcons.clock, iconBg: AppColors.warningBg, iconFg: AppColors.warning, value: '$dosesToday', label: 'Dosis hoy'),
        _StatCard(icon: LucideIcons.alertTriangle, iconBg: alerts > 0 ? AppColors.dangerBg : AppColors.bg, iconFg: alerts > 0 ? AppColors.dangerDark : AppColors.textMuted, value: '$alerts', label: 'Alertas', valueColor: alerts > 0 ? AppColors.dangerDark : AppColors.textMuted),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    final data = _weeklyData();
    final avg = data.isEmpty ? 0 : data.values.reduce((a, b) => a + b) / data.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusCard), boxShadow: AppDimensions.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Adherencia Semanal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text('${avg.round()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: avg >= 80 ? AppColors.accent : avg >= 50 ? AppColors.warning : AppColors.danger)),
        ]),
        const SizedBox(height: 12),
        AdherenceBarChart(data: data, height: 140),
      ]),
    );
  }

  Map<String, double> _weeklyData() {
    final now = DateTime.now();
    final map = <String, double>{};
    const labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final dayLogs = _recentLogs.where((l) => l.scheduledDatetime.year == day.year && l.scheduledDatetime.month == day.month && l.scheduledDatetime.day == day.day).toList();
      double pct = 0;
      if (dayLogs.isNotEmpty) {
        final ok = dayLogs.where((l) => l.status == LogStatus.confirmado || l.status == LogStatus.retraso).length;
        pct = (ok / dayLogs.length * 100).clamp(0, 100).toDouble();
      }
      final label = labels[day.weekday - 1];
      // Evita colisión de labels, usa "Hoy" para el último
      final key = i == 0 ? 'Hoy' : label;
      // Si hay duplicado (dos lunes), usa día/mes
      String k = key;
      int dup = 1;
      while (map.containsKey(k)) { k = '$key$dup'; dup++; }
      map[k] = pct;
    }
    return map;
  }

  Widget _buildQuickActions(BuildContext context, Patient patient) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.25,
      children: [
        _ActionCard(icon: LucideIcons.activity, iconBg: AppColors.primaryLight, iconFg: AppColors.primary, label: 'Ver historial', onTap: () => Navigator.pushNamed(context, AppRoutes.history, arguments: patient.id)),
        _ActionCard(icon: LucideIcons.plus, iconBg: AppColors.accentLight, iconFg: AppColors.accent, label: 'Agregar medicamento', onTap: () => Navigator.pushNamed(context, AppRoutes.addMedication, arguments: patient.id)),
        _ActionCard(icon: LucideIcons.shieldAlert, iconBg: _activeSos.isNotEmpty ? AppColors.dangerBg : AppColors.primaryLight, iconFg: _activeSos.isNotEmpty ? AppColors.dangerDark : AppColors.primary, label: 'Centro SOS', subtitle: _activeSos.isNotEmpty ? '${_activeSos.length} activa(s)' : 'Estado y ayuda', onTap: () => Navigator.pushNamed(context, AppRoutes.sosEmergency, arguments: patient.id)),
        _ActionCard(icon: LucideIcons.pill, iconBg: AppColors.iconPurpleBg, iconFg: AppColors.iconPurpleFg, label: 'Pastillero', subtitle: 'Compartimentos', onTap: () => Navigator.pushNamed(context, AppRoutes.configureDispenser, arguments: patient.id)),
      ],
    );
  }

  Widget _buildFamilySection(BuildContext context, Patient patient) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Text('Familiares vinculados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)), child: Text('${_caregivers.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
        ]),
        GestureDetector(onTap: () => Navigator.pushNamed(context, AppRoutes.familyMembers, arguments: patient.id), child: const Text('Ver todos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))),
      ]),
      const SizedBox(height: 12),
      if (_caregivers.isEmpty)
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.sendRequests, arguments: {'patientId': patient.id}),
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5), boxShadow: AppDimensions.cardShadow),
            child: Column(children: [
              Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle), child: const Icon(LucideIcons.userPlus, size: 24, color: AppColors.primary)),
              const SizedBox(height: 12),
              const Text('Vincular cuidador', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 4),
              const Text('Agrega un cuidador para compartir la gestión de este paciente', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
          ),
        )
      else
        ..._caregivers.take(3).map((c) {
          final label = c.displayName?.isNotEmpty == true ? c.displayName! : 'Cuidador';
          final kin = c.kinshipDisplay ?? c.kinship;
          final subtitle = kin != null ? '$kin · Prioridad: ${c.emergencyCallPriority ?? 'Normal'}' : 'Prioridad: ${c.emergencyCallPriority ?? 'Normal'}';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppDimensions.cardShadow),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle), child: Center(child: Text(c.initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(kin != null ? '$label ($kin)' : label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ])),
                const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
              ]),
            ),
          );
        }),
    ]);
  }

  Widget _buildMedicationsSection(BuildContext context) {
    final activeDetails = _treatments.where((t) => t.status == TreatmentStatus.activo).expand((t) => t.details ?? []).where((d) => d.status == MedicationStatus.enCurso).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Medicamentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        GestureDetector(onTap: () => Navigator.pushNamed(context, AppRoutes.configureDispenser, arguments: _patientId), child: const Text('Ver todos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))),
      ]),
      const SizedBox(height: 12),
      if (activeDetails.isEmpty)
        const VitalEmptyState(icon: LucideIcons.pill, title: 'Sin medicamentos', description: 'No hay medicamentos registrados para este paciente.\nAgrega uno desde el botón superior.')
      else
        ...activeDetails.map((d) {
          final med = d.medication;
          final name = med?.name ?? 'Medicamento #${d.medicationId}';
          final pres = med?.presentation ?? '';
          final comp = d.compartmentNumber != null ? 'Comp. ${d.compartmentNumber}' : (d.isExternal == true ? 'Externo' : 'Sin compartimento');
          final scheds = d.schedules ?? [];
          final times = scheds.isNotEmpty ? scheds.map((s) => s.timeDisplay).join(' · ') : '${d.firstTakeTime.hour.toString().padLeft(2, '0')}:${d.firstTakeTime.minute.toString().padLeft(2, '0')}';
          final isExternal = d.isExternal == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppDimensions.cardShadow, border: Border.all(color: isExternal ? AppColors.warning.withValues(alpha: 0.2) : AppColors.borderLight)),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: isExternal ? AppColors.warningBg : AppColors.primaryLight, borderRadius: BorderRadius.circular(10)), child: Icon(isExternal ? LucideIcons.package : LucideIcons.pill, size: 20, color: isExternal ? AppColors.warning : AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                if (pres.isNotEmpty) Text(pres, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(20)), child: Text(comp, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                  if (d.doseInfo != null) ...[const SizedBox(width: 6), Flexible(child: Text(d.doseInfo!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)))],
                ]),
                const SizedBox(height: 4),
                Row(children: [const Icon(LucideIcons.clock, size: 11, color: AppColors.textLight), const SizedBox(width: 4), Expanded(child: Text(times, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)))]),
              ])),
              const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textLight),
            ]),
          );
        }),
    ]);
  }

}

class _StatCard extends StatelessWidget {
  final IconData icon; final Color iconBg; final Color iconFg; final String value; final String label; final Color? valueColor;
  const _StatCard({required this.icon, required this.iconBg, required this.iconFg, required this.value, required this.label, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: FittedBox(fit: BoxFit.scaleDown, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: iconFg)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textDark)),
        const SizedBox(height: 2),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ])),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final Color iconBg; final Color iconFg; final String label; final String? subtitle; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.iconBg, required this.iconFg, required this.label, this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
        child: FittedBox(fit: BoxFit.scaleDown, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 18, color: iconFg)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w400))],
        ])),
      ),
    );
  }
}
