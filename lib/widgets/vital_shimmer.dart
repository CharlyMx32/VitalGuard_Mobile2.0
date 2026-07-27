import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class VitalShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const VitalShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppDimensions.radiusCard,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<VitalShimmer> createState() => _VitalShimmerState();
}

class _VitalShimmerState extends State<VitalShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.bgCard;
    final highlight = widget.highlightColor ?? Colors.white;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: _animation.value,
              end: Alignment.centerLeft,
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}

class VitalShimmerCard extends StatelessWidget {
  final int lines;
  final double? height;
  const VitalShimmerCard({super.key, this.lines = 3, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.cardMarginHorizontal,
      ) + const EdgeInsets.only(bottom: AppDimensions.cardMarginBottom),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const VitalShimmer(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VitalShimmer(
                      height: 14,
                      width: height != null ? (height! * 0.6) : 140.0,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 8),
                    VitalShimmer(
                      height: 10,
                      width: height != null ? (height! * 0.4) : 100.0,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lines > 1) ...[
            const SizedBox(height: 16),
            ...List.generate(lines - 1, (i) => Padding(
              padding: EdgeInsets.only(bottom: i < lines - 2 ? 10 : 0),
              child: VitalShimmer(
                height: 12,
                width: [double.infinity, double.infinity, 160.0][i.clamp(0, 2)],
                borderRadius: 4,
              ),
            )),
          ],
        ],
      ),
    );
  }
}
