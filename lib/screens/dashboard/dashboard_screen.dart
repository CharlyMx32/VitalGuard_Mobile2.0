import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vital_tap.dart';
import '../../widgets/vital_card.dart';

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
    return Container(
      color: AppColors.bg,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                const Text('María García',
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
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Text('MG',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) +
          const EdgeInsets.only(top: 16, bottom: 80),
      child: Column(
        children: [
          _NextDoseCard(
            targetHour: 8,
            targetMinute: 0,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStatCard(
                  icon: LucideIcons.heartPulse,
                  value: '87%',
                  label: 'Adherencia',
                  color: AppColors.accent),
              const SizedBox(width: 10),
              _MiniStatCard(
                  icon: LucideIcons.users,
                  value: '2',
                  label: 'Pacientes',
                  color: AppColors.primary),
              const SizedBox(width: 10),
              _MiniStatCard(
                  icon: LucideIcons.pill,
                  value: '5',
                  label: 'Dosis hoy',
                  color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 16),
          _SOSGlowButton(
            glowController: _glowController,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.sosEmergency),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mis Pacientes',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
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
          VitalCard(
            borderColor: const Color(0xFF4A90E2),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            child: _PatientRow(
              initials: 'JG',
              name: 'Juan García',
              relation: 'Padre - 68 años',
              adherence: '92%',
              adherenceColor: AppColors.accent,
              avatarGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A90E2), Color(0xFF3A7BD5)]),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.patientDetail),
            ),
          ),
          VitalCard(
            borderColor: const Color(0xFF6FCF97),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            child: _PatientRow(
              initials: 'RG',
              name: 'Rosa García',
              relation: 'Madre - 72 años',
              adherence: '81%',
              adherenceColor: AppColors.warning,
              avatarGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6FCF97), Color(0xFF27AE60)]),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.patientDetail),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Próximas Dosis',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
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
          _TimelineItem(
            time: '08:00 AM',
            label: 'Losartan 50mg',
            dose: '1 pastilla',
            isCompleted: false,
          ),
          _TimelineItem(
            time: '08:00 AM',
            label: 'Metformina 850mg',
            dose: '1 pastilla',
            isCompleted: false,
          ),
          _TimelineItem(
            time: '02:00 PM',
            label: 'Atorvastatina 20mg',
            dose: '1 pastilla',
            isCompleted: true,
          ),
        ],
      ),
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
