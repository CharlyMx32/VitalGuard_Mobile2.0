import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_service.dart';
import '../../widgets/vital_charts.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_empty_state.dart';
import '../../models/patient.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientService = context.read<PatientService>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder(
        future: patientService.getPatient(1),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SingleChildScrollView(
              child: SkeletonDetail(),
            );
          }
          final patient = snapshot.data;
          if (patient == null) {
            return const VitalEmptyState(
              icon: LucideIcons.userX,
              title: 'Paciente no encontrado',
              description: 'No se encontró información del paciente.',
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, patient),
                _buildContent(context, patient),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Patient patient) {
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
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editPatient);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.pencil,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.moreVertical,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                patient.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            patient.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${patient.age} años',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.circle,
                  size: 8,
                  color: Color(0xFF6FCF97),
                ),
                SizedBox(width: 6),
                Text(
                  'Conectado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Patient patient) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ) + const EdgeInsets.only(top: 20, bottom: 80),
      child: Column(
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 20),
          _buildQuickActions(context),
          const SizedBox(height: 20),
          _buildWeeklyChart(),
          const SizedBox(height: 20),
          _buildSectionHeader('Medicamentos'),
          const SizedBox(height: 12),
          const VitalEmptyState(
            icon: LucideIcons.pill,
            title: 'Sin medicamentos',
            description: 'No hay medicamentos registrados para este paciente.',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          icon: LucideIcons.checkCircle,
          iconBg: AppColors.accentLight,
          iconFg: AppColors.accent,
          value: '92%',
          label: 'Adherencia',
          valueColor: AppColors.accent,
        ),
        _StatCard(
          icon: LucideIcons.plusSquare,
          iconBg: AppColors.primaryLight,
          iconFg: AppColors.primary,
          value: '5',
          label: 'Medicamentos',
        ),
        _StatCard(
          icon: LucideIcons.clock,
          iconBg: AppColors.warningBg,
          iconFg: AppColors.warning,
          value: '3',
          label: 'Dosis hoy',
        ),
        _StatCard(
          icon: LucideIcons.alertTriangle,
          iconBg: AppColors.dangerBg,
          iconFg: AppColors.dangerDark,
          value: '1',
          label: 'Alertas',
          valueColor: AppColors.dangerDark,
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Adherencia Semanal',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              Text('87%',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 12),
          const AdherenceBarChart(
            data: {
              'Lun': 92,
              'Mar': 85,
              'Mié': 78,
              'Jue': 90,
              'Vie': 95,
              'Sáb': 82,
              'Dom': 88,
            },
            height: 140,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _ActionCard(
          icon: LucideIcons.activity,
          iconBg: AppColors.primaryLight,
          iconFg: AppColors.primary,
          label: 'Ver historial',
          onTap: () => Navigator.pushNamed(context, AppRoutes.history),
        ),
        _ActionCard(
          icon: LucideIcons.plus,
          iconBg: AppColors.accentLight,
          iconFg: AppColors.accent,
          label: 'Agregar medicamento',
          onTap: () => Navigator.pushNamed(context, AppRoutes.addMedication),
        ),
        _ActionCard(
          icon: LucideIcons.messageCircle,
          iconBg: AppColors.warningBg,
          iconFg: AppColors.warning,
          label: 'Enviar mensaje',
          onTap: () => Navigator.pushNamed(context, AppRoutes.voiceMessages),
        ),
        _ActionCard(
          icon: LucideIcons.alertTriangle,
          iconBg: AppColors.dangerBg,
          iconFg: AppColors.dangerDark,
          label: 'Alerta SOS',
          onTap: () => Navigator.pushNamed(context, AppRoutes.sosEmergency),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Text(
          'Ver todos',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconFg),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconFg),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
