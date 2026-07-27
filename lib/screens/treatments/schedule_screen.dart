import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: const ScheduleContent(),
    );
  }
}

class ScheduleContent extends StatefulWidget {
  const ScheduleContent({super.key});
  @override
  State<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> {
  int _selectedDayIndex = 0;

  List<_DayData> _days() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.add(Duration(days: i));
      return _DayData(
        day: _shortDay(d.weekday),
        date: d.day,
        isToday: i == 0,
        isSelected: i == _selectedDayIndex,
        fullDate: d,
      );
    });
  }

  String _shortDay(int weekday) {
    return ['', 'L', 'M', 'X', 'J', 'V', 'S', 'D'][weekday];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingHorizontal,
              ) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                children: [
                  _buildDaySelector(),
                  const SizedBox(height: 20),
                  _buildTimelineSection(
                    label: 'Mañana',
                    icon: LucideIcons.sunrise,
                    iconColor: AppColors.warning,
                    iconBg: AppColors.warningBg,
                    items: const [
                      _ScheduleMed(
                        name: 'Losartan 50mg',
                        dose: '1 pastilla',
                        time: '08:00',
                        patient: 'Juan García',
                        status: _MedStatus.completed,
                        iconColor: AppColors.primaryLight,
                        iconFg: AppColors.primary,
                      ),
                      _ScheduleMed(
                        name: 'Metformina 850mg',
                        dose: '1 pastilla',
                        time: '08:00',
                        patient: 'Juan García',
                        status: _MedStatus.completed,
                        iconColor: AppColors.accentLight,
                        iconFg: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineSection(
                    label: 'Tarde',
                    icon: LucideIcons.sun,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primaryLight,
                    items: const [
                      _ScheduleMed(
                        name: 'Atorvastatina 20mg',
                        dose: '1 pastilla',
                        time: '14:00',
                        patient: 'Juan García',
                        status: _MedStatus.pending,
                        iconColor: AppColors.primaryLight,
                        iconFg: AppColors.primary,
                      ),
                      _ScheduleMed(
                        name: 'Omeprazol 20mg',
                        dose: '1 pastilla',
                        time: '15:00',
                        patient: 'Rosa García',
                        status: _MedStatus.pending,
                        iconColor: AppColors.iconOrangeBg,
                        iconFg: AppColors.iconOrangeFg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineSection(
                    label: 'Noche',
                    icon: LucideIcons.moon,
                    iconColor: AppColors.iconPurpleFg,
                    iconBg: AppColors.iconPurpleBg,
                    items: const [
                      _ScheduleMed(
                        name: 'Melatonina 3mg',
                        dose: '1 pastilla',
                        time: '21:00',
                        patient: 'Rosa García',
                        status: _MedStatus.pending,
                        iconColor: AppColors.iconPurpleBg,
                        iconFg: AppColors.iconPurpleFg,
                      ),
                    ],
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
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusHeaderBottom),
          bottomRight: Radius.circular(AppDimensions.radiusHeaderBottom),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: AppDimensions.paddingHeaderBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horario',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            _getDateLabel(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _SummaryChip(icon: LucideIcons.checkCircle, label: '2 ¡Bien hecho!', color: AppColors.accent),
              SizedBox(width: 12),
              _SummaryChip(icon: LucideIcons.clock, label: '3 te esperan', color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = _days();
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final d = days[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              decoration: BoxDecoration(
                color: d.isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.day,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: d.isSelected ? Colors.white70 : AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('${d.date}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: d.isSelected ? Colors.white : AppColors.textDark)),
                  if (d.isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineSection({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required List<_ScheduleMed> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(width: 8),
              Text('${items.length} ${items.length == 1 ? 'med' : 'meds'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        ...List.generate(items.length, (i) {
          final med = items[i];
          final isLast = i == items.length - 1;
          return _buildTimelineItem(med, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineItem(_ScheduleMed med, bool isLast) {
    final isCompleted = med.status == _MedStatus.completed;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12, height: 12,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.accent : AppColors.warning,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (isCompleted ? AppColors.accent : AppColors.warning).withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.borderLight),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppDimensions.cardShadow,
                border: isCompleted
                    ? Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: med.iconColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.pill, size: 18, color: med.iconFg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med.name,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                decoration: isCompleted ? TextDecoration.lineThrough : null)),
                        const SizedBox(height: 2),
                        Text(med.patient,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(med.time,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? AppColors.accent : AppColors.textDark)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.accentLight : AppColors.warningBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(med.dose,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? AppColors.accent : AppColors.warning)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateLabel() {
    final now = DateTime.now();
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${now.day} de ${months[now.month]} · ${_getDayName(now.weekday)}';
  }

  String _getDayName(int weekday) {
    const days = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday];
  }
}

enum _MedStatus { pending, completed }

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SummaryChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

class _ScheduleMed {
  final String name;
  final String dose;
  final String time;
  final String patient;
  final _MedStatus status;
  final Color iconColor;
  final Color iconFg;
  const _ScheduleMed({
    required this.name,
    required this.dose,
    required this.time,
    required this.patient,
    required this.status,
    required this.iconColor,
    required this.iconFg,
  });
}

class _DayData {
  final String day;
  final int date;
  final bool isToday;
  final bool isSelected;
  final DateTime fullDate;
  const _DayData({
    required this.day,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.fullDate,
  });
}
