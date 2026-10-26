import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Modern theme-aware loading shimmer and skeleton placeholder components.

/// 1. Theme-Aware Shimmer Container
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const AppShimmer({
    required this.child,
    super.key,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1400),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBase = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceContainer;
    final defaultHighlight = isDark
        ? AppColors.darkSurfaceContainerHigh
        : const Color(0xFFF4F8FD);

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBase,
      highlightColor: highlightColor ?? defaultHighlight,
      period: period,
      child: child,
    );
  }
}

/// 2. Atomic Skeleton Placeholders
abstract final class AppSkeleton {
  /// Rectangular or custom-radius box placeholder
  static Widget box({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? AppRadius.smAll,
      ),
    );
  }

  /// Single line text placeholder
  static Widget text({
    double width = 120,
    double height = 14,
    EdgeInsetsGeometry? margin,
  }) {
    return box(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
      margin: margin,
    );
  }

  /// Circular placeholder for avatars, icons, or badges
  static Widget circle({
    double size = 40,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Card placeholder with rounded corners
  static Widget card({
    double? width,
    double height = 90,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return box(
      width: width ?? double.infinity,
      height: height,
      borderRadius: borderRadius ?? AppRadius.lgAll,
      margin: margin,
    );
  }
}

/// 3. Prebuilt Composite Skeletons for Common Screens

/// Skeleton list of content rows (avatar + title + subtitle)
class AppSkeletonList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const AppSkeletonList({
    super.key,
    this.itemCount = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        itemBuilder: (_, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                AppSkeleton.circle(size: 38),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton.text(width: 140, height: 14),
                      const SizedBox(height: 8),
                      AppSkeleton.text(width: 200, height: 11),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AppSkeleton.box(width: 24, height: 24, borderRadius: BorderRadius.circular(6)),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton for topic / subject cards
class AppSkeletonTopicCard extends StatelessWidget {
  const AppSkeletonTopicCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: AppRadius.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeleton.box(width: 32, height: 32, borderRadius: BorderRadius.circular(8)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton.text(width: 160, height: 15),
                      const SizedBox(height: 6),
                      AppSkeleton.text(width: 90, height: 11),
                    ],
                  ),
                ),
                AppSkeleton.box(width: 60, height: 22, borderRadius: BorderRadius.circular(12)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: AppSkeleton.box(height: 6, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 12),
                AppSkeleton.text(width: 36, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for study tools grid
class AppSkeletonGrid extends StatelessWidget {
  final int itemCount;
  const AppSkeletonGrid({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: AppRadius.lgAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeleton.box(width: 38, height: 38, borderRadius: BorderRadius.circular(10)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton.text(width: 100, height: 14),
                    const SizedBox(height: 6),
                    AppSkeleton.text(width: 60, height: 10),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
