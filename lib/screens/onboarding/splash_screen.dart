import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bgController;
  late Animation<double> _fadeLogo;
  late Animation<double> _fadeText;
  late Animation<double> _fadeLoader;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );

    _fadeLogo = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );
    _fadeText = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)),
    );
    _fadeLoader = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.8)),
    );

    _controller.forward();
    _bgController.repeat();

    _navigationTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('onboarding_seen') ?? false;
      String route;
      if (auth.isLoggedIn) {
        route = auth.isProfileComplete
            ? AppRoutes.dashboard
            : AppRoutes.completeProfile;
      } else {
        route = seen ? AppRoutes.login : AppRoutes.onboarding1;
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, route);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.87, -0.50),
            end: Alignment(-0.87, 0.50),
            colors: [Color(0xFF4A90E2), Color(0xFF6FCF97)],
          ),
        ),
        child: Stack(
          children: [
            // Background circles
            Positioned(
              top: -80,
              right: -60,
              child: _FloatingCircle(
                size: 300,
                opacity: 0.06,
                animation: _bgController,
                phase: 0.0,
                drift: const Offset(18, 22),
                breathe: 0.05,
              ),
            ),
            Positioned(
              bottom: 120,
              left: -40,
              child: _FloatingCircle(
                size: 200,
                opacity: 0.06,
                animation: _bgController,
                phase: 2.2,
                drift: const Offset(24, 16),
                breathe: 0.07,
              ),
            ),
            Positioned(
              bottom: -30,
              right: 40,
              child: _FloatingCircle(
                size: 150,
                opacity: 0.06,
                animation: _bgController,
                phase: 4.4,
                drift: const Offset(14, 26),
                breathe: 0.09,
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  FadeTransition(
                    opacity: _fadeLogo,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0x40FFFFFF),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/isotipo_transparente.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildMedicalCrossLogo(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  FadeTransition(
                    opacity: _fadeText,
                    child: Text(
                      'VitalGuard',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  FadeTransition(
                    opacity: _fadeText,
                    child: Text(
                      'Tecnología que cuida\na quienes nos cuidaron',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loader dots
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeLoader,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedDot(
                      delay: index * 200,
                    );
                  }),
                ),
              ),
            ),

            // Version
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeLoader,
                  child: Text(
                    'v1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildMedicalCrossLogo() {
    return const Icon(
      LucideIcons.heartPulse,
      size: 48,
      color: Colors.white,
    );
  }

}

class _FloatingCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final Animation<double> animation;
  final double phase;
  final Offset drift;
  final double breathe;

  const _FloatingCircle({
    required this.size,
    required this.opacity,
    required this.animation,
    required this.phase,
    required this.drift,
    required this.breathe,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value * 2 * math.pi + phase;
        final dx = drift.dx * math.sin(t);
        final dy = drift.dy * math.cos(t * 0.75 + phase * 0.3);
        final scale = 1 + breathe * math.sin(t * 0.5);
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: opacity),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedDot extends StatefulWidget {
  final int delay;
  const AnimatedDot({super.key, this.delay = 0});

  @override
  State<AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: Opacity(
              opacity: _opacityAnim.value,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


