import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SosEmergencyScreen extends StatelessWidget {
  const SosEmergencyScreen({super.key});

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
                  _buildActivateButton(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Contactos de emergencia'),
                  const SizedBox(height: 12),
                  _buildContactCard('MG', 'María García', 'Hija - Cuidadora principal', AppColors.primary),
                  const SizedBox(height: 8),
                  _buildContactCard('CG', 'Carlos García', 'Hijo', AppColors.accent),
                  const SizedBox(height: 8),
                  _buildContactCard('DM', 'Dr. Martínez', 'Médico tratante', const Color(0xFF9B59B6)),
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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: Colors.white)),
          ),
          const Expanded(child: Text('Emergencia SOS', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
          const SizedBox(width: 32),
        ]),
        const SizedBox(height: 20),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(LucideIcons.alertTriangle, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text('SOS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Activa la alarma de emergencia', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
      ]),
    );
  }

  Widget _buildActivateButton() {
    return Container(
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)));
  }

  Widget _buildContactCard(String initials, String name, String relation, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: Text(initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text(relation, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
          child: const Icon(LucideIcons.phone, size: 16, color: AppColors.accent),
        ),
      ]),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ubicación actual', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 12),
        _buildInfoRow(LucideIcons.mapPin, 'Dirección', 'Calle Principal 123, Ciudad'),
        const Divider(height: 1, color: AppColors.borderLight),
        _buildInfoRow(LucideIcons.clock, 'Última conexión', 'Hace 5 minutos'),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
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
