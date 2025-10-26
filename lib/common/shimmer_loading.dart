import 'package:flutter/material.dart';
import '../configs/app_color.dart';
import '../configs/app_size.dart';

/// YouTube-style shimmer loading effects for the luxury real estate app
class ShimmerLoading {
  
  /// Simple shimmer effect for better performance
  static Widget simpleShimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return _SimpleShimmerEffect(
      baseColor: baseColor ?? AppColor.descriptionColor.withOpacity(0.1),
      highlightColor: highlightColor ?? AppColor.descriptionColor.withOpacity(0.3),
      child: child,
    );
  }

  /// Property card shimmer (for property listings)
  static Widget propertyCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.appSize16),
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Row(
        children: [
          // Property image shimmer
          simpleShimmer(
            child: Container(
              width: AppSize.appSize90,
              height: AppSize.appSize90,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
            ),
          ),
          const SizedBox(width: AppSize.appSize16),
          // Property details shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price shimmer
                simpleShimmer(
                  child: Container(
                    height: AppSize.appSize20,
                    width: AppSize.appSize100,
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.appSize8),
                // Title shimmer
                simpleShimmer(
                  child: Container(
                    height: AppSize.appSize16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.appSize4),
                // Location shimmer
                simpleShimmer(
                  child: Container(
                    height: AppSize.appSize14,
                    width: AppSize.appSize100,
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.appSize8),
                // Features shimmer
                Row(
                  children: [
                    simpleShimmer(
                      child: Container(
                        height: AppSize.appSize12,
                        width: AppSize.appSize60,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.appSize8),
                    simpleShimmer(
                      child: Container(
                        height: AppSize.appSize12,
                        width: AppSize.appSize60,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Property grid shimmer (for grid layouts)
  static Widget propertyGridShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          simpleShimmer(
            child: Container(
              height: AppSize.appSize150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSize.appSize12),
                  topRight: Radius.circular(AppSize.appSize12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSize.appSize12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price shimmer
                simpleShimmer(
                  child: Container(
                    height: AppSize.appSize18,
                    width: AppSize.appSize80,
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.appSize8),
                // Title shimmer
                simpleShimmer(
                  child: Container(
                    height: AppSize.appSize16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.appSize4),
                // Location shimmer
                simpleShimmer(
                  child: Container(
                    height: AppSize.appSize14,
                    width: AppSize.appSize100,
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.appSize8),
                // Features shimmer
                Row(
                  children: [
                    simpleShimmer(
                      child: Container(
                        height: AppSize.appSize12,
                        width: AppSize.appSize50,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.appSize8),
                    simpleShimmer(
                      child: Container(
                        height: AppSize.appSize12,
                        width: AppSize.appSize50,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Property details shimmer (for property detail pages)
  static Widget propertyDetailsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main image shimmer
        simpleShimmer(
          child: Container(
            height: AppSize.appSize200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
          ),
        ),
        const SizedBox(height: AppSize.appSize16),
        // Price and title shimmer
        simpleShimmer(
          child: Container(
            height: AppSize.appSize24,
            width: AppSize.appSize150,
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize4),
            ),
          ),
        ),
        const SizedBox(height: AppSize.appSize8),
        simpleShimmer(
          child: Container(
            height: AppSize.appSize20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize4),
            ),
          ),
        ),
        const SizedBox(height: AppSize.appSize16),
        // Features shimmer
        Row(
          children: List.generate(3, (index) => 
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 2 ? AppSize.appSize8 : 0),
                child: simpleShimmer(
                  child: Container(
                    height: AppSize.appSize60,
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSize.appSize24),
        // Description shimmer
        simpleShimmer(
          child: Container(
            height: AppSize.appSize16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize4),
            ),
          ),
        ),
        const SizedBox(height: AppSize.appSize8),
        simpleShimmer(
          child: Container(
            height: AppSize.appSize16,
            width: AppSize.appSize200,
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize4),
            ),
          ),
        ),
      ],
    );
  }

  /// Profile shimmer (for user profiles)
  static Widget profileShimmer() {
    return Column(
      children: [
        // Profile image shimmer
        simpleShimmer(
          child: Container(
            width: AppSize.appSize80,
            height: AppSize.appSize80,
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: AppSize.appSize16),
        // Name shimmer
        simpleShimmer(
          child: Container(
            height: AppSize.appSize20,
            width: AppSize.appSize100,
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize4),
            ),
          ),
        ),
        const SizedBox(height: AppSize.appSize8),
        // Email shimmer
        simpleShimmer(
          child: Container(
            height: AppSize.appSize16,
            width: AppSize.appSize150,
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize4),
            ),
          ),
        ),
      ],
    );
  }

  /// List shimmer (for any list content)
  static Widget listShimmer({int itemCount = 5}) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: AppSize.appSize12),
          child: simpleShimmer(
            child: Container(
              height: AppSize.appSize60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Image shimmer (for loading images)
  static Widget imageShimmer({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return simpleShimmer(
      child: Container(
        width: width ?? double.infinity,
        height: height ?? AppSize.appSize200,
        decoration: BoxDecoration(
          color: AppColor.descriptionColor.withOpacity(0.1),
          borderRadius: borderRadius ?? BorderRadius.circular(AppSize.appSize8),
        ),
      ),
    );
  }

  /// Text shimmer (for loading text content)
  static Widget textShimmer({
    double? width,
    double? height,
    int lines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lines,
        (index) => Container(
          margin: EdgeInsets.only(bottom: index < lines - 1 ? AppSize.appSize4 : 0),
          child: simpleShimmer(
            child: Container(
              height: height ?? AppSize.appSize16,
              width: width ?? (index == lines - 1 ? AppSize.appSize100 : double.infinity),
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Custom shimmer with specific colors
  static Widget customShimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration? period,
  }) {
    return _ShimmerEffect(
      baseColor: baseColor ?? AppColor.descriptionColor.withOpacity(0.1),
      highlightColor: highlightColor ?? AppColor.descriptionColor.withOpacity(0.3),
      child: child,
    );
  }
}

/// Custom shimmer effect implementation
class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerEffect({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Simple shimmer effect implementation for better performance
class _SimpleShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const _SimpleShimmerEffect({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_SimpleShimmerEffect> createState() => _SimpleShimmerEffectState();
}

class _SimpleShimmerEffectState extends State<_SimpleShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Color.lerp(widget.baseColor, widget.highlightColor, _animation.value),
          ),
          child: widget.child,
        );
      },
    );
  }
}
