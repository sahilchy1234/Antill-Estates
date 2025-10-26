import 'package:flutter/material.dart';
import 'package:antill_estates/configs/app_animations.dart';

/// Utility class for widget animations
/// Use these for animating widgets within your pages
class AnimationUtils {
  AnimationUtils._();

  /// Fade in animation widget wrapper
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? AppAnimations.medium,
      curve: curve ?? AppAnimations.smoothCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide in from bottom with fade
  static Widget slideInFromBottom({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 50.0, end: 0.0),
      duration: duration ?? AppAnimations.medium,
      curve: curve ?? AppAnimations.smoothCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (value / 50),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration? duration,
    double? begin,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin ?? 0.8, end: 1.0),
      duration: duration ?? AppAnimations.medium,
      curve: curve ?? AppAnimations.smoothCurve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide in from right
  static Widget slideInFromRight({
    required Widget child,
    Duration? duration,
    double? distance,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: distance ?? 100.0, end: 0.0),
      duration: duration ?? AppAnimations.medium,
      curve: curve ?? AppAnimations.smoothCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide in from left
  static Widget slideInFromLeft({
    required Widget child,
    Duration? duration,
    double? distance,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -(distance ?? 100.0), end: 0.0),
      duration: duration ?? AppAnimations.medium,
      curve: curve ?? AppAnimations.smoothCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Delayed animation wrapper
  static Widget delayed({
    required Widget child,
    required Duration delay,
    Duration? duration,
  }) {
    return _DelayedAnimation(
      delay: delay,
      duration: duration ?? AppAnimations.medium,
      child: child,
    );
  }

  /// Stagger list animation
  static Widget staggeredList({
    required int index,
    required Widget child,
    Duration? delay,
    Duration? duration,
  }) {
    final itemDelay = (delay ?? const Duration(milliseconds: 100)) * index;
    return delayed(
      delay: itemDelay,
      duration: duration,
      child: slideInFromBottom(
        child: child,
        duration: duration ?? AppAnimations.medium,
      ),
    );
  }

  /// Shimmer loading effect
  static Widget shimmer({
    required Widget child,
    Duration? duration,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -2.0, end: 2.0),
      duration: duration ?? const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor ?? Colors.grey[300]!,
                highlightColor ?? Colors.grey[100]!,
                baseColor ?? Colors.grey[300]!,
              ],
              stops: [
                value - 0.3,
                value,
                value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Bounce animation
  static Widget bounce({
    required Widget child,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? AppAnimations.medium,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Rotate animation
  static Widget rotate({
    required Widget child,
    Duration? duration,
    double? begin,
    double? end,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin ?? 0.0, end: end ?? 6.28), // 2*pi
      duration: duration ?? AppAnimations.slow,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Helper widget for delayed animations
class _DelayedAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const _DelayedAnimation({
    required this.child,
    required this.delay,
    required this.duration,
  });

  @override
  State<_DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<_DelayedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Animated list item widget
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Curve curve;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Hero animation helper
class HeroAnimationHelper {
  /// Create a hero widget with custom flight shuttle
  static Widget hero({
    required String tag,
    required Widget child,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder ??
          (flightContext, animation, direction, fromContext, toContext) {
            return ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.1).animate(animation),
              child: DefaultTextStyle(
                style: DefaultTextStyle.of(toContext).style,
                child: toContext.widget,
              ),
            );
          },
      child: child,
    );
  }
}

