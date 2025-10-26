import 'dart:io';
import 'package:flutter/material.dart';

class CachedFirebaseImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool showLoadingIndicator;
  final bool enableResponsiveLoading;
  final int? cacheWidth;
  final int? cacheHeight;

  const CachedFirebaseImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.showLoadingIndicator = true,
    this.enableResponsiveLoading = true,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap in RepaintBoundary for better performance
    return RepaintBoundary(
      child: FutureBuilder<String?>(
        future: _getCachedImagePath(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildNetworkImage();
          }

          if (snapshot.hasData && snapshot.data != null) {
            return _buildCachedImage(snapshot.data!);
          }

          // Fallback to network image
          return _buildNetworkImage();
        },
      ),
    );
  }

  Future<String?> _getCachedImagePath() async {
    // Use network image with built-in caching for now
    // Future: Implement advanced caching strategy
    return null;
  }

  /// Safely calculate cache size to avoid NaN/Infinity errors
  int? _safeCalculateCacheSize(double? dimension, double multiplier) {
    if (dimension == null || dimension.isNaN || dimension.isInfinite || dimension <= 0) {
      return null;
    }
    final result = dimension * multiplier;
    if (result.isNaN || result.isInfinite || result <= 0) {
      return null;
    }
    return result.round();
  }

  Widget _buildCachedImage(String cachedPath) {
    Widget imageWidget = Image.file(
      File(cachedPath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildNetworkImage() {
    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth ?? _safeCalculateCacheSize(width, 2.5),
      cacheHeight: cacheHeight ?? _safeCalculateCacheSize(height, 2.5),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 200),
            child: child,
          );
        }
        return _buildLoadingWidget();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildLoadingWidget() {
    if (placeholder != null) {
      return placeholder!;
    }

    if (!showLoadingIndicator) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
        size: 24,
      ),
    );
  }
}
