import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/vital_bottom_nav.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/patients_content.dart';
import '../screens/treatments/dispenser_screen.dart';
import '../screens/treatments/schedule_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../services/auth_service.dart';
import '../services/patient_service.dart';
import '../services/patient_current_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPatients());
  }

  Future<void> _loadPatients() async {
    final patientService = context.read<PatientService>();
    final patientCurrent = context.read<PatientCurrentService>();
    final patients = await patientService.getPatients();
    patientCurrent.setPatients(patients);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isSelfCare = auth.isSelfCare;

    final pages = <Widget>[
      const DashboardContent(),
      if (!isSelfCare) const PatientsContent(),
      const DispenserContent(),
      const ScheduleContent(),
      const SettingsContent(),
    ];

    final maxIndex = pages.length - 1;
    final safeIndex = _currentIndex.clamp(0, maxIndex);

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
        child: pages[safeIndex],
      ),
      bottomNavigationBar: VitalBottomNav(
        currentIndex: safeIndex,
        showPacientes: !isSelfCare,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
