import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shimmer_loading.dart';

/// Opens a rich, interactive lightbox modal to enlarge images with zoom, pan, and gallery navigation.
Future<void> showEnlargedImageDialog(
  BuildContext context, {
  required String? imageUrl,
  List<String>? images,
  String? title,
  String? subtitle,
  int initialIndex = 0,
}) {
  final validImages = (images != null && images.isNotEmpty)
      ? images.where((img) => img.trim().isNotEmpty).toList()
      : (imageUrl != null && imageUrl.trim().isNotEmpty ? [imageUrl] : <String>[]);

  if (validImages.isEmpty) {
    return Future.value();
  }

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.82),
    builder: (dialogContext) => _EnlargedImageLightbox(
      images: validImages,
      initialIndex: initialIndex.clamp(0, validImages.length - 1),
      title: title,
      subtitle: subtitle,
    ),
  );
}

class _EnlargedImageLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? title;
  final String? subtitle;

  const _EnlargedImageLightbox({
    required this.images,
    required this.initialIndex,
    this.title,
    this.subtitle,
  });

  @override
  State<_EnlargedImageLightbox> createState() => _EnlargedImageLightboxState();
}

class _EnlargedImageLightboxState extends State<_EnlargedImageLightbox> {
  late int _currentIndex;
  final TransformationController _transformationController = TransformationController();
  final FocusNode _focusNode = FocusNode();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _transformationController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale != _currentScale) {
      setState(() => _currentScale = scale);
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) {
      setState(() {
        _currentIndex++;
        _resetZoom();
      });
    }
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _resetZoom();
      });
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _zoomIn() {
    final current = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (current * 1.4).clamp(1.0, 5.0);
    _transformationController.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
  }

  void _zoomOut() {
    final current = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (current / 1.4).clamp(1.0, 5.0);
    _transformationController.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    String currentUrl = widget.images[_currentIndex].trim();
    if (currentUrl.startsWith('//')) {
      currentUrl = 'https:$currentUrl';
    }
    final hasMultiple = widget.images.length > 1;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _nextImage();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _previousImage();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960, maxHeight: 850),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF334155).withValues(alpha: 0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- TOP BAR ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image_search_rounded,
                            color: Color(0xFF38BDF8),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title ?? 'Product Image Preview',
                                style: const TextStyle(
                                  color: Color(0xFFF8FAFC),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                                Text(
                                  widget.subtitle!,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (hasMultiple)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_currentIndex + 1} / ${widget.images.length}',
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        // Zoom Controls
                        IconButton(
                          tooltip: 'Zoom Out',
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF94A3B8), size: 20),
                          onPressed: _zoomOut,
                        ),
                        IconButton(
                          tooltip: 'Reset Zoom',
                          icon: const Icon(Icons.restart_alt_rounded, color: Color(0xFF94A3B8), size: 20),
                          onPressed: _resetZoom,
                        ),
                        IconButton(
                          tooltip: 'Zoom In',
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF94A3B8), size: 20),
                          onPressed: _zoomIn,
                        ),
                        const SizedBox(width: 4),

                        // Close Button
                        IconButton(
                          tooltip: 'Close (Esc)',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // --- MAIN IMAGE VIEWPORT ---
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: InteractiveViewer(
                              transformationController: _transformationController,
                              minScale: 0.8,
                              maxScale: 5.0,
                              boundaryMargin: const EdgeInsets.all(80),
                              child: Center(
                                child: Image.network(
                                  currentUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Color(0xFF38BDF8),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 260,
                                      height: 260,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image_rounded, color: Color(0xFFEF4444), size: 48),
                                          SizedBox(height: 12),
                                          Text(
                                            'Failed to load image',
                                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Previous Arrow
                        if (hasMultiple && _currentIndex > 0)
                          Positioned(
                            left: 16,
                            child: _NavButton(
                              icon: Icons.chevron_left_rounded,
                              tooltip: 'Previous Image (Left Arrow)',
                              onTap: _previousImage,
                            ),
                          ),

                        // Next Arrow
                        if (hasMultiple && _currentIndex < widget.images.length - 1)
                          Positioned(
                            right: 16,
                            child: _NavButton(
                              icon: Icons.chevron_right_rounded,
                              tooltip: 'Next Image (Right Arrow)',
                              onTap: _nextImage,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // --- BOTTOM THUMBNAIL STRIP (If multiple images) ---
                  if (hasMultiple)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF1E293B), width: 1),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.images.length, (index) {
                            final isSelected = index == _currentIndex;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _currentIndex = index;
                                    _resetZoom();
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      widget.images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Color(0xFF64748B),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final bool enableEnlarge;
  final String? title;
  final String? subtitle;
  final List<String>? images;

  const ImagePreview({
    super.key,
    required this.url,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
    this.enableEnlarge = false,
    this.title,
    this.subtitle,
    this.images,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool _isHovered = false;

  double _computeIconSize(double? dimension) {
    if (dimension != null && dimension.isFinite && dimension > 0) {
      return (dimension * 0.45).clamp(14.0, 48.0);
    }
    return 24.0;
  }

  void _handleEnlarge(BuildContext context) {
    showEnlargedImageDialog(
      context,
      imageUrl: widget.url,
      images: widget.images,
      title: widget.title,
      subtitle: widget.subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconSize = _computeIconSize(widget.width ?? widget.height);
    String effectiveUrl = (widget.url ?? '').trim();
    if (effectiveUrl.startsWith('//')) {
      effectiveUrl = 'https:$effectiveUrl';
    }
    final hasValidUrl = effectiveUrl.isNotEmpty;

    if (!hasValidUrl) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            size: iconSize,
          ),
        ),
      );
    }

    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Image.network(
        effectiveUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                size: iconSize,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer(
            child: SkeletonBox(
              width: (widget.width != null && widget.width!.isFinite) ? widget.width! : 48,
              height: (widget.height != null && widget.height!.isFinite) ? widget.height! : 48,
              borderRadius: widget.borderRadius,
            ),
          );
        },
      ),
    );

    if (widget.enableEnlarge) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Tooltip(
          message: 'Click to enlarge image',
          waitDuration: const Duration(milliseconds: 400),
          child: GestureDetector(
            onTap: () => _handleEnlarge(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                imageWidget,
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return imageWidget;
  }
}
