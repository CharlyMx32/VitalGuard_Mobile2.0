import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

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
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Información personal'),
                  const SizedBox(height: 8),
                  _buildInfoGroup([
                    ('Nombre completo', 'María García'),
                    ('Correo electrónico', 'maria.garcia@email.com'),
                    ('Teléfono', '+506 8888 8888'),
                    ('Fecha de nacimiento', '15/03/1985'),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Foto de perfil'),
                  const SizedBox(height: 8),
                  _buildPhotoOption(),
                  const SizedBox(height: 20),
                  _buildButton('Guardar cambios', AppColors.primary, Colors.white),
                  const SizedBox(height: 12),
                  _buildButton('Cerrar sesión', Colors.white, AppColors.textDark, border: true),
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

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
          child: const Center(child: Text('MG', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('María García', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            Text('maria.garcia@email.com', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: const Text('Cuidadora', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
          ]),
        ),
      ]),
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

  Widget _buildPhotoOption() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.camera, size: 18, color: AppColors.primary)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cambiar foto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            SizedBox(height: 2),
            Text('Subir imagen o tomar foto', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
        ]),
      ),
    );
  }

  Widget _buildButton(String label, Color bg, Color fg, {bool border = false}) {
    return Container(
      width: double.infinity, height: 44,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: border ? Border.all(color: AppColors.borderLight) : null),
      child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg))),
    );
  }
}
