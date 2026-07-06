import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class NotificationsConfigScreen extends StatefulWidget {
  const NotificationsConfigScreen({super.key});

  @override
  State<NotificationsConfigScreen> createState() => _NotificationsConfigScreenState();
}

class _NotificationsConfigScreenState extends State<NotificationsConfigScreen> {
  bool _general = true;
  bool _doses = true;
  bool _emergency = true;
  bool _reminders = false;
  bool _dnd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Alertas'),
                  const SizedBox(height: 8),
                  _buildToggleGroup([
                    _ToggleData(LucideIcons.bell, AppColors.accentLight, AppColors.primary, 'Notificaciones generales', 'Recibir todas las alertas', _general, (v) => setState(() => _general = v)),
                    _ToggleData(LucideIcons.clock, AppColors.warningBg, AppColors.warning, 'Alertas de dosis', 'Avisos de medicación pendiente', _doses, (v) => setState(() => _doses = v)),
                    _ToggleData(LucideIcons.alertTriangle, AppColors.dangerBg, AppColors.dangerDark, 'Alertas de emergencia', 'SOS y situaciones críticas', _emergency, (v) => setState(() => _emergency = v)),
                    _ToggleData(LucideIcons.calendar, const Color(0xFFF3E8FF), const Color(0xFF9B59B6), 'Recordatorios', 'Avisos programados', _reminders, (v) => setState(() => _reminders = v)),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Horario de silencio'),
                  const SizedBox(height: 8),
                  _buildToggleGroup([
                    _ToggleData(LucideIcons.clock, AppColors.accentLight, AppColors.accent, 'No molestar', 'Silenciar todas las notificaciones', _dnd, (v) => setState(() => _dnd = v)),
                  ]),
                  const SizedBox(height: 8),
                  _buildTimeRange(),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Las alertas SOS siempre se recibirán, incluso en modo silencio.', style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.5)),
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
            child: Text('Notificaciones', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
    );
  }

  Widget _buildToggleGroup(List<_ToggleData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) return const Divider(height: 1, indent: 64, color: AppColors.borderLight);
          final t = items[i ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: t.iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(t.icon, size: 18, color: t.iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(t.desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => t.onChanged(!t.value),
                  child: Container(
                    width: 48, height: 28,
                    decoration: BoxDecoration(
                      color: t.value ? AppColors.primary : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: t.value ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 22, height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3)]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeRange() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.clock, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Horario', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 2),
                const Text('Silencio automático', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(20)),
            child: const Text('22:00 - 07:00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _ToggleData {
  final IconData icon;
  final Color iconBg, iconFg;
  final String label, desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleData(this.icon, this.iconBg, this.iconFg, this.label, this.desc, this.value, this.onChanged);
}
