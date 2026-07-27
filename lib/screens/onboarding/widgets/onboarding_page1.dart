import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_animations.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F7FF), Color(0xFFE3F0FF)],
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
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  FloatingWidget(amplitude: 8, child: _buildPillBox()),
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
                      'Tu pastillero inteligente',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(text: 'VitalGuard es un dispositivo con '),
                          TextSpan(
                            text: '5 compartimentos',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              height: 1.6,
                            ),
                          ),
                          const TextSpan(
                            text: ' que administra tus medicamentos de forma automática y segura.',
                          ),
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

  Widget _buildPillBox() {
    return SizedBox(
      width: 200,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: 180,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27AE60), Color(0xFF219A52)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 14,
            child: Container(
              width: 180,
              height: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A90E2), Color(0xFF3A7BD5)],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                  top: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: List.generate(5, (i) {
                    final filled = i < 3;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: filled
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: filled
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: filled
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: [const Color(0xFFEB5757), const Color(0xFF4A90E2), const Color(0xFFF2C94C)][i],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    width: 10,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: [const Color(0xFF4A90E2), const Color(0xFF27AE60), const Color(0xFFEB5757)][i],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
