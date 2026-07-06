import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _skip() {
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              _OnboardingPage1(),
              _OnboardingPage2(),
              _OnboardingPage3(),
              _OnboardingPage4(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedDots(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getPageBtnColor(_currentPage),
                        foregroundColor: _getPageBtnTextColor(_currentPage),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 3 ? 'Comenzar' : 'Siguiente',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage < 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: _skip,
                          style: TextButton.styleFrom(
                            foregroundColor: _getPageBtnColor(_currentPage),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Saltar -->',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getPageBtnColor(_currentPage),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPageBtnColor(int page) {
    const colors = [
      Color(0xFF4A90E2),
      Color(0xFFF2C94C),
      Color(0xFF27AE60),
      Color(0xFF8B5CF6),
    ];
    return colors[page];
  }

  Color _getPageBtnTextColor(int page) {
    return page == 1 ? const Color(0xFF1E293B) : Colors.white;
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Floating animation wrapper ──
class _FloatingWidget extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  const _FloatingWidget({
    required this.child,
    this.amplitude = 6,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _anim.value * widget.amplitude),
          child: widget.child,
        );
      },
    );
  }
}

// ── Pulse animation wrapper ──
class _PulseWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  const _PulseWidget({
    required this.child,
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

// ── Page 1: Dispositivo ──
class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

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
                  _PulseWidget(
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
                  _FloatingWidget(amplitude: 8, child: _buildPillBox()),
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
          // Lid (green indicator)
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
          // Body with 5 compartments
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

// ── Page 2: Familia ──
class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

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
                  _PulseWidget(
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
                  _FloatingWidget(amplitude: 6, child: _buildNotifications()),
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
            _PulseWidget(
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

// ── Page 3: Medico ──
class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

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
                  _PulseWidget(
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
                  _FloatingWidget(amplitude: 5, child: _buildChart()),
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
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.6),
                        children: [
                          const TextSpan(text: 'Genera '),
                          TextSpan(
                            text: 'reportes de adherencia',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B), height: 1.6),
                          ),
                          const TextSpan(text: ' detallados que tu médico puede revisar para ajustar tu tratamiento.'),
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
                  painter: _CircleProgressPainter(0.78),
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

// ── Page 4: Voz ──
class _OnboardingPage4 extends StatefulWidget {
  const _OnboardingPage4();

  @override
  State<_OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<_OnboardingPage4>
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
                  _PulseWidget(
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
            // Animated ripple rings
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(200, 200),
                  painter: _RipplePainter(_rippleController.value),
                );
              },
            ),
            _FloatingWidget(
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

// ── Painters ──
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  _CircleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFE2E8F0)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()..color = const Color(0xFF27AE60)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RipplePainter extends CustomPainter {
  final double progress;
  _RipplePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      final t = (progress + i * 0.33) % 1.0;
      final radius = 60.0 + t * 40.0;
      final opacity = (1.0 - t) * 0.3;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF8B5CF6).withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
