import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Performance configuration and optimization utilities
class PerformanceConfig {
  PerformanceConfig._();

  /// Initialize performance optimizations
  static void init() {
    // Optimize image cache - increased for better performance
    PaintingBinding.instance.imageCache.maximumSize = 200; // More cached images
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB
    
    // Enable hardware acceleration
    debugProfileBuildsEnabled = false;
    debugProfilePaintsEnabled = false;
    debugDisableClipLayers = false;
    debugDisablePhysicalShapeLayers = false;
  }

  /// Optimization settings
  static const bool useRepaintBoundaries = true;
  static const bool useCachedImages = true;
  static const bool useHeroAnimations = true;
  static const bool enableSemanticsDebugger = false;
  
  /// Animation settings for smooth 60 FPS
  static const Duration standardAnimationDuration = Duration(milliseconds: 250);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration microAnimationDuration = Duration(milliseconds: 100);
  static const Curve standardCurve = Curves.easeInOutCubic;
  static const Curve fastCurve = Curves.easeOut;
  
  /// List performance settings
  static const int initialItemCacheExtent = 5;
  static const double listCacheExtent = 800.0;
  static const int maxListCacheExtent = 1000;
  
  /// Network and image settings
  static const Duration imageLoadTimeout = Duration(seconds: 10);
  static const int maxConcurrentImageRequests = 5;
  
  /// Memory management
  static const int minImageCacheSize = 50;
  static const int maxImageCacheSize = 200;
  static const int imageCacheSizeBytes = 100 << 20; // 100 MB
}

/// Wrapper widget for performance optimization
class PerformanceWrapper extends StatelessWidget {
  final Widget child;
  final bool useRepaintBoundary;
  
  const PerformanceWrapper({
    super.key,
    required this.child,
    this.useRepaintBoundary = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useRepaintBoundary) {
      return RepaintBoundary(child: child);
    }
    return child;
  }
}

/// Optimized image widget
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const SizedBox.shrink();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

