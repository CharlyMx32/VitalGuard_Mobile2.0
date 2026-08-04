import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../models/medication.dart';
import '../../widgets/medication_search_field.dart';

class ScheduleConfigScreen extends StatefulWidget {
  const ScheduleConfigScreen({super.key});

  @override
  State<ScheduleConfigScreen> createState() => _ScheduleConfigScreenState();
}

class _ScheduleConfigScreenState extends State<ScheduleConfigScreen> {
  int _selectedType = 0;
  final _doseController = TextEditingController();
  int? _compartmentNumber;
  DateTime? _endDate;
  Medication? _selectedMedication;
  int _frequencyHours = 8;
  TimeOfDay _firstTakeTime = const TimeOfDay(hour: 8, minute: 0);

  static const List<int> _frequencyOptions = [3, 5, 6, 7, 8, 10, 12];

  @override
  void dispose() {
    _doseController.dispose();
    super.dispose();
  }

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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark))),
          const Expanded(child: Text('Agregar Medicamento', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
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
            _buildTypeOption(0, LucideIcons.rectangleVertical, 'En pastillero'),
            const SizedBox(width: 8),
            _buildTypeOption(1, LucideIcons.clock, 'Manual'),
          ],
        ),
        const SizedBox(height: 12),
        _buildFormLabel('Dosis'),
        const SizedBox(height: 6),
        TextField(
          controller: _doseController,
          decoration: InputDecoration(
            hintText: 'Ej: 1 tableta, 5ml',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          ),
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
    return Container(
      height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_compartmentNumber != null ? 'Compartimento #$_compartmentNumber' : 'Seleccionar',
          style: TextStyle(fontSize: 14, color: _compartmentNumber != null ? AppColors.textDark : AppColors.textMuted)),
        PopupMenuButton<int>(
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
          onSelected: (v) => setState(() => _compartmentNumber = v),
          itemBuilder: (context) => List.generate(8, (i) => PopupMenuItem(value: i + 1, child: Text('Compartimento #${i + 1}'))),
        ),
      ]),
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
        _buildFormLabel('Cada cuanto debe tomarse'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _frequencyOptions.map((h) {
            final selected = _frequencyHours == h;
            return GestureDetector(
              onTap: () => setState(() => _frequencyHours = h),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight),
                ),
                child: Text('Cada $h horas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textDark)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        const Align(alignment: Alignment.centerLeft, child: Text('Ej: cada 8 horas = 3 tomas al dia', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
        const SizedBox(height: 16),
        _buildFormLabel('Hora de la primera toma'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _firstTakeTime,
            );
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
    if (_selectedMedication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Busca y selecciona un medicamento del catalogo'), backgroundColor: AppColors.warning),
      );
      return;
    }
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
