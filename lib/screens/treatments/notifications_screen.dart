import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;

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
                  const VitalEmptyState(
                    icon: LucideIcons.bellOff,
                    title: 'Sin notificaciones',
                    description: 'No tienes notificaciones pendientes.\nLas notificaciones aparecerán aquí cuando tengas actividad.',
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5))),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark))),
          const Expanded(child: Text('Notificaciones', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark))),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay notificaciones para marcar'), backgroundColor: AppColors.accent)),
            child: const Text('Marcar todo leído', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ['Todas (0)', 'Dosis (0)', 'Alertas (0)', 'Sistema (0)'];
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
