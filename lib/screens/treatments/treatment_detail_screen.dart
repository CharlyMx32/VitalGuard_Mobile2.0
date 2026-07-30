import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/treatment_service.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_empty_state.dart';
import '../../models/treatment.dart';

class TreatmentDetailScreen extends StatelessWidget {
  const TreatmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final treatmentService = context.read<TreatmentService>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder(
        future: treatmentService.getTreatments(1),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SingleChildScrollView(
              child: SkeletonDetail(),
            );
          }
          final treatments = snapshot.data ?? [];
          final treatment = treatments.isNotEmpty ? treatments.first : null;
          if (treatment == null) {
            return const VitalEmptyState(
              icon: LucideIcons.heartPulse,
              title: 'Sin tratamiento activo',
              description: 'No hay un tratamiento activo actualmente.',
            );
          }
          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingHorizontal,
                  ) + const EdgeInsets.only(top: 16, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(treatment),
                      const SizedBox(height: 16),
                      _buildProgressCard(treatment),
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                          'Medicamentos (${treatment.details?.length ?? 0})'),
                      const SizedBox(height: 8),
                      if (treatment.details != null &&
                          treatment.details!.isNotEmpty)
                        ...treatment.details!.map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildMedCard(d),
                            ))
                      else
                        const VitalEmptyState(
                          icon: LucideIcons.pill,
                          title: 'Sin medicamentos',
                          description:
                              'No hay medicamentos en este tratamiento.',
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(LucideIcons.chevronLeft,
                    size: 18, color: AppColors.textDark)),
          ),
          const Expanded(
            child: Text('Detalle del Tratamiento',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Treatment treatment) {
    final details = treatment.details ?? [];
    final totalDays = treatment.totalDays;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.87, -0.50),
          end: Alignment(-0.87, 0.50),
          colors: [Color(0xFF4A90E2), Color(0xFF6FCF97)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tratamiento ${treatment.startDate.day}/${treatment.startDate.month}/${treatment.startDate.year}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inicio: ${treatment.startDate.day} ${_monthName(treatment.startDate.month)} ${treatment.startDate.year}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  treatment.status.name,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeroStat(
                  value: '${details.length}',
                  label: 'Medicamentos'),
              _HeroStat(
                  value: '${treatment.elapsedDays}',
                  label: 'Días transcurridos'),
              _HeroStat(
                  value: '${totalDays - treatment.elapsedDays}',
                  label: 'Días restantes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Treatment treatment) {
    final endDate = treatment.endDate ?? DateTime.now();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso general',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              Text('${treatment.elapsedDays} / ${treatment.totalDays} días',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: treatment.progress,
              minHeight: 6,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${treatment.startDate.day} ${_monthName(treatment.startDate.month)} ${treatment.startDate.year}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textLight)),
              Text(
                  '${endDate.day} ${_monthName(endDate.month)} ${endDate.year}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        const Text('+ Agregar',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary)),
      ],
    );
  }

  Widget _buildMedCard(TreatmentDetail detail) {
    final medication = detail.medication;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.pill,
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication?.name ?? 'Medicamento',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.doseInfo ?? '',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Activo',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (detail.schedules != null && detail.schedules!.isNotEmpty)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: detail.schedules!.map((s) => Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Horario',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.textLight)),
                    const SizedBox(height: 2),
                    Text(s.timeDisplay,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                  ],
                ),
              )).toList(),
            ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progreso',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                  Text('${detail.frequencyHours ?? 0}h',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 1),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }
}
