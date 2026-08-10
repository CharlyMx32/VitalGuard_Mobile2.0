import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/notification_service.dart';
import '../../models/app_notification.dart';
import '../../models/enums.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/vital_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<NotificationService>().getNotifications();
  }

  List<AppNotification> _filter(List<AppNotification> items) {
    if (_selectedFilter == 0) return items;
    final types = {
      1: NotificationType.dosisRecordatorio,
      2: NotificationType.sosAlerta,
      3: NotificationType.sistema,
    };
    final type = types[_selectedFilter];
    if (type == null) return items;
    return items.where((n) => n.type == type).toList();
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.dosisRecordatorio:
        return LucideIcons.pill;
      case NotificationType.medicamentoSolicitud:
        return LucideIcons.stethoscope;
      case NotificationType.sosAlerta:
        return LucideIcons.siren;
      case NotificationType.sistema:
        return LucideIcons.info;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.dosisRecordatorio:
        return AppColors.primary;
      case NotificationType.medicamentoSolicitud:
        return AppColors.accent;
      case NotificationType.sosAlerta:
        return AppColors.danger;
      case NotificationType.sistema:
        return AppColors.textMuted;
    }
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(
            title: 'Notificaciones',
            actions: [
              GestureDetector(
                onTap: () async {
                  await context.read<NotificationService>().markAllAsRead();
                  setState(() {});
                },
                child: const Text('Marcar todo leído', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<AppNotification>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data ?? [];
                final filtered = _filter(all);
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterTabs(all),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        VitalEmptyState(
                          icon: LucideIcons.bellOff,
                          title: 'Sin notificaciones',
                          description: 'No tienes notificaciones ${_selectedFilter == 0 ? "" : "en esta categoría"}',
                        )
                      else
                        ...filtered.map((n) => _NotificationCard(
                          notification: n,
                          timeAgo: _timeAgo(n.createdAt),
                          icon: _iconForType(n.type),
                          iconColor: _colorForType(n.type),
                          onTap: () async {
                            if (!n.isRead) {
                              await context.read<NotificationService>().markAsRead(n.id);
                              setState(() {});
                            }
                          },
                        )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(List<AppNotification> all) {
    final doseCount = all.where((n) => n.type == NotificationType.dosisRecordatorio).length;
    final alertCount = all.where((n) => n.type == NotificationType.sosAlerta).length;
    final sysCount = all.where((n) => n.type == NotificationType.sistema).length;
    final tabs = [
      'Todas (${all.length})',
      'Dosis ($doseCount)',
      'Alertas ($alertCount)',
      'Sistema ($sysCount)',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedFilter == i;
          return Padding(
            padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight)),
                child: Text(tabs[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.textSecondary)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notification.isRead ? AppColors.borderLight : AppColors.primary.withValues(alpha: 0.2)),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notification.title, style: TextStyle(fontSize: 14, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textDark)),
                      ),
                      if (timeAgo.isNotEmpty)
                        Text(timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification.message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
