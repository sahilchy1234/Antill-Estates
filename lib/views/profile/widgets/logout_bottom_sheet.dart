import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/services/auth_service.dart';
import 'package:antill_estates/services/UserDataController.dart';

logoutBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSize.appSize12),
        topRight: Radius.circular(AppSize.appSize12),
      ),
      borderSide: BorderSide.none,
    ),
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      final RxBool isLoggingOut = false.obs;
      
      return Obx(() => Container(
        width: MediaQuery.of(context).size.width,
        height: AppSize.appSize180,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26, bottom: AppSize.appSize20,
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.logout,
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                Text(
                  AppString.logoutString,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isLoggingOut.value ? null : () {
                      Get.back();
                    },
                    child: Container(
                      height: AppSize.appSize49,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColor.primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                      ),
                      child: Center(
                        child: Text(
                          AppString.noButton,
                          style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.appSize26),
                Expanded(
                  child: GestureDetector(
                    onTap: isLoggingOut.value ? null : () async {
                      isLoggingOut.value = true;
                      
                      try {
                        // Get AuthService instance
                        final authService = Get.find<AuthService>();
                        
                        // Logout from auth service
                        await authService.logout();
                        
                        // Clear SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        
                        // Clear UserDataController if exists
                        if (Get.isRegistered<UserDataController>()) {
                          try {
                            Get.delete<UserDataController>();
                          } catch (e) {
                            print('Error deleting UserDataController: $e');
                          }
                        }
                        
                        // Show success message
                        Get.snackbar(
                          '✓ Logged Out',
                          'You have been logged out successfully',
                          backgroundColor: AppColor.successColor,
                          colorText: AppColor.whiteColor,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                        
                        // Close bottom sheet and navigate to onboard
                        Get.back();
                        
                        // Navigate to onboard screen
                        await Future.delayed(const Duration(milliseconds: 300));
                        Get.offAllNamed(AppRoutes.onboardView);
                        
                      } catch (e) {
                        print('Logout error: $e');
                        Get.snackbar(
                          '✗ Error',
                          'An error occurred during logout. Please try again.',
                          backgroundColor: AppColor.errorColor,
                          colorText: AppColor.whiteColor,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        isLoggingOut.value = false;
                      }
                    },
                    child: Container(
                      height: AppSize.appSize49,
                      decoration: BoxDecoration(
                        color: isLoggingOut.value 
                            ? AppColor.primaryColor.withOpacity(0.6)
                            : AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                      ),
                      child: Center(
                        child: isLoggingOut.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.whiteColor,
                                  ),
                                ),
                              )
                            : Text(
                                AppString.yesButton,
                                style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingOnly(bottom: AppSize.appSize10),
          ],
        ),
      ));
    },
  );
}
