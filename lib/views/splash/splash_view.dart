import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/splash_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/services/app_startup_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  SplashController get splashController => Get.put(SplashController());

  @override
  void initState() {
    super.initState();
    
    // Shimmer animation for the top loader
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: buildOptimizedSplash(),
    );
  }

  Widget buildOptimizedSplash() {
    return GetBuilder<AppStartupService>(
      init: Get.find<AppStartupService>(),
      builder: (startupService) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo with enhanced animation
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    final pulseValue = _pulseController.value;
                    return Transform.scale(
                      scale: (0.8 + (0.2 * value)) * (1.0 + pulseValue * 0.05),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryColor.withOpacity(0.3 * pulseValue),
                                blurRadius: 30 * pulseValue,
                                spreadRadius: 10 * pulseValue,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            Assets.images.appLogo.path,
                            width: AppSize.appSize200,
                            height: AppSize.appSize200,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            
            // App Name with slide animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Text(
                      AppString.appName,
                      style: AppStyle.appHeading(
                        color: AppColor.primaryColor,
                        letterSpacing: AppSize.appSize3,
                      ),
                    ).paddingOnly(top: AppSize.appSize20),
                  ),
                );
              },
            ),
            
            // Loading Progress Section
            const SizedBox(height: 50),
            
            // Enhanced Progress Indicator
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: startupService.initializationProgress),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                // Clamp value to ensure it's exactly 1.0 at 100%
                final clampedValue = value.clamp(0.0, 1.0);
                
                return Column(
                  children: [
                    // Modern Progress Bar with glow effect
                    Container(
                      width: 250,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.primaryColor.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // Animated progress using FractionallySizedBox for precise filling
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: clampedValue,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColor.primaryColor,
                                        AppColor.primaryColor.withOpacity(0.7),
                                        AppColor.primaryColor,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.primaryColor.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Shimmer effect on progress bar
                            if (clampedValue < 1.0)
                              AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (context, child) {
                                  return Positioned(
                                    left: -100 + (350 * _shimmerController.value),
                                    child: Container(
                                      width: 100,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.white.withOpacity(0.4),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Status Text with fade animation
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        startupService.initializationStatus,
                        key: ValueKey(startupService.initializationStatus),
                        style: AppStyle.appSubHeading(
                          color: AppColor.descriptionColor,
                          fontSize: AppSize.appSize14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Progress Percentage with scale animation
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.9, end: 1.0),
                      builder: (context, scaleValue, child) {
                        return Transform.scale(
                          scale: scaleValue,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColor.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${(startupService.initializationProgress * 100).toInt()}%',
                              style: AppStyle.appSubHeading(
                                color: AppColor.primaryColor,
                                fontSize: AppSize.appSize16,
                              ).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            
            // Animated Loading Dots
            const SizedBox(height: 30),
            _buildLoadingDots(),
          ],
        );
      },
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (_shimmerController.value + delay) % 1.0;
            final opacity = (animValue < 0.5) ? animValue * 2 : (1 - animValue) * 2;
            final scale = 0.5 + (opacity * 0.5);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primaryColor.withOpacity(opacity),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(opacity * 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
