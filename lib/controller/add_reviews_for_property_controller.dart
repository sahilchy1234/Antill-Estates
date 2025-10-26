import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/controller/property_details_controller.dart';
import 'package:antill_estates/model/review_model.dart';
import 'package:antill_estates/services/review_service.dart';

class AddReviewsForPropertyController extends GetxController {
  TextEditingController writeAReviewController = TextEditingController();
  
  // Edit mode properties
  RxBool isEditMode = false.obs;
  RxDouble currentRating = 0.0.obs;
  RxBool isLoading = false.obs;
  String? propertyId;
  Review? existingReview;

  @override
  void onInit() {
    super.onInit();
    // Get property ID from arguments
    propertyId = Get.arguments as String?;
    
    if (propertyId != null) {
      checkForExistingReview();
    }
  }

  /// Check if user has an existing review for this property
  Future<void> checkForExistingReview() async {
    if (propertyId == null) return;
    
    try {
      isLoading.value = true;
      existingReview = await ReviewService.getUserReviewForProperty(propertyId!);
      
      if (existingReview != null) {
        isEditMode.value = true;
        currentRating.value = existingReview!.rating;
        writeAReviewController.text = existingReview!.comment;
        print('🔍 Found existing review: ${existingReview!.comment}');
      } else {
        isEditMode.value = false;
        currentRating.value = 3.0; // Default rating
        print('🔍 No existing review found');
      }
    } catch (e) {
      print('❌ Error checking for existing review: $e');
      isEditMode.value = false;
      currentRating.value = 3.0;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update rating
  void updateRating(double rating) {
    currentRating.value = rating;
  }

  /// Submit or update review
  Future<void> submitReview() async {
    if (propertyId == null) {
      Get.snackbar('Error', 'Property ID not found');
      return;
    }

    if (currentRating.value == 0.0) {
      Get.snackbar('Error', 'Please select a rating');
      return;
    }

    if (writeAReviewController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please write a review');
      return;
    }

    try {
      isLoading.value = true;
      
      await ReviewService.addOrUpdateReview(
        propertyId: propertyId!,
        rating: currentRating.value,
        comment: writeAReviewController.text.trim(),
      );

      Get.snackbar(
        isEditMode.value ? 'Review Updated' : 'Review Added',
        isEditMode.value 
          ? 'Your review has been updated successfully'
          : 'Your review has been submitted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh property details reviews if PropertyDetailsController is available
      try {
        if (Get.isRegistered<PropertyDetailsController>()) {
          final propertyDetailsController = Get.find<PropertyDetailsController>();
          await propertyDetailsController.loadPropertyReviews(propertyId!);
        }
      } catch (e) {
        print('⚠️ Could not refresh property details: $e');
      }

      Get.back();
    } catch (e) {
      print('❌ Error submitting review: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isEditMode.value ? 'update' : 'add'} review: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete user's review for this property
  Future<void> deleteReview() async {
    if (propertyId == null) {
      Get.snackbar('Error', 'Property ID not found');
      return;
    }

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete your review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      
      await ReviewService.deleteUserReviewForProperty(propertyId!);

      Get.snackbar(
        'Review Deleted',
        'Your review has been deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      print('❌ Error deleting review: $e');
      Get.snackbar(
        'Error',
        'Failed to delete review: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    writeAReviewController.clear();
  }
}
