import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';

class FirstPatientScreen extends StatelessWidget {
  const FirstPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  _buildWelcomeBanner(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('¿QUÉ DESEAS HACER?'),
                  const SizedBox(height: 8),
                  _buildOptionCard(
                    context,
                    icon: LucideIcons.userPlus,
                    iconBg: AppColors.iconBlueBg,
                    iconFg: AppColors.primary,
                    name: 'Agregar paciente',
                    desc: 'Registra los datos de la persona que cuidarás',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.registerPatient),
                  ),
                  const SizedBox(height: 10),
                  _buildOptionCard(
                    context,
                    icon: LucideIcons.home,
                    iconBg: AppColors.iconGreenBg,
                    iconFg: AppColors.accent,
                    name: 'Ir al dashboard',
                    desc: 'Puedes agregar pacientes más tarde desde "Mis Pacientes"',
                    onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(children: [
        Row(children: [
          const SizedBox(width: 32),
          const Expanded(child: Text('Bienvenido, Cuidador', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ]),
        const SizedBox(height: 4),
        const Text('Comienza cuidando a quienes más quieres', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(LucideIcons.heart, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text('Tu primer paso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 6),
        Text(
          'Agrega un paciente para comenzar a gestionar su tratamiento y horarios de medicamentos.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
        ),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)));
  }

  Widget _buildOptionCard(BuildContext context, {required IconData icon, required Color iconBg, required Color iconFg, required String name, required String desc, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusCard), border: Border.all(color: AppColors.borderLight), boxShadow: AppDimensions.cardShadow),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppDimensions.radiusInput)), child: Icon(icon, size: 24, color: iconFg)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
          ])),
          Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textLight),
        ]),
      ),
    );
  }
}
