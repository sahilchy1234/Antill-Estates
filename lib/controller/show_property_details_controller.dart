import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/model/review_model.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:antill_estates/services/review_service.dart';

class ShowPropertyDetailsController extends GetxController {
  // Existing observables
  RxBool isExpanded = false.obs;
  RxInt selectAgent = 0.obs;
  RxBool isChecked = false.obs;
  RxInt selectProperty = 0.obs;
  RxBool isVisitExpanded = false.obs;
  String truncatedText = AppString.aboutPropertyString.substring(0, 200);
  RxBool hasFullNameFocus = false.obs;
  RxBool hasFullNameInput = false.obs;
  RxBool hasPhoneNumberFocus = true.obs;
  RxBool hasPhoneNumberInput = true.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;

  // Firebase related observables
  Rx<Property?> property = Rx<Property?>(null);
  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;
  
  // Owner contact information
  RxString ownerName = ''.obs;
  RxString ownerPhone = ''.obs;
  RxString ownerAvatar = ''.obs;

  FocusNode focusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  TextEditingController fullNameController = TextEditingController(text: AppString.francisZieme);
  TextEditingController mobileNumberController = TextEditingController(text: AppString.francisZiemeNumber);
  TextEditingController emailController = TextEditingController(text: AppString.francisZiemeEmail);

  // Similar properties from Firebase
  RxList<Property> similarProperties = <Property>[].obs;
  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;

  // Reviews from Firebase
  RxList<Review> propertyReviews = <Review>[].obs;
  RxDouble averageRating = 0.0.obs;
  RxInt reviewCount = 0.obs;
  RxBool hasUserReviewed = false.obs;
  RxBool isLoadingReviews = false.obs;

  ScrollController scrollController = ScrollController();
  RxDouble selectedOffset = 0.0.obs;
  RxBool showBottomProperty = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Don't load property details here - wait for initializeWithPropertyId to be called
    isLoading.value = false;

