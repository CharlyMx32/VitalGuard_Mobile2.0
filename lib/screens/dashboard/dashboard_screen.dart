import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/treatment_service.dart';
import '../../services/patient_service.dart';
import '../../services/auth_service.dart';
import '../../services/avatar_service.dart';
import '../../services/patient_current_service.dart';
import '../../services/notification_service.dart';
import '../../data/avatar_data.dart';
import '../../widgets/vital_tap.dart';
import '../../widgets/vital_avatar.dart';
import '../../widgets/vital_card.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/patient_selector_header.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';
import '../../models/patient.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: const DashboardContent(),
    );
  }
}

/// Content-only widget for MainShell (no Scaffold, no bottom nav)
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});
  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int _dashboardRefreshKey = 0;
  late Future<_DashboardData> _dashboardFuture;
  PatientCurrentService? _patientSvc;
  int? _loadedForPatientId;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final svc = context.read<PatientCurrentService>();
    if (!identical(svc, _patientSvc)) {
      _patientSvc?.removeListener(_onPatientChanged);
      _patientSvc = svc;
      _patientSvc!.addListener(_onPatientChanged);
    }
    if (!_started) {
      _started = true;
      _loadDashboard();
    }
  }

  void _onPatientChanged() {
    final svc = _patientSvc;
    if (svc == null || svc.patientId == _loadedForPatientId) return;
    setState(_loadDashboard);
  }

  void _loadDashboard() {
    final patientCurrent = context.read<PatientCurrentService>();
    final patientService = context.read<PatientService>();
    final auth = context.read<AuthService>();
    final treatmentService = context.read<TreatmentService>();
    _loadedForPatientId = patientCurrent.patientId;
    _dashboardFuture = _fetchDashboardData(
      patientCurrent, patientService, auth, treatmentService,
    );
  }

  Future<_DashboardData> _fetchDashboardData(
    PatientCurrentService patientCurrent,
    PatientService patientService,
    AuthService auth,
    TreatmentService treatmentService,
  ) async {
    List<Patient> patients = [];
    try {
      patients = await patientService.getPatients();
      patientCurrent.setPatients(patients);
    } catch (_) {}
    final pid = patientCurrent.patientId ?? auth.patientId ?? 0;
    var treatments = <Treatment>[];
    var adherence = 0.0;
    try {
      treatments = await treatmentService.getTreatments(pid);
    } catch (_) {}
    try {
      adherence = await treatmentService.getAdherence(pid);
    } catch (_) {}
    return _DashboardData(
      patientId: pid,
      patients: patients,
      treatments: treatments,
      adherence: adherence,
    );
  }

  void _reload() {
    setState(_loadDashboard);
  }

  @override
  void dispose() {
    _patientSvc?.removeListener(_onPatientChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final isSelfCare = auth.isSelfCare;
    final userName = auth.firstName ?? '';
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _dashboardRefreshKey++;
          _loadDashboard();
        });
      },
      child: FutureBuilder<_DashboardData>(
        key: ValueKey('dashboard_$_dashboardRefreshKey'),
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: SkeletonDashboard(),
            );
          }
          final data = snapshot.data ?? _DashboardData.empty();
          final avatarConfig = context.select<AvatarService, AvatarConfig>((s) => s.config);
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context, avatarConfig, isSelfCare: isSelfCare, userName: userName),
                _buildContent(context, data: data, isSelfCare: isSelfCare),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AvatarConfig avatarConfig,
      {bool isSelfCare = false, String userName = ''}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusHeaderBottom),
          bottomRight: Radius.circular(AppDimensions.radiusHeaderBottom),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70)),
                const SizedBox(height: 2),
                Text(userName.isNotEmpty ? userName : (isSelfCare ? 'Autocuidado' : 'Cuidador'),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
          Consumer<NotificationService>(
            builder: (context, notificationService, _) {
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                child: NotificationBadge(
                  count: notificationService.unreadCount,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.iconContainerRadius)),
                    child: const Icon(LucideIcons.bell,
                        size: 20, color: AppColors.textMuted),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => showAvatarPreview(context, config: avatarConfig, onChangeTap: () => Navigator.pushNamed(context, AppRoutes.avatarPicker)),
            child: Hero(
              tag: 'avatar_hero',
              child: VitalAvatar(
                style: avatarConfig.style,
                seed: avatarConfig.seed,
                size: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context,
      {required _DashboardData data, required bool isSelfCare}) {
    final treatments = data.treatments;
    final nextDose = _computeNextDose(treatments);
    return Padding(
      padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingHorizontal) +
          const EdgeInsets.only(top: 8, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PatientSelectorHeader(),
          const SizedBox(height: 8),
          nextDose.hasNext
              ? _NextDoseCard(nextDose: nextDose)
              : _EmptyNextDose(),
          const SizedBox(height: 12),
          _buildStatCards(data, isSelfCare: isSelfCare),
          const SizedBox(height: 16),
          _QuickActionsGrid(
            onTapAddMed: () => Navigator.pushNamed(context, AppRoutes.addMedication),
            onTapHistory: () => Navigator.pushNamed(context, AppRoutes.history),
            onTapDevice: () => Navigator.pushNamed(context, AppRoutes.devices),
          ),
          const SizedBox(height: 16),
          if (!isSelfCare) _TreatmentPanel(data: data, onRefresh: _reload),
          if (isSelfCare) _buildSelfCareInfo(context),
          const SizedBox(height: 20),
          _buildTimelineSection(context, treatments, isSelfCare: isSelfCare),
        ],
      ),
    );
  }

  _NextDose _computeNextDose(List<Treatment> treatments) {
    final now = DateTime.now();
    DateTime? bestTime;
    for (final t in treatments) {
      if (t.status == TreatmentStatus.finalizado) continue;
      for (final d in (t.details ?? [])) {
        if (d.status == MedicationStatus.finalizado) continue;
        for (final s in (d.schedules ?? [])) {
          final tTime = s.timeOfDay;
          var scheduled =
              DateTime(now.year, now.month, now.day, tTime.hour, tTime.minute);
          if (!scheduled.isAfter(now)) {
            scheduled = scheduled.add(const Duration(days: 1));
          }
          if (bestTime == null || scheduled.isBefore(bestTime)) {
            bestTime = scheduled;
          }
        }
      }
    }
    if (bestTime == null) {
      return const _NextDose(hour: 8, minute: 0, hasNext: false);
    }

    final items = <_NextDoseItem>[];
    for (final t in treatments) {
      if (t.status == TreatmentStatus.finalizado) continue;
      for (final d in (t.details ?? [])) {
        if (d.status == MedicationStatus.finalizado) continue;
        for (final s in (d.schedules ?? [])) {
          final tTime = s.timeOfDay;
          var scheduled =
              DateTime(now.year, now.month, now.day, tTime.hour, tTime.minute);
          if (!scheduled.isAfter(now)) {
            scheduled = scheduled.add(const Duration(days: 1));
          }
          if (scheduled.hour == bestTime.hour &&
              scheduled.minute == bestTime.minute) {
            final name = d.medication?.name ?? s.medicationName ?? '';
            final presentation = d.medication?.presentation;
            final dose = d.doseInfo ?? s.doseInfo ?? '';
            final key = '$name|$dose';
            final existing = items.any((e) =>
                '${e.name}|${e.dose}' == key || (name.isNotEmpty && e.name == name));
            if (!existing) {
              items.add(_NextDoseItem(
                name: name,
                presentation: presentation,
                dose: dose,
              ));
            }
          }
        }
      }
    }

    return _NextDose(
      hour: bestTime.hour,
      minute: bestTime.minute,
      hasNext: true,
      items: items,
    );
  }

  Widget _buildSelfCareInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.selfCare),
      child: VitalCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(LucideIcons.user, size: 24, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modo autocuidado',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  SizedBox(height: 2),
                  Text('Estás gestionando tus propios medicamentos',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(_DashboardData data, {bool isSelfCare = false}) {
    final hasData = data.treatments.isNotEmpty;
    final hasPatients = data.patients.isNotEmpty;
    final patientCount = data.patients.length;
    final adherencePct = (data.adherence * 100).round();
    final todaySchedules = data.treatments
        .where((t) => t.status != TreatmentStatus.finalizado)
        .expand((t) => t.details ?? [])
        .where((d) => d.status != MedicationStatus.finalizado)
        .expand((d) => d.schedules ?? [])
        .length;
    return Row(
      children: [
        _MiniStatCard(
            icon: LucideIcons.heartPulse,
            value: hasData ? '$adherencePct%' : '--',
            label: 'Adherencia',
            color: hasData ? AppColors.accent : AppColors.textMuted),
        if (!isSelfCare) ...[
          const SizedBox(width: 10),
          _MiniStatCard(
              icon: LucideIcons.users,
              value: hasPatients ? '$patientCount' : '--',
              label: 'Pacientes',
              color: hasPatients ? AppColors.primary : AppColors.textMuted),
        ],
        const SizedBox(width: 10),
        _MiniStatCard(
            icon: LucideIcons.pill,
            value: hasData ? '$todaySchedules' : '--',
            label: 'Dosis hoy',
            color: hasData ? AppColors.warning : AppColors.textMuted),
      ],
    );
  }

  Widget _buildTimelineSection(
      BuildContext context, List<Treatment> treatments,
      {bool isSelfCare = false}) {
    final items = treatments
        .where((t) => t.status != TreatmentStatus.finalizado)
        .expand((t) => t.details ?? [])
        .where((d) => d.status != MedicationStatus.finalizado)
        .expand((d) => (d.schedules ?? []).map((s) => (schedule: s, detail: d)))
        .toList();
    
    // Ordenar cronológicamente
    items.sort((a, b) => a.schedule.timeOfDay.compareTo(b.schedule.timeOfDay));
    
    final displayItems = items.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Próximas Dosis',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            if (displayItems.isNotEmpty)
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.schedule),
                child: const Text('Ver horario',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (displayItems.isNotEmpty)
          ...displayItems.map((e) => _TimelineItem(
                time: e.schedule.timeDisplay,
                label: e.detail.medication?.name ?? e.schedule.medicationName ?? 'Dosis',
                dose: e.detail.doseInfo ?? e.schedule.doseInfo ?? '',
                isCompleted: e.schedule.logs?.any((l) => l.status == LogStatus.confirmado) ?? false,
                onMarkTaken: !isSelfCare
                    ? null
                    : (e.schedule.logs?.any((l) => l.status == LogStatus.confirmado) ?? false)
                        ? null
                        : () async {
                            final svc = context.read<TreatmentService>();
                            await svc.confirmDose(e.schedule);
                            if (mounted) setState(() {});
                          },
              ))
        else
          const VitalEmptyState(
            icon: LucideIcons.calendar,
            title: 'Sin dosis programadas',
            description: 'No hay dosis próximas para hoy.',
          ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días,';
    if (hour < 19) return 'Buenas tardes,';
    return 'Buenas noches,';
  }
}

class _DashboardData {
  final int patientId;
  final List<Patient> patients;
  final List<Treatment> treatments;
  final double adherence;
  const _DashboardData({
    this.patientId = 0,
    this.patients = const [],
    this.treatments = const [],
    this.adherence = 0,
  });

  const _DashboardData.empty()
      : patientId = 0,
        patients = const [],
        treatments = const [],
        adherence = 0;
}

class _TreatmentPanel extends StatelessWidget {
  final _DashboardData data;
  final VoidCallback onRefresh;
  const _TreatmentPanel({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final treatments = data.treatments;
    final current = context.watch<PatientCurrentService>().current;
    final name = current?.fullName ?? '';
    final activeTreatments =
        treatments.where((t) => t.status != TreatmentStatus.finalizado).toList();

    if (activeTreatments.isEmpty) {
      return VitalCard(
        borderRadius: 16,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(LucideIcons.pill,
                        size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tratamiento',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(
                          name.isEmpty
                              ? 'Sin tratamiento activo'
                              : 'Sin tratamiento activo para $name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: VitalTap(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.addMedication),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text('Crear tratamiento',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final treatment = _preferred(activeTreatments);
    final details = treatment.details ?? [];
    final endDate = treatment.endDate;
    final paused = treatment.status == TreatmentStatus.pausado;
    final finished = treatment.status == TreatmentStatus.finalizado;
    final progress = treatment.progress;

    return VitalCard(
      borderRadius: 16,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Tratamiento' : 'Tratamiento de $name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusChip(status: treatment.status),
                          if (endDate != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Fin: ${endDate.day}/${endDate.month}/${endDate.year}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.treatmentDetail),
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.eye,
                        size: 18, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${treatment.elapsedDays} de ${treatment.totalDays} días',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),
                Text('${(progress * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Medicamentos',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted)),
              const SizedBox(height: 8),
              ...details.take(4).map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(LucideIcons.pill,
                              size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            d.medication?.name ?? 'Medicamento',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark),
                          ),
                        ),
                        if (d.doseInfo != null && d.doseInfo!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(d.doseInfo!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                          ),
                      ],
                    ),
                  )),
            ],
            if (!finished) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: VitalTap(
                  onTap: () => _toggle(context, treatment),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: paused
                          ? AppColors.accentLight
                          : AppColors.warningBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: paused ? AppColors.accent : AppColors.warning,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          paused ? LucideIcons.play : LucideIcons.pause,
                          size: 16,
                          color: paused ? AppColors.accent : AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          paused
                              ? 'Reanudar tratamiento'
                              : 'Pausar tratamiento',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: paused
                                  ? AppColors.accent
                                  : AppColors.warning),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Treatment _preferred(List<Treatment> ts) {
    for (final t in ts) {
      if (t.status == TreatmentStatus.activo) return t;
    }
    return ts.first;
  }

  void _toggle(BuildContext context, Treatment t) async {
    final svc = context.read<TreatmentService>();
    final newStatus =
        t.status == TreatmentStatus.pausado ? 'Activo' : 'Pausado';
    await svc.updateTreatmentFields(t.id, {'status': newStatus});
    onRefresh();
  }
}

class _StatusChip extends StatelessWidget {
  final TreatmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color fg) = switch (status) {
      TreatmentStatus.activo => (
          'Activo',
          AppColors.accentLight,
          AppColors.accent,
        ),
      TreatmentStatus.pausado => (
          'Pausado',
          AppColors.warningBg,
          AppColors.warning,
        ),
      TreatmentStatus.finalizado => (
          'Finalizado',
          AppColors.bg,
          AppColors.textMuted,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _NextDoseItem {
  final String name;
  final String? presentation;
  final String dose;
  const _NextDoseItem({
    this.name = '',
    this.presentation,
    this.dose = '',
  });
}

class _NextDose {
  final int hour;
  final int minute;
  final bool hasNext;
  final List<_NextDoseItem> items;
  const _NextDose({
    required this.hour,
    required this.minute,
    this.hasNext = false,
    this.items = const [],
  });
}

class _NextDoseCard extends StatelessWidget {
  final _NextDose nextDose;
  const _NextDoseCard({required this.nextDose});

  Duration _timeUntil() {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, nextDose.hour, nextDose.minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(now);
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h h $m min';
    return '$m min';
  }

  String _doseTime() {
    final hour = nextDose.hour;
    final minute = nextDose.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:$minute $amPm';
  }

  Widget _medChip(_NextDoseItem item) {
    final hasDose = item.dose.isNotEmpty;
    return SizedBox(
      width: 150,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 8, hasDose ? 6 : 10, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.pill,
                  size: 14, color: AppColors.accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name.isNotEmpty ? item.name : 'Medicamento',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                  if (item.presentation != null &&
                      item.presentation!.isNotEmpty)
                    Text(
                      item.presentation!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
            if (hasDose) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.dose,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _timeUntil();
    final items = nextDose.items;
    return VitalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.accentLight,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.clock,
                    size: 26, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Próxima dosis',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent)),
                    const SizedBox(height: 2),
                    Text(
                      'en ${_format(remaining)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_doseTime(),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent)),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _medChip(items[i]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyNextDose extends StatelessWidget {
  const _EmptyNextDose();

  @override
  Widget build(BuildContext context) {
    return VitalCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      backgroundColor: AppColors.accentLight,
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(LucideIcons.clock,
                size: 26, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Próxima dosis',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent)),
                SizedBox(height: 2),
                Text('Sin dosis programadas',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _MiniStatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onTapAddMed;
  final VoidCallback onTapHistory;
  final VoidCallback onTapDevice;
  const _QuickActionsGrid({
    required this.onTapAddMed,
    required this.onTapHistory,
    required this.onTapDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _QuickActionTile(
          icon: LucideIcons.plus,
          label: 'Crear\ntratamiento',
          onTap: onTapAddMed,
          color: AppColors.primary,
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickActionTile(
          icon: LucideIcons.activity,
          label: 'Historial',
          onTap: onTapHistory,
          color: AppColors.accent,
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickActionTile(
          icon: LucideIcons.monitor,
          label: 'Mi\ndispositivo',
          onTap: onTapDevice,
          color: AppColors.iconPurpleFg,
        )),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return VitalTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String time;
  final String label;
  final String dose;
  final bool isCompleted;
  final VoidCallback? onMarkTaken;
  const _TimelineItem(
      {required this.time,
      required this.label,
      required this.dose,
      required this.isCompleted,
      this.onMarkTaken});

  @override
  Widget build(BuildContext context) {
    final completed = isCompleted;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: completed ? 20 : 14,
                  height: completed ? 20 : 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed ? AppColors.accent : AppColors.warning,
                    border: completed
                        ? null
                        : Border.all(color: AppColors.warning, width: 3),
                  ),
                  child: completed
                      ? const Icon(LucideIcons.check,
                          size: 12, color: Colors.white)
                      : null,
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.borderLight,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: completed
                      ? AppColors.accent.withValues(alpha: 0.4)
                      : AppColors.borderLight,
                ),
                boxShadow: AppDimensions.cardShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: completed
                                  ? AppColors.textMuted
                                  : AppColors.textDark,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                        const SizedBox(height: 4),
                        if (dose.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(dose,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                          ),
                        if (completed) ...[
                          const SizedBox(height: 4),
                          const Text('Tomada',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accent)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (!completed && onMarkTaken != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: onMarkTaken,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.check,
                                size: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(time,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning)),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.accent.withValues(alpha: 0.12)
                            : AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: completed
                                ? AppColors.accent
                                : AppColors.warning),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
