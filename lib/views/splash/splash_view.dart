import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/splash_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/services/app_startup_service.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  SplashController get splashController => Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: buildOptimizedSplash(),
    );
  }

  Widget buildOptimizedSplash() {
    return GetBuilder<AppStartupService>(
      builder: (startupService) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: Image.asset(
                      Assets.images.appLogo.path,
                      width: AppSize.appSize200,
                      height: AppSize.appSize200,
                    ),
                  ),
                );
              },
            ),
            
            // App Name
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    AppString.appName,
                    style: AppStyle.appHeading(
                      color: AppColor.primaryColor,
                      letterSpacing: AppSize.appSize3,
                    ),
                  ).paddingOnly(top: AppSize.appSize20),
                );
              },
            ),
            
            // Loading Progress
            const SizedBox(height: 50),
            
            // Progress Indicator
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: startupService.initializationProgress),
              builder: (context, value, child) {
                return Column(
                  children: [
                    // Progress Bar
                    Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColor.primaryColor.withOpacity(0.1),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 200 * value,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                AppColor.primaryColor,
                                AppColor.primaryColor.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Status Text
                    const SizedBox(height: 16),
                    Text(
                      startupService.initializationStatus,
                      style: AppStyle.appSubHeading(
                        color: AppColor.descriptionColor,
                        fontSize: AppSize.appSize14,
                      ),
                    ),
                    
                    // Progress Percentage
                    const SizedBox(height: 8),
                    Text(
                      '${(startupService.initializationProgress * 100).toInt()}%',
                      style: AppStyle.appSubHeading(
                        color: AppColor.primaryColor,
                        fontSize: AppSize.appSize12,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Loading Animation
            const SizedBox(height: 30),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
