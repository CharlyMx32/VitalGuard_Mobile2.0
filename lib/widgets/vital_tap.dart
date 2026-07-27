import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper that adds haptic feedback + scale animation on tap.
/// Use this instead of GestureDetector for all tappable cards/buttons.
class VitalTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final bool enableHaptic;
  final bool enableScale;

  const VitalTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.97,
    this.enableHaptic = true,
    this.enableScale = true,
  });

  @override
  State<VitalTap> createState() => _VitalTapState();
}

class _VitalTapState extends State<VitalTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.enableHaptic) {
          HapticFeedback.lightImpact();
        }
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: widget.enableScale
          ? AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: child,
                );
              },
              child: widget.child,
            )
          : widget.child,
    );
  }
}
