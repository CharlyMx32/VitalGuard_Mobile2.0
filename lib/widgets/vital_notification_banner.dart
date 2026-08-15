import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../models/app_notification.dart';
import '../models/enums.dart';

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
    _currentEntry?.remove();
    _currentEntry = OverlayEntry(
      builder: (context) => _VitalNotificationBannerOverlay(
        notification: notification,
        onTap: onTap,
        onDismiss: onDismiss,
        duration: duration,
        onRemove: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );
    Overlay.of(context).insert(_currentEntry!);
  }

  static void dismiss() {
    _currentEntry?.remove();
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
      case NotificationType.sistema:
        return LucideIcons.settings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();
    final typeIcon = _getTypeIcon();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.iconContainerRadius),
                      ),
                      child: Icon(typeIcon, size: 20, color: typeColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.notification.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  widget.onDismiss?.call();
                                  _dismiss();
                                },
                                child: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.notification.message,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
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
