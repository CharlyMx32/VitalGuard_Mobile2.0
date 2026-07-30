import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vital_empty_state.dart';

class SosEmergencyScreen extends StatefulWidget {
  const SosEmergencyScreen({super.key});
  @override
  State<SosEmergencyScreen> createState() => _SosEmergencyScreenState();
}

class _SosEmergencyScreenState extends State<SosEmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  _buildActivateButton(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Contactos de emergencia'),
                  const SizedBox(height: 12),
                  const VitalEmptyState(
                    icon: LucideIcons.phoneOff,
                    title: 'Sin contactos',
                    description: 'No hay contactos de emergencia registrados.\nAgrega contactos en la configuración de SOS.',
                  ),
                  const SizedBox(height: 20),
                  _buildLocationInfo(),
                  const SizedBox(height: 20),
                  _buildCancelButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 32),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.dangerDark, Color(0xFFFF8A65)])),
      child: Column(children: [
        Row(children: [
          GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: Colors.white))),
          const Expanded(child: Text('Emergencia SOS', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
          const SizedBox(width: 32),
        ]),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final val = _pulseController.value;
            return Transform.scale(
              scale: 1.0 + val * 0.1,
              child: Opacity(
                opacity: 1.0 - val * 0.2,
                child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.alertTriangle, size: 40, color: Colors.white)),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text('SOS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Activa la alarma de emergencia', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
      ]),
    );
  }

  Widget _buildActivateButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.sosAlarm),
      child: Container(
        width: double.infinity, height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.dangerDark, Color(0xFFFF8A65)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.dangerDark.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.phone, size: 24, color: Colors.white),
          SizedBox(width: 12),
          Text('Activar SOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)));
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ubicación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 12),
        _buildInfoRow(LucideIcons.mapPin, 'Dirección', 'No disponible'),
        const Divider(height: 1, color: AppColors.borderLight),
        _buildInfoRow(LucideIcons.clock, 'Última conexión', 'No disponible'),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        ])),
      ]),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('Cancelar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark))),
      ),
    );
  }
}
