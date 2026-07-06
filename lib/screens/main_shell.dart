import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/vital_bottom_nav.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/treatments/medications_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../theme/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardContent(),      // 0 - Inicio
    SchedulePlaceholder(),   // 1 - Horario
    MedicationsContent(),    // 2 - Tratamientos
    SettingsContent(),       // 3 - Ajustes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: VitalBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}

class SchedulePlaceholder extends StatelessWidget {
  const SchedulePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20, right: 20, bottom: 16,
            ),
            child: const Text('Horario', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(40)),
                    child: const Icon(LucideIcons.calendar, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Horario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  const Text('Próximamente', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
