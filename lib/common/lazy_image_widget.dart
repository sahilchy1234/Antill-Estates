import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';

/// Lazy loading image widget that only loads when visible
class LazyImageWidget extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool showLoadingIndicator;
  final Duration fadeInDuration;
  final double threshold;

  const LazyImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.showLoadingIndicator = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.threshold = 0.1, // Load when 10% of widget is visible
  });

  @override
  State<LazyImageWidget> createState() => _LazyImageWidgetState();
}

class _LazyImageWidgetState extends State<LazyImageWidget>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  bool _hasLoaded = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction >= widget.threshold && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
      
      // Start fade in animation after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _fadeController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('lazy_image_${widget.imageUrl.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
        ),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (!_isVisible) {
      return _buildPlaceholder();
    }

    if (!_hasLoaded) {
      _hasLoaded = true;
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: CachedFirebaseImage(
            imageUrl: widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholder: widget.placeholder,
            errorWidget: widget.errorWidget,
            borderRadius: widget.borderRadius,
            showLoadingIndicator: widget.showLoadingIndicator,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: widget.showLoadingIndicator
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            )
          : null,
    );
  }
}

/// Lazy loading image grid for property galleries
class LazyImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const LazyImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.spacing = 8.0,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return LazyImageWidget(
          imageUrl: imageUrls[index],
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
          borderRadius: borderRadius,
        );
      },
    );
  }
}

/// Lazy loading image carousel for property details
class LazyImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final BoxFit fit;
  final bool showIndicators;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LazyImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 250.0,
    this.fit = BoxFit.cover,
    this.showIndicators = true,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<LazyImageCarousel> createState() => _LazyImageCarouselState();
}

class _LazyImageCarouselState extends State<LazyImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return LazyImageWidget(
                imageUrl: widget.imageUrls[index],
                height: widget.height,
                fit: widget.fit,
                placeholder: widget.placeholder,
                errorWidget: widget.errorWidget,
                threshold: 0.5, // Load when 50% visible for carousel
              );
            },
          ),
        ),
        if (widget.showIndicators && widget.imageUrls.length > 1)
          _buildPageIndicators(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No images available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.imageUrls.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }
}
