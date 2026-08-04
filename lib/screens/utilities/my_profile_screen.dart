import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/avatar_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/vital_avatar.dart';
import '../../widgets/vital_button.dart';
import '../../widgets/vital_modal.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

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
                  _buildProfileCard(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Información personal'),
                  const SizedBox(height: 8),
                  _buildInfoGroup([
                    ('Nombre completo', '---'),
                    ('Correo electrónico', '---'),
                    ('Teléfono', '---'),
                    ('Fecha de nacimiento', '---'),
                  ]),
                  const SizedBox(height: 20),
                  _buildButton('Guardar cambios', AppColors.primary, Colors.white,
                      onTap: () => VitalFeedback.success(
                            context,
                            code: 'PROFILE_SAVED',
                            message: 'Perfil actualizado correctamente',
                          )),
                  const SizedBox(height: 12),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark))),
        const Expanded(child: Text('Mi Perfil', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final avatarConfig = context.watch<AvatarService>().config;
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
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sin perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 2),
            Text('Toca para personalizar', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
              const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
            ]),
          );
        }),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = context.read<AuthService>();
    final shouldLogout = await VitalModal.show<bool>(
      context: context,
      title: 'Cerrar sesión',
      description: '¿Seguro que deseas cerrar sesión?',
      iconType: ModalIconType.warning,
      icon: LucideIcons.logOut,
      actions: [
        VitalButton.ghost(
          label: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(height: 8),
        VitalButton(
          label: 'Cerrar sesión',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (shouldLogout == true && context.mounted) {
      await auth.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
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
