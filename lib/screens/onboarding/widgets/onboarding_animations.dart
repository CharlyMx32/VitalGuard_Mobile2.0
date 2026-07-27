import 'dart:math';
import 'package:flutter/material.dart';

class FloatingWidget extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  const FloatingWidget({
    super.key,
    required this.child,
    this.amplitude = 6,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
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

class PulseWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  const PulseWidget({
    super.key,
    required this.child,
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
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

class CircleProgressPainter extends CustomPainter {
  final double progress;
  CircleProgressPainter(this.progress);

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

class RipplePainter extends CustomPainter {
  final double progress;
  RipplePainter(this.progress);

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
