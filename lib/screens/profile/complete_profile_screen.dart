import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  int _selectedRole = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 100),
              child: Column(
                children: [
                  _buildWelcomeBanner(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('INFORMACIÓN PERSONAL'),
                  const SizedBox(height: 8),
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('¿CÓMO VAS A USAR VITALGUARD?'),
                  const SizedBox(height: 8),
                  _buildRoleOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          context.read<AuthService>().completeProfile();
          if (_selectedRole == 0) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.firstPatient, (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal, vertical: 16),
          color: AppColors.bg,
          child: Container(
            width: double.infinity, height: 48,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LucideIcons.check, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text('Continuar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(children: [
        Row(children: [
          const SizedBox(width: 32),
          const Expanded(child: Text('Completa tu Perfil', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ]),
        const SizedBox(height: 4),
        const Text('Necesitamos algunos datos para continuar', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(LucideIcons.user, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('María García', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 2),
          Text('maria.garcia@email.com', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
        ]),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)));
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(children: [
        _buildField('Teléfono', '+52 55 1234 5678'),
        const SizedBox(height: 14),
        _buildField('Fecha de Nacimiento', 'DD/MM/AAAA'),
      ]),
    );
  }

  Widget _buildField(String label, String placeholder) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      const SizedBox(height: 6),
      Container(
        height: 48,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: const TextField(decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16), hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14))),
      ),
    ]);
  }

  Widget _buildRoleOptions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(children: [
        _buildRoleOption(0, LucideIcons.heart, AppColors.accentLight, AppColors.accent, 'Cuidar a alguien', 'Voy a cuidar a un paciente'),
        const SizedBox(height: 10),
        _buildRoleOption(1, LucideIcons.userPlus, AppColors.primaryLight, AppColors.primary, 'Cuidarme a mí', 'Soy paciente (autocuidado)'),
      ]),
    );
  }

  Widget _buildRoleOption(int index, IconData icon, Color bg, Color fg, String name, String desc) {
    final selected = _selectedRole == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLight : AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight),
        ),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: fg)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight, width: 1.5)), child: selected ? const Center(child: Icon(LucideIcons.circle, size: 10, color: AppColors.primary)) : null),
        ]),
      ),
    );
  }
}
