import 'package:flutter/material.dart';

/// Central configuration for all app animations
/// Provides consistent durations, curves, and animation constants
class AppAnimations {
  AppAnimations._();

  // Animation Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 700);

  // Animation Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve decelerate = Curves.decelerate;
  
  // Custom curves for premium feel
  static final Curve smoothCurve = Curves.easeInOutCubicEmphasized;
  static const Curve sharpCurve = Curves.easeInOutExpo;
  
  // Page Transition Durations
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration modalTransition = Duration(milliseconds: 350);
  
  // Reverse Multiplier
  static const double reverseMultiplier = 0.8;
}

