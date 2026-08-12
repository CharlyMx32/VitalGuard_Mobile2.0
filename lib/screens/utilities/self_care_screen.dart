import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/vital_header.dart';
import '../../widgets/vital_card.dart';

class SelfCareScreen extends StatefulWidget {
  const SelfCareScreen({super.key});

  @override
  State<SelfCareScreen> createState() => _SelfCareScreenState();
}

class _SelfCareScreenState extends State<SelfCareScreen> {
  String _userName = '';
  String _firstName = '';
  String _lastName = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final auth = context.read<AuthService>();
    _firstName = auth.firstName ?? '';
    _lastName = auth.paternalLastName ?? '';
    _userName = _firstName.isNotEmpty ? '$_firstName $_lastName' : 'Autocuidado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Mi Perfil'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 100),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildMedicalInfoSection(),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.user, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Autocuidado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INFORMACIÓN MÉDICA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('Datos importantes para tu cuidado', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.selfCareProfile),
          child: VitalCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 12,
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(LucideIcons.fileText, size: 20, color: AppColors.warning),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Completar perfil médico', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      SizedBox(height: 2),
                      Text('Tipo de sangre, notas médicas', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACCIONES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        _buildActionItem(
          icon: LucideIcons.pill,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          title: 'Mis tratamientos',
          subtitle: 'Ver y gestionar tus tratamientos',
          onTap: () => Navigator.pushNamed(context, AppRoutes.schedule),
        ),
        const SizedBox(height: 8),
        _buildActionItem(
          icon: LucideIcons.clock,
          iconColor: AppColors.accent,
          iconBg: AppColors.accentLight,
          title: 'Mi historial',
          subtitle: 'Revisa tu historial de dosis',
          onTap: () => Navigator.pushNamed(context, AppRoutes.history),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: VitalCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 12,
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
