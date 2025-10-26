import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../configs/app_color.dart';
import '../configs/app_size.dart';
import 'shimmer_loading.dart';

/// Optimized image widget with compression, caching, and shimmer loading
class OptimizedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showShimmer;
  final Duration fadeInDuration;
  final Duration shimmerDuration;

  const OptimizedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.showShimmer = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.shimmerDuration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: borderRadius != null
          ? BoxDecoration(borderRadius: borderRadius)
          : null,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          fadeInDuration: fadeInDuration,
          placeholder: (context, url) => showShimmer
              ? ShimmerLoading.imageShimmer(
                  width: width,
                  height: height,
                  borderRadius: borderRadius,
                )
              : placeholder ??
                  Container(
                    color: AppColor.descriptionColor.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
          errorWidget: (context, url, error) => errorWidget ??
              Container(
                color: AppColor.descriptionColor.withOpacity(0.1),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColor.descriptionColor,
                ),
              ),
          // Enable memory cache for better performance
          memCacheWidth: _safeSizeToInt(width),
          memCacheHeight: _safeSizeToInt(height),
          // Use maxWidth and maxHeight for network optimization
          maxWidthDiskCache: _safeSizeToInt(width) ?? 800,
          maxHeightDiskCache: _safeSizeToInt(height) ?? 600,
        ),
      ),
    );
  }

  /// Safely convert size to int, handling NaN and Infinity
  int? _safeSizeToInt(double? size) {
    if (size == null || size.isNaN || size.isInfinite || size <= 0) {
      return null;
    }
    return size.toInt();
  }
}

/// Property image widget with optimized loading
class PropertyImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isMainImage;
  final VoidCallback? onTap;

  const PropertyImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isMainImage = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OptimizedImageWidget(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        showShimmer: true,
        fadeInDuration: const Duration(milliseconds: 500),
        errorWidget: Container(
          color: AppColor.descriptionColor.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_outlined,
                color: AppColor.descriptionColor,
                size: isMainImage ? 48 : 32,
              ),
              if (isMainImage) ...[
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Property Image',
                  style: TextStyle(
                    color: AppColor.descriptionColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile image widget with circular design
class ProfileImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? fallbackText;
  final VoidCallback? onTap;

  const ProfileImageWidget({
    super.key,
    this.imageUrl,
    this.size = 80,
    this.fallbackText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? OptimizedImageWidget(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  showShimmer: true,
                  errorWidget: _buildFallback(),
                )
              : _buildFallback(),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: fallbackText != null
            ? Text(
                fallbackText!.toUpperCase(),
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                color: AppColor.primaryColor,
                size: size * 0.5,
              ),
      ),
    );
  }
}

/// Gallery image widget for property galleries
class GalleryImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showPlayIcon;

  const GalleryImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.onTap,
    this.showPlayIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          OptimizedImageWidget(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(AppSize.appSize8),
            showShimmer: true,
          ),
          if (showPlayIcon)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSize.appSize8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Thumbnail image widget for small previews
class ThumbnailImageWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ThumbnailImageWidget({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OptimizedImageWidget(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSize.appSize8),
        showShimmer: true,
        fadeInDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

/// Hero image widget for smooth transitions
class HeroImageWidget extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const HeroImageWidget({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: OptimizedImageWidget(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        showShimmer: true,
        fadeInDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
