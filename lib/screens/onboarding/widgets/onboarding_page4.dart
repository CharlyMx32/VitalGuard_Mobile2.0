import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'onboarding_animations.dart';

class OnboardingPage4 extends StatefulWidget {
  const OnboardingPage4({super.key});

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _rippleController.repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3E8FF), Color(0xFFEDE0FF)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PulseWidget(
                    minScale: 0.97,
                    maxScale: 1.03,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  _buildAlexa(),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      'Control por voz con Alexa',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.6),
                        children: [
                          const TextSpan(text: 'Compatible con '),
                          TextSpan(text: 'Amazon Alexa', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B), height: 1.6)),
                          const TextSpan(text: '. Consulta dosis, confirma tomas y envía mensajes usando solo tu voz.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlexa() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(200, 200),
                  painter: RipplePainter(_rippleController.value),
                );
              },
            ),
            FloatingWidget(
              amplitude: 5,
              duration: const Duration(milliseconds: 3000),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, 12))],
                ),
                child: const Icon(LucideIcons.mic, size: 48, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 260,
          child: Column(
            children: [
              _cmd(LucideIcons.mic, '"Alexa, ¿cuándo es mi próxima dosis?"'),
              const SizedBox(height: 8),
              _cmd(LucideIcons.check, '"Alexa, confirmo que tomé mi pastilla"'),
              const SizedBox(height: 8),
              _cmd(LucideIcons.alertTriangle, '"Alexa, envía un mensaje a mamá"'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cmd(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: Color(0xFFF3E8FF), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF1E293B), fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}
