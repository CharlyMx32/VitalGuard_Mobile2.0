import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/treatment_service.dart';
import '../../services/auth_service.dart';
import '../../services/patient_current_service.dart';
import '../../widgets/vital_header.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/vital_shimmer.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';

class TreatmentHistoryScreen extends StatefulWidget {
  const TreatmentHistoryScreen({super.key});

  @override
  State<TreatmentHistoryScreen> createState() => _TreatmentHistoryScreenState();
}

class _TreatmentHistoryScreenState extends State<TreatmentHistoryScreen> {
  late Future<List<Treatment>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final pid = context.read<PatientCurrentService>().patientId ?? context.read<AuthService>().patientId;
    if (pid == null) {
      _future = Future.value([]);
      return;
    }
    _future = context.read<TreatmentService>().getTreatments(pid);
  }

  void _refresh() => setState(_load);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<List<Treatment>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SingleChildScrollView(child: SkeletonDetail());
          }
          final all = snap.data ?? [];
          final history = all.where((t) => t.status == TreatmentStatus.finalizado).toList()
            ..sort((a, b) => (b.endDate ?? b.startDate).compareTo(a.endDate ?? a.startDate));

          return Column(
            children: [
              VitalHeader.white(
                title: history.isEmpty ? 'Historial' : 'Historial · ${history.length}',
                actions: [
                  GestureDetector(
                    onTap: _refresh,
                    child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.bg, shape: BoxShape.circle), child: const Icon(LucideIcons.refreshCw, size: 16, color: AppColors.textMuted)),
                  ),
                ],
              ),
              if (history.isEmpty)
                const Expanded(
                  child: VitalEmptyState(
                    icon: LucideIcons.archive,
                    title: 'Sin historial',
                    description: 'Aún no hay tratamientos finalizados.\nCuando finalices un tratamiento aparecerá aquí para consulta.',
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal, vertical: 16) + const EdgeInsets.only(bottom: 80),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _HistoryCard(treatment: history[i], index: i),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Treatment treatment;
  final int index;
  const _HistoryCard({required this.treatment, required this.index});

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }

  String _monthName(int m) {
    const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return months[m-1];
  }

  @override
  Widget build(BuildContext context) {
    final details = treatment.details ?? [];
    final duration = treatment.endDate != null ? treatment.endDate!.difference(treatment.startDate).inDays : null;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow, border: Border.all(color: AppColors.borderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment(0.9, -0.5), end: Alignment(-0.9, 0.5), colors: [Color(0xFF8E9AAF), Color(0xFFCBC0D3)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.archive, size: 20, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Tratamiento finalizado', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('${treatment.startDate.day} ${_monthName(treatment.startDate.month)} ${treatment.startDate.year} → ${_fmt(treatment.endDate)}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ]),
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: const Text('Finalizado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _MiniStat(icon: LucideIcons.pill, value: '${details.length}', label: 'Meds'),
                  const SizedBox(width: 12),
                  _MiniStat(icon: LucideIcons.calendar, value: duration != null ? '${duration}d' : '—', label: 'Duración'),
                  const SizedBox(width: 12),
                  _MiniStat(icon: LucideIcons.package, value: '${details.where((d) => d.compartmentNumber != null).length}', label: 'Compart.'),
                ]),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...details.take(4).map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)), child: const Icon(LucideIcons.pill, size: 14, color: AppColors.textMuted)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.medication?.name ?? 'Medicamento', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (d.doseInfo != null) Text(d.doseInfo!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ])),
                      if (d.compartmentNumber != null) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(6)), child: Text('#${d.compartmentNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                    ]),
                  )),
                  if (details.length > 4) Text('+ ${details.length - 4} más', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniStat({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ]),
      ),
    );
  }
}
