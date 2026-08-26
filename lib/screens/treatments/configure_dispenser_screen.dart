import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_current_service.dart';
import '../../services/auth_service.dart';
import '../../services/treatment_service.dart';
import '../../widgets/vital_header.dart';
import '../../models/treatment.dart';
import '../../models/enums.dart';

class ConfigureDispenserScreen extends StatefulWidget {
  const ConfigureDispenserScreen({super.key});

  @override
  State<ConfigureDispenserScreen> createState() =>
      _ConfigureDispenserScreenState();
}

class _ConfigureDispenserScreenState extends State<ConfigureDispenserScreen> {
  late Future<List<Treatment>> _treatmentsFuture;
  int? _selectedDetailId;
  int? _selectedCompartment;
  final Map<int, Color> _compartmentColors = {
    1: const Color(0xFF4CAF50),
    2: const Color(0xFF2196F3),
    3: const Color(0xFFFF9800),
    4: const Color(0xFF9C27B0),
    5: const Color(0xFFE91E63),
  };

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  void _loadTreatments() {
    final patientCurrent = context.read<PatientCurrentService>();
    final auth = context.read<AuthService>();
    final treatmentService = context.read<TreatmentService>();
    _treatmentsFuture = treatmentService.getTreatments(
      patientCurrent.patientId ?? auth.patientId ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<List<Treatment>>(
        future: _treatmentsFuture,
        builder: (context, snapshot) {
          final treatments = snapshot.data ?? [];
          final allDetails = treatments
              .where((t) => t.status != TreatmentStatus.finalizado)
              .expand<TreatmentDetail>((t) => t.details ?? [])
              .where((d) => d.status != MedicationStatus.finalizado)
              .toList();

          return Column(
            children: [
              VitalHeader.white(title: 'Configurar Pastillero'),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingHorizontal,
                      ) +
                      const EdgeInsets.only(top: 16, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDispenserVisual(allDetails),
                      const SizedBox(height: 20),
                      _buildSectionHeader(
                        'Selecciona un medicamento de tu tratamiento',
                        '',
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Solo puedes asignar medicamentos que ya estén en tu tratamiento activo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTreatmentsList(allDetails),
                      if (_selectedDetailId != null) ...[
                        const SizedBox(height: 16),
                        _buildSectionHeader('Selecciona compartimento', ''),
                        const SizedBox(height: 8),
                        _buildCompartmentSelector(),
                      ],
                      if (_selectedDetailId != null &&
                          _selectedCompartment != null) ...[
                        const SizedBox(height: 16),
                        _buildAssignButton(),
                      ],
                      const SizedBox(height: 16),
                      _buildNoTreatmentsHint(),
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

  Widget _buildDispenserVisual(List<TreatmentDetail> assignedDetails) {
    final occupiedCompartments = assignedDetails
        .where((d) => d.compartmentNumber != null && d.compartmentNumber! > 0)
        .map((d) => d.compartmentNumber!)
        .toSet();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final compartment = i + 1;
          final isOccupied = occupiedCompartments.contains(compartment);
          final isSelected = _selectedCompartment == compartment;
          final color = _compartmentColors[compartment]!;
          return Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isOccupied
                  ? color.withValues(alpha: 0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isOccupied
                    ? color.withValues(alpha: 0.4)
                    : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '$compartment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : isOccupied
                      ? color
                      : AppColors.textMuted,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildTreatmentsList(List<TreatmentDetail> allDetails) {
    if (allDetails.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              size: 18,
              color: AppColors.warning,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No tienes tratamientos activos. Primero crea un tratamiento desde "Crear tratamiento".',
                style: TextStyle(fontSize: 12, color: AppColors.textDark),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: allDetails.length,
        separatorBuilder: (_, i) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final detail = allDetails[index];
          final isSelected = _selectedDetailId == detail.id;
          final alreadyAssigned =
              detail.compartmentNumber != null && detail.compartmentNumber! > 0;
          final compartmentColor = alreadyAssigned
              ? _compartmentColors[detail.compartmentNumber]
              : null;

          return InkWell(
            onTap: alreadyAssigned
                ? null
                : () {
                    setState(() {
                      _selectedDetailId = detail.id;
                      _selectedCompartment = null;
                    });
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: isSelected ? AppColors.primaryLight : null,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: alreadyAssigned
                          ? compartmentColor!.withValues(alpha: 0.12)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      alreadyAssigned ? LucideIcons.check : LucideIcons.pill,
                      size: 16,
                      color: alreadyAssigned
                          ? compartmentColor
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.medication?.name ?? 'Medicamento',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: alreadyAssigned
                                ? AppColors.textMuted
                                : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (alreadyAssigned)
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: compartmentColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Compartimento #${detail.compartmentNumber}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: compartmentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            '${detail.doseInfo ?? "Sin dosis"} · Cada ${detail.frequencyHours}h',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      LucideIcons.checkCircle,
                      size: 18,
                      color: AppColors.primary,
                    )
                  else if (alreadyAssigned)
                    Icon(LucideIcons.check, size: 16, color: compartmentColor)
                  else
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompartmentSelector() {
    return Row(
      children: List.generate(5, (i) {
        final compartment = i + 1;
        final isSelected = _selectedCompartment == compartment;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCompartment = compartment),
            child: Container(
              height: 48,
              margin: EdgeInsets.only(right: i < 4 ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$compartment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAssignButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _onAssign,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Asignar al compartimento',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildNoTreatmentsHint() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.addMedication),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '¿No tienes tratamientos? Crear uno nuevo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAssign() async {
    if (_selectedDetailId == null || _selectedCompartment == null) return;

    final treatmentService = context.read<TreatmentService>();
    try {
      await treatmentService.updateTreatmentDetail(
        _selectedDetailId!,
        {'compartmentNumber': _selectedCompartment},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Medicamento asignado al compartimento #$_selectedCompartment',
          ),
          backgroundColor: AppColors.accent,
        ),
      );
      setState(() {
        _selectedDetailId = null;
        _selectedCompartment = null;
      });
      _loadTreatments();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo asignar al compartimento. Intenta de nuevo.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
