import 'package:flutter/material.dart';
import 'app_color.dart';

/// Enhanced design system for beautiful and elegant UI
class AppDesign {
  AppDesign._();

  // ========== SHADOWS ==========
  
  /// Subtle shadow for cards and containers
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow for elevated elements
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Strong shadow for floating elements
  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: 0,
    ),
  ];

  /// Subtle inner shadow effect
  static List<BoxShadow> get innerShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  // ========== BORDER RADIUS ==========
  
  static BorderRadius get smallRadius => BorderRadius.circular(8);
  static BorderRadius get mediumRadius => BorderRadius.circular(12);
  static BorderRadius get largeRadius => BorderRadius.circular(16);
  static BorderRadius get xLargeRadius => BorderRadius.circular(20);
  static BorderRadius get xxLargeRadius => BorderRadius.circular(24);

  // ========== BORDERS ==========
  
  static Border get subtleBorder => Border.all(
    color: AppColor.borderColor.withOpacity(0.5),
    width: 1,
  );

  static Border get mediumBorder => Border.all(
    color: AppColor.borderColor,
    width: 1,
  );

  static Border get accentBorder => Border.all(
    color: AppColor.primaryColor.withOpacity(0.2),
    width: 1.5,
  );

  // ========== DECORATIONS ==========
  
  /// Card decoration with elegant styling
  static BoxDecoration get card => BoxDecoration(
    color: AppColor.whiteColor,
    borderRadius: mediumRadius,
    boxShadow: cardShadow,
    border: Border.all(
      color: AppColor.borderColor.withOpacity(0.3),
      width: 0.5,
    ),
  );

  /// Elevated card decoration
  static BoxDecoration get elevatedCard => BoxDecoration(
    color: AppColor.whiteColor,
    borderRadius: mediumRadius,
    boxShadow: elevatedShadow,
  );

  /// Input field decoration
  static BoxDecoration get inputDecoration => BoxDecoration(
    color: AppColor.whiteColor,
    borderRadius: mediumRadius,
    boxShadow: cardShadow,
    border: Border.all(
      color: AppColor.borderColor.withOpacity(0.4),
      width: 1,
    ),
  );

  /// Subtle background container
  static BoxDecoration get subtleContainer => BoxDecoration(
    color: AppColor.secondaryColor,
    borderRadius: mediumRadius,
    border: Border.all(
      color: AppColor.borderColor.withOpacity(0.3),
      width: 0.5,
    ),
  );

  /// Primary accent container
  static BoxDecoration get accentContainer => BoxDecoration(
    color: AppColor.primaryColor.withOpacity(0.05),
    borderRadius: mediumRadius,
    border: Border.all(
      color: AppColor.primaryColor.withOpacity(0.15),
      width: 1,
    ),
  );

  // ========== SPACING ==========
  
  static const EdgeInsets tinyPadding = EdgeInsets.all(4);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);
  static const EdgeInsets mediumPadding = EdgeInsets.all(12);
  static const EdgeInsets largePadding = EdgeInsets.all(16);
  static const EdgeInsets xLargePadding = EdgeInsets.all(20);
  static const EdgeInsets xxLargePadding = EdgeInsets.all(24);

  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // ========== GAPS ==========
  
  static const SizedBox tinyGap = SizedBox(height: 4, width: 4);
  static const SizedBox smallGap = SizedBox(height: 8, width: 8);
  static const SizedBox mediumGap = SizedBox(height: 12, width: 12);
  static const SizedBox largeGap = SizedBox(height: 16, width: 16);
  static const SizedBox xLargeGap = SizedBox(height: 20, width: 20);
  static const SizedBox xxLargeGap = SizedBox(height: 24, width: 24);

  // ========== ANIMATIONS ==========
  
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 350);

  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve snapCurve = Curves.easeOut;

  // ========== BUTTONS ==========
  
  /// Primary button style
  static BoxDecoration get primaryButton => BoxDecoration(
    color: AppColor.primaryColor,
    borderRadius: mediumRadius,
    boxShadow: [
      BoxShadow(
        color: AppColor.primaryColor.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Secondary button style
  static BoxDecoration get secondaryButton => BoxDecoration(
    color: AppColor.whiteColor,
    borderRadius: mediumRadius,
    boxShadow: cardShadow,
    border: Border.all(
      color: AppColor.primaryColor,
      width: 1.5,
    ),
  );

  /// Floating action button style
  static BoxDecoration get fab => BoxDecoration(
    color: AppColor.primaryColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: floatingShadow,
  );

  // ========== DIVIDERS ==========
  
  static Divider get subtleDivider => Divider(
    color: AppColor.borderColor.withOpacity(0.3),
    height: 1,
    thickness: 0.5,
  );

  static Divider get mediumDivider => const Divider(
    color: AppColor.borderColor,
    height: 1,
    thickness: 1,
  );

  // ========== BADGES ==========
  
  static BoxDecoration badgeDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: color.withOpacity(0.3),
      width: 1,
    ),
  );

  static BoxDecoration get primaryBadge => badgeDecoration(AppColor.primaryColor);
  static BoxDecoration get successBadge => badgeDecoration(AppColor.successColor);
  static BoxDecoration get errorBadge => badgeDecoration(AppColor.errorColor);
  static BoxDecoration get warningBadge => badgeDecoration(AppColor.warningColor);

  // ========== IMAGE CONTAINERS ==========
  
  static BoxDecoration get imageContainer => BoxDecoration(
    color: AppColor.backgroundColor,
    borderRadius: mediumRadius,
    border: Border.all(
      color: AppColor.borderColor.withOpacity(0.2),
      width: 0.5,
    ),
  );

  static BoxDecoration get imageOverlay => BoxDecoration(
    borderRadius: mediumRadius,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.7),
      ],
      stops: const [0.5, 1.0],
    ),
  );
}

