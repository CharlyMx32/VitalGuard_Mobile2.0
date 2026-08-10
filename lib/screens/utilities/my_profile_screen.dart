import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/avatar_service.dart';
import '../../data/avatar_data.dart';
import '../../widgets/vital_avatar.dart';
import '../../widgets/vital_header.dart';
import '../../utils/session_utils.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final fullName = [auth.firstName, auth.paternalLastName, auth.maternalLastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    final displayName = fullName.isNotEmpty ? fullName : 'Sin perfil';
    final displayEmail = auth.email ?? '---';
    final displayPhone = auth.phone ?? '---';
    final displayBirthDate = _formatDate(auth.birthDate);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Mi Perfil'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  _buildProfileCard(context, displayName),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Información personal'),
                  const SizedBox(height: 8),
                  _buildInfoGroup([
                    ('Nombre completo', displayName),
                    ('Correo electrónico', displayEmail),
                    ('Teléfono', displayPhone),
                    ('Fecha de nacimiento', displayBirthDate),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoNote(),
                  const SizedBox(height: 20),
                  _buildButton('Cerrar sesión', Colors.white, AppColors.textDark,
                      border: true, onTap: () => _confirmLogout(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String displayName) {
    final avatarConfig = context.select<AvatarService, AvatarConfig>((s) => s.config);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.avatarPicker),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          GestureDetector(
            onTap: () => showAvatarPreview(context, config: avatarConfig, onChangeTap: () => Navigator.pushNamed(context, AppRoutes.avatarPicker)),
            child: Hero(tag: 'avatar_hero', child: VitalAvatar(style: avatarConfig.style, seed: avatarConfig.seed, size: 60)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            const Text('Toca para personalizar', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ])),
          const Icon(LucideIcons.chevronRight, size: 18, color: Colors.white54),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)));
  }

  Widget _buildInfoGroup(List<(String, String)> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) return const Divider(height: 1, indent: 16, color: AppColors.borderLight);
          final item = items[i ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(item.$2, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ])),
            ]),
          );
        }),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '---';
    try {
      final date = DateTime.parse(dateStr);
      const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    await confirmAndLogout(context);
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tu información personal se administra desde Vital ID.',
              style: TextStyle(fontSize: 12, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color bg, Color fg, {bool border = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 44,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: border ? Border.all(color: AppColors.borderLight) : null),
        child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg))),
      ),
    );
  }
}
