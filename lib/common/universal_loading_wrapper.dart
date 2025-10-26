import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/enhanced_loading_service.dart';
import '../configs/app_color.dart';
import '../configs/app_size.dart';

/// Universal loading wrapper component for any page
class UniversalLoadingWrapper extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Widget? customLoadingWidget;
  final String? pageType;
  final bool showOverlay;

  const UniversalLoadingWrapper({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.customLoadingWidget,
    this.pageType,
    this.showOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    if (showOverlay) {
      return EnhancedLoadingService.buildLoadingOverlay(
        isLoading: isLoading,
        child: child,
        loadingText: loadingText,
      );
    }

    if (customLoadingWidget != null) {
      return customLoadingWidget!;
    }

    // Use page-specific loading based on pageType
    switch (pageType?.toLowerCase()) {
      case 'home':
        return EnhancedLoadingService.buildHomePageLoading();
      case 'property_list':
        return EnhancedLoadingService.buildPropertyListLoading();
      case 'property_details':
        return EnhancedLoadingService.buildPropertyDetailsLoading();
      case 'profile':
        return EnhancedLoadingService.buildProfilePageLoading();
      case 'search':
        return EnhancedLoadingService.buildSearchPageLoading();
      case 'activity':
        return EnhancedLoadingService.buildActivityPageLoading();
      case 'saved':
        return EnhancedLoadingService.buildSavedPropertiesLoading();
      case 'auth':
      case 'login':
      case 'register':
        return EnhancedLoadingService.buildAuthPageLoading();
      case 'post_property':
        return EnhancedLoadingService.buildPostPropertyLoading();
      case 'gallery':
        return EnhancedLoadingService.buildGalleryLoading();
      case 'notification':
        return EnhancedLoadingService.buildNotificationLoading();
      case 'drawer':
        return EnhancedLoadingService.buildDrawerLoading();
      default:
        return EnhancedLoadingService.buildDefaultPageLoading();
    }
  }
}

/// Loading state mixin for controllers
mixin LoadingStateMixin {
  final RxBool _isLoading = false.obs;
  
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;
  
  void setLoading(bool loading) => isLoading = loading;
  
  Future<T> withLoading<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      return await operation();
    } finally {
      setLoading(false);
    }
  }
}

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? size;
  final bool showText;

  const LoadingIndicator({
    super.key,
    this.text,
    this.color,
    this.size,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColor.primaryColor,
            ),
            strokeWidth: 3.0,
          ),
          if (showText && text != null) ...[
            const SizedBox(height: AppSize.appSize16),
            Text(
              text!,
              style: const TextStyle(
                color: AppColor.textColor,
                fontSize: AppSize.appSize16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton loading widget
class SkeletonLoader extends StatelessWidget {
  final String contentType;
  final int itemCount;
  final double? height;
  final double? width;

  const SkeletonLoader({
    super.key,
    required this.contentType,
    this.itemCount = 3,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedLoadingService.buildSkeletonLoading(
      contentType: contentType,
      itemCount: itemCount,
    );
  }
}

/// Page loading wrapper with automatic loading state detection
class PageLoadingWrapper extends StatelessWidget {
  final Widget child;
  final String pageType;
  final bool Function()? isLoadingCheck;
  final Widget? customLoadingWidget;

  const PageLoadingWrapper({
    super.key,
    required this.child,
    required this.pageType,
    this.isLoadingCheck,
    this.customLoadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalLoadingWrapper(
      isLoading: isLoadingCheck?.call() ?? false,
      pageType: pageType,
      customLoadingWidget: customLoadingWidget,
      child: child,
    );
  }
}

/// Loading state builder
class LoadingStateBuilder extends StatelessWidget {
  final bool isLoading;
  final Widget Function() loadingBuilder;
  final Widget Function() contentBuilder;
  final Widget Function()? errorBuilder;

  const LoadingStateBuilder({
    super.key,
    required this.isLoading,
    required this.loadingBuilder,
    required this.contentBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingBuilder();
    }
    
    return contentBuilder();
  }
}

/// Animated loading wrapper
class AnimatedLoadingWrapper extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration animationDuration;
  final String? pageType;

  const AnimatedLoadingWrapper({
    super.key,
    required this.child,
    required this.isLoading,
    this.animationDuration = const Duration(milliseconds: 300),
    this.pageType,
  });

  @override
  State<AnimatedLoadingWrapper> createState() => _AnimatedLoadingWrapperState();
}

class _AnimatedLoadingWrapperState extends State<AnimatedLoadingWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedLoadingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        if (widget.isLoading) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: UniversalLoadingWrapper(
              isLoading: true,
              pageType: widget.pageType,
              child: widget.child,
            ),
          );
        }
        
        return Opacity(
          opacity: 1.0 - _fadeAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
