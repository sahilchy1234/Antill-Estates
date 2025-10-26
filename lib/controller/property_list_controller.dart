import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:antill_estates/services/review_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyListController extends GetxController {
  // Real property data
  RxList<Property> allProperties = <Property>[].obs;
  RxList<Property> filteredProperties = <Property>[].obs;
  RxList<Property> searchResults = <Property>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;
  bool hasSearchResults = false; // Flag to track if search results have been set
  
  // Property ratings map (propertyId -> averageRating)
  RxMap<String, double> propertyRatings = <String, double>{}.obs;

  // Constructor to accept initial search results
  PropertyListController({List<Property>? initialSearchResults}) {
    if (initialSearchResults != null) {
      hasSearchResults = true;
      searchResults.assignAll(initialSearchResults);
      filteredProperties.assignAll(initialSearchResults);
      allProperties.assignAll(initialSearchResults);
      print('✅ PropertyListController: Initialized with ${initialSearchResults.length} search results');
    }
  }

  void launchDialer(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'No Contact',
        'Contact number not available for this property',
        backgroundColor: AppColor.warningColor,
        colorText: AppColor.whiteColor,
      );
      return;
    }
    
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch dialer',
        backgroundColor: AppColor.negativeColor,
        colorText: AppColor.whiteColor,
      );
    }
  }

  RxList<String> searchImageList = [
    Assets.images.searchProperty1.path,
    Assets.images.searchProperty3.path,
    Assets.images.searchProperty4.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.semiModernHouse,
    AppString.theAcceptanceSociety,
    AppString.happinessChasers,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.address6,
    AppString.mistyAddress,
    AppString.wildermanAddress,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.lakh25,
    AppString.crore1,
  ].obs;

  RxList<String> searchRatingList = [
    AppString.rating4Point5,
    AppString.rating4Point2,
    AppString.rating4Point2,
  ].obs;

  RxList<String> searchSquareFeetList = [
    AppString.squareFeet966,
    AppString.squareFeet866,
    AppString.squareFeet1000,
  ].obs;

  RxList<String> searchSquareFeet2List = [
    AppString.squareFeet773,
    AppString.squareFeet658,
    AppString.squareFeet985,
  ].obs;

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

  @override
  void onInit() {
    super.onInit();
    
    print('🔍 PropertyListController: onInit called, hasSearchResults: $hasSearchResults');
    
    // Only load all properties if no search results have been set
    if (!hasSearchResults) {
      print('🔍 PropertyListController: No search results set, loading all properties');
      loadAllProperties();
    } else {
      print('🔍 PropertyListController: Search results already set, loading ratings');
      // Load ratings for initial search results
      loadRatingsForProperties();
    }
  }

  /// Load all active properties
  Future<void> loadAllProperties() async {
    print('🔍 PropertyListController: loadAllProperties() called');
    print('🔍 PropertyListController: hasSearchResults = $hasSearchResults');
    print('🔍 PropertyListController: searchResults.length = ${searchResults.length}');
    
    // Print stack trace to see where this is being called from
    print('🔍 Stack trace:');
    print(StackTrace.current);
    
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final properties = await PropertyService.getAllActiveProperties(limit: 50);
      allProperties.assignAll(properties);
      filteredProperties.assignAll(properties);
      searchResults.assignAll(properties);
      
      print('✅ PropertyListController: Loaded ${properties.length} properties successfully');
      
      // Load ratings for all properties
      await loadRatingsForProperties();
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load ratings for all properties
  Future<void> loadRatingsForProperties() async {
    try {
      print('🔍 Loading ratings for ${searchResults.length} properties');
      
      // Load all ratings in parallel
      final ratingFutures = searchResults.map((property) async {
        if (property.id != null && property.id!.isNotEmpty) {
          final rating = await ReviewService.getPropertyAverageRating(property.id!);
          return MapEntry(property.id!, rating);
        }
        return null;
      }).toList();
      
      final entries = await Future.wait(ratingFutures);
      final validEntries = entries.whereType<MapEntry<String, double>>().toList();
      
      // Build the map from valid entries
      propertyRatings.clear();
      for (var entry in validEntries) {
        propertyRatings[entry.key] = entry.value;
      }
      
      print('✅ Loaded ratings for ${propertyRatings.length} properties');
    } catch (e) {
      print('❌ Error loading ratings: $e');
    }
  }

  /// Get rating for a property
  double getPropertyRating(String? propertyId) {
    if (propertyId == null || propertyId.isEmpty) {
      return 0.0;
    }
    return propertyRatings[propertyId] ?? 0.0;
  }



  /// Get property at index
  Property? getPropertyAtIndex(int index) {
    if (index < searchResults.length) {
      return searchResults[index];
    }
    return null;
  }

  /// Get property count
  int get propertyCount => searchResults.length;

  /// Set search results from external source (e.g., from search view)
  Future<void> setSearchResults(List<Property> results) async {
    print('🔍 PropertyListController: Setting ${results.length} search results');
    print('🔍 PropertyListController: hasSearchResults before: $hasSearchResults');
    
    searchResults.assignAll(results);
    filteredProperties.assignAll(results);
    allProperties.assignAll(results);
    
    // Set flag to indicate search results have been provided
    hasSearchResults = true;
    
    print('🔍 PropertyListController: hasSearchResults after: $hasSearchResults');
    
    print('✅ PropertyListController: Set ${results.length} search results');
    print('✅ PropertyListController: searchResults now has ${searchResults.length} properties');
    print('✅ PropertyListController: filteredProperties now has ${filteredProperties.length} properties');
    
    // Load ratings for search results
    await loadRatingsForProperties();
  }

  /// Navigate to property details
  void navigateToPropertyDetails(String propertyId) {
    if (propertyId.isNotEmpty) {
      Get.toNamed(AppRoutes.propertyDetailsView, arguments: propertyId);
    } else {
      print('❌ Property ID is empty');
      Get.snackbar('Error', 'Property ID not available', backgroundColor: AppColor.negativeColor);
    }
  }

}
