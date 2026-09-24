import 'package:flutter/material.dart';
import 'custom_table.dart';

/// A high-performance, synchronized Shimmer effect wrapper used across enterprise ERPs.
/// Creates a smooth, continuous linear gradient sweep across all child skeleton elements.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBaseColor = isDark
        ? const Color(0xFF1E293B) // Dark slate
        : const Color(0xFFE2E8F0); // Light slate 200

    final defaultHighlightColor = isDark
        ? const Color(0xFF334155) // Dark slate 700
        : const Color(0xFFF8FAFC); // Light slate 50

    final base = widget.baseColor ?? defaultBaseColor;
    final highlight = widget.highlightColor ?? defaultHighlightColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base,
                highlight,
                base,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// A basic skeleton box with rounded corners.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 6,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A circular skeleton placeholder (for avatars, icon badges).
class SkeletonCircle extends StatelessWidget {
  final double size;
  final Color? color;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A skeleton pill/badge placeholder.
class SkeletonBadge extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;

  const SkeletonBadge({
    super.key,
    this.width = 64,
    this.height = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

/// Sleek top indeterminate progress bar used during secondary loading (filtering, searching, paginating).
class TopLinearProgressBar extends StatelessWidget {
  final Color? color;
  final double height;

  const TopLinearProgressBar({
    super.key,
    this.color,
    this.height = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = color ?? theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          backgroundColor: primary.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(primary),
        ),
      ),
    );
  }
}

/// Skeleton representation for enterprise ERP tables (SAP / Salesforce / Shopify style).
class TableSkeletonRows extends StatelessWidget {
  final List<TableColumnDef> columns;
  final int rowCount;
  final bool isDark;

  const TableSkeletonRows({
    super.key,
    required this.columns,
    this.rowCount = 6,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(rowCount, (index) {
          final isEven = index % 2 == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isEven
                  ? Colors.transparent
                  : (isDark ? const Color(0xFF0F172A).withValues(alpha: 0.3) : const Color(0xFFF8FAFC)),
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: columns.asMap().entries.map((cellEntry) {
                final colIdx = cellEntry.key;
                final colDef = cellEntry.value;

                Widget skeletonCell;
                // Heuristic based on column label or width
                final labelLower = colDef.label.toLowerCase();
                if (labelLower.contains('image') || labelLower.contains('icon') || (colDef.width != null && colDef.width! <= 60)) {
                  skeletonCell = const SkeletonBox(width: 34, height: 34, borderRadius: 6);
                } else if (labelLower.contains('action')) {
                  skeletonCell = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SkeletonBox(width: 24, height: 24, borderRadius: 4),
                      SizedBox(width: 6),
                      SkeletonBox(width: 24, height: 24, borderRadius: 4),
                    ],
                  );
                } else if (labelLower.contains('status')) {
                  skeletonCell = const SkeletonBadge(width: 60, height: 20);
                } else if (labelLower.contains('variant')) {
                  skeletonCell = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SkeletonBox(width: 64, height: 18, borderRadius: 4),
                      SizedBox(height: 3),
                      SkeletonBox(width: 48, height: 10, borderRadius: 3),
                    ],
                  );
                } else if (labelLower.contains('category')) {
                  skeletonCell = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SkeletonBox(width: 76, height: 16, borderRadius: 4),
                      SizedBox(height: 3),
                      SkeletonBox(width: 54, height: 10, borderRadius: 3),
                    ],
                  );
                } else if (labelLower.contains('title') || labelLower.contains('name') || labelLower.contains('product')) {
                  skeletonCell = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkeletonBox(width: (130 + (index % 3) * 35).toDouble(), height: 13, borderRadius: 3),
                      const SizedBox(height: 4),
                      SkeletonBox(width: (70 + (index % 2) * 25).toDouble(), height: 10, borderRadius: 3),
                    ],
                  );
                } else {
                  skeletonCell = SkeletonBox(
                    width: (60 + (colIdx * 15) % 50).toDouble(),
                    height: 12,
                    borderRadius: 3,
                  );
                }

                final alignedChild = Align(
                  alignment: colDef.alignment,
                  child: skeletonCell,
                );

                if (colDef.width != null) {
                  return SizedBox(width: colDef.width, child: alignedChild);
                }
                return Expanded(flex: colDef.flex, child: alignedChild);
              }).toList(),
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton for KPI/Dashboard Stat Cards.
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SkeletonBox(width: 90, height: 14, borderRadius: 4),
                  SkeletonBox(width: 38, height: 38, borderRadius: 10),
                ],
              ),
              const SizedBox(height: 12),
              const SkeletonBox(width: 120, height: 26, borderRadius: 6),
              const SizedBox(height: 10),
              Row(
                children: const [
                  SkeletonBox(width: 45, height: 14, borderRadius: 4),
                  SizedBox(width: 8),
                  SkeletonBox(width: 80, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for Category or Collection Grid Cards.
class CategoryCardSkeleton extends StatelessWidget {
  final double borderRadius;
  const CategoryCardSkeleton({super.key, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: double.infinity, height: 140, borderRadius: borderRadius),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 140, height: 16, borderRadius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 200, height: 12, borderRadius: 3),
                  SizedBox(height: 12),
                  SkeletonBox(width: 100, height: 14, borderRadius: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
