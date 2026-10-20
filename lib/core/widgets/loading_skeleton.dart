import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loading widget for product cards.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonLine(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    _SkeletonLine(width: 80, height: 12),
                    const Spacer(),
                    _SkeletonLine(width: 60, height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton for a detail screen header.
class DetailHeaderSkeleton extends StatelessWidget {
  const DetailHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 300, color: Colors.white),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SkeletonLine(width: double.infinity, height: 24),
                  const SizedBox(height: 12),
                  const _SkeletonLine(width: 160, height: 16),
                  const SizedBox(height: 12),
                  const _SkeletonLine(width: 100, height: 20),
                  const SizedBox(height: 24),
                  const _SkeletonLine(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  const _SkeletonLine(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _SkeletonLine(width: MediaQuery.sizeOf(context).width * 0.6, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
