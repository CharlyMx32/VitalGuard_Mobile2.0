import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vital_tap.dart';

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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: VitalTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            boxShadow: AppDimensions.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String initials;
  final String name;
  final String relation;
  final String adherence;
  final Color adherenceColor;
  final Gradient avatarGradient;
  final VoidCallback onTap;

  const _PatientCard({
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
    return VitalTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.cardMarginBottom),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: avatarGradient,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    relation,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  adherence,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: adherenceColor,
                  ),
                ),
                const Text(
                  'Adherencia',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _DoseStatus { pending, completed }

class _DoseCard extends StatelessWidget {
  final String time;
  final _DoseStatus status;
  final List<_DoseItem> items;

  const _DoseCard({
    required this.time,
    required this.status,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == _DoseStatus.pending;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? AppColors.warningBg : AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPending ? 'Pendiente' : 'Completada',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPending ? AppColors.warning : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.pill,
                    size: 16,
                    color: item.iconFg,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Text(
                  item.dose,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _DoseItem {
  final String name;
  final String dose;
  final Color iconColor;
  final Color iconFg;

  const _DoseItem({
    required this.name,
    required this.dose,
    required this.iconColor,
    required this.iconFg,
  });
}

/// Content-only widget for MainShell (no Scaffold, no bottom nav)
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

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
        top: MediaQuery.of(context).padding.top + 16,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: AppDimensions.paddingHeaderBottom,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buenos días,', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white70)),
                  SizedBox(height: 4),
                  Text('María García', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(AppDimensions.iconContainerRadius)),
                      child: const Icon(LucideIcons.bell, size: 20, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Text('MG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCard(value: '2', label: 'Pacientes'),
              const SizedBox(width: 12),
              _StatCard(value: '87%', label: 'Adherencia'),
              const SizedBox(width: 12),
              _StatCard(value: '5', label: 'Dosis hoy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 20, bottom: 80),
      child: Column(
        children: [
          Row(
            children: [
              _QuickAction(
                icon: LucideIcons.plus,
                label: 'Agregar',
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.addMedication),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: LucideIcons.activity,
                label: 'Historial',
                iconBg: AppColors.accentLight,
                iconColor: AppColors.accent,
                onTap: () => Navigator.pushNamed(context, AppRoutes.history),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: LucideIcons.alertTriangle,
                label: 'SOS',
                iconBg: AppColors.warningBg,
                iconColor: AppColors.warning,
                onTap: () => Navigator.pushNamed(context, AppRoutes.sosEmergency),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mis Pacientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.patientList),
                child: const Text('Ver todos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PatientCard(
            initials: 'JG', name: 'Juan García', relation: 'Padre - 68 años', adherence: '92%', adherenceColor: AppColors.accent,
            avatarGradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4A90E2), Color(0xFF3A7BD5)]),
            onTap: () => Navigator.pushNamed(context, AppRoutes.patientDetail),
          ),
          _PatientCard(
            initials: 'RG', name: 'Rosa García', relation: 'Madre - 72 años', adherence: '81%', adherenceColor: AppColors.warning,
            avatarGradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6FCF97), Color(0xFF27AE60)]),
            onTap: () => Navigator.pushNamed(context, AppRoutes.patientDetail),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Próximas Dosis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.schedule),
                child: const Text('Ver horario', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DoseCard(
            time: '08:00 AM - Mañana', status: _DoseStatus.pending,
            items: const [
              _DoseItem(name: 'Losartan 50mg', dose: '1 pastilla', iconColor: AppColors.primaryLight, iconFg: AppColors.primary),
              _DoseItem(name: 'Metformina 850mg', dose: '1 pastilla', iconColor: AppColors.accentLight, iconFg: AppColors.accent),
            ],
          ),
          const SizedBox(height: 12),
          _DoseCard(
            time: '02:00 PM - Tarde', status: _DoseStatus.completed,
            items: const [
              _DoseItem(name: 'Atorvastatina 20mg', dose: '1 pastilla', iconColor: AppColors.primaryLight, iconFg: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}
