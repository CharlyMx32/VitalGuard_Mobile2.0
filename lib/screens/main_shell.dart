import 'package:flutter/material.dart';
import '../widgets/vital_bottom_nav.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/treatments/schedule_screen.dart';
import '../screens/treatments/medications_screen.dart';
import '../screens/settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardContent(),      // 0 - Inicio
    ScheduleContent(),       // 1 - Horario
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


