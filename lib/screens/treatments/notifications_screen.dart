import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;

  final _notifications = [
    _NotifGroup(title: 'Hoy', items: [
      _NotifData(icon: LucideIcons.clock, iconType: _NotifIconType.dose, title: 'Hora de tomar Losartan', desc: 'Juan García tiene programada su dosis de 8:00 AM', time: 'Hace 15 minutos', unread: true, action: 'Confirmar toma'),
      _NotifData(icon: LucideIcons.checkCircle, iconType: _NotifIconType.success, title: 'Dosis confirmada', desc: 'Rosa García confirmó la toma de Metformina 850mg', time: 'Hace 1 hora', unread: true),
    ]),
    _NotifGroup(title: 'Ayer', items: [
      _NotifData(icon: LucideIcons.xCircle, iconType: _NotifIconType.danger, title: 'Dosis perdida', desc: 'Juan García no confirmó la toma de Atorvastatina 20mg a las 8:00 PM', time: 'Ayer, 8:30 PM', unread: false),
      _NotifData(icon: LucideIcons.info, iconType: _NotifIconType.info, title: 'Reporte semanal disponible', desc: 'El reporte de adherencia de la semana está listo para revisar', time: 'Ayer, 9:00 AM', unread: false, action: 'Ver reporte'),
    ]),
    _NotifGroup(title: 'Esta semana', items: [
      _NotifData(icon: LucideIcons.checkCircle, iconType: _NotifIconType.success, title: 'Dispositivo sincronizado', desc: 'El pastillero de Juan García se sincronizó correctamente', time: 'Lunes, 10:15 AM', unread: false),
      _NotifData(icon: LucideIcons.info, iconType: _NotifIconType.info, title: 'Actualización disponible', desc: 'Hay una nueva versión del firmware para el pastillero', time: 'Domingo, 2:00 PM', unread: false, action: 'Actualizar'),
    ]),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterTabs(),
                  const SizedBox(height: 16),
                  ..._notifications.map((group) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildGroup(group),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark)),
          ),
          const Expanded(
            child: Text('Notificaciones', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text('Marcar todo leído', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ['Todas (7)', 'Dosis (4)', 'Alertas (1)', 'Sistema (2)'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final isActive = _selectedFilter == i;
        return Padding(
          padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight),
              ),
              child: Text(tabs[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.textSecondary)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGroup(_NotifGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        ...group.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildNotifCard(item),
        )),
      ],
    );
  }

  Widget _buildNotifCard(_NotifData item) {
    final (bgColor, fgColor) = switch (item.iconType) {
      _NotifIconType.dose => (AppColors.primaryLight, AppColors.primary),
      _NotifIconType.success => (AppColors.accentLight, AppColors.accent),
      _NotifIconType.warning => (AppColors.warningBg, AppColors.warning),
      _NotifIconType.danger => (AppColors.dangerBg, AppColors.dangerDark),
      _NotifIconType.info => (const Color(0xFFF0F4FF), const Color(0xFF5B6ABF)),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
        border: item.unread ? Border(left: BorderSide(color: AppColors.primary, width: 3)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(item.icon, size: 18, color: fgColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(item.desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
                const SizedBox(height: 6),
                Text(item.time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                if (item.action != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                      child: Text(item.action!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotifIconType { dose, success, warning, danger, info }

class _NotifGroup {
  final String title;
  final List<_NotifData> items;
  const _NotifGroup({required this.title, required this.items});
}

class _NotifData {
  final IconData icon;
  final _NotifIconType iconType;
  final String title, desc, time;
  final bool unread;
  final String? action;
  const _NotifData({required this.icon, required this.iconType, required this.title, required this.desc, required this.time, required this.unread, this.action});
}
