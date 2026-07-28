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

// ── Skeleton Lines ──

class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return VitalShimmer(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return VitalShimmer(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

class SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppDimensions.radiusCard,
  });

  @override
  Widget build(BuildContext context) {
    return VitalShimmer(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

// ── Dashboard Skeleton ──

class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Blue header bar skeleton
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLine(width: 80, height: 12, borderRadius: 4),
                    const SizedBox(height: 6),
                    Container(
                      width: 140,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        // Content skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const SkeletonBlock(height: 100, borderRadius: 16),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(child: SkeletonBlock(height: 88, borderRadius: 16)),
                  SizedBox(width: 10),
                  Expanded(child: SkeletonBlock(height: 88, borderRadius: 16)),
                  SizedBox(width: 10),
                  Expanded(child: SkeletonBlock(height: 88, borderRadius: 16)),
                ],
              ),
              const SizedBox(height: 20),
              const SkeletonLine(width: 140, height: 16),
              const SizedBox(height: 12),
              const SkeletonCardShimmer(),
              const SizedBox(height: 10),
              const SkeletonCardShimmer(),
              const SizedBox(height: 20),
              const SkeletonLine(width: 140, height: 16),
              const SizedBox(height: 12),
              ...List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppDimensions.cardShadow,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 40,
                        child: Column(
                          children: [
                            SkeletonCircle(size: 14),
                            SizedBox(height: 4),
                            SkeletonLine(width: 2, height: 30),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLine(
                              width: [120.0, 100.0, 140.0][i],
                              height: 13,
                            ),
                            const SizedBox(height: 4),
                            SkeletonLine(
                              width: [80.0, 70.0, 60.0][i],
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class SkeletonCardShimmer extends StatelessWidget {
  const SkeletonCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          const SkeletonCircle(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 160, height: 14),
                const SizedBox(height: 6),
                const SkeletonLine(width: 100, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── List Skeleton ──

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 76,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(
            bottom: i < itemCount - 1 ? AppDimensions.cardMarginBottom : 0,
          ),
          child: Container(
            height: itemHeight,
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.cardMarginHorizontal,
            ),
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              boxShadow: AppDimensions.cardShadow,
            ),
            child: Row(
              children: [
                const SkeletonCircle(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(width: 140, height: 13),
                      const SizedBox(height: 6),
                      const SkeletonLine(width: 90, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Schedule Skeleton ──

class SkeletonSchedule extends StatelessWidget {
  const SkeletonSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header skeleton
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(width: 100, height: 22, borderRadius: 4),
              SizedBox(height: 6),
              SkeletonLine(width: 140, height: 13, borderRadius: 4),
              SizedBox(height: 20),
              Row(
                children: [
              SkeletonLine(width: 100, height: 10, borderRadius: 4),
                  SizedBox(width: 12),
              SkeletonLine(width: 100, height: 10, borderRadius: 4),
                ],
              ),
            ],
          ),
        ),
        // Content skeleton
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day selector row
              Container(
                height: 72,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppDimensions.cardShadow,
                ),
                child: Row(
                  children: List.generate(
                    7,
                    (i) => Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SkeletonCircle(size: 32),
                          const SizedBox(height: 4),
                          const SkeletonLine(width: 16, height: 8, borderRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Schedule cards - full width, no timeline dots
              ...List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppDimensions.cardShadow,
                    ),
                    child: Row(
                      children: [
                        SkeletonCircle(size: [42.0, 42.0, 42.0, 36.0, 36.0][i]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SkeletonLine(
                                    width: [100.0, 130.0, 90.0, 110.0, 80.0][i],
                                    height: 13,
                                    borderRadius: 3,
                                  ),
                                  const Spacer(),
                                  SkeletonLine(
                                    width: [36.0, 36.0, 36.0, 36.0, 36.0][i],
                                    height: 12,
                                    borderRadius: 3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SkeletonLine(
                                width: [70.0, 60.0, 80.0, 50.0, 60.0][i],
                                height: 10,
                                borderRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Detail Skeleton ──

class SkeletonDetail extends StatelessWidget {
  const SkeletonDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBlock(height: 140),
          const SizedBox(height: 20),
          const SkeletonLine(width: 120, height: 16),
          const SizedBox(height: 12),
          const SkeletonBlock(height: 12),
          const SizedBox(height: 8),
          const SkeletonBlock(width: 0.7, height: 12),
          const SizedBox(height: 20),
          const SkeletonLine(width: 100, height: 16),
          const SizedBox(height: 12),
          const SkeletonCardShimmer(),
          const SizedBox(height: 12),
          const SkeletonCardShimmer(),
        ],
      ),
    );
  }
}

// ── Async Widget ──

class AsyncWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object? error)? errorBuilder;
  final Widget? loading;
  final T? initialData;

  const AsyncWidget({
    super.key,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loading,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const SizedBox();
        }
        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder!(context, snapshot.error);
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar datos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}
