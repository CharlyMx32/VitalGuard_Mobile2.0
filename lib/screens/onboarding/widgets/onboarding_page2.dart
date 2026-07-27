import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'onboarding_animations.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF8E8), Color(0xFFFFF3D6)],
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
                        color: const Color(0xFFF2C94C).withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  FloatingWidget(amplitude: 6, child: _buildNotifications()),
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
                      'Notificaciones para la familia',
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
                          const TextSpan(text: 'Recibe alertas en '),
                          TextSpan(
                            text: 'tiempo real',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              height: 1.6,
                            ),
                          ),
                          const TextSpan(
                            text: ' sobre la medicación de tus seres queridos. Confirma tomas, omisiones y emergencias.',
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

  Widget _buildNotifications() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            PulseWidget(
              minScale: 0.92,
              maxScale: 1.08,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF2C94C), Color(0xFFF0B429)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF2C94C).withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.bell, size: 32, color: Colors.white),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFEB5757),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text('3', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 240,
          child: Column(
            children: [
              _notifCard(LucideIcons.check, const Color(0xFFE8F5E9), const Color(0xFF27AE60), 'María confirmó su dosis', 'Losartan - hace 5 min'),
              const SizedBox(height: 8),
              _notifCard(LucideIcons.alertTriangle, const Color(0xFFFFF8E1), const Color(0xFFF2C94C), 'Próxima dosis en 30 min', 'Metformina - 20:00'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _notifCard(IconData icon, Color bg, Color color, String title, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFFCCCCCC))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
