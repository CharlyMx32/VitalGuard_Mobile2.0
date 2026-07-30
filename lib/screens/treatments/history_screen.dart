import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_empty_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 1;
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                children: [
                  _buildCalendarNav(),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 12),
                  _buildAdherenceCard(),
                  const SizedBox(height: 16),
                  const VitalEmptyState(
                    icon: LucideIcons.clock,
                    title: 'Sin historial',
                    description: 'Aún no hay registro de dosis.\nEl historial se llenará automáticamente al tomar tus medicamentos.',
                  ),
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
          const Expanded(child: Text('Historial', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildCalendarNav() {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() { _currentMonth--; if (_currentMonth < 1) { _currentMonth = 12; _currentYear--; } }),
            child: const Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.textMuted),
          ),
          Text('${months[_currentMonth - 1]} $_currentYear', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          GestureDetector(
            onTap: () => setState(() { _currentMonth++; if (_currentMonth > 12) { _currentMonth = 1; _currentYear++; } }),
            child: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final tabs = ['Diario', 'Semanal', 'Mensual'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final isActive = _selectedFilter == i;
        return Padding(
          padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              height: 32, padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight)),
              child: Center(child: Text(tabs[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.textMuted))),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAdherenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Adherencia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const Text('--%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: 0, minHeight: 8, backgroundColor: AppColors.borderLight, valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(value: '0', label: 'Tomadas', valueColor: AppColors.textMuted),
              _StatItem(value: '0', label: 'Perdidas', valueColor: AppColors.textMuted),
              _StatItem(value: '0', label: 'Total', valueColor: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  const _StatItem({required this.value, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: valueColor)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
    ]);
  }
}
