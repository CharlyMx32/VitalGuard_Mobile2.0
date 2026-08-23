import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_current_service.dart';
import '../../services/auth_service.dart';
import '../../services/treatment_service.dart';
import '../../services/device_service.dart';
import '../../widgets/vital_card.dart';
import '../../widgets/vital_shimmer.dart';
import '../../widgets/vital_empty_state.dart';
import '../../widgets/vital_header.dart';
import '../../widgets/patient_selector_header.dart';
import '../../models/treatment.dart';

class DispenserScreen extends StatelessWidget {
  const DispenserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: const DispenserContent(),
    );
  }
}

class DispenserContent extends StatefulWidget {
  const DispenserContent({super.key});

  @override
  State<DispenserContent> createState() => _DispenserContentState();
}

class _DispenserContentState extends State<DispenserContent> {
  late Future<List<Treatment>> _treatmentsFuture;
  Future<bool>? _hasDeviceFuture;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final patientCurrent = context.read<PatientCurrentService>();
    final auth = context.read<AuthService>();
    final treatmentService = context.read<TreatmentService>();
    final deviceService = context.read<DeviceService>();
    final patientId = patientCurrent.patientId ?? auth.patientId ?? 0;
    _treatmentsFuture = treatmentService.getTreatments(patientId);
    _hasDeviceFuture = _checkDevice(deviceService, patientId);
  }

  Future<bool> _checkDevice(DeviceService deviceService, int? patientId) async {
    if (patientId == null) return false;
    final device = await deviceService.getPatientDevice(patientId);
    return device != null;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _refreshKey++;
          _loadData();
        });
      },
      child: Column(
        children: [
          VitalHeader.colored(child: Text('Pastillero', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PatientSelectorHeader(),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Treatment>>(
                    key: ValueKey('dispenser_$_refreshKey'),
                    future: _treatmentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SkeletonList(itemCount: 3);
                      }
                      final treatments = snapshot.data ?? [];
                      final details = treatments.expand((t) => t.details ?? []).toList();
                      final withCompartment = details.where((d) => d.compartmentNumber != null && d.compartmentNumber! > 0).toList();
                      final assigned = withCompartment.map((d) => d.compartmentNumber!).toSet();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Compartimentos', '${assigned.length} de 5 asignados'),
                          const SizedBox(height: 8),
                          ...List.generate(5, (i) {
                            final compartment = i + 1;
                            final detail = withCompartment.where((d) => d.compartmentNumber == compartment).firstOrNull;
                            return _buildCompartmentCard(compartment, detail);
                          }),
                          if (withCompartment.isEmpty) ...[
                            const SizedBox(height: 8),
                            const VitalEmptyState(
                              icon: LucideIcons.package,
                              title: 'Sin asignaciones',
                              description: 'Aún no se han asignado medicamentos a los compartimentos.',
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildTipsCard(),
                          const SizedBox(height: 16),
                          _buildConfigButton(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildCompartmentCard(int compartment, TreatmentDetail? detail) {
    final isAssigned = detail != null;
    final colors = [
      [AppColors.primary, AppColors.primaryLight],
      [AppColors.accent, AppColors.accentLight],
      [AppColors.warning, AppColors.warningBg],
      [AppColors.danger, AppColors.dangerBg],
      [AppColors.iconPurpleFg, AppColors.iconPurpleBg],
    ];
    final c = colors[(compartment - 1) % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: c[1],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text('$compartment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c[0])),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAssigned ? (detail.medication?.name ?? 'Medicamento') : 'Vacío',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAssigned ? AppColors.textDark : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAssigned ? 'Cada ${detail.frequencyHours}h' : 'Sin medicamento asignado',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: isAssigned ? AppColors.accentLight : AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isAssigned ? LucideIcons.check : LucideIcons.plus,
              size: 14,
              color: isAssigned ? AppColors.accent : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return VitalCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: AppColors.primaryLight,
      child: Row(
        children: [
          const Icon(LucideIcons.info, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Asigna medicamentos a cada compartimento para que VitalGuard libere la dosis correcta en el momento indicado.',
              style: TextStyle(fontSize: 12, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigButton() {
    return FutureBuilder<bool>(
      future: _hasDeviceFuture,
      builder: (context, snapshot) {
        final hasDevice = snapshot.data ?? false;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: double.infinity, height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (!hasDevice) {
          final patientCurrent = context.read<PatientCurrentService>();
          final auth = context.read<AuthService>();
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.linkDevice, arguments: {
              'patientId': patientCurrent.patientId ?? auth.patientId,
              'fromProfile': true,
            }),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning, width: 1.2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.smartphone, size: 18, color: AppColors.warning),
                  SizedBox(width: 8),
                  Text('Vincular dispositivo primero', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.warning)),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.configureDispenser),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.settings, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text('Configurar pastillero', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
  }
}
