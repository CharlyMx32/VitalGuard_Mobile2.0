import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  DateTime _startDate = DateTime(2026, 6, 26);
  DateTime? _endDate = DateTime(2026, 7, 26);

  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Losartan 50mg',
      'dose': '1 tableta',
      'compartment': 1,
      'time': '08:00 AM',
      'frequency': 'Cada 8h',
      'alarms': '3 alarmas/día',
      'type': 'pastillero',
    },
    {
      'name': 'Metformina 850mg',
      'dose': '1 tableta',
      'compartment': 2,
      'time': '12:00 PM',
      'frequency': 'Cada 12h',
      'alarms': '2 alarmas/día',
      'type': 'pastillero',
    },
  ];

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
                  ...List.generate(_medications.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildMedCard(_medications[i], i),
                  )),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 12,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark)),
          ),
          const Expanded(
            child: Text('Crear Tratamiento', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: 0.4,
            minHeight: 4,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tratamiento', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary)),
            Text('Medicamentos', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
            Text('Horarios', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            onChanged(picked);
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? '${date.day} ${_monthName(date.month)} ${date.year}' : 'Seleccionar',
                  style: TextStyle(fontSize: 14, color: date != null ? AppColors.textDark : AppColors.textMuted),
                ),
                const Icon(LucideIcons.calendar, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month];
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        Text(count, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildMedCard(Map<String, dynamic> med, int index) {
    final bool isPastillero = med['type'] == 'pastillero';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isPastillero ? AppColors.primaryLight : AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.pill, size: 18, color: isPastillero ? AppColors.primary : AppColors.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(med['dose'], style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPastillero ? AppColors.primaryLight : const Color(0xFFFEF7E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPastillero ? 'Comp #${med['compartment']}' : 'Manual',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isPastillero ? AppColors.primary : const Color(0xFFB78F00)),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _medications.removeAt(index)),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(LucideIcons.x, size: 12, color: AppColors.dangerDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5))),
            child: Row(
              children: [
                _buildScheduleChip(LucideIcons.clock, med['time']),
                const SizedBox(width: 12),
                _buildScheduleChip(LucideIcons.bell, med['frequency']),
                const SizedBox(width: 12),
                _buildScheduleChip(LucideIcons.calendar, med['alarms']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAddMedButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.scheduleConfig),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Agregar medicamento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Guardar Tratamiento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.borderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancelar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}
