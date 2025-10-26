import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/model/review_model.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:antill_estates/services/review_service.dart';
import 'package:antill_estates/services/cache_service.dart';
import 'package:antill_estates/services/instant_cache_service.dart';

class PropertyDetailsController extends GetxController {
  RxBool isExpanded = false.obs;
  RxInt selectAgent = 0.obs;
  RxBool isChecked = false.obs;
  RxInt selectProperty = 0.obs;
  RxBool isVisitExpanded = false.obs;
  String truncatedText = AppString.aboutPropertyString.substring(0, 200);

  // Property data
  Rx<Property?> currentProperty = Rx<Property?>(null);
  RxBool isLoading = false.obs;
  String? propertyId;
  String? heroTag;

  // Save functionality
  RxBool isPropertySaved = false.obs;
  RxBool isSaving = false.obs;

  // Owner contact information
  RxString ownerName = ''.obs;
  RxString ownerPhone = ''.obs;
  RxString ownerAvatar = ''.obs;

  // Similar properties from Firebase
  RxList<Property> similarProperties = <Property>[].obs;
  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;
  RxList<bool> isSimilarPropertySaving = <bool>[].obs;

  // Reviews from Firebase
  RxList<Review> propertyReviews = <Review>[].obs;
  RxDouble averageRating = 0.0.obs;
  RxInt reviewCount = 0.obs;
  RxBool hasUserReviewed = false.obs;
  RxBool isLoadingReviews = false.obs;

  ScrollController scrollController = ScrollController();
  RxDouble selectedOffset = 0.0.obs;
  RxBool showBottomProperty = false.obs;

  InstantCacheService? _instantCache;
  bool _isLoadingData = false;
  bool _hasLoadedRelatedData = false;
  
  @override
  void onInit() {
    super.onInit();
    
    // Safely get InstantCacheService
    if (Get.isRegistered<InstantCacheService>()) {
      _instantCache = Get.find<InstantCacheService>();
    }
    
    // Handle both old (String) and new (Map) argument formats
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      propertyId = args['propertyId'] as String?;
      heroTag = args['heroTag'] as String?;
    } else if (args is String) {
      propertyId = args;
      heroTag = 'property-$propertyId';
    }
    
    if (propertyId == null || propertyId!.isEmpty) {
      isLoading.value = false;
      return;
    }
    
