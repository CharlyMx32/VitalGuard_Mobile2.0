import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_empty_state.dart';
import '../../services/treatment_service.dart';
import '../../services/auth_service.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 1;
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  List<MedicationLog> _logs = [];
  double _adherence = 0.0;
  int _totalLogs = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final treatmentService = context.read<TreatmentService>();
    final auth = context.read<AuthService>();
    final logs = await treatmentService.getRecentLogs(auth.patientId);
    double adherence = 0.0;
    try {
      adherence = await treatmentService.getAdherence(auth.patientId);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _logs = logs;
        _adherence = adherence;
        _totalLogs = logs.length;
        _loading = false;
      });
    }
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
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                children: [
                  _buildCalendarNav(),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 12),
                  _buildAdherenceCard(),
                  const SizedBox(height: 16),
                  _buildLogsSection(),
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
    final percent = (_adherence * 100).round();
    final completed = _logs.where((l) => l.status == LogStatus.confirmado).length;
    final missed = _logs.where((l) => l.status == LogStatus.omitida).length;
    final total = _logs.isNotEmpty ? _logs.length : _totalLogs;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Adherencia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text(_loading ? '--%' : '$percent%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _loading ? 0 : _adherence.clamp(0.0, 1.0), minHeight: 8, backgroundColor: AppColors.borderLight, valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(value: _loading ? '0' : '$completed', label: 'Tomadas', valueColor: AppColors.accent),
              _StatItem(value: _loading ? '0' : '$missed', label: 'Perdidas', valueColor: AppColors.dangerDark),
              _StatItem(value: _loading ? '0' : '$total', label: 'Total', valueColor: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (_logs.isEmpty) {
      return const VitalEmptyState(
        icon: LucideIcons.clock,
        title: 'Sin historial',
        description: 'Aún no hay registro de dosis.\nEl historial se llenará automáticamente al tomar tus medicamentos.',
      );
    }
    return Column(
      children: _logs.map((log) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppDimensions.cardShadow),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: _logColor(log.status).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(_logIcon(log.status), size: 18, color: _logColor(log.status)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_logStatusLabel(log.status), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(_formatDateTime(log.scheduledDatetime), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ])),
            Text(log.actualTakenDatetime != null ? 'Tomada' : '—', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: log.actualTakenDatetime != null ? AppColors.accent : AppColors.textLight)),
          ]),
        ),
      )).toList(),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} · $h:$m';
  }

  String _logStatusLabel(LogStatus status) {
    switch (status) {
      case LogStatus.confirmado: return 'Dosis confirmada';
      case LogStatus.retraso: return 'Dosis con retraso';
      case LogStatus.omitida: return 'Dosis omitida';
      case LogStatus.pendiente: return 'Dosis pendiente';
    }
  }

  IconData _logIcon(LogStatus status) {
    switch (status) {
      case LogStatus.confirmado: return LucideIcons.checkCircle;
      case LogStatus.retraso: return LucideIcons.clock;
      case LogStatus.omitida: return LucideIcons.xCircle;
      case LogStatus.pendiente: return LucideIcons.clock;
    }
  }

  Color _logColor(LogStatus status) {
    switch (status) {
      case LogStatus.confirmado: return AppColors.accent;
      case LogStatus.retraso: return AppColors.warning;
      case LogStatus.omitida: return AppColors.dangerDark;
      case LogStatus.pendiente: return AppColors.textMuted;
    }
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
