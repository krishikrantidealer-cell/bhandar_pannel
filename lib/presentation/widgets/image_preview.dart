import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class ImagePreview extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const ImagePreview({
    super.key,
    required this.url,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  double _computeIconSize(double? dimension) {
    if (dimension != null && dimension.isFinite && dimension > 0) {
      return (dimension * 0.45).clamp(14.0, 48.0);
    }
    return 24.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconSize = _computeIconSize(width ?? height);

    if (url == null || url!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            size: iconSize,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                size: iconSize,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer(
            child: SkeletonBox(
              width: (width != null && width!.isFinite) ? width! : 48,
              height: (height != null && height!.isFinite) ? height! : 48,
              borderRadius: borderRadius,
            ),
          );
        },
      ),
    );
  }
}