    // INSTANT: Load from memory cache (0ms!)
    final cached = _instantCache?.getProperty(propertyId!);
    if (cached != null) {
      currentProperty.value = cached;
      isLoading.value = false;
      // Load save status immediately for cached properties
      loadSaveStatus(propertyId!);
      // Don't load fresh data immediately - wait for onReady
    } else {
      // Try disk cache
      _loadFromDiskCache();
    }
  }
  
  @override
  void onReady() {
    super.onReady();
    
    // Delay to let transition complete smoothly
    Future.delayed(const Duration(milliseconds: 300), () {
      if (propertyId != null && propertyId!.isNotEmpty) {
        // Load fresh data if from cache
        if (currentProperty.value != null && !_isLoadingData) {
          _loadFreshData();
        }
        
        // Load related data after another small delay
        Future.delayed(const Duration(milliseconds: 200), () {
          if (currentProperty.value != null && !_hasLoadedRelatedData) {
            _hasLoadedRelatedData = true;
            _loadRelatedData();
          }
        });
      }
    });
  }
  
  /// Load from disk cache instantly
  void _loadFromDiskCache() {
    try {
      if (!Get.isRegistered<CacheService>()) {
        isLoading.value = true;
        return;
      }
      
      final cacheService = Get.find<CacheService>();
      final cachedProperty = cacheService.getCachedProperty(propertyId!);
      
      if (cachedProperty != null) {
        final property = Property.fromJson(cachedProperty);
        currentProperty.value = property;
        _instantCache?.setProperty(propertyId!, property);
        isLoading.value = false;
        // Load save status immediately for disk cached properties
        loadSaveStatus(propertyId!);
        // Fresh data will be loaded in onReady
      } else {
        // No cache, load fresh data immediately
        isLoading.value = true;
        _loadFreshData();
      }
    } catch (e) {
      isLoading.value = true;
      _loadFreshData();
    }
  }
  
  /// Load fresh data in background
  Future<void> _loadFreshData() async {
    if (propertyId == null || _isLoadingData) return;
    
    _isLoadingData = true;
    
    try {
      await loadPropertyData();
    } catch (e) {
      if (currentProperty.value == null) {
        isLoading.value = false;
      }
    } finally {
      _isLoadingData = false;
    }
  }
  
  /// Load related data (similar, reviews, etc.) - Staggered for smooth performance
  Future<void> _loadRelatedData() async {
    if (propertyId == null || _hasLoadedRelatedData) return;
    
    try {
      // Load save status first (quick)
      await loadSaveStatus(propertyId!);
      
      // Delay before heavy operations
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Load reviews and similar properties in parallel
      await Future.wait([
        loadPropertyReviews(propertyId!),
        loadSimilarProperties(propertyId!),
      ]);
    } catch (e) {
      // Silent fail
    }
  }

  /// Load property data by ID - FAST with instant memory caching
  Future<void> loadPropertyData() async {
    if (propertyId == null) return;
    
    try {
        final property = await PropertyService.getPropertyById(propertyId!);
        if (property != null) {
          currentProperty.value = property;

          // Store in INSTANT memory cache
          _instantCache?.setProperty(propertyId!, property);
          
          // Load save status immediately for fresh data
          loadSaveStatus(propertyId!);
        
        // Cache to disk in background
        if (Get.isRegistered<CacheService>()) {
          Get.find<CacheService>().cacheProperty(propertyId!, property.toJson()).catchError((_) => false);
        }
        
        // Load owner contact info
        PropertyService.getPropertyOwnerContactInfo(propertyId!).then((info) {
          if (info != null) {
            ownerName.value = info['ownerName'] ?? '';
            ownerPhone.value = info['ownerPhone'] ?? '';
            ownerAvatar.value = info['ownerAvatar'] ?? '';
          } else {
            ownerName.value = property.contactName.isNotEmpty ? property.contactName : 'Property Owner';
            ownerPhone.value = property.contactPhone.isNotEmpty ? property.contactPhone : '';
            ownerAvatar.value = property.contactAvatar.isNotEmpty ? property.contactAvatar : '';
          }
        }).catchError((_) => null);
      }
    } catch (e) {
      if (currentProperty.value == null) {
        Get.snackbar('Error', 'Failed to load property');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Load similar properties from Firebase - OPTIMIZED with BATCH save status loading
  Future<void> loadSimilarProperties(String propertyId) async {
    try {
      print('🔍 Loading similar properties for: $propertyId');
      final similarProps = await PropertyService.getSimilarProperties(propertyId, limit: 5);
      similarProperties.value = similarProps;
      
      // Extract property IDs
      final propertyIds = similarProps
          .where((p) => p.id != null)
          .map((p) => p.id!)
          .toList();
      
      if (propertyIds.isEmpty) {
        isSimilarPropertyLiked.value = [];
        isSimilarPropertySaving.value = [];
        return;
      }
      
      // BATCH check all at once - MUCH faster!
      final saveStatusMap = await PropertyService.arePropertiesSaved(propertyIds);
      
      // Map back to list
      final saveStatuses = similarProps.map((property) {
        if (property.id != null) {
          return saveStatusMap[property.id!] ?? false;
        }
        return false;
      }).toList();
      
      isSimilarPropertyLiked.value = saveStatuses;
      isSimilarPropertySaving.value = List<bool>.generate(similarProps.length, (index) => false);
      
      print('🔍 Loaded ${similarProps.length} similar properties with save status via BATCH');
    } catch (e) {
      print('❌ Error loading similar properties: $e');
      similarProperties.value = [];
      isSimilarPropertyLiked.value = [];
      isSimilarPropertySaving.value = [];
    }
  }

  // Load property reviews from Firebase - OPTIMIZED with parallel loading
  Future<void> loadPropertyReviews(String propertyId) async {
    try {
      isLoadingReviews.value = true;
      print('🔍 Loading reviews for property: $propertyId');
      
      // Load all review-related data in parallel
      final results = await Future.wait([
        ReviewService.getPropertyReviews(propertyId, limit: 10),
        ReviewService.getPropertyAverageRating(propertyId),
        ReviewService.getPropertyReviewCount(propertyId),
        ReviewService.hasUserReviewedProperty(propertyId),
      ]);
      
      propertyReviews.value = results[0] as List<Review>;
      averageRating.value = results[1] as double;
      reviewCount.value = results[2] as int;
      hasUserReviewed.value = results[3] as bool;
      
      print('🔍 Loaded ${propertyReviews.length} reviews in parallel, avg rating: ${averageRating.value}, count: ${reviewCount.value}');
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

  // Add or update a review
  Future<void> addOrUpdateReview(double rating, String comment) async {
    try {
      if (currentProperty.value == null || propertyId == null) return;
      
      await ReviewService.addOrUpdateReview(
        propertyId: propertyId!,
        rating: rating,
        comment: comment,
      );
      
      // Reload reviews
      await loadPropertyReviews(propertyId!);
      
      Get.snackbar(
        hasUserReviewed.value ? 'Review Updated' : 'Review Added',
        hasUserReviewed.value 
          ? 'Your review has been updated successfully'
          : 'Your review has been submitted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error adding/updating review: $e');
      Get.snackbar(
        'Error',
        'Failed to ${hasUserReviewed.value ? 'update' : 'add'} review: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Add a review (legacy method - kept for backward compatibility)
  Future<void> addReview(double rating, String comment) async {
    return addOrUpdateReview(rating, comment);
  }

  // Delete user's review for this property
  Future<void> deleteUserReview() async {
    try {
      if (currentProperty.value == null || propertyId == null) return;
      
      await ReviewService.deleteUserReviewForProperty(propertyId!);
      
      // Reload reviews
      await loadPropertyReviews(propertyId!);
      
      Get.snackbar(
        'Review Deleted',
        'Your review has been deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error deleting review: $e');
      Get.snackbar(
        'Error',
        'Failed to delete review: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Load save status for the current property
  Future<void> loadSaveStatus(String propertyId) async {
    try {
      print('🔍 Loading save status for property: $propertyId');
      final saved = await PropertyService.isPropertySaved(propertyId);
      isPropertySaved.value = saved;
      print('🔍 Property save status: $saved');
    } catch (e) {
      print('❌ Error loading save status: $e');
      isPropertySaved.value = false;
    }
  }

  // Toggle save status of the current property
  Future<void> toggleSaveProperty() async {
    if (currentProperty.value == null || propertyId == null) return;
    
    try {
      isSaving.value = true;
      print('🔍 Toggling save status for property: $propertyId');
      
      final newSaveStatus = await PropertyService.toggleSaveProperty(propertyId!);
      isPropertySaved.value = newSaveStatus;
      
      Get.snackbar(
        newSaveStatus ? 'Property Saved' : 'Property Removed',
        newSaveStatus 
          ? 'Property has been saved to your favorites'
          : 'Property has been removed from your favorites',
        backgroundColor: newSaveStatus ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
      
      print('✅ Save status toggled: $newSaveStatus');
    } catch (e) {
      print('❌ Error toggling save status: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isPropertySaved.value ? 'remove' : 'save'} property: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Toggle save status for similar property
  Future<void> toggleSimilarPropertySave(int index) async {
    if (index >= similarProperties.length) return;
    
    final property = similarProperties[index];
    if (property.id == null) return;

    try {
      // Set loading state for this specific property
      if (index < isSimilarPropertySaving.length) {
        isSimilarPropertySaving[index] = true;
      }
      
      final newSaveStatus = await PropertyService.toggleSaveProperty(property.id!);
      isSimilarPropertyLiked[index] = newSaveStatus;
      
      Get.snackbar(
        newSaveStatus ? 'Property Saved' : 'Property Removed',
        newSaveStatus 
          ? 'Property has been saved to your favorites'
          : 'Property has been removed from your favorites',
        backgroundColor: newSaveStatus ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error toggling similar property save: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isSimilarPropertyLiked[index] ? 'remove' : 'save'} property: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Clear loading state
      if (index < isSimilarPropertySaving.length) {
        isSimilarPropertySaving[index] = false;
      }
    }
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

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point2,
    AppString.bhk2,
  ].obs;

  RxList<String> searchProperty2ImageList = [
    Assets.images.plot.path,
    Assets.images.indianRupee.path,
  ].obs;

  RxList<String> searchProperty2TitleList = [
    AppString.squareFeet966,
    AppString.rupee3252,
  ].obs;

  RxList<String> keyHighlightsTitleList = [
    AppString.parkingAvailable,
    AppString.poojaRoomAvailable,
    AppString.semiFurnishedText,
    AppString.balconies1,
  ].obs;

  RxList<String> propertyDetailsTitleList = [
    AppString.layout,
    AppString.ownerShip,
    AppString.superArea,
    AppString.overlooking,
    AppString.widthOfFacingRoad,
    AppString.flooring,
    AppString.waterSource,
    AppString.furnishing,
    AppString.facing,
    AppString.propertyId,
  ].obs;

  RxList<String> propertyDetailsSubTitleList = [
    AppString.bhk3PoojaRoom,
    AppString.freehold,
    AppString.square785,
    AppString.parkMainRoad,
    AppString.feet60,
    AppString.vitrified,
    AppString.municipalCorporation,
    AppString.semiFurnished,
    AppString.west,
    AppString.propertyIdNumber,
  ].obs;

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

  RxList<String> facilitiesImageList = [
    Assets.images.privateGarden.path,
    Assets.images.reservedParking.path,
    Assets.images.rainWater.path,
  ].obs;

  RxList<String> facilitiesTitleList = [
    AppString.privateGarden,
    AppString.reservedParking,
    AppString.rainWaterHarvesting,
  ].obs;

  RxList<String> dayList = [
    AppString.mondayText,
    AppString.tuesdayText,
    AppString.wednesdayText,
    AppString.thursdayText,
    AppString.fridayText,
    AppString.saturdayText,
    AppString.sundayText,
  ].obs;

  RxList<String> timingList = [
    AppString.timing1012,
    AppString.timing1012,
    AppString.timing1012,
    AppString.timing1012,
    AppString.timing1012,
    AppString.timing1012,
    AppString.close,
  ].obs;

  RxList<String> realEstateList = [
    AppString.yes,
    AppString.no,
  ].obs;

  RxList<String> reviewDateList = [
    AppString.november13,
    AppString.december13,
    AppString.may22,
  ].obs;

  RxList<String> reviewRatingImageList = [
    Assets.images.rating4.path,
    Assets.images.rating3.path,
    Assets.images.rating5.path,
  ].obs;

  RxList<String> reviewProfileList = [
    Assets.images.dh.path,
    Assets.images.da.path,
    Assets.images.mm.path,
  ].obs;

  RxList<String> reviewProfileNameList = [
    AppString.dorothyHowe,
    AppString.douglasAnderson,
    AppString.mamieMonahan,
  ].obs;

  RxList<String> reviewTypeList = [
    AppString.buyer,
    AppString.seller,
    AppString.seller,
  ].obs;

  RxList<String> reviewDescriptionList = [
    AppString.dorothyHoweString,
    AppString.douglasAndersonString,
    AppString.mamieMonahanString,
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.alexaneFranecki.path,
    Assets.images.searchProperty5.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.alexane,
    AppString.happinessChasers,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.baumbachLakes,
    AppString.wildermanAddress,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.crore1,
  ].obs;

  RxList<String> searchRatingList = [
    AppString.rating4Point5,
    AppString.rating4Point2,
  ].obs;

  RxList<String> similarPropertyTitleList = [
    AppString.point2,
    AppString.point1,
    AppString.squareMeter256,
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

  RxList<String> propertyList = [
    AppString.overview,
    AppString.highlights,
    AppString.propertyDetails,
    AppString.photos,
    AppString.about,
    AppString.owner,
    AppString.articles,
  ].obs;

  @override
  void dispose() {
    super.dispose();
  }
}
