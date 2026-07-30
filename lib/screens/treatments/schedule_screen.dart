import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/treatment_service.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_empty_state.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';

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
  int _scheduleRefreshKey = 0;

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
    final treatmentService = context.read<TreatmentService>();
    final patientId = 1;
    return RefreshIndicator(
      onRefresh: () async {
        final newKey = _scheduleRefreshKey + 1;
        setState(() => _scheduleRefreshKey = newKey);
      },
      child: FutureBuilder<List<Schedule>>(
        key: ValueKey('schedule_$_scheduleRefreshKey'),
        future: treatmentService.getTodaySchedules(patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: SkeletonSchedule(),
            );
          }
          final schedules = snapshot.data ?? [];
          final morning = schedules.where((s) => s.timeOfDay.hour < 12).toList();
          final afternoon = schedules.where((s) => s.timeOfDay.hour >= 12 && s.timeOfDay.hour < 18).toList();
          final evening = schedules.where((s) => s.timeOfDay.hour >= 18).toList();
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context, schedules),
                _buildDaySelectorSection(morning, afternoon, evening),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDateLabel() {
    final d = _days()[_selectedDayIndex];
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${d.date} de ${months[d.fullDate.month - 1]}';
  }

  Widget _buildHeader(BuildContext context, List<Schedule> schedules) {
    final completed = schedules.where((s) =>
        s.logs?.any((l) => l.status == LogStatus.confirmado) ?? false).length;
    final pending = schedules.length - completed;
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
          Row(
            children: [
              _SummaryChip(
                icon: LucideIcons.checkCircle,
                label: '$completed completadas',
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              _SummaryChip(
                icon: LucideIcons.clock,
                label: '$pending pendientes',
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelectorSection(
      List<Schedule> morning, List<Schedule> afternoon, List<Schedule> evening) {
    return Column(
      children: [
        _buildDaySelector(),
        const SizedBox(height: 20),
        if (morning.isNotEmpty)
          _buildTimelineSection(
            label: 'Mañana',
            icon: LucideIcons.sunrise,
            iconColor: AppColors.warning,
            iconBg: AppColors.warningBg,
            items: morning,
          ),
        if (morning.isNotEmpty && (afternoon.isNotEmpty || evening.isNotEmpty))
          const SizedBox(height: 16),
        if (afternoon.isNotEmpty)
          _buildTimelineSection(
            label: 'Tarde',
            icon: LucideIcons.sun,
            iconColor: AppColors.primary,
            iconBg: AppColors.primaryLight,
            items: afternoon,
          ),
        if (afternoon.isNotEmpty && evening.isNotEmpty)
          const SizedBox(height: 16),
        if (evening.isNotEmpty)
          _buildTimelineSection(
            label: 'Noche',
            icon: LucideIcons.moon,
            iconColor: AppColors.iconPurpleFg,
            iconBg: AppColors.iconPurpleBg,
            items: evening,
          ),
        if (morning.isEmpty && afternoon.isEmpty && evening.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: VitalEmptyState(
              icon: LucideIcons.calendar,
              title: 'Sin dosis programadas',
              description: 'No hay dosis programadas para este día.\nAgrega un medicamento para comenzar.',
            ),
          ),
      ],
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
    required List<Schedule> items,
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
          final sched = items[i];
          final isLast = i == items.length - 1;
          final isCompleted = sched.logs?.any((l) => l.status == LogStatus.confirmado) ?? false;
          return _buildTimelineItem(sched, isLast, isCompleted);
        }),
      ],
    );
  }

  Widget _buildTimelineItem(Schedule sched, bool isLast, bool isCompleted) {
    final circleColor = isCompleted ? AppColors.accent : AppColors.warning;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: isCompleted ? 16 : 14,
                  height: isCompleted ? 16 : 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                  ),
                  child: isCompleted
                      ? const Icon(LucideIcons.check, size: 10, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.borderLight,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppDimensions.cardShadow,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dosis #${sched.id}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sched.timeDisplay,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    sched.timeDisplay,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isCompleted ? AppColors.accent : AppColors.warning),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
