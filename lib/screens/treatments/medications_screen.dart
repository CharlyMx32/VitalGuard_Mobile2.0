import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/treatment_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_empty_state.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: const MedicationsContent(),
    );
  }
}

class MedicationsContent extends StatefulWidget {
  const MedicationsContent({super.key});

  @override
  State<MedicationsContent> createState() => _MedicationsContentState();
}

class _MedicationsContentState extends State<MedicationsContent> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final treatmentService = context.read<TreatmentService>();
    final auth = context.read<AuthService>();
    final patientId = auth.isSelfCare ? 1 : 1;
    return Container(
      color: AppColors.bg,
      child: FutureBuilder<List<Treatment>>(
        future: treatmentService.getTreatments(patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList(itemCount: 4);
          }
          final allDetails = (snapshot.data ?? [])
              .expand<TreatmentDetail>((t) => t.details ?? [])
              .toList();
          final activeCount = allDetails
              .where((d) => d.status == MedicationStatus.enCurso)
              .length;
          final pausedCount = allDetails
              .where((d) => d.status == MedicationStatus.finalizado)
              .length;
          final filtered = _filterDetails(allDetails);
          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingHorizontal) +
                      const EdgeInsets.only(top: 16, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterTabs(
                          allDetails.length, activeCount, pausedCount),
                      const SizedBox(height: 12),
                      if (filtered.isNotEmpty)
                        ...filtered.map((d) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: _buildMedCard(d),
                            ))
                      else
                        const VitalEmptyState(
                          icon: LucideIcons.pill,
                          title: 'Sin medicamentos',
                          description:
                              'No tienes medicamentos registrados.\nAgrega uno para comenzar.',
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

  List<TreatmentDetail> _filterDetails(List<TreatmentDetail> details) {
    switch (_selectedFilter) {
      case 1:
        return details
            .where((d) => d.status == MedicationStatus.enCurso)
            .toList();
      case 2:
        return details
            .where((d) => d.status == MedicationStatus.finalizado)
            .toList();
      default:
        return details;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom:
                BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 32),
          const Expanded(
            child: Text('Mis Medicamentos',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .pushNamed(AppRoutes.scheduleConfig),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(LucideIcons.plus,
                  size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(int total, int active, int paused) {
    final tabs = [
      'Todos ($total)',
      'Activos ($active)',
      'Pausados ($paused)',
    ];
    return Row(
      children: List.generate(tabs.length, (i) {
        final isActive = _selectedFilter == i;
        return Padding(
          padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.borderLight,
                ),
              ),
              child: Text(tabs[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : AppColors.textSecondary,
                  )),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMedCard(TreatmentDetail detail) {
    final medication = detail.medication;
    final schedules = detail.schedules ?? [];
    final isActive = detail.status == MedicationStatus.enCurso;
    final colors = _cardColors(isActive);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(LucideIcons.pill,
                    size: 22, color: colors.fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication?.name ?? 'Medicamento',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medication?.presentation ?? '',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.moreVertical,
                  size: 16, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              _detailGrid('Dosis', detail.doseInfo ?? '--'),
              _detailGrid('Frecuencia',
                  detail.frequencyHours != null
                      ? 'Cada ${detail.frequencyHours}h'
                      : '--'),
              _detailGrid(
                  'Lugar',
                  detail.compartmentNumber != null
                      ? '#${detail.compartmentNumber}'
                      : '--'),
              _detailGrid(
                  'Estado',
                  isActive ? 'Activo' : 'Pausado'),
            ],
          ),
          if (schedules.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: schedules
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(20)),
                        child: Text(s.timeDisplay,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: AppColors.borderLight,
                        width: 0.5))),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(isActive
                                  ? 'Medicamento pausado'
                                  : 'Medicamento activado'),
                              backgroundColor: isActive
                                  ? AppColors.warning
                                  : AppColors.accent),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.bg,
                        foregroundColor: AppColors.textDark,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        isActive ? 'Pausar' : 'Activar',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoutes.scheduleConfig),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Editar',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailGrid(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }

  _CardColors _cardColors(bool active) {
    if (active) {
      return _CardColors(
          bg: AppColors.primaryLight, fg: AppColors.primary);
    }
    return _CardColors(
        bg: AppColors.bg, fg: AppColors.textMuted);
  }
}

class _CardColors {
  final Color bg;
  final Color fg;
  const _CardColors({required this.bg, required this.fg});
}
