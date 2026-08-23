import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/treatment_service.dart';
import '../../services/auth_service.dart';
import '../../services/patient_current_service.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_badge.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/vital_header.dart';
import '../../models/treatment.dart';

class TreatmentDetailScreen extends StatefulWidget {
  const TreatmentDetailScreen({super.key});

  @override
  State<TreatmentDetailScreen> createState() => _TreatmentDetailScreenState();
}

class _TreatmentDetailScreenState extends State<TreatmentDetailScreen> {
  late Future<List<Treatment>> _treatmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  void _loadTreatments() {
    final patientCurrent = context.read<PatientCurrentService>();
    final auth = context.read<AuthService>();
    final treatmentService = context.read<TreatmentService>();
    final patientId = patientCurrent.patientId ?? auth.patientId;
    if (patientId == null) return;
    _treatmentsFuture = treatmentService.getTreatments(patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder(
        future: _treatmentsFuture,
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
              VitalHeader.white(
                title: 'Detalle del Tratamiento',
                actions: [
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar tratamiento'),
                            content: const Text('¿Estás seguro? Se eliminarán todos los medicamentos y horarios asociados.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.danger))),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          await context.read<TreatmentService>().deleteTreatment(treatment.id);
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(LucideIcons.trash2,
                              size: 18, color: AppColors.danger)),
                    ),
                ],
              ),
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
                      _buildSectionHeader(context,
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
              Expanded(
              child: Column(
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
              ),
              const SizedBox(width: 8),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.addMedication),
          child: const Text('+ Agregar',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildMedCard(TreatmentDetail detail) {
    final medication = detail.medication;
    final pres = medication?.presentation;
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
                    if (pres != null && pres.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        pres,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted),
                      ),
                    ],
                    if (detail.doseInfo != null &&
                        detail.doseInfo!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail.doseInfo!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const VitalBadge.completed(label: 'Activo'),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.calendar,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Fin: ${_formatDate(detail.endDate)}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark),
                  ),
                ),
                Text('Cada ${detail.frequencyHours ?? 0}h',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha de fin';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
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
