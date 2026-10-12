import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Skeleton loader for project cards and lists during loading state.
class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.height = 16.0,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? AppRadius.radiusSm,
          ),
        );
      },
    );
  }
}

/// A skeleton placeholder for a Project Card
class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(height: 20.0, width: 80.0),
              SkeletonLoader(height: 20.0, width: 20.0),
            ],
          ),
          SizedBox(height: 12.0),
          SkeletonLoader(height: 20.0, width: 220.0),
          SizedBox(height: 8.0),
          SkeletonLoader(height: 14.0, width: double.infinity),
          SizedBox(height: 6.0),
          SkeletonLoader(height: 14.0, width: 160.0),
          SizedBox(height: 16.0),
          Row(
            children: [
              SkeletonLoader(height: 24.0, width: 60.0),
              SizedBox(width: 8.0),
              SkeletonLoader(height: 24.0, width: 70.0),
              SizedBox(width: 8.0),
              SkeletonLoader(height: 24.0, width: 50.0),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(height: 14.0, width: 100.0),
              SkeletonLoader(height: 14.0, width: 120.0),
            ],
          ),
        ],
      ),
    );
  }
}
