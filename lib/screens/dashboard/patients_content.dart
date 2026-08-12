import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_service.dart';
import '../../services/patient_current_service.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_badge.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/vital_search_bar.dart';
import '../../models/patient.dart';

class PatientsContent extends StatefulWidget {
  const PatientsContent({super.key});

  @override
  State<PatientsContent> createState() => _PatientsContentState();
}

class _PatientsContentState extends State<PatientsContent> {
  final _searchController = TextEditingController();
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  late Future<List<Patient>> _patientsFuture;

  static const _avatarGradients = [
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A90E2), Color(0xFF3A7BD5)]),
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6FCF97), Color(0xFF27AE60)]),
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF39C12), Color(0xFFE67E22)]),
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() {
    final patientService = context.read<PatientService>();
    _patientsFuture = patientService.getPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    if (query.isEmpty) {
      setState(() => _filteredPatients = List.from(_allPatients));
    } else {
      setState(() => _filteredPatients = _allPatients
          .where((p) =>
              p.fullName.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: FutureBuilder<List<Patient>>(
            key: ValueKey('patients_list'),
            future: _patientsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SkeletonList(itemCount: 5);
              }
              final patients = snapshot.data ?? [];
              _allPatients = patients;
              _filteredPatients = List.from(patients);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<PatientCurrentService>().setPatients(patients);
              });

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingHorizontal,
                ) + const EdgeInsets.only(top: 16, bottom: 80),
                child: Column(
                  children: [
                    _buildSearch(),
                    const SizedBox(height: 16),
                    if (patients.isNotEmpty)
                      ..._filteredPatients.asMap().entries.map((e) =>
                          _buildPatientCard(e.value, e.key))
                    else
                      const VitalEmptyState(
                        icon: LucideIcons.users,
                        title: 'Sin pacientes',
                        description:
                            'Aún no tienes pacientes registrados.\nRegistra un nuevo paciente para comenzar.',
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusHeaderBottom),
          bottomRight: Radius.circular(AppDimensions.radiusHeaderBottom),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Mis Pacientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.registerPatient),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.plus, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return VitalSearchBar(
      controller: _searchController,
      hint: 'Buscar paciente...',
      onChanged: _filter,
    );
  }

  Widget _buildPatientCard(Patient patient, int index) {
    final patientCurrent = context.read<PatientCurrentService>();
    final isSelected = patientCurrent.current?.id == patient.id;

    return GestureDetector(
      onTap: () {
        patientCurrent.selectPatient(patient);
        Navigator.pushNamed(context, AppRoutes.patientDetail, arguments: patient.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.cardMarginBottom),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _avatarGradients[index % _avatarGradients.length],
              ),
              child: Center(
                child: Text(
                  patient.initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
            if (isSelected)
              const VitalBadge.info(label: 'Activo')
            else
              const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
