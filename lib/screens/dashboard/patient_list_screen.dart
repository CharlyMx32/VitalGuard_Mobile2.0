import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_service.dart';
import '../../widgets/vital_shimmer.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  int _selectedFilter = 0;
  final _searchController = TextEditingController();

  final _filters = ['Todos (3)', 'Activos (2)', 'Inactivo (1)'];

  final _patients = [
    _PatientData(
      initials: 'JG',
      name: 'Juan García',
      relation: 'Padre - 68 años',
      online: true,
      adherence: '92%',
      adherenceLevel: _AdherenceLevel.good,
      medications: 5,
      dosesToday: 3,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A90E2), Color(0xFF3A7BD5)],
      ),
    ),
    _PatientData(
      initials: 'RG',
      name: 'Rosa García',
      relation: 'Madre - 72 años',
      online: true,
      adherence: '81%',
      adherenceLevel: _AdherenceLevel.warning,
      medications: 4,
      dosesToday: 2,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6FCF97), Color(0xFF27AE60)],
      ),
    ),
    _PatientData(
      initials: 'PM',
      name: 'Pedro Martínez',
      relation: 'Abuelo - 78 años',
      online: false,
      adherence: '65%',
      adherenceLevel: _AdherenceLevel.danger,
      medications: 6,
      dosesToday: 4,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
      ),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientService = context.watch<PatientService>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder(
        future: patientService.getPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList(itemCount: 5);
          }
          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingHorizontal,
                  ) + const EdgeInsets.only(top: 16, bottom: 80),
                  child: Column(
                    children: [
                      _buildFilters(),
                      const SizedBox(height: 16),
                      ..._patients.map((p) => _buildPatientCard(p)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Mis Pacientes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.registerPatient),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.plus,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.search,
                  size: 18,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar paciente...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPlaceholder,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: List.generate(_filters.length, (i) {
        final isActive = i == _selectedFilter;
        return Padding(
          padding: EdgeInsets.only(right: i < _filters.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPatientCard(_PatientData patient) {
    final adherenceColor = switch (patient.adherenceLevel) {
      _AdherenceLevel.good => AppColors.accent,
      _AdherenceLevel.warning => AppColors.warning,
      _AdherenceLevel.danger => AppColors.dangerDark,
    };

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.patientDetail),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.cardMarginBottom),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: patient.gradient,
                  ),
                  child: Center(
                    child: Text(
                      patient.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        patient.relation,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: patient.online ? AppColors.accentLight : AppColors.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: patient.online ? AppColors.accent : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        patient.online ? 'En línea' : 'Desconectado',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: patient.online ? AppColors.accent : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatMini(
                  value: patient.adherence,
                  label: 'Adherencia',
                  color: adherenceColor,
                ),
                const SizedBox(width: 8),
                _StatMini(
                  value: '${patient.medications}',
                  label: 'Medicamentos',
                ),
                const SizedBox(width: 8),
                _StatMini(
                  value: '${patient.dosesToday}',
                  label: 'Dosis hoy',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ver historial',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.patientDetail),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ver detalle',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;

  const _StatMini({
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color ?? AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AdherenceLevel { good, warning, danger }

class _PatientData {
  final String initials;
  final String name;
  final String relation;
  final bool online;
  final String adherence;
  final _AdherenceLevel adherenceLevel;
  final int medications;
  final int dosesToday;
  final Gradient gradient;

  const _PatientData({
    required this.initials,
    required this.name,
    required this.relation,
    required this.online,
    required this.adherence,
    required this.adherenceLevel,
    required this.medications,
    required this.dosesToday,
    required this.gradient,
  });
}
