import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometric = false;
  bool _twoFactor = true;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Cambiar contraseña'),
                  const SizedBox(height: 8),
                  _buildPasswordField('Contraseña actual', 'Ingresa tu contraseña actual', _obscureCurrent, (v) => setState(() => _obscureCurrent = v)),
                  _buildPasswordField('Nueva contraseña', 'Ingresa tu nueva contraseña', _obscureNew, (v) => setState(() => _obscureNew = v)),
                  _buildPasswordField('Confirmar contraseña', 'Confirma tu nueva contraseña', _obscureConfirm, (v) => setState(() => _obscureConfirm = v)),
                  const SizedBox(height: 4),
                  _buildUpdateButton(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Autenticación'),
                  const SizedBox(height: 8),
                  _buildToggleGroup([
                    _SecToggle(LucideIcons.fingerprint, AppColors.accentLight, AppColors.accent, 'Autenticación biométrica', 'Huella digital o reconocimiento facial', _biometric, (v) => setState(() => _biometric = v)),
                    _SecToggle(LucideIcons.shield, AppColors.accentLight, AppColors.primary, 'Verificación en 2 pasos', 'Capa extra de seguridad', _twoFactor, (v) => setState(() => _twoFactor = v)),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Sesiones'),
                  const SizedBox(height: 8),
                  _buildDangerButton(),
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 12,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark)),
          ),
          const Expanded(
            child: Text('Seguridad', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(left: 4), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)));
  }

  Widget _buildPasswordField(String label, String placeholder, bool obscure, ValueChanged<bool> onToggle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Container(
              height: 44,
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight, width: 1.5)),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      obscureText: obscure,
                      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                      decoration: InputDecoration(border: InputBorder.none, hintText: placeholder, hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onToggle(!obscure),
                    child: SizedBox(width: 32, height: 32, child: Icon(obscure ? LucideIcons.eyeOff : LucideIcons.eye, size: 18, color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity, height: 44,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Text('Actualizar contraseña', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
    );
  }

  Widget _buildToggleGroup(List<_SecToggle> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) return const Divider(height: 1, indent: 64, color: AppColors.borderLight);
          final t = items[i ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: t.iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(t.icon, size: 18, color: t.iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(t.desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ]),
                ),
                GestureDetector(
                  onTap: () => t.onChanged(!t.value),
                  child: Container(
                    width: 48, height: 28,
                    decoration: BoxDecoration(color: t.value ? AppColors.primary : AppColors.borderLight, borderRadius: BorderRadius.circular(14)),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: t.value ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(width: 22, height: 22, margin: const EdgeInsets.symmetric(horizontal: 3), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3)]),),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDangerButton() {
    return Container(
      width: double.infinity, height: 44,
      decoration: BoxDecoration(color: AppColors.dangerDark, borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Text('Cerrar sesión en todos los dispositivos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
    );
  }
}

class _SecToggle {
  final IconData icon;
  final Color iconBg, iconFg;
  final String label, desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SecToggle(this.icon, this.iconBg, this.iconFg, this.label, this.desc, this.value, this.onChanged);
}
