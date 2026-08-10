import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/patient_service.dart';
import '../../services/device_service.dart';
import '../../widgets/vital_shimmer.dart';
import '../../models/patient.dart';
import '../../models/device.dart';
import '../../widgets/vital_badge.dart';
import '../../widgets/vital_header.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late Future<List<Patient>> _patientsFuture;
  Map<int, Device?> _devices = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patientService = context.read<PatientService>();
    _patientsFuture = patientService.getPatients();
    final patients = await _patientsFuture;
    await _loadDevices(patients);
  }

  Future<void> _loadDevices(List<Patient> patients) async {
    final deviceService = context.read<DeviceService>();
    final Map<int, Device?> devices = {};
    for (final p in patients) {
      try {
        devices[p.id] = await deviceService.getPatientDevice(p.id);
      } catch (_) {
        devices[p.id] = null;
      }
    }
    if (mounted) setState(() { _devices = devices; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.colored(child: Text('Dispositivos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
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
                          Icon(LucideIcons.monitor, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text('Sin pacientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          SizedBox(height: 4),
                          Text('Registra pacientes para configurar sus dispositivos', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async { await _loadData(); },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal, vertical: 16),
                    itemCount: patients.length,
                    itemBuilder: (context, index) => _buildDeviceCard(patients[index], index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Patient patient, int index) {
    final device = _devices[patient.id];
    final hasDevice = device != null;
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
        if (hasDevice) {
          Navigator.pushNamed(context, AppRoutes.myVitalGuard);
        } else {
          Navigator.pushNamed(context, AppRoutes.linkDevice, arguments: {'patientId': patient.id, 'fromProfile': true});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c[0], c[0].withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(patient.initials, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
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
                Icon(hasDevice ? LucideIcons.chevronRight : LucideIcons.plus, size: 18, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            hasDevice
                ? VitalBadge.completed(label: 'VitalGuard vinculado')
                : VitalBadge(label: 'Sin dispositivo', type: BadgeType.warning),
          ],
        ),
      ),
    );
  }
}
