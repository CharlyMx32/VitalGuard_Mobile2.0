import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_animations.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0FFF4), Color(0xFFE6F9ED)],
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
                        color: const Color(0xFF27AE60).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  FloatingWidget(amplitude: 5, child: _buildChart()),
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
                      'Reportes para tu médico',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comparte tu progreso con tu médico\npara ajustar tu tratamiento.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.6),
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

  Widget _buildChart() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 220,
          height: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Adherencia semanal', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                  Text('78%', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF27AE60))),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _bar(0.85, const Color(0xFF27AE60)),
                    const SizedBox(width: 6),
                    _bar(0.90, const Color(0xFF27AE60)),
                    const SizedBox(width: 6),
                    _bar(0.70, const Color(0xFF6FCF97)),
                    const SizedBox(width: 6),
                    _bar(0.80, const Color(0xFF27AE60)),
                    const SizedBox(width: 6),
                    _bar(0.60, const Color(0xFFF2C94C)),
                    const SizedBox(width: 6),
                    _bar(0.85, const Color(0xFF27AE60)),
                    const SizedBox(width: 6),
                    _bar(0.75, const Color(0xFF6FCF97)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((d) =>
                  Text(d, style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFFCCCCCC)))
                ).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CustomPaint(
                  painter: CircleProgressPainter(0.78),
                  child: Center(
                    child: Text('78%', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Adherencia este mes', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                  Text('+5% vs mes anterior', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF27AE60), fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bar(double h, Color c) {
    return Expanded(child: Align(alignment: Alignment.bottomCenter, child: Container(height: 80 * h, decoration: BoxDecoration(color: c, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))))));
  }
}
