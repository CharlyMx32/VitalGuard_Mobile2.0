import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/notification_service.dart';
import '../../services/fcm_service.dart';
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
  List<AppNotification> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    // Escucha pushes FCM/WS para refresco instantáneo sin polling (fail-safe)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final fcm = context.read<FcmService>();
        fcm.onMessage.listen((_) async {
          if (!mounted) return;
          await _load(silent: true);
        });
      } catch (_) {}
      // También escucha realtime via NotificationService (WS)
      try {
        final notifService = context.read<NotificationService>();
        // El badge ya se actualiza vía watch, solo refresca lista
        notifService.addListener(() {
          if (!mounted) return;
          // Si cambia unreadCount, recarga silenciosa
          _load(silent: true);
        });
      } catch (_) {}
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    final data = await context.read<NotificationService>().getNotifications();
    if (!mounted) return;
    setState(() {
      _all = data;
      _loading = false;
    });
  }

  List<AppNotification> get _filtered {
    if (_selectedFilter == 0) return _all;
    const map = {
      1: NotificationType.dosisRecordatorio,
      2: NotificationType.sosAlerta,
      3: NotificationType.invitacionCuidador,
      4: NotificationType.sistema,
    };
    final type = map[_selectedFilter];
    if (type == null) return _all;
    return _all.where((n) => n.type == type).toList();
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.dosisRecordatorio:
        return LucideIcons.pill;
      case NotificationType.medicamentoSolicitud:
        return LucideIcons.stethoscope;
      case NotificationType.invitacionCuidador:
        return LucideIcons.userPlus;
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
      case NotificationType.invitacionCuidador:
        return const Color(0xFF7C3AED);
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
    final unread = context.watch<NotificationService>().unreadCount;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(
            title: unread > 0 ? 'Notificaciones ($unread)' : 'Notificaciones',
            actions: [
              if (unread > 0)
                GestureDetector(
                  onTap: () async {
                    await context.read<NotificationService>().markAllAsRead();
                    await _load(silent: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Marcar todo leído',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _load(silent: true),
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) +
                          const EdgeInsets.only(top: 16, bottom: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterTabs(),
                          const SizedBox(height: 16),
                          if (_filtered.isEmpty)
                            VitalEmptyState(
                              icon: _selectedFilter == 2 ? LucideIcons.shieldCheck : LucideIcons.bellOff,
                              title: _selectedFilter == 2
                                  ? 'Sin alertas SOS'
                                  : _selectedFilter == 3
                                      ? 'Sin invitaciones'
                                      : 'Sin notificaciones',
                              description: _selectedFilter == 0
                                  ? 'Cuando recibas invitaciones, alertas o recordatorios aparecerán aquí'
                                  : 'No tienes notificaciones en esta categoría',
                            )
                          else
                            ..._filtered.map((n) => _NotificationCard(
                                  notification: n,
                                  timeAgo: _timeAgo(n.createdAt),
                                  icon: _iconForType(n.type),
                                  iconColor: _colorForType(n.type),
                                  onTap: () async {
                                    if (!n.isRead) {
                                      await context.read<NotificationService>().markAsRead(n.id);
                                      await _load(silent: true);
                                    }
                                    if (n.type == NotificationType.invitacionCuidador) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Ve a Invitaciones para gestionar esta solicitud')),
                                      );
                                    }
                                  },
                                )),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final counts = {
      0: _all.length,
      1: _all.where((n) => n.type == NotificationType.dosisRecordatorio).length,
      2: _all.where((n) => n.type == NotificationType.sosAlerta).length,
      3: _all.where((n) => n.type == NotificationType.invitacionCuidador).length,
      4: _all.where((n) => n.type == NotificationType.sistema).length,
    };
    final tabs = [
      {'label': 'Todas', 'count': counts[0]!, 'icon': LucideIcons.layers},
      {'label': 'Dosis', 'count': counts[1]!, 'icon': LucideIcons.pill},
      {'label': 'SOS', 'count': counts[2]!, 'icon': LucideIcons.siren},
      {'label': 'Invitaciones', 'count': counts[3]!, 'icon': LucideIcons.userPlus},
      {'label': 'Sistema', 'count': counts[4]!, 'icon': LucideIcons.info},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedFilter == i;
          final tab = tabs[i];
          return Padding(
            padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight),
                  boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8)] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab['icon'] as IconData, size: 14, color: isActive ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('${tab['label']} (${tab['count']})',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.textSecondary)),
                  ],
                ),
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
    final isSos = notification.type == NotificationType.sosAlerta;
    final isInvite = notification.type == NotificationType.invitacionCuidador;
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSos && isUnread
              ? const Color(0xFFFFF1F2)
              : isUnread
                  ? const Color(0xFFF8FAFF)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSos
                ? AppColors.danger.withValues(alpha: isUnread ? 0.4 : 0.15)
                : isInvite
                    ? const Color(0xFF7C3AED).withValues(alpha: isUnread ? 0.3 : 0.15)
                    : isUnread
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.borderLight,
            width: isSos && isUnread ? 1.5 : 1,
          ),
          boxShadow: isUnread ? AppDimensions.cardShadow : null,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isSos)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(6)),
                                child: const Text('SOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            if (isInvite)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(6)),
                                child: const Text('INVITACIÓN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            Expanded(
                              child: Text(notification.title,
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600, color: AppColors.textDark)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(notification.message,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (notification.patient != null) ...[
                              Icon(LucideIcons.user, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(notification.patient!.fullName,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 12),
                            ],
                            Icon(LucideIcons.clock3, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            const Spacer(),
                            if (isUnread)
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isInvite && isUnread)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                  border: Border(top: BorderSide(color: const Color(0xFF7C3AED).withValues(alpha: 0.1))),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(LucideIcons.info, size: 14, color: const Color(0xFF7C3AED)),
                    const SizedBox(width: 6),
                    const Expanded(
                        child: Text('Toca para ver y responder la invitación',
                            style: TextStyle(fontSize: 12, color: Color(0xFF7C3AED), fontWeight: FontWeight.w500))),
                    Icon(LucideIcons.chevronRight, size: 16, color: const Color(0xFF7C3AED)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
