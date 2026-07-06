import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

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
                colors: [Color(0xFFF0F7FF), Color(0xFFE3F0FF)],
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
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.08),
                  ),
                ),

                // Pill box
                _buildPillBox(),
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
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(
                          text: 'VitalGuard es un dispositivo con ',
                        ),
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
                          text:
                              ' que administra tus medicamentos de forma automática y segura.',
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
                _buildDotIndicators(0),

                const SizedBox(height: 8),

                // Next button (transparent)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.onboarding2);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Siguiente',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Skip button
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.onboarding4);
                  },
                  child: Text(
                    'Saltar -->',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFCCCCCC),
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

  Widget _buildPillBox() {
    return SizedBox(
      width: 160,
      height: 120,
      child: Stack(
        children: [
          // Green indicator bar
          Positioned(
            top: 0,
            left: 50,
            child: Container(
              width: 40,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Pill box body
          Positioned(
            bottom: 0,
            child: Container(
              width: 160,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A90E2), Color(0xFF3A7BD5)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  crossAxisCount: 5,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1,
                  children: [
                    _buildSlot(true),
                    _buildSlot(true),
                    _buildSlot(true),
                    _buildSlot(false),
                    _buildSlot(false),
                    _buildSlot(true),
                    _buildSlot(true),
                    _buildSlot(false),
                    _buildSlot(true),
                    _buildSlot(false),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(bool filled) {
    return Container(
      decoration: BoxDecoration(
        color: filled
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: filled
              ? Colors.white
              : Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
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
