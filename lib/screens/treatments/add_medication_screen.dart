import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/treatment_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/vital_modal.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<Map<String, dynamic>> _medications = [];
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressSection(),
                  const SizedBox(height: 16),
                  _buildDateFields(),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Medicamentos del tratamiento', '${_medications.length} agregados'),
                  const SizedBox(height: 8),
                  if (_medications.isEmpty)
                    const VitalEmptyState(
                      icon: LucideIcons.pill,
                      title: 'Sin medicamentos',
                      description: 'Busca los medicamentos en el catalogo\ny agregalos a tu tratamiento.',
                    )
                  else
                    ..._medications.asMap().entries.map((e) => _buildMedItem(e.key, e.value)),
                  const SizedBox(height: 8),
                  _buildAddMedButton(),
                  const SizedBox(height: 16),
                  _buildFooterButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedItem(int index, Map<String, dynamic> med) {
    final frequency = med['frequencyHours'] as int? ?? 8;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: const Icon(LucideIcons.pill, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(med['medicationName'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text('${med['doseInfo'] ?? 'Dosis no especificada'} · Cada $frequency horas', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ])),
        GestureDetector(
          onTap: () => setState(() => _medications.removeAt(index)),
          child: const Icon(LucideIcons.trash2, size: 16, color: AppColors.dangerDark),
        ),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark))),
          const Expanded(child: Text('Crear Tratamiento', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = _medications.isEmpty ? 0.3 : 0.7;
    return Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: AppColors.borderLight, valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Tratamiento', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary)),
          Text('Medicamentos', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _medications.isNotEmpty ? AppColors.primary : AppColors.textMuted)),
          const Text('Horarios', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
        ]),
      ],
    );
  }

  Widget _buildDateFields() {
    return Column(
      children: [
        _buildDateField('Fecha de inicio', _startDate, (date) {
          if (date != null) setState(() => _startDate = date);
        }),
        const SizedBox(height: 12),
        _buildDateField('Fecha de fin (opcional)', _endDate, (date) {
          setState(() => _endDate = date);
        }),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, ValueChanged<DateTime?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030));
          onChanged(picked);
        },
        child: Container(
          height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(date != null ? '${date.day} ${_monthName(date.month)} ${date.year}' : 'Seleccionar',
              style: TextStyle(fontSize: 14, color: date != null ? AppColors.textDark : AppColors.textMuted)),
            const Icon(LucideIcons.calendar, size: 16, color: AppColors.textMuted),
          ]),
        ),
      ),
    ]);
  }

  String _monthName(int month) {
    const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month];
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      Text(count, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
    ]);
  }

  Widget _buildAddMedButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).pushNamed(AppRoutes.scheduleConfig);
        if (result != null && result is Map<String, dynamic>) {
          setState(() => _medications.add(result));
        }
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight, width: 1.5), borderRadius: BorderRadius.circular(12)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Agregar medicamento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
        ]),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Column(
      children: [
        SizedBox(width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: _medications.isEmpty ? null : _onSaveTreatment,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, disabledBackgroundColor: AppColors.borderLight),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Guardar Tratamiento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.borderLight), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Cancelar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Future<void> _onSaveTreatment() async {
    setState(() => _isSaving = true);
    final treatmentService = context.read<TreatmentService>();
    final auth = context.read<AuthService>();

    final treatment = await treatmentService.createTreatment(
      auth.patientId, _startDate, _endDate,
    );

    for (final med in _medications) {
      final firstTake = DateTime(
        _startDate.year, _startDate.month, _startDate.day, 8, 0,
      );
      final frequencyHours = med['frequencyHours'] as int? ?? 8;
      final detail = TreatmentDetail(
        id: DateTime.now().millisecondsSinceEpoch + med.hashCode,
        treatmentId: treatment.id,
        medicationId: med['medicationId'] as int? ?? 0,
        doseInfo: med['doseInfo'] as String?,
        frequencyHours: frequencyHours,
        firstTakeTime: firstTake,
        endDate: med['endDate'] as DateTime?,
        status: MedicationStatus.enCurso,
        compartmentNumber: med['compartmentNumber'] as int?,
        isExternal: med['isExternal'] as bool?,
      );
      final saved = await treatmentService.addDetail(treatment.id, detail);

      if (saved.id != 0) {
        for (var i = 0; i < 24 ~/ frequencyHours; i++) {
          await treatmentService.addSchedule(Schedule(
            id: DateTime.now().millisecondsSinceEpoch + med.hashCode + i,
            treatmentDetailId: saved.id,
            timeOfDay: firstTake.add(Duration(hours: frequencyHours * i)),
          ));
        }
      }
    }

    if (mounted) {
      VitalFeedback.success(
        context,
        message: 'Tratamiento guardado correctamente',
        onAction: () => Navigator.of(context).pop(),
      );
    }
  }
}
