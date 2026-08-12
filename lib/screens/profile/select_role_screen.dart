import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  int _selectedRole = -1;

  void _continue() async {
    if (_selectedRole == -1) return;
    final auth = context.read<AuthService>();
    await auth.setRole(_selectedRole == 1 ? 'PATIENT' : 'CAREGIVER');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.completeProfile,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  _buildBanner(),
                  const SizedBox(height: 24),
                  _buildRoleOption(
                    0,
                    LucideIcons.heart,
                    AppColors.accentLight,
                    AppColors.accent,
                    'Cuidar a alguien',
                    'Voy a cuidar a un paciente y gestionar su tratamiento',
                  ),
                  const SizedBox(height: 14),
                  _buildRoleOption(
                    1,
                    LucideIcons.userCheck,
                    AppColors.primaryLight,
                    AppColors.primary,
                    'Cuidarme a mí',
                    'Soy paciente y uso VitalGuard en modo autocuidado',
                  ),
                  const SizedBox(height: 24),
                  _buildContinueButton(),
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
      child: Column(children: [
        Row(children: [
          const SizedBox(width: 32),
          const Expanded(child: Text('Tu rol en VitalGuard', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ]),
        const SizedBox(height: 4),
        const Text('Elige cómo quieres usar la aplicación', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(LucideIcons.users, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Selecciona tu rol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          SizedBox(height: 2),
          Text('Puedes cambiarlo más tarde desde Ajustes', style: TextStyle(fontSize: 12, color: Colors.white70)),
        ])),
      ]),
    );
  }

  Widget _buildRoleOption(int index, IconData icon, Color bg, Color fg, String name, String desc) {
    final selected = _selectedRole == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? fg : AppColors.borderLight, width: selected ? 2 : 1),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)), child: Icon(icon, size: 24, color: fg)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? fg : Colors.transparent,
              border: Border.all(color: selected ? fg : AppColors.borderLight, width: 2),
            ),
            child: selected ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }

  Widget _buildContinueButton() {
    final enabled = _selectedRole != -1;
    return GestureDetector(
      onTap: enabled ? _continue : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.borderLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text('Continuar', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : AppColors.textMuted,
          )),
        ),
      ),
    );
  }
}
