import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vital_empty_state.dart';
import '../../services/caregiver_service.dart';
import '../../services/auth_service.dart';
import '../../services/patient_current_service.dart';
import '../../models/caregiver.dart';
import '../../widgets/vital_header.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  List<Caregiver> _caregivers = [];
  bool _loading = true;
  int? _patientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patientId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _patientId = args;
      } else {
        final patientCurrent = context.read<PatientCurrentService>();
        final auth = context.read<AuthService>();
        _patientId = patientCurrent.patientId ?? auth.patientId;
      }
      _loadCaregivers();
    }
  }

  Future<void> _loadCaregivers() async {
    final caregiverService = context.read<CaregiverService>();
    final caregivers = await caregiverService.getCaregivers(_patientId!);
    if (mounted) setState(() { _caregivers = caregivers; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Cuidadores vinculados'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(),
                  const SizedBox(height: 8),
                  _buildCaregiversList(),
                  const SizedBox(height: 20),
                  _buildAddButton(),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Al agregar un cuidador, se enviará una solicitud de vinculación',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Text('Vinculados', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
          child: Text(_loading ? '...' : '${_caregivers.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        ),
      ],
    );
  }

  Widget _buildCaregiversList() {
    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (_caregivers.isEmpty) {
      return const VitalEmptyState(
        icon: LucideIcons.users,
        title: 'Sin cuidadores',
        description: 'No hay cuidadores vinculados.\nAgrega un cuidador para compartir la gestión.',
      );
    }
    return Column(
      children: _caregivers.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppDimensions.cardShadow),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(LucideIcons.user, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cuidador #${c.id}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text('Prioridad: ${c.emergencyCallPriority ?? 'Normal'}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ])),
          ]),
        ),
      )).toList(),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.sendRequests, arguments: {'patientId': _patientId}),
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight, width: 1.5), borderRadius: BorderRadius.circular(16)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Agregar cuidador', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
      ),
    );
  }
}
