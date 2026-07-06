import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 1;
  int _currentMonth = 6;
  int _currentYear = 2026;

  final _calendarDays = [
    [1, 2, 3, 4, 5, 6, 7],
    [8, 9, 10, 11, 12, 13, 14],
    [15, 16, 0, 0, 0, 0, 0],
  ];

  final _dayStatus = {
    1: 'green', 2: 'green', 3: 'yellow', 4: 'green', 5: 'green', 6: 'red', 7: 'green',
    8: 'green', 9: 'green', 10: 'yellow', 11: 'green', 12: 'red', 13: 'green', 14: 'green',
    15: 'green', 16: 'today',
  };

  final _historyItems = [
    _HistoryItem(time: '08:00', name: 'Losartan 50mg', detail: '1 pastilla', status: 'Tomada', isTaken: true, iconBg: AppColors.accentLight, iconFg: AppColors.accent),
    _HistoryItem(time: '08:00', name: 'Metformina 850mg', detail: '1 pastilla', status: 'Tomada', isTaken: true, iconBg: AppColors.accentLight, iconFg: AppColors.accent),
    _HistoryItem(time: '12:00', name: 'Metformina 850mg', detail: '1 pastilla', status: 'Pendiente', isTaken: false, iconBg: AppColors.warningBg, iconFg: AppColors.warning),
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
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                children: [
                  _buildCalendarNav(),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 12),
                  _buildAdherenceCard(),
                  const SizedBox(height: 12),
                  _buildCalendarCard(),
                  const SizedBox(height: 8),
                  _buildLegend(),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Hoy - 16 Junio'),
                  const SizedBox(height: 8),
                  ..._historyItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _buildHistoryItem(item),
                  )),
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
            child: Text('Historial', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildCalendarNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _currentMonth--;
              if (_currentMonth < 1) { _currentMonth = 12; _currentYear--; }
            }),
            child: const Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.textMuted),
          ),
          Text('Junio $_currentYear', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          GestureDetector(
            onTap: () => setState(() {
              _currentMonth++;
              if (_currentMonth > 12) { _currentMonth = 1; _currentYear++; }
            }),
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
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight),
              ),
              child: Center(
                child: Text(tabs[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.textMuted)),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAdherenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Adherencia esta semana', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const Text('87%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.87,
              minHeight: 8,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(value: '23', label: 'Tomadas', valueColor: AppColors.accent),
              _StatItem(value: '3', label: 'Perdidas', valueColor: AppColors.dangerDark),
              _StatItem(value: '26', label: 'Total', valueColor: AppColors.textDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
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
            children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'].map((d) =>
              Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted))))
            ).toList(),
          ),
          const SizedBox(height: 8),
          ..._calendarDays.map((week) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: week.map((day) {
                if (day == 0) return const Expanded(child: SizedBox(height: 32));
                final status = _dayStatus[day];
                return Expanded(child: _buildCalendarDay(day, status));
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(int day, String? status) {
    Color? bg;
    Color textColor = AppColors.textDark;

    if (status == 'green') { bg = const Color(0xFFE8F8EF); textColor = AppColors.accent; }
    else if (status == 'yellow') { bg = const Color(0xFFFEF7E0); textColor = AppColors.warning; }
    else if (status == 'red') { bg = AppColors.dangerBg; textColor = AppColors.dangerDark; }
    else if (status == 'today') { bg = AppColors.primary; textColor = Colors.white; }
    else { textColor = AppColors.textMuted; }

    return Container(
      height: 32,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text('$day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor))),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _LegendItem(color: AppColors.accent, label: 'Cumplido'),
        const SizedBox(width: 12),
        _LegendItem(color: AppColors.warning, label: 'Parcial'),
        const SizedBox(width: 12),
        _LegendItem(color: AppColors.dangerDark, label: 'Sin cumplir'),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
    );
  }

  Widget _buildHistoryItem(_HistoryItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(item.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(LucideIcons.pill, size: 14, color: item.iconFg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(item.detail, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.isTaken ? AppColors.accentLight : AppColors.warningBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(item.status, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: item.isTaken ? AppColors.accent : AppColors.warning,
            )),
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
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: valueColor)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
      ],
    );
  }
}

class _HistoryItem {
  final String time, name, detail, status;
  final bool isTaken;
  final Color iconBg, iconFg;
  const _HistoryItem({required this.time, required this.name, required this.detail, required this.status, required this.isTaken, required this.iconBg, required this.iconFg});
}
