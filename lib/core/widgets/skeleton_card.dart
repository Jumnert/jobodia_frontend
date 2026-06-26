import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/widgets/shimmer_placeholder.dart';

/// Skeleton placeholder matching [JobFeedCard] dimensions:
/// company logo circle · title bar · subtitle bar · tag chips · salary row.
class SkeletonJobCard extends StatelessWidget {
  const SkeletonJobCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: logo + title/subtitle ──
            Row(
              children: [
                const ShimmerPlaceholder(
                  width: 44,
                  height: 44,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerPlaceholder(width: 140, height: 14),
                      SizedBox(height: 6),
                      ShimmerPlaceholder(width: 90, height: 11),
                    ],
                  ),
                ),
                const ShimmerPlaceholder(
                  width: 48,
                  height: 22,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Tag chips row ──
            Row(
              children: const [
                ShimmerPlaceholder(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                SizedBox(width: 8),
                ShimmerPlaceholder(
                  width: 48,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                SizedBox(width: 8),
                ShimmerPlaceholder(
                  width: 72,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Salary row ──
            const ShimmerPlaceholder(width: 110, height: 13),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder for a profile header: avatar + text bars.
class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const ShimmerPlaceholder(
            width: 72,
            height: 72,
            borderRadius: BorderRadius.all(Radius.circular(36)),
          ),
          const SizedBox(height: 14),
          const ShimmerPlaceholder(width: 150, height: 16),
          const SizedBox(height: 8),
          const ShimmerPlaceholder(width: 100, height: 12),
          const SizedBox(height: 12),
          const ShimmerPlaceholder(width: 220, height: 12),
          const SizedBox(height: 6),
          const ShimmerPlaceholder(width: 180, height: 12),
          const SizedBox(height: 20),
          // ── Experience cards ──
          ...List.generate(
            2,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerPlaceholder(width: 160, height: 13),
                    SizedBox(height: 8),
                    ShimmerPlaceholder(width: 120, height: 11),
                    SizedBox(height: 6),
                    ShimmerPlaceholder(width: 200, height: 11),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for a notification row.
class SkeletonNotificationRow extends StatelessWidget {
  const SkeletonNotificationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const ShimmerPlaceholder(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerPlaceholder(width: 180, height: 13),
                SizedBox(height: 6),
                ShimmerPlaceholder(width: 120, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for a job detail header.
class SkeletonJobDetailHeader extends StatelessWidget {
  const SkeletonJobDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerPlaceholder(width: double.infinity, height: 200),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerPlaceholder(width: 220, height: 18),
              SizedBox(height: 10),
              ShimmerPlaceholder(width: 150, height: 13),
              SizedBox(height: 14),
              Row(
                children: [
                  ShimmerPlaceholder(
                    width: 80,
                    height: 26,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  SizedBox(width: 8),
                  ShimmerPlaceholder(
                    width: 60,
                    height: 26,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ShimmerPlaceholder(width: double.infinity, height: 12),
              SizedBox(height: 6),
              ShimmerPlaceholder(width: double.infinity, height: 12),
              SizedBox(height: 6),
              ShimmerPlaceholder(width: 180, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
