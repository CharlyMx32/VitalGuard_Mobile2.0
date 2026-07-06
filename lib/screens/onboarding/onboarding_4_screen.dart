import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';

class Onboarding4Screen extends StatelessWidget {
  const Onboarding4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Illustration area
          Container(
            width: double.infinity,
            height: 380,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3E8FF), Color(0xFFEDE0FF)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Decorative circle
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                  ),
                ),

                // Alexa illustration
                _buildAlexaIllustration(),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                children: [
                  Text(
                    'Control por voz con Alexa',
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
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Compatible con ',
                        ),
                        TextSpan(
                          text: 'Amazon Alexa',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            height: 1.6,
                          ),
                        ),
                        const TextSpan(
                          text:
                              '. Consulta dosis, confirma tomas y envía mensajes usando solo tu voz.',
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Column(
              children: [
                // Dot indicators
                _buildDotIndicators(3),

                const SizedBox(height: 8),

                // Start button (filled)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.onboarding1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'Comenzar',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlexaIllustration() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Alexa device with rings
        Stack(
          alignment: Alignment.center,
          children: [
            // Ripple rings
            ...List.generate(3, (index) {
              return Container(
                width: 140.0 + (index * 30),
                height: 140.0 + (index * 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              );
            }),

            // Device
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _AlexaIconPainter(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Voice commands
        SizedBox(
          width: 260,
          child: Column(
            children: [
              _buildVoiceCommand(
                icon: LucideIcons.mic,
                text: '"Alexa, ¿cuándo es mi próxima dosis?"',
              ),
              const SizedBox(height: 8),
              _buildVoiceCommand(
                icon: LucideIcons.checkCircle,
                text: '"Alexa, confirmo que tomé mi pastilla"',
              ),
              const SizedBox(height: 8),
              _buildVoiceCommand(
                icon: LucideIcons.alertTriangle,
                text: '"Alexa, envía un mensaje a mamá"',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceCommand({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators(int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: index == activeIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == activeIndex
                ? const Color(0xFF4A90E2)
                : const Color(0xFFEAEAEA),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _AlexaIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Head
    canvas.drawCircle(
      Offset(center.dx, center.dy - 16),
      8,
      paint,
    );

    // Body
    final bodyPath = Path();
    bodyPath.moveTo(center.dx - 14, center.dy + 20);
    bodyPath.quadraticBezierTo(
      center.dx,
      center.dy - 2,
      center.dx + 14,
      center.dy + 20,
    );
    bodyPath.close();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
