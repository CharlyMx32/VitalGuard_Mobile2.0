import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SelfCareProfileScreen extends StatelessWidget {
  const SelfCareProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 100),
              child: Column(
                children: [
                  _buildWelcomeBanner(),
                  const SizedBox(height: 16),
                  _buildRoleCard(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('INFORMACIÓN MÉDICA'),
                  const SizedBox(height: 4),
                  const Padding(padding: EdgeInsets.only(left: 4), child: Text('Datos importantes para tu cuidado', style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
                  const SizedBox(height: 8),
                  _buildMedicalForm(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal, vertical: 16),
        color: AppColors.bg,
        child: Container(
          width: double.infinity, height: 48,
          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(LucideIcons.check, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text('Completar y Continuar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(children: [
        Row(children: [
          const SizedBox(width: 32),
          const Expanded(child: Text('Datos del Paciente', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ]),
        const SizedBox(height: 4),
        const Text('Completa tu información para el autocuidado', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(LucideIcons.userCheck, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('María García', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 2),
            Text('maria.garcia@email.com', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: const Text('Autocuidado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildRoleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFE8F8EF), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.accent)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.userCheck, size: 18, color: AppColors.accent)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Autocuidado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          SizedBox(height: 1),
          Text('Cuidas de ti mismo', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)));
  }

  Widget _buildMedicalForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tipo de Sangre', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Container(
          height: 48, width: double.infinity,
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
          child: const Row(children: [
            SizedBox(width: 16),
            Expanded(child: Text('Seleccionar', style: TextStyle(fontSize: 14, color: AppColors.textMuted))),
            Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
            SizedBox(width: 16),
          ]),
        ),
        const SizedBox(height: 14),
        const Text('Notas Médicas (opcional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Container(
          height: 80, width: double.infinity,
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Ej: Alergia a la penicilina, presión arterial alta...', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          ),
        ),
      ]),
    );
  }
}
