import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/treatment_service.dart';
import '../../services/auth_service.dart';
import '../../services/avatar_service.dart';
import '../../data/avatar_data.dart';
import '../../widgets/vital_tap.dart';
import '../../widgets/vital_avatar.dart';
import '../../widgets/vital_card.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_empty_state.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';

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

class _DashboardContentState extends State<DashboardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int _dashboardRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treatmentService = context.read<TreatmentService>();
    final auth = context.read<AuthService>();
    final avatarService = context.watch<AvatarService>();
    final isSelfCare = auth.isSelfCare;
    return RefreshIndicator(
      onRefresh: () async {
        final newKey = _dashboardRefreshKey + 1;
        setState(() => _dashboardRefreshKey = newKey);
      },
      child: FutureBuilder<List<Treatment>>(
        key: ValueKey('dashboard_$_dashboardRefreshKey'),
        future: treatmentService.getTreatments(auth.patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: SkeletonDashboard(),
            );
          }
          final treatments = snapshot.data ?? [];
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context, avatarService.config),
                _buildContent(context, treatments: treatments, isSelfCare: isSelfCare),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AvatarConfig avatarConfig) {
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
                const Text('---',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
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

  static const _avatarGradients = [
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A90E2), Color(0xFF3A7BD5)]),
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6FCF97), Color(0xFF27AE60)]),
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF39C12), Color(0xFFE67E22)]),
  ];

  Widget _buildContent(BuildContext context,
      {required List<Treatment> treatments, required bool isSelfCare}) {
    final hasData = treatments.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingHorizontal) +
          const EdgeInsets.only(top: 16, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hasData
              ? _NextDoseCard(targetHour: 8, targetMinute: 0)
              : _EmptyNextDose(),
          const SizedBox(height: 12),
          _buildStatCards(treatments, isSelfCare: isSelfCare),
          const SizedBox(height: 16),
          _QuickActionsGrid(onTapAddMed: () => Navigator.pushNamed(context, AppRoutes.addMedication), onTapHistory: () => Navigator.pushNamed(context, AppRoutes.history), onTapSos: () => Navigator.pushNamed(context, AppRoutes.sosEmergency)),
          const SizedBox(height: 16),
          _SOSGlowButton(
              glowController: _glowController,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.sosEmergency)),
          const SizedBox(height: 24),
          if (!isSelfCare) _buildPatientsSection(context, treatments),
          if (isSelfCare) _buildSelfCareInfo(context),
          const SizedBox(height: 20),
          _buildTimelineSection(context, treatments),
        ],
      ),
    );
  }

  Widget _buildSelfCareInfo(BuildContext context) {
    return VitalCard(
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
        ],
      ),
    );
  }

  Widget _buildStatCards(List<Treatment> treatments, {bool isSelfCare = false}) {
    final hasData = treatments.isNotEmpty;
    final patientCount = treatments.map((t) => t.patientId).toSet().length;
    final todaySchedules = treatments
        .expand((t) => t.details ?? [])
        .expand((d) => d.schedules ?? [])
        .length;
    return Row(
      children: [
        _MiniStatCard(
            icon: LucideIcons.heartPulse,
            value: hasData ? '${treatments.length}' : '--',
            label: 'Adherencia',
            color: hasData ? AppColors.accent : AppColors.textMuted),
        if (!isSelfCare) ...[
          const SizedBox(width: 10),
          _MiniStatCard(
              icon: LucideIcons.users,
              value: hasData ? '$patientCount' : '--',
              label: 'Pacientes',
              color: hasData ? AppColors.primary : AppColors.textMuted),
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

  Widget _buildPatientsSection(
      BuildContext context, List<Treatment> treatments) {
    final patients = treatments
        .where((t) => t.patient != null)
        .map((t) => t.patient!)
        .toSet()
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mis Pacientes',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            if (patients.isNotEmpty)
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.patientList),
                child: const Text('Ver todos',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (patients.isNotEmpty)
          ...patients.asMap().entries.map(
                (e) => VitalCard(
                  borderColor: _avatarGradients[e.key % _avatarGradients.length]
                      .colors
                      .first,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: _PatientRow(
                    initials: e.value.initials,
                    name: e.value.fullName,
                    relation: '${e.value.age} años',
                    adherence: '--',
                    adherenceColor: AppColors.textMuted,
                    avatarGradient:
                        _avatarGradients[e.key % _avatarGradients.length],
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.patientDetail),
                  ),
                ),
              )
        else
          const VitalEmptyState(
            icon: LucideIcons.users,
            title: 'Sin pacientes',
            description:
                'Aún no tienes pacientes registrados.\nConecta un nuevo paciente para comenzar.',
          ),
      ],
    );
  }

  Widget _buildTimelineSection(
      BuildContext context, List<Treatment> treatments) {
    final items = treatments
        .expand((t) => t.details ?? [])
        .expand((d) => d.schedules ?? [])
        .take(5)
        .toList();
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
            if (items.isNotEmpty)
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
        if (items.isNotEmpty)
          ...items.map((s) => _TimelineItem(
                time: s.timeDisplay,
                label: 'Dosis',
                dose: '',
                isCompleted: s.logs?.any((l) => l.status == LogStatus.confirmado) ?? false,
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

class _NextDoseCard extends StatelessWidget {
  final int targetHour;
  final int targetMinute;
  const _NextDoseCard(
      {required this.targetHour, required this.targetMinute});

  Duration _timeUntil() {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
    if (next.isBefore(now)) {
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

  @override
  Widget build(BuildContext context) {
    final remaining = _timeUntil();
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onTapAddMed;
  final VoidCallback onTapHistory;
  final VoidCallback onTapSos;
  const _QuickActionsGrid({
    required this.onTapAddMed,
    required this.onTapHistory,
    required this.onTapSos,
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
          icon: LucideIcons.alertTriangle,
          label: 'Emergencia\nSOS',
          onTap: onTapSos,
          color: AppColors.warning,
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

class _SOSGlowButton extends StatelessWidget {
  final AnimationController glowController;
  final VoidCallback onTap;
  const _SOSGlowButton(
      {required this.glowController, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        final glow = glowController.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withValues(alpha: 0.15 + glow * 0.25),
                blurRadius: 8 + glow * 12,
                spreadRadius: glow * 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: VitalTap(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertTriangle,
                  size: 22, color: Colors.white),
              SizedBox(width: 10),
              Text('SOS - Emergencia',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientRow extends StatelessWidget {
  final String initials;
  final String name;
  final String relation;
  final String adherence;
  final Color adherenceColor;
  final Gradient avatarGradient;
  final VoidCallback onTap;

  const _PatientRow({
    required this.initials,
    required this.name,
    required this.relation,
    required this.adherence,
    required this.adherenceColor,
    required this.avatarGradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: avatarGradient,
          ),
          child: Center(
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(relation,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(adherence,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: adherenceColor)),
            const Text('Adherencia',
                style: TextStyle(
                    fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String time;
  final String label;
  final String dose;
  final bool isCompleted;
  const _TimelineItem(
      {required this.time,
      required this.label,
      required this.dose,
      required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final circleColor = isCompleted ? AppColors.accent : AppColors.warning;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: isCompleted ? 16 : 14,
                  height: isCompleted ? 16 : 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                  ),
                  child: isCompleted
                      ? const Icon(LucideIcons.check,
                          size: 10, color: Colors.white)
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
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppDimensions.cardShadow,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(dose,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  const Spacer(),
                  Text(time,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isCompleted
                              ? AppColors.accent
                              : AppColors.warning)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
