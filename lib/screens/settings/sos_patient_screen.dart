import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_service.dart';
import '../../services/patient_current_service.dart';
import '../../widgets/vital_shimmer.dart';
import '../../models/patient.dart';
import '../../widgets/vital_header.dart';

class SosPatientScreen extends StatefulWidget {
  const SosPatientScreen({super.key});

  @override
  State<SosPatientScreen> createState() => _SosPatientScreenState();
}

class _SosPatientScreenState extends State<SosPatientScreen> {
  late Future<List<Patient>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    final patientService = context.read<PatientService>();
    _patientsFuture = patientService.getPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.colored(child: Text('Configurar SOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
          Expanded(
            child: FutureBuilder<List<Patient>>(
              future: _patientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonList(itemCount: 5);
                }
                final patients = snapshot.data ?? [];
                if (patients.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.shield, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text('Sin pacientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          SizedBox(height: 4),
                          Text('Registra pacientes para configurar su SOS', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal, vertical: 16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) => _buildPatientCard(patients[index], index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient, int index) {
    final colors = [
      [AppColors.primary, AppColors.primaryLight],
      [AppColors.accent, AppColors.accentLight],
      [AppColors.warning, AppColors.warningBg],
      [AppColors.danger, AppColors.dangerBg],
      [AppColors.iconPurpleFg, AppColors.iconPurpleBg],
    ];
    final c = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        context.read<PatientCurrentService>().selectPatient(patient);
        Navigator.pushNamed(context, AppRoutes.sosConfig);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c[0], c[0].withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(patient.initials, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('${patient.age} años', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
