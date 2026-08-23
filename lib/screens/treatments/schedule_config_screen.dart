import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../models/medication.dart';
import '../../models/treatment.dart';
import '../../services/treatment_service.dart';
import '../../services/auth_service.dart';
import '../../services/patient_current_service.dart';
import '../../widgets/medication_search_field.dart';
import '../../widgets/vital_header.dart';
import '../../widgets/vital_form_field.dart';
import '../../utils/vital_validator.dart';

class ScheduleConfigScreen extends StatefulWidget {
  const ScheduleConfigScreen({super.key});

  @override
  State<ScheduleConfigScreen> createState() => _ScheduleConfigScreenState();
}

class _ScheduleConfigScreenState extends State<ScheduleConfigScreen> {
  int _selectedType = 0;
  final _doseController = TextEditingController();
  final _frequencyController = TextEditingController(text: '8');
  int? _compartmentNumber;
  DateTime? _endDate;
  Medication? _selectedMedication;
  int _frequencyHours = 8;
  TimeOfDay _firstTakeTime = const TimeOfDay(hour: 8, minute: 0);
  Set<int> _occupiedCompartments = {};
  Set<int> _sessionOccupied = {};

  TreatmentDetail? _editDetail;
  bool get _isEditing => _editDetail != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _sessionOccupied = (args['occupiedCompartments'] as Set<int>?) ?? {};
      }
      _loadOccupiedCompartments();
      if (args is TreatmentDetail) {
        _editDetail = args;
        _doseController.text = args.doseInfo ?? '';
        _frequencyHours = args.frequencyHours ?? 8;
        _frequencyController.text = '$_frequencyHours';
        _compartmentNumber = args.compartmentNumber;
        _selectedType = args.isExternal == true ? 1 : 0;
        _firstTakeTime = TimeOfDay(hour: args.firstTakeTime.hour, minute: args.firstTakeTime.minute);
        if (args.endDate != null) _endDate = args.endDate;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _doseController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _loadOccupiedCompartments() async {
    final patientCurrent = context.read<PatientCurrentService>();
    final auth = context.read<AuthService>();
    final treatmentService = context.read<TreatmentService>();
    final patientId = patientCurrent.patientId ?? auth.patientId ?? 0;
    try {
      final treatments = await treatmentService.getTreatments(patientId);
      final occupied = <int>{};
      for (final t in treatments) {
        for (final d in (t.details ?? [])) {
          if (d.compartmentNumber != null && d.compartmentNumber! > 0) {
            occupied.add(d.compartmentNumber!);
          }
        }
      }
      occupied.addAll(_sessionOccupied);
      if (mounted) setState(() => _occupiedCompartments = occupied);
    } catch (_) {
      if (_sessionOccupied.isNotEmpty) {
        if (mounted) setState(() => _occupiedCompartments = _sessionOccupied);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: _isEditing ? 'Editar Medicamento' : 'Agregar Medicamento'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressSection(),
                  const SizedBox(height: 16),
                  _buildMedicationSection(),
                  const SizedBox(height: 16),
                  _buildDivider('Configuracion'),
                  const SizedBox(height: 12),
                  _buildConfigSection(),
                  const SizedBox(height: 16),
                  _buildDivider('Frecuencia'),
                  const SizedBox(height: 12),
                  _buildFrequencySection(),
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

  Widget _buildProgressSection() {
    return Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: 0.7, minHeight: 4, backgroundColor: AppColors.borderLight, valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
        ),
        const SizedBox(height: 8),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Tratamiento', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.accent)),
          Text('Medicamentos', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary)),
          Text('Horarios', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
        ]),
      ],
    );
  }

  Widget _buildMedicationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleccionar medicamento', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        MedicationSearchField(
          onSelected: (med) => setState(() => _selectedMedication = med),
        ),
      ],
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.borderLight)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5))),
        Expanded(child: Container(height: 1, color: AppColors.borderLight)),
      ],
    );
  }

  Widget _buildConfigSection() {
    return Column(
      children: [
        _buildFormLabel('Tipo de medicamento'),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildTypeOption(0, LucideIcons.package, 'En pastillero'),
            const SizedBox(width: 8),
            _buildTypeOption(1, LucideIcons.clock, 'Fuera del pastillero'),
          ],
        ),
        const SizedBox(height: 12),
        _buildFormLabel('Dosis'),
        const SizedBox(height: 6),
        VitalFormField(
          label: '',
          controller: _doseController,
          hint: 'Ej: 1 tableta, 5ml',
          validator: VitalValidator.doseInfo,
          onChanged: (_) => setState(() {}),
        ),
        if (_selectedType == 0) ...[
          const SizedBox(height: 12),
          _buildFormLabel('Compartimento (pastillero)'),
          const SizedBox(height: 6),
          _buildCompartmentSelector(),
        ],
        const SizedBox(height: 12),
        _buildFormLabel('Fecha de fin (opcional)'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030));
            if (picked != null) setState(() => _endDate = picked);
          },
          child: Container(
            height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'Seleccionar',
                style: TextStyle(fontSize: 14, color: _endDate != null ? AppColors.textDark : AppColors.textMuted)),
              const Icon(LucideIcons.calendar, size: 16, color: AppColors.textMuted),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCompartmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            final num = i + 1;
            final isOccupied = _occupiedCompartments.contains(num) && _compartmentNumber != num;
            final isSelected = _compartmentNumber == num;
            return Expanded(
              child: GestureDetector(
                onTap: isOccupied ? null : () => setState(() => _compartmentNumber = num),
                child: Container(
                  height: 52,
                  margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isOccupied
                            ? const Color(0xFFFDEAEA)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isOccupied
                              ? const Color(0xFFE57373)
                              : AppColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isOccupied ? LucideIcons.lock : LucideIcons.package,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : isOccupied
                                ? const Color(0xFFD32F2F)
                                : AppColors.textMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$num',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : isOccupied
                                  ? const Color(0xFFD32F2F)
                                  : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        if (_occupiedCompartments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFFDEAEA), borderRadius: BorderRadius.circular(2), border: Border.all(color: const Color(0xFFE57373)))),
                const SizedBox(width: 4),
                const Text('Ocupado', style: TextStyle(fontSize: 10, color: Color(0xFFD32F2F))),
                const SizedBox(width: 12),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                const Text('Seleccionado', style: TextStyle(fontSize: 10, color: AppColors.primary)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted));
  }

  Widget _buildTypeOption(int index, IconData icon, String label) {
    final isSelected = _selectedType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = index),
        child: Container(
          height: 44,
          decoration: BoxDecoration(color: isSelected ? const Color(0xFFF0F7FF) : Colors.white, border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.primary : AppColors.textDark),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textDark)),
          ]),
        ),
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      children: [
        _buildFormLabel('Cada cuantas horas'),
        const SizedBox(height: 6),
        VitalFormField(
          label: '',
          controller: _frequencyController,
          hint: 'Ej: 8',
          validator: VitalValidator.frequencyHours,
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null && n > 0 && n <= 72) _frequencyHours = n;
            setState(() {});
          },
        ),
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerLeft, child: Text(
          _frequencyHours > 0 ? _buildFrequencyText() : 'Ingresa un numero entre 1 y 72',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        )),
        const SizedBox(height: 16),
        _buildFormLabel('Hora de la primera toma'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: _firstTakeTime);
            if (picked != null) setState(() => _firstTakeTime = picked);
          },
          child: Container(
            height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_formatTime(_firstTakeTime), style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
              const Icon(LucideIcons.clock, size: 16, color: AppColors.textMuted),
            ]),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  String _buildFrequencyText() {
    if (_frequencyHours <= 24) {
      final tomas = (24 / _frequencyHours).ceil();
      return 'Cada $_frequencyHours horas = $tomas ${tomas == 1 ? "toma" : "tomas"} al dia';
    } else {
      final dias = (_frequencyHours / 24).ceil();
      return 'Cada $_frequencyHours horas = 1 toma cada $dias ${dias == 1 ? "dia" : "dias"}';
    }
  }

  Widget _buildFooterButtons() {
    return Column(
      children: [
        SizedBox(width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Guardar medicamento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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

  void _onSave() {
    if (_selectedMedication == null && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Busca y selecciona un medicamento del catalogo'), backgroundColor: AppColors.warning),
      );
      return;
    }
    final freq = int.tryParse(_frequencyController.text.trim());
    if (freq == null || freq < 1 || freq > 72) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La frecuencia debe ser entre 1 y 72 horas'), backgroundColor: AppColors.warning),
      );
      return;
    }
    _frequencyHours = freq;

    if (_isEditing) {
      final firstTake = '${_firstTakeTime.hour.toString().padLeft(2, '0')}:${_firstTakeTime.minute.toString().padLeft(2, '0')}';
      final data = {
        'doseInfo': _doseController.text.trim().isEmpty ? null : _doseController.text.trim(),
        'frequencyHours': _frequencyHours,
        'compartmentNumber': _selectedType == 0 ? _compartmentNumber : null,
        'isExternal': _selectedType == 1,
        'firstTakeTime': firstTake,
      };
      if (_endDate != null) data['endDate'] = _endDate!.toIso8601String().split('T')[0];
      context.read<TreatmentService>().updateTreatmentDetail(_editDetail!.id, data);
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pop({
        'medicationId': _selectedMedication!.id,
        'medicationName': _selectedMedication!.name,
        'doseInfo': _doseController.text.trim().isEmpty ? null : _doseController.text.trim(),
        'frequencyHours': _frequencyHours,
        'compartmentNumber': _selectedType == 0 ? _compartmentNumber : null,
        'isExternal': _selectedType == 1,
        'endDate': _endDate,
        'firstTakeHour': _firstTakeTime.hour,
        'firstTakeMinute': _firstTakeTime.minute,
      });
    }
  }
}
