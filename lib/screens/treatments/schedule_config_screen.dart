import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';


class ScheduleConfigScreen extends StatefulWidget {
  const ScheduleConfigScreen({super.key});

  @override
  State<ScheduleConfigScreen> createState() => _ScheduleConfigScreenState();
}

class _ScheduleConfigScreenState extends State<ScheduleConfigScreen> {
  int _selectedCatalogIndex = 0;
  int _selectedType = 0;
  int _selectedFreq = 2;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);

  final List<Map<String, String>> _catalog = [
    {'name': 'Losartan 50mg', 'detail': 'Tabletas - Antihipertensivo'},
    {'name': 'Metformina 850mg', 'detail': 'Tabletas - Antidiabético'},
    {'name': 'Vitamina D 5000UI', 'detail': 'Cápsulas - Suplemento'},
    {'name': 'AAS 100mg', 'detail': 'Tabletas - Antitrombótico'},
  ];

  final List<Map<String, String>> _frequencies = [
    {'hours': '3h', 'label': '8/día'},
    {'hours': '6h', 'label': '4/día'},
    {'hours': '8h', 'label': '3/día'},
    {'hours': '12h', 'label': '2/día'},
    {'hours': '24h', 'label': '1/día'},
    {'hours': '48h', 'label': '1/2d'},
    {'hours': '72h', 'label': '1/3d'},
    {'hours': '...', 'label': 'Otro'},
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
                  _buildCatalogSection(),
                  const SizedBox(height: 16),
                  _buildDivider('Configuración'),
                  const SizedBox(height: 12),
                  _buildConfigSection(),
                  const SizedBox(height: 16),
                  _buildDivider('Horario'),
                  const SizedBox(height: 12),
                  _buildScheduleSection(),
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
            child: Text('Agregar Medicamento', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
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
            value: 0.7,
            minHeight: 4,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tratamiento', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.accent)),
            Text('Medicamentos', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary)),
            Text('Horarios', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildCatalogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleccionar medicamento existente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar medicamento...',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.separated(
            itemCount: _catalog.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = _catalog[index];
              final isSelected = _selectedCatalogIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedCatalogIndex = index),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(LucideIcons.pill, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                            const SizedBox(height: 2),
                            Text(item['detail']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.plus, size: 12, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              const Text('Crear medicamento nuevo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
        ),
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
          decoration: InputDecoration(
            hintText: 'Ej: 1 tableta, 5ml',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildFormLabel('Compartimento (pastillero)'),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Seleccionar', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildFormLabel('Fecha de fin (opcional)'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2026, 7, 10),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() {});
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('10 Jul 2026', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                Icon(LucideIcons.calendar, size: 16, color: AppColors.textMuted),
              ],
            ),
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
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? AppColors.primary : AppColors.textDark),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      children: [
        _buildFormLabel('Hora de primera toma'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: _startTime);
            if (picked != null) setState(() => _startTime = picked);
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('A partir de qué hora sonará la primera alarma', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ),
        const SizedBox(height: 12),
        _buildFormLabel('Frecuencia'),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: _frequencies.length,
          itemBuilder: (context, index) {
            final freq = _frequencies[index];
            final isSelected = _selectedFreq == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFreq = index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(freq['hours']!, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                    )),
                    const SizedBox(height: 1),
                    Text(freq['label']!, style: TextStyle(
                      fontSize: 8, fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    )),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
            child: const Text('Guardar medicamento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
