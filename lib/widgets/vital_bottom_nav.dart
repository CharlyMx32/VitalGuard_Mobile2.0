import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';


class VitalBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const VitalBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: LucideIcons.home,
                activeIcon: LucideIcons.home,
                label: 'Inicio',
                isActive: currentIndex == 0,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(0);
                },
              ),
              _NavItem(
                icon: LucideIcons.calendar,
                activeIcon: LucideIcons.calendar,
                label: 'Horario',
                isActive: currentIndex == 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(1);
                },
              ),
              _NavItem(
                icon: LucideIcons.bookmark,
                activeIcon: LucideIcons.bookmark,
                label: 'Tratamientos',
                isActive: currentIndex == 2,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(2);
                },
              ),
              _NavItem(
                icon: LucideIcons.settings,
                activeIcon: LucideIcons.settings,
                label: 'Ajustes',
                isActive: currentIndex == 3,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 15,
                  color: isActive ? Colors.white : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textLight,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
    );
  }
}
