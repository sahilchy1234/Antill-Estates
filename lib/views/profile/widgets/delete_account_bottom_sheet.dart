import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/services/auth_service.dart';
import 'package:antill_estates/services/UserDataController.dart';

deleteAccountBottomSheet(BuildContext context) {
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
      final RxBool isDeleting = false.obs;
      
      return Obx(() => Container(
        width: MediaQuery.of(context).size.width,
        height: AppSize.appSize355,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
          bottom: AppSize.appSize20,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppString.deleteAccount,
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                    GestureDetector(
                      onTap: isDeleting.value ? null : () {
                        Get.back();
                      },
                      child: Image.asset(
                        Assets.images.close.path,
                        width: AppSize.appSize24,
                      ),
                    ),
                  ],
                ),
                Text(
                  AppString.deleteAccountString,
                  style: AppStyle.heading4Regular(color: AppColor.textColor),
                ).paddingOnly(top: AppSize.appSize16),
                customRow(AppString.deleteAccountString1),
                customRow(AppString.deleteAccountString2),
                customRow(AppString.deleteAccountString3),
              ],
            ),
            CommonButton(
              onPressed: isDeleting.value ? null : () async {
                // Show confirmation dialog
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('⚠️ Final Warning'),
                    content: const Text(
                      'This action cannot be undone. All your data will be permanently deleted.\n\nAre you absolutely sure?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Yes, Delete My Account'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed != true) return;
                
                isDeleting.value = true;
                
                try {
                  // Get AuthService and current user ID
                  final authService = Get.find<AuthService>();
                  final userId = authService.userId.value;
                  
                  if (userId.isEmpty) {
                    throw Exception('User ID not found');
                  }
                  
                  final firestore = FirebaseFirestore.instance;
                  final firebaseAuth = FirebaseAuth.instance;
                  
                  // Delete user data from Firestore
                  await firestore.collection('users').doc(userId).delete();
                  print('✅ User document deleted from Firestore');
                  
                  // Delete user's properties if any
                  final propertiesSnapshot = await firestore
                      .collection('properties')
                      .where('userId', isEqualTo: userId)
                      .get();
                  
                  for (var doc in propertiesSnapshot.docs) {
                    await doc.reference.delete();
                  }
                  print('✅ User properties deleted');
                  
                  // Delete user's saved properties
                  final savedPropertiesSnapshot = await firestore
                      .collection('savedProperties')
                      .where('userId', isEqualTo: userId)
                      .get();
                  
                  for (var doc in savedPropertiesSnapshot.docs) {
                    await doc.reference.delete();
                  }
                  print('✅ Saved properties deleted');
                  
                  // Delete user's reviews
                  final reviewsSnapshot = await firestore
                      .collection('reviews')
                      .where('userId', isEqualTo: userId)
                      .get();
                  
                  for (var doc in reviewsSnapshot.docs) {
                    await doc.reference.delete();
                  }
                  print('✅ User reviews deleted');
                  
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
                  
                  // Try to delete Firebase Auth user (if not anonymous)
                  try {
                    final currentUser = firebaseAuth.currentUser;
                    if (currentUser != null && !currentUser.isAnonymous) {
                      await currentUser.delete();
                      print('✅ Firebase Auth user deleted');
                    }
                  } catch (e) {
                    print('⚠️ Could not delete Firebase Auth user: $e');
                    // Continue anyway as the main data is already deleted
                  }
                  
                  // Show success message
                  Get.snackbar(
                    '✓ Account Deleted',
                    'Your account has been permanently deleted',
                    backgroundColor: AppColor.successColor,
                    colorText: AppColor.whiteColor,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 3),
                  );
                  
                  // Close bottom sheet
                  Get.back();
                  
                  // Navigate to onboard screen
                  await Future.delayed(const Duration(milliseconds: 500));
                  Get.offAllNamed(AppRoutes.onboardView);
                  
                } catch (e) {
                  print('Delete account error: $e');
                  Get.snackbar(
                    '✗ Error',
                    'Failed to delete account: ${e.toString()}',
                    backgroundColor: AppColor.errorColor,
                    colorText: AppColor.whiteColor,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 4),
                  );
                  isDeleting.value = false;
                }
              },
              backgroundColor: isDeleting.value 
                  ? AppColor.errorColor.withOpacity(0.6)
                  : AppColor.errorColor,
              child: isDeleting.value
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
                      AppString.continueToDeleteButton,
                      style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                    ),
            ).paddingOnly(bottom: AppSize.appSize10),
          ],
        ),
      ));
    },
  );
}

customRow(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: AppSize.appSize5,
        height: AppSize.appSize5,
        margin: const EdgeInsets.only(
          right: AppSize.appSize12,
          top: AppSize.appSize8,
          left: AppSize.appSize12,
        ),
        decoration: const BoxDecoration(
          color: AppColor.descriptionColor,
          shape: BoxShape.circle,
        ),
      ),
      Expanded(
        child: Text(
          text,
          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
        ),
      ),
    ],
  ).paddingOnly(top: AppSize.appSize16);
}
