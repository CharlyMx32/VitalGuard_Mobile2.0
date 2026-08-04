import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/avatar_service.dart';
import '../../widgets/vital_avatar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: const SettingsContent(),
    );
  }
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildSection('Cuenta', AppColors.primary, [
                      _SettingsItem(
                        icon: LucideIcons.user,
                        iconBg: AppColors.primaryLight,
                        iconFg: AppColors.primary,
                        label: 'Mi perfil',
                        description: 'Editar información personal',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.myProfile),
                      ),
                      _SettingsItem(
                        icon: LucideIcons.shield,
                        iconBg: AppColors.accentLight,
                        iconFg: AppColors.accent,
                        label: 'Seguridad (Vital ID)',
                        description: 'Contraseña, 2FA y sesiones',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.securitySettings),
                      ),
                      _SettingsItem(
                        icon: LucideIcons.userPlus,
                        iconBg: const Color(0xFFF3E8FF),
                        iconFg: const Color(0xFF9B59B6),
                        label: 'Enviar solicitudes',
                        description: 'Invitar cuidador, autocuidado o médico',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.sendRequests),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSection('Dispositivo', AppColors.accent, [
                      _SettingsItem(
                        icon: LucideIcons.monitor,
                        iconBg: AppColors.primaryLight,
                        iconFg: AppColors.primary,
                        label: 'Mi VitalGuard',
                        description: 'Información del dispositivo',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.myVitalGuard),
                      ),
                      _SettingsItem(
                        icon: LucideIcons.wifi,
                        iconBg: AppColors.iconGrayBg,
                        iconFg: AppColors.iconGrayFg,
                        label: 'Configurar WiFi',
                        description: 'Conectar a una red',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.wifiSetup),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSection('Preferencias', AppColors.warning, [
                      _SettingsItem(
                        icon: LucideIcons.bell,
                        iconBg: AppColors.warningBg,
                        iconFg: AppColors.warning,
                        label: 'Notificaciones',
                        description: 'Alertas y recordatorios',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.notificationsConfig),
                      ),
                      _SettingsItem(
                        icon: LucideIcons.mic,
                        iconBg: AppColors.accentLight,
                        iconFg: AppColors.accent,
                        label: 'Asistente de voz',
                        description: 'Configurar Alexa',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.voiceAssistant),
                      ),
                      _SettingsItem(
                        icon: LucideIcons.alertTriangle,
                        iconBg: AppColors.dangerBg,
                        iconFg: AppColors.dangerDark,
                        label: 'Botón SOS',
                        description: 'Configurar emergencias',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.sosConfig),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSection('Soporte', AppColors.textMuted, [
                      _SettingsItem(
                        icon: LucideIcons.helpCircle,
                        iconBg: AppColors.iconGrayBg,
                        iconFg: AppColors.iconGrayFg,
                        label: 'Ayuda y Soporte',
                        description: 'Preguntas frecuentes y contacto',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: 16,
      ),
      child: const Text('Ajustes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
    );
  }

  Widget _buildProfileCard() {
    final avatarConfig = context.watch<AvatarService>().config;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.myProfile),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(1.61, -0.50),
            end: Alignment(-1.61, 0.50),
            colors: [Color(0xFF4A90E2), Color(0xFF6FCF97)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => showAvatarPreview(context, config: avatarConfig, onChangeTap: () => Navigator.pushNamed(context, AppRoutes.avatarPicker)),
              child: Hero(
                tag: 'avatar_hero',
                child: VitalAvatar(
                  style: avatarConfig.style,
                  seed: avatarConfig.seed,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('---', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 2),
                  const Text('---', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Sin perfil', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color color, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            boxShadow: AppDimensions.cardShadow,
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: iconFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
