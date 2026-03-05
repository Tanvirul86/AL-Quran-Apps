import 'package:flutter/material.dart';

/// Shimmer loading skeleton widget
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? (isDark ? Colors.grey[850]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 + _controller.value * 2, 0.0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Skeleton placeholder for text
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton for circular avatar
class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton for surah list item
class SurahListItemSkeleton extends StatelessWidget {
  const SurahListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SkeletonAvatar(size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonLine(
                        width: 100,
                        height: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(width: 12),
                      SkeletonLine(
                        width: 80,
                        height: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SkeletonLine(
                    width: 120,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            SkeletonLine(
              width: 60,
              height: 20,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for ayah card
class AyahCardSkeleton extends StatelessWidget {
  const AyahCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ayah number and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(
                  width: 40,
                  height: 32,
                  borderRadius: BorderRadius.circular(16),
                ),
                Row(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SkeletonLine(
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Arabic text
            SkeletonLine(
              height: 24,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            SkeletonLine(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 24,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            
            // Translation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  SkeletonLine(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading state with multiple skeletons
class LoadingSkeletons extends StatelessWidget {
  final String type;
  final int count;

  const LoadingSkeletons({
    super.key,
    this.type = 'surah',
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: ListView.builder(
        itemCount: count,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return type == 'ayah'
              ? const AyahCardSkeleton()
              : const SurahListItemSkeleton();
        },
      ),
    );
  }
}
