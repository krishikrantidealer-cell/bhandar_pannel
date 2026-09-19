import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (url == null || url!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          Icons.image_outlined,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          size: width * 0.5,
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
            child: Icon(
              Icons.broken_image_outlined,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              size: width * 0.45,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
