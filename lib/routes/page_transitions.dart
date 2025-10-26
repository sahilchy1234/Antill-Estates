import 'package:flutter/material.dart';
import 'package:antill_estates/configs/app_animations.dart';
import 'dart:math' as math;

/// Premium custom page transitions for luxury real estate app
class PageTransitions {
  PageTransitions._();

  /// Slide and Fade transition - Smooth and elegant
  static Widget slideAndFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: AppAnimations.smoothCurve),
    );
    final offsetAnimation = animation.drive(tween);
    final fadeAnimation = animation.drive(
      CurveTween(curve: AppAnimations.smoothCurve),
    );

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  /// Scale and Fade - Modern and smooth
  static Widget scaleAndFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: AppAnimations.smoothCurve,
      ),
    );

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    );

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  /// Rotation and Fade - Unique and eye-catching
  static Widget rotationFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: AppAnimations.smoothCurve,
      ),
    );

    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: AppAnimations.smoothCurve,
      ),
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(rotationAnimation.value)
        ..scale(scaleAnimation.value),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Slide Up - Perfect for modal-style pages
  static Widget slideUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: AppAnimations.smoothCurve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Zoom and Rotate - Premium transition
  static Widget zoomRotate(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final zoomAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: AppAnimations.smoothCurve,
      ),
    );

    final rotateAnimation = Tween<double>(
      begin: math.pi / 8,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: AppAnimations.smoothCurve,
      ),
    );

    return Transform.scale(
      scale: zoomAnimation.value,
      child: Transform.rotate(
        angle: rotateAnimation.value,
        child: child,
      ),
    );
  }

  /// Shared Axis X - Material Design inspired
  static Widget sharedAxisX(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    );
  }

  /// Shared Axis Y - Material Design inspired
  static Widget sharedAxisY(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.vertical,
      child: child,
    );
  }

  /// Fade Through - Clean and sophisticated
  static Widget fadeThrough(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppAnimations.smoothCurve,
          ),
        ),
        child: child,
      ),
    );
  }

  /// 3D Flip Horizontal - Very premium
  static Widget flip3D(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.smoothCurve,
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      child: child,
      builder: (context, child) {
        final value = curvedAnimation.value;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(math.pi * (1 - value)),
          child: value > 0.5
              ? child
              : Container(color: Colors.transparent),
        );
      },
    );
  }

  /// Slide from bottom with scale - iOS style
  static Widget slideScale(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 0.1);
    const end = Offset.zero;

    final slideTween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: AppAnimations.smoothCurve),
    );

    final scaleTween = Tween<double>(begin: 0.9, end: 1.0).chain(
      CurveTween(curve: AppAnimations.smoothCurve),
    );

    return SlideTransition(
      position: animation.drive(slideTween),
      child: ScaleTransition(
        scale: animation.drive(scaleTween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  /// Elastic entrance - Fun and engaging
  static Widget elastic(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final elasticAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      ),
    );

    return ScaleTransition(
      scale: elasticAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Shared Axis Transition Implementation
enum SharedAxisTransitionType { horizontal, vertical, scaled }

class SharedAxisTransition extends StatelessWidget {
  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final SharedAxisTransitionType transitionType;

  @override
  Widget build(BuildContext context) {
    final primaryAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    final secondaryAnimationCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    return Stack(
      children: [
        // Outgoing page
        SlideTransition(
          position: _getTween(transitionType, reverse: true)
              .animate(secondaryAnimationCurved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0)
                .animate(secondaryAnimationCurved),
            child: Container(),
          ),
        ),
        // Incoming page
        SlideTransition(
          position: _getTween(transitionType).animate(primaryAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(primaryAnimation),
            child: child,
          ),
        ),
      ],
    );
  }

  Tween<Offset> _getTween(SharedAxisTransitionType type,
      {bool reverse = false}) {
    switch (type) {
      case SharedAxisTransitionType.horizontal:
        return Tween<Offset>(
          begin: Offset(reverse ? -0.3 : 0.3, 0.0),
          end: Offset.zero,
        );
      case SharedAxisTransitionType.vertical:
        return Tween<Offset>(
          begin: Offset(0.0, reverse ? -0.3 : 0.3),
          end: Offset.zero,
        );
      case SharedAxisTransitionType.scaled:
        return Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        );
    }
  }
}