    // Focus listeners
    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });
    mobileNumberController.addListener(() {
      hasPhoneNumberInput.value = mobileNumberController.text.isNotEmpty;
    });
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  // Load similar properties from Firebase
  Future<void> loadSimilarProperties(String propertyId) async {
    try {
      print('🔍 Loading similar properties for: $propertyId');
      final similarProps = await PropertyService.getSimilarProperties(propertyId, limit: 5);
      similarProperties.value = similarProps;
      isSimilarPropertyLiked.value = List<bool>.generate(similarProps.length, (index) => false);
      print('🔍 Loaded ${similarProps.length} similar properties');
    } catch (e) {
      print('❌ Error loading similar properties: $e');
      similarProperties.value = [];
      isSimilarPropertyLiked.value = [];
    }
  }

  // Load property reviews from Firebase
  Future<void> loadPropertyReviews(String propertyId) async {
    try {
      isLoadingReviews.value = true;
      print('🔍 Loading reviews for property: $propertyId');
      
      // Load reviews
      final reviews = await ReviewService.getPropertyReviews(propertyId, limit: 10);
      propertyReviews.value = reviews;
      
      // Load average rating
      final avgRating = await ReviewService.getPropertyAverageRating(propertyId);
      averageRating.value = avgRating;
      
      // Load review count
      final count = await ReviewService.getPropertyReviewCount(propertyId);
      reviewCount.value = count;
      
      // Check if user has reviewed
      final hasReviewed = await ReviewService.hasUserReviewedProperty(propertyId);
      hasUserReviewed.value = hasReviewed;
      
      print('🔍 Loaded ${reviews.length} reviews, avg rating: $avgRating, count: $count');
    } catch (e) {
      print('❌ Error loading property reviews: $e');
      propertyReviews.value = [];
      averageRating.value = 0.0;
      reviewCount.value = 0;
      hasUserReviewed.value = false;
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // Add a review
  Future<void> addReview(double rating, String comment) async {
    try {
      if (property.value == null) return;
      
      final propertyId = property.value!.id!;
      await ReviewService.addReview(
        propertyId: propertyId,
        rating: rating,
        comment: comment,
      );
      
      // Reload reviews
      await loadPropertyReviews(propertyId);
      
      Get.snackbar(
        'Review Added',
        'Your review has been submitted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error adding review: $e');
      Get.snackbar(
        'Error',
        'Failed to add review: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Initialize the controller with property ID (called when view is shown)
  void initializeWithPropertyId(String propertyId) {
    print('🔍 ShowPropertyDetailsController initializing with property ID: $propertyId');
    loadPropertyDetails(propertyId);
  }

  // Load property details from Firebase
  Future<void> loadPropertyDetails(String propertyId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Load property details
      final propertyData = await PropertyService.getPropertyById(propertyId);
      
      // Load owner contact information
      final ownerContactInfo = await PropertyService.getPropertyOwnerContactInfo(propertyId);

      if (propertyData != null) {
        property.value = propertyData;
        
        // Update owner contact information
        if (ownerContactInfo != null) {
          ownerName.value = ownerContactInfo['ownerName'] ?? '';
          ownerPhone.value = ownerContactInfo['ownerPhone'] ?? '';
          ownerAvatar.value = ownerContactInfo['ownerAvatar'] ?? '';
          
          print('🔍 Owner contact info loaded:');
          print('   Name: ${ownerName.value}');
          print('   Phone: ${ownerPhone.value}');
          print('   Avatar: ${ownerAvatar.value}');
        } else {
          print('⚠️ No owner contact info found, using defaults');
          // Set default values if no contact info found
          ownerName.value = propertyData.contactName.isNotEmpty ? propertyData.contactName : 'Property Owner';
          ownerPhone.value = propertyData.contactPhone.isNotEmpty ? propertyData.contactPhone : '';
          ownerAvatar.value = propertyData.contactAvatar.isNotEmpty ? propertyData.contactAvatar : '';
        }
        
        // Load similar properties
        await loadSimilarProperties(propertyId);
        
        // Load reviews
        await loadPropertyReviews(propertyId);
      } else {
        hasError.value = true;
        errorMessage.value = 'Property not found';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading property details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods to format property data
  String getPropertyPrice() {
    final price = property.value?.expectedPrice ?? AppString.rupees50Lakh;
    return price.startsWith('₹') ? price : '₹ $price';
  }

  String getPropertyTitle() {
    if (property.value == null) return AppString.semiModernHouse;
    return '${property.value!.noOfBedrooms} BHK ${property.value!.propertyType}';
  }

  String getPropertyAddress() {
    if (property.value == null) return AppString.northBombaySociety;
    return '${property.value!.locality}, ${property.value!.city}';
  }

  String getFullAddress() {
    if (property.value == null) return AppString.address6;
    return '${property.value!.subLocality}, ${property.value!.locality}, ${property.value!.city}';
  }

  String getPropertyDescription() {
    return property.value?.description ?? AppString.aboutPropertyString;
  }

  List<String> getPropertyImages() {
    if (property.value?.propertyPhotos.isEmpty ?? true) {
      return [Assets.images.property3.path];
    }
    return property.value!.propertyPhotos;
  }

  void toggleVisitExpansion() {
    isVisitExpanded.value = !isVisitExpanded.value;
  }

  void updateAgent(int index) {
    selectAgent.value = index;
  }

  void toggleCheckbox() {
    isChecked.toggle();
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  // Static lists for UI elements that don't change
  RxList<String> furnishingDetailsImageList = [
    Assets.images.wardrobe.path,
    Assets.images.bedSheet.path,
    Assets.images.stove.path,
    Assets.images.waterPurifier.path,
    Assets.images.fan.path,
    Assets.images.lights.path,
  ].obs;

  RxList<String> furnishingDetailsTitleList = [
    AppString.wardrobe,
    AppString.sofa,
    AppString.stove,
    AppString.waterPurifier,
    AppString.fan,
    AppString.lights,
  ].obs;

  RxList<String> interestingImageList = [
    Assets.images.read1.path,
    Assets.images.read2.path,
  ].obs;

  RxList<String> interestingTitleList = [
    AppString.readString1,
    AppString.readString2,
  ].obs;

  RxList<String> interestingDateList = [
    AppString.november23,
    AppString.october16,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.clear();
    mobileNumberController.clear();
    emailController.clear();
  }
}
