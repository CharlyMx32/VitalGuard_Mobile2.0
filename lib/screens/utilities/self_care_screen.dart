import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vital_empty_state.dart';

class SelfCareScreen extends StatelessWidget {
  const SelfCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Información médica'),
                  const SizedBox(height: 8),
                  _buildMedicalInfo(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Acciones'),
                  const SizedBox(height: 8),
                  _buildActionCard(LucideIcons.pill, AppColors.accentLight, AppColors.accent, 'Mis tratamientos', 'Ver y gestionar mis medicamentos', () => Navigator.pushNamed(context, AppRoutes.medications)),
                  const SizedBox(height: 8),
                  _buildActionCard(LucideIcons.history, AppColors.accentLight, AppColors.primary, 'Mi historial', 'Revisar historial de dosis', () => Navigator.pushNamed(context, AppRoutes.history)),
                  const SizedBox(height: 8),
                  _buildActionCard(LucideIcons.bell, AppColors.warningBg, AppColors.warning, 'Notificaciones', 'Configurar alertas y recordatorios', () => Navigator.pushNamed(context, AppRoutes.notificationsConfig)),
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark))),
        const Expanded(child: Text('Autocuidado', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(LucideIcons.userCheck, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mi Perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          SizedBox(height: 2),
          Text('Paciente - Autocuidado', style: TextStyle(fontSize: 12, color: Colors.white70)),
        ])),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)));
  }

  Widget _buildMedicalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: const VitalEmptyState(
        icon: LucideIcons.heart,
        title: 'Sin datos médicos',
        description: 'Completa tu perfil médico para ver esta información.',
      ),
    );
  }

  Widget _buildActionCard(IconData icon, Color bg, Color fg, String title, String desc, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: fg)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}
