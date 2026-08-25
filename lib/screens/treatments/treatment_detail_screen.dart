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
import '../../models/enums.dart';

class TreatmentDetailScreen extends StatefulWidget {
  const TreatmentDetailScreen({super.key});

  @override
  State<TreatmentDetailScreen> createState() => _TreatmentDetailScreenState();
}

class _TreatmentDetailScreenState extends State<TreatmentDetailScreen> {
  late Future<List<Treatment>> _treatmentsFuture;
  int _selectedIdx = 0;

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

  void _refresh() {
    setState(() {
      _selectedIdx = 0;
      _loadTreatments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder(
        future: _treatmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SingleChildScrollView(child: SkeletonDetail());
          }
          final treatments = (snapshot.data ?? []).where((t) => t.status != TreatmentStatus.finalizado).toList();
          // Mantener todos si solo hay finalizados, para no mostrar vacío engañoso
          final list = treatments.isNotEmpty ? treatments : (snapshot.data ?? []);
          if (list.isEmpty) {
            return Column(
              children: [
                VitalHeader.white(title: 'Tratamientos', actions: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.addMedication).then((_) => _refresh()),
                    child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle), child: const Icon(LucideIcons.plus, size: 16, color: AppColors.primary)),
                  ),
                ]),
                const Expanded(child: VitalEmptyState(icon: LucideIcons.heartPulse, title: 'Sin tratamientos', description: 'No hay tratamientos registrados para este paciente.\nToca + para crear uno.')),
              ],
            );
          }
          // Clamp selected
          if (_selectedIdx >= list.length) _selectedIdx = 0;
          final treatment = list[_selectedIdx];
          final totalMeds = list.expand((t) => t.details ?? []).where((d) => d.status == MedicationStatus.enCurso).length;
          return Column(
            children: [
              VitalHeader.white(
                title: list.length == 1 ? 'Detalle del Tratamiento' : 'Tratamientos',
                actions: [
                  if (treatment.status != TreatmentStatus.finalizado)
                    PopupMenuButton<String>(
                      icon: Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.bg, shape: BoxShape.circle), child: const Icon(LucideIcons.ellipsisVertical, size: 16, color: AppColors.textMuted)),
                      onSelected: (value) async {
                        if (value == 'finalize') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.checkCircle2, size: 20, color: AppColors.primary)), const SizedBox(width: 10), const Expanded(child: Text('Finalizar tratamiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))]),
                              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('¿Finalizar Tratamiento ${_selectedIdx + 1}?', style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                const Text('Se marcarán todos los medicamentos como finalizados, se liberarán los compartimentos y se actualizará el pastillero por MQTT.', style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4)),
                                const SizedBox(height: 10),
                                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.warning.withValues(alpha: 0.2))), child: Row(children: [const Icon(LucideIcons.info, size: 14, color: AppColors.warning), const SizedBox(width: 6), Expanded(child: Text('${treatment.details?.length ?? 0} medicamentos · Fin: ${_formatDate(treatment.endDate)}', style: const TextStyle(fontSize: 12, color: AppColors.warning)))])),
                              ]),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Finalizar')),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            await context.read<TreatmentService>().finalizeTreatment(treatment.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tratamiento finalizado · Compartimentos liberados y pastillero actualizado'), backgroundColor: AppColors.accent));
                            _refresh();
                          }
                        } else if (value == 'pause' || value == 'resume') {
                          final isPause = value == 'pause';
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(isPause ? 'Pausar tratamiento' : 'Reanudar tratamiento'),
                              content: Text(isPause ? 'Se pausará la dispensación y no se crearán nuevas dosis hasta reanudar.' : 'Se reanudará la dispensación del tratamiento.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isPause ? 'Pausar' : 'Reanudar')),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            await context.read<TreatmentService>().togglePauseTreatment(treatment.id, isPause);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isPause ? 'Tratamiento pausado' : 'Tratamiento reanudado')));
                            _refresh();
                          }
                        } else if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar tratamiento'),
                              content: Text('¿Eliminar Tratamiento ${_selectedIdx + 1}? Se borrarán ${treatment.details?.length ?? 0} medicamentos y horarios.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.danger))),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            await context.read<TreatmentService>().deleteTreatment(treatment.id);
                            _refresh();
                          }
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'finalize', child: Row(children: [Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.primary), SizedBox(width: 8), Text('Finalizar tratamiento')])),
                        PopupMenuItem(value: treatment.status == TreatmentStatus.pausado ? 'resume' : 'pause', child: Row(children: [Icon(treatment.status == TreatmentStatus.pausado ? LucideIcons.play : LucideIcons.pause, size: 16, color: AppColors.warning), SizedBox(width: 8), Text(treatment.status == TreatmentStatus.pausado ? 'Reanudar' : 'Pausar')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(LucideIcons.trash2, size: 16, color: AppColors.danger), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppColors.danger))])),
                      ],
                    ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (list.length > 1) ...[
                        _buildAggregateCard(list, totalMeds),
                        const SizedBox(height: 12),
                        _buildTreatmentSelector(list),
                        const SizedBox(height: 16),
                      ],
                      _buildHeroCard(treatment, index: _selectedIdx, total: list.length),
                      const SizedBox(height: 16),
                      _buildProgressCard(treatment),
                      if (treatment.status != TreatmentStatus.finalizado) ...[
                        const SizedBox(height: 12),
                        _buildActionBar(context, treatment),
                      ] else ...[
                        const SizedBox(height: 12),
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)), child: Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle), child: const Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.accent)), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tratamiento finalizado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)), Text('Compartimentos liberados · Pastillero actualizado', style: TextStyle(fontSize: 11, color: AppColors.textMuted))]))])),
                      ],
                      const SizedBox(height: 16),
                      _buildSectionHeader(context, 'Medicamentos (${treatment.details?.length ?? 0})'),
                      const SizedBox(height: 8),
                      if (treatment.details != null && treatment.details!.isNotEmpty)
                        ...treatment.details!.map((d) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildMedCard(d)))
                      else
                        const VitalEmptyState(icon: LucideIcons.pill, title: 'Sin medicamentos', description: 'No hay medicamentos en este tratamiento.'),
                      if (list.length > 1) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.15))),
                          child: Row(children: [
                            Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(LucideIcons.info, size: 16, color: AppColors.primary)),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('Desliza entre tratamientos. Cada uno puede tener varios medicamentos y compartimentos.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4))),
                          ]),
                        ),
                      ],
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

  Widget _buildAggregateCard(List<Treatment> list, int totalMeds) {
    final activos = list.where((t) => t.status == TreatmentStatus.activo).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppDimensions.cardShadow),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.layers, size: 18, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${list.length} tratamiento${list.length > 1 ? 's' : ''} · $totalMeds medicamento${totalMeds != 1 ? 's' : ''}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text('$activos activo${activos != 1 ? 's' : ''} · Cada tratamiento agrupa medicamentos con horarios y compartimentos', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }

  Widget _buildTreatmentSelector(List<Treatment> list) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = list[i];
          final isSel = i == _selectedIdx;
          final meds = t.details?.length ?? 0;
          return GestureDetector(
            onTap: () => setState(() => _selectedIdx = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? AppColors.primary : AppColors.borderLight),
                boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : AppDimensions.cardShadow,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: isSel ? Colors.white : (t.status == TreatmentStatus.activo ? AppColors.accent : AppColors.textLight))),
                const SizedBox(width: 8),
                Text('T${i + 1} · ${meds} med${meds != 1 ? 's' : ''}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSel ? Colors.white : AppColors.textDark)),
                const SizedBox(width: 6),
                Text('${t.startDate.day}/${t.startDate.month}', style: TextStyle(fontSize: 11, color: isSel ? Colors.white70 : AppColors.textMuted)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(Treatment treatment, {required int index, required int total}) {
    final details = treatment.details ?? [];
    final totalDays = treatment.totalDays;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment(0.87, -0.50), end: Alignment(-0.87, 0.50), colors: [Color(0xFF4A90E2), Color(0xFF6FCF97)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(total > 1 ? 'Tratamiento ${index + 1} de $total' : 'Tratamiento ${treatment.startDate.day}/${treatment.startDate.month}/${treatment.startDate.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Inicio: ${treatment.startDate.day} ${_monthName(treatment.startDate.month)} ${treatment.startDate.year}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text(treatment.status.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _HeroStat(value: '${details.length}', label: 'Medicamentos'),
          _HeroStat(value: '${treatment.elapsedDays}', label: 'Días transcurridos'),
          _HeroStat(value: '${(totalDays - treatment.elapsedDays).clamp(0, 9999)}', label: 'Días restantes'),
        ]),
      ]),
    );
  }

  Widget _buildProgressCard(Treatment treatment) {
    final endDate = treatment.endDate;
    final isChronic = endDate == null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Progreso general', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text(isChronic ? 'Crónico' : '${treatment.elapsedDays} / ${treatment.totalDays} días', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: isChronic ? null : treatment.progress, minHeight: 6, backgroundColor: AppColors.borderLight, valueColor: AlwaysStoppedAnimation(isChronic ? AppColors.accent : AppColors.primary))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${treatment.startDate.day} ${_monthName(treatment.startDate.month)} ${treatment.startDate.year}', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          Text(isChronic ? 'Sin fecha fin' : '${endDate!.day} ${_monthName(endDate.month)} ${endDate.year}', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ]),
      ]),
    );
  }

  Widget _buildActionBar(BuildContext context, Treatment treatment) {
    final isPausado = treatment.status == TreatmentStatus.pausado;
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () async {
            final isPause = !isPausado;
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(isPause ? 'Pausar tratamiento' : 'Reanudar tratamiento'),
                content: Text(isPause ? 'Se pausará la dispensación y no se crearán dosis hasta reanudar.' : 'Se reanudará la dispensación.'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isPause ? 'Pausar' : 'Reanudar'))],
              ),
            );
            if (confirmed == true && context.mounted) {
              await context.read<TreatmentService>().togglePauseTreatment(treatment.id, isPause);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isPause ? 'Tratamiento pausado' : 'Tratamiento reanudado')));
              _refresh();
            }
          },
          icon: Icon(isPausado ? LucideIcons.play : LucideIcons.pause, size: 16),
          label: Text(isPausado ? 'Reanudar' : 'Pausar', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: isPausado ? AppColors.accent : AppColors.warning), foregroundColor: isPausado ? AppColors.accent : AppColors.warning),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: FilledButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.checkCircle2, size: 20, color: AppColors.primary)), const SizedBox(width: 10), const Expanded(child: Text('Finalizar tratamiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))]),
                content: const Text('Se marcarán medicamentos como finalizados, se liberarán compartimentos y se actualizará el pastillero.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Finalizar'))],
              ),
            );
            if (confirmed == true && context.mounted) {
              await context.read<TreatmentService>().finalizeTreatment(treatment.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tratamiento finalizado · Compartimentos liberados'), backgroundColor: AppColors.accent));
              _refresh();
            }
          },
          icon: const Icon(LucideIcons.checkCircle2, size: 16),
          label: const Text('Finalizar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: AppColors.primary),
        ),
      ),
    ]);
  }

  String _monthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      GestureDetector(onTap: () => Navigator.pushNamed(context, AppRoutes.addMedication).then((_) => _refresh()), child: const Text('+ Agregar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary))),
    ]);
  }

  Widget _buildMedCard(TreatmentDetail detail) {
    final medication = detail.medication;
    final pres = medication?.presentation;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.pill, size: 20, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(medication?.name ?? 'Medicamento', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            if (pres != null && pres.isNotEmpty) ...[const SizedBox(height: 2), Text(pres, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted))],
            if (detail.doseInfo != null && detail.doseInfo!.isNotEmpty) ...[const SizedBox(height: 2), Text(detail.doseInfo!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))],
          ])),
          VitalBadge.completed(label: detail.status == MedicationStatus.enCurso ? 'Activo' : 'Finalizado'),
        ]),
        const SizedBox(height: 12),
        if (detail.schedules != null && detail.schedules!.isNotEmpty)
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
            children: detail.schedules!.map((s) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Horario', style: TextStyle(fontSize: 9, color: AppColors.textLight)),
                const SizedBox(height: 2),
                Text(s.timeDisplay, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ]),
            )).toList(),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(LucideIcons.calendar, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(child: Text('Fin: ${_formatDate(detail.endDate)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark))),
            Text('Cada ${detail.frequencyHours ?? 0}h', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
        ),
      ]),
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
  final String value; final String label;
  const _HeroStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)), const SizedBox(height: 1), Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70))]));
  }
}
