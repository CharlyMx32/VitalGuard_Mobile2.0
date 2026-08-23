import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../models/app_notification.dart';
import '../models/enums.dart';
import '../utils/navigator_key.dart';

class VitalNotificationBanner extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  const VitalNotificationBanner({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: 4),
  });

  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, {
    required AppNotification notification,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 4),
  }) {
    try {
      // Usa navigatorKey global para evitar No Overlay cuando context está por encima de MaterialApp
      final overlay = appNavigatorKey.currentState?.overlay ??
          Overlay.maybeOf(context, rootOverlay: true) ??
          Overlay.maybeOf(context);
      if (overlay == null) {
        debugPrint('[Banner] No Overlay found for context $context (navigatorKey: ${appNavigatorKey.currentState})');
        return;
      }
      // Limpia banner previo de forma segura (evita "removed only once")
      if (_currentEntry != null) {
        try {
          if (_currentEntry!.mounted) _currentEntry!.remove();
        } catch (_) {}
        _currentEntry = null;
      }
      _currentEntry = OverlayEntry(
        builder: (context) => _VitalNotificationBannerOverlay(
          notification: notification,
          onTap: onTap,
          onDismiss: onDismiss,
          duration: duration,
          onRemove: () {
            try {
              if (_currentEntry != null && _currentEntry!.mounted) _currentEntry!.remove();
            } catch (_) {}
            _currentEntry = null;
          },
        ),
      );
      overlay.insert(_currentEntry!);
    } catch (e) {
      debugPrint('[Banner] show failed: $e');
    }
  }

  static void dismiss() {
    try {
      if (_currentEntry != null && _currentEntry!.mounted) _currentEntry!.remove();
    } catch (_) {}
    _currentEntry = null;
  }

  @override
  State<VitalNotificationBanner> createState() => _VitalNotificationBannerState();
}

class _VitalNotificationBannerOverlay extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;
  final VoidCallback onRemove;

  const _VitalNotificationBannerOverlay({
    required this.notification,
    this.onTap,
    this.onDismiss,
    required this.duration,
    required this.onRemove,
  });

  @override
  State<_VitalNotificationBannerOverlay> createState() => _VitalNotificationBannerOverlayState();
}

class _VitalNotificationBannerOverlayState extends State<_VitalNotificationBannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onRemove());
  }

  Color _getTypeColor() {
    switch (widget.notification.type) {
      case NotificationType.sosAlerta:
        return AppColors.danger;
      case NotificationType.dosisRecordatorio:
        return AppColors.warning;
      case NotificationType.medicamentoSolicitud:
        return AppColors.primary;
      case NotificationType.invitacionCuidador:
        return AppColors.accent;
      case NotificationType.sistema:
        return AppColors.textMuted;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.notification.type) {
      case NotificationType.sosAlerta:
        return LucideIcons.alertTriangle;
      case NotificationType.dosisRecordatorio:
        return LucideIcons.clock;
      case NotificationType.medicamentoSolicitud:
        return LucideIcons.pill;
      case NotificationType.invitacionCuidador:
        return LucideIcons.userPlus;
      case NotificationType.sistema:
        return LucideIcons.settings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();
    final typeIcon = _getTypeIcon();
    final isInvite = widget.notification.type == NotificationType.invitacionCuidador;
    final isSos = widget.notification.type == NotificationType.sosAlerta;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 6,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                widget.onTap?.call();
                _dismiss();
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < -100) {
                  _dismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSos
                        ? AppColors.danger.withValues(alpha: 0.25)
                        : isInvite
                            ? const Color(0xFF7C3AED).withValues(alpha: 0.2)
                            : typeColor.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: typeColor.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: isInvite
                                ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4A90E2)])
                                : isSos
                                    ? const LinearGradient(colors: [Color(0xFFEB5757), Color(0xFFFF6B6B)])
                                    : null,
                            color: isInvite || isSos ? null : typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: typeColor.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(typeIcon, size: 22, color: isInvite || isSos ? Colors.white : typeColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: typeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isInvite
                                          ? 'INVITACIÓN'
                                          : isSos
                                              ? 'SOS'
                                              : typeColor == AppColors.warning
                                                  ? 'DOSIS'
                                                  : 'VITALGUARD',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: typeColor),
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      widget.onDismiss?.call();
                                      _dismiss();
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(color: AppColors.bg, shape: BoxShape.circle),
                                      child: const Icon(LucideIcons.x, size: 12, color: AppColors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.notification.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.notification.message,
                                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isInvite) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Rechazar rápido - cierra y notifica
                                widget.onDismiss?.call();
                                _dismiss();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: AppColors.bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.x, size: 14, color: AppColors.textMuted),
                                    SizedBox(width: 6),
                                    Text('Rechazar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.onTap?.call();
                                _dismiss();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4A90E2)]),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Color(0xFF7C3AED).withValues(alpha: 0.3), blurRadius: 8, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.check, size: 14, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text('Aceptar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VitalNotificationBannerState extends State<VitalNotificationBanner> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
