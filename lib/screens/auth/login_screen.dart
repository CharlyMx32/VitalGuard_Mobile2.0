import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vital_tap.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'vital_id_webview_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo with shadow
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4A90E2), Color(0xFF3A7BD5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Bienvenido a VitalGuard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Accede de forma segura con tu cuenta\nde Vital ID',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Vital ID badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.shield, size: 14, color: AppColors.vitalGreen),
                        SizedBox(width: 6),
                        Text(
                          'Autenticación con Vital ID',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.vitalGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Main login button
                  VitalTap(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder: (context, a, b) => const VitalIdWebViewScreen(),
                          transitionsBuilder: (context, animation, c, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A8E5A), Color(0xFF27AE60)],
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A8E5A).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.logIn, size: 20, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Acceder con Vital ID',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Register link
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      children: [
                        TextSpan(text: '¿No tienes cuenta? '),
                        TextSpan(
                          text: 'Créala en Vital ID',
                          style: TextStyle(
                            color: AppColors.vitalGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Feature items with staggered animation
                  _AnimatedFeatureItem(
                    delay: 100,
                    animController: _animController,
                    icon: LucideIcons.shield,
                    iconBg: AppColors.accentLight,
                    iconColor: AppColors.vitalGreen,
                    label: 'Acceso Seguro',
                    description: 'Un solo login para todas las apps',
                  ),

                  const SizedBox(height: 12),

                  _AnimatedFeatureItem(
                    delay: 200,
                    animController: _animController,
                    icon: LucideIcons.lock,
                    iconBg: AppColors.primaryLight,
                    iconColor: AppColors.primary,
                    label: 'Protección Avanzada',
                    description: '2FA por email incluido',
                  ),

                  const SizedBox(height: 12),

                  _AnimatedFeatureItem(
                    delay: 300,
                    animController: _animController,
                    icon: LucideIcons.users,
                    iconBg: AppColors.iconPurpleBg,
                    iconColor: AppColors.iconPurpleFg,
                    label: 'Multi-Aplicación',
                    description: 'Misma cuenta, múltiples servicios',
                  ),

                  const Spacer(flex: 2),

                  // Dev button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () async {
                        final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
                        final authService = context.read<AuthService>();
                        final navigator = Navigator.of(context);
                        final storage = context.read<StorageService>();
                        try {
                          // Usar vitalId del cuidador de prueba en el seed
                          final res = await dio.post('/auth/dev-login', data: {
                            'vitalId': 'a0000000-0000-0000-0000-000000000002',
                          });
                          final token = res.data['token'] as String;
                          await authService.login(token);
                          if (mounted) {
                            navigator.pushReplacementNamed(AppRoutes.dashboard);
                          }
                        } catch (_) {
                          // Backend no disponible: login local de respaldo
                          await authService.login('dev-local-token');
                          final patients = await storage.loadPatients();
                          if (patients.isNotEmpty) {
                            await authService.setPatientId(patients.first.id);
                          }
                          if (!authService.isProfileComplete) {
                            await authService.completeProfile(
                              isSelfCare: authService.isSelfCare,
                            );
                          }
                          if (mounted) {
                            navigator.pushReplacementNamed(AppRoutes.dashboard);
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.terminal, size: 16, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text(
                            'DEV: Ir al Dashboard',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.splash);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.repeat, size: 16, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text(
                            'DEV: Ver Onboarding',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'VitalGuard © 2026',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedFeatureItem extends StatelessWidget {
  final int delay;
  final AnimationController animController;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String description;

  const _AnimatedFeatureItem({
    required this.delay,
    required this.animController,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        final delayMs = delay / 800;
        final adjustedProgress = Curves.easeOutCubic.transform(
          (animController.value - delayMs).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: adjustedProgress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - adjustedProgress)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppDimensions.iconContainerRadius),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
