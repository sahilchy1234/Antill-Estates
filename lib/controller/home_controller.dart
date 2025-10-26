import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/services/home_data_service.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:antill_estates/services/review_service.dart';
import 'package:antill_estates/services/cache_service.dart';
import 'package:antill_estates/services/instant_cache_service.dart';

class HomeController extends GetxController {
  InstantCacheService? _instantCache;
  
  TextEditingController searchController = TextEditingController();
  RxInt selectProperty = 0.obs;
  RxInt selectCountry = 0.obs;
  RxList<bool> isTrendPropertyLiked = <bool>[].obs;

  // Firebase data observables
  RxList<Property> recommendedProperties = <Property>[].obs;
  RxList<Property> trendingProperties = <Property>[].obs;
  // Removed: Rx<Property?> userListing = Rx<Property?>(null); - Your Listing functionality disabled
  RxList<Map<String, dynamic>> upcomingProjects = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> popularCities = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  // Save functionality
  RxList<bool> isRecommendedPropertyLiked = <bool>[].obs;
  RxList<bool> isTrendingPropertySaving = <bool>[].obs;
  RxList<bool> isRecommendedPropertySaving = <bool>[].obs;

  // Rating functionality
  RxList<double> trendingPropertyRatings = <double>[].obs;
  RxList<double> recommendedPropertyRatings = <double>[].obs;

  void updateProperty(int index) {
    selectProperty.value = index;
    
    // Navigate based on property type selection
    switch (index) {
      case 0: // Buy
        _navigateToPropertySearch('buy');
        break;
      case 1: // Rent
        _navigateToPropertySearch('rent');
        break;
      case 2: // Plot/Land
        _navigateToPropertySearch('plot');
        break;
      case 3: // PG
        _navigateToPropertySearch('pg');
        break;
      case 4: // Co-working Space
        _navigateToPropertySearch('coworking');
        break;
      case 5: // By Commercial
        _navigateToPropertySearch('commercial_buy');
        break;
      case 6: // Lease Commercial
        _navigateToPropertySearch('commercial_lease');
        break;
      case 7: // Post a Property
        Get.toNamed('/post_property_view');
        break;
    }
  }

  void _navigateToPropertySearch(String propertyType) {
    // Navigate to search view with property type filter
    Get.toNamed('/search_view', arguments: {
      'propertyType': propertyType,
      'selectedPropertyIndex': selectProperty.value,
    });
  }

  void updateCountry(int index) {
    selectCountry.value = index;
  }

  /// Load all Firebase data for home screen
  Future<void> loadHomeData({bool showLoading = true}) async {
    try {
      // Initialize InstantCacheService if not already initialized
      if (_instantCache == null && Get.isRegistered<InstantCacheService>()) {
        _instantCache = Get.find<InstantCacheService>();
      }
      
      // Only check cache service if it's registered
      bool hasCache = false;
      try {
        if (Get.isRegistered<CacheService>()) {
          final cacheService = Get.find<CacheService>();
          
          // Try to load from cache first for instant display
          final cachedData = cacheService.getPreCachedHomeData();
          if (cachedData != null) {
            _loadFromCache(cachedData);
            hasCache = true;
            print('✅ Loaded home data from cache');
          }
        }
      } catch (e) {
        print('⚠️ Cache load failed, loading fresh data: $e');
      }
      
      // Only show loading if explicitly requested and no cached data exists
      if (showLoading && !hasCache && !hasCachedData()) {
        isLoading.value = true;
      }
      
      // Always fetch fresh data (in background if cache exists)
      print('🔄 Fetching fresh home data from Firebase...');
      final futures = await Future.wait([
        HomeDataService.getRecommendedProperties(limit: 6),
        HomeDataService.getTrendingProperties(limit: 3),
        // Removed: HomeDataService.getUserListing(), - Your Listing functionality disabled
        // Removed: HomeDataService.getRecentResponses(limit: 4), - Recent Response section removed
        // Removed: HomeDataService.getPopularBuilders(limit: 6), - Popular Builders section removed
        HomeDataService.getUpcomingProjects(limit: 3),
        HomeDataService.getPopularCities(limit: 7),
      ]);

      // Update observables with fetched data
      recommendedProperties.value = futures[0] as List<Property>;
      trendingProperties.value = futures[1] as List<Property>;
      
      // Store ALL properties in INSTANT memory cache
      for (final property in recommendedProperties) {
        if (property.id != null) {
          _instantCache?.setProperty(property.id!, property);
        }
      }
      for (final property in trendingProperties) {
        if (property.id != null) {
          _instantCache?.setProperty(property.id!, property);
        }
      }
      
      print('✅ Fresh home data loaded: ${recommendedProperties.length} recommended, ${trendingProperties.length} trending');
      
      // Cache the new data for next time
      try {
        if (Get.isRegistered<CacheService>()) {
          await _cacheHomeData(futures);
          print('✅ Home data cached for next load');
        }
      } catch (e) {
        print('⚠️ Cache save failed: $e');
      }
      // Removed: userListing.value = futures[2] as Property?; - Your Listing functionality disabled
      upcomingProjects.value = futures[2] as List<Map<String, dynamic>>;
      popularCities.value = futures[3] as List<Map<String, dynamic>>;

      // Load save status and ratings in parallel for MUCH faster loading
      await Future.wait([
        _loadSaveStatusForTrendingProperties(),
        _loadSaveStatusForRecommendedProperties(),
        _loadRatingsForTrendingProperties(),
        _loadRatingsForRecommendedProperties(),
      ]);
      
      print('✅ Save status and ratings loaded in parallel');

      // Pre-cache property details IMMEDIATELY for instant clicks
      _preCacheVisibleProperties();

      print('✅ Home data loaded successfully');
    } catch (e) {
      print('❌ Error loading home data: $e');
      if (showLoading) {
        Get.snackbar('Error', 'Failed to load home data');
      }
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// Check if we have cached data to show instantly
  bool hasCachedData() {
    return recommendedProperties.isNotEmpty || 
           trendingProperties.isNotEmpty || 
           // Removed: userListing.value != null || - Your Listing functionality disabled
           upcomingProjects.isNotEmpty ||
           popularCities.isNotEmpty;
  }

  /// Refresh home data
  Future<void> refreshHomeData() async {
    await loadHomeData(showLoading: false);
  }

  /// Load data in background without showing loading indicator
  Future<void> loadHomeDataInBackground() async {
    await loadHomeData(showLoading: false);
  }

  /// Load save status for trending properties - OPTIMIZED with BATCH loading
  Future<void> _loadSaveStatusForTrendingProperties() async {
    try {
      // Extract property IDs
      final propertyIds = trendingProperties
          .where((p) => p.id != null)
          .map((p) => p.id!)
          .toList();
      
      if (propertyIds.isEmpty) {
        isTrendPropertyLiked.value = List<bool>.generate(trendingProperties.length, (index) => false);
        isTrendingPropertySaving.value = List<bool>.generate(trendingProperties.length, (index) => false);
        return;
      }
      
      // BATCH check all at once - MUCH faster!
      final saveStatusMap = await PropertyService.arePropertiesSaved(propertyIds);
      
      // Map back to list
      final saveStatuses = trendingProperties.map((property) {
        if (property.id != null) {
          return saveStatusMap[property.id!] ?? false;
        }
        return false;
      }).toList();
      
      isTrendPropertyLiked.value = saveStatuses;
      isTrendingPropertySaving.value = List<bool>.generate(trendingProperties.length, (index) => false);
      
      print('✅ Loaded save status for ${trendingProperties.length} trending properties via BATCH');
    } catch (e) {
      print('❌ Error loading save status for trending properties: $e');
      isTrendPropertyLiked.value = List<bool>.generate(trendingProperties.length, (index) => false);
      isTrendingPropertySaving.value = List<bool>.generate(trendingProperties.length, (index) => false);
    }
  }

  /// Load save status for recommended properties - OPTIMIZED with BATCH loading
  Future<void> _loadSaveStatusForRecommendedProperties() async {
    try {
      // Extract property IDs
      final propertyIds = recommendedProperties
          .where((p) => p.id != null)
          .map((p) => p.id!)
          .toList();
      
      if (propertyIds.isEmpty) {
        isRecommendedPropertyLiked.value = List<bool>.generate(recommendedProperties.length, (index) => false);
        isRecommendedPropertySaving.value = List<bool>.generate(recommendedProperties.length, (index) => false);
        return;
      }
      
      // BATCH check all at once - MUCH faster!
      final saveStatusMap = await PropertyService.arePropertiesSaved(propertyIds);
      
      // Map back to list
      final saveStatuses = recommendedProperties.map((property) {
        if (property.id != null) {
          return saveStatusMap[property.id!] ?? false;
        }
        return false;
      }).toList();
      
      isRecommendedPropertyLiked.value = saveStatuses;
      isRecommendedPropertySaving.value = List<bool>.generate(recommendedProperties.length, (index) => false);
      
      print('✅ Loaded save status for ${recommendedProperties.length} recommended properties via BATCH');
    } catch (e) {
      print('❌ Error loading save status for recommended properties: $e');
      isRecommendedPropertyLiked.value = List<bool>.generate(recommendedProperties.length, (index) => false);
      isRecommendedPropertySaving.value = List<bool>.generate(recommendedProperties.length, (index) => false);
    }
  }

  /// Toggle save status for trending property
  Future<void> toggleTrendingPropertySave(int index) async {
    if (index >= trendingProperties.length) return;
    
    final property = trendingProperties[index];
    if (property.id == null) return;

    try {
      // Set loading state for this specific property
      if (index < isTrendingPropertySaving.length) {
        isTrendingPropertySaving[index] = true;
      }
      
      final newSaveStatus = await PropertyService.toggleSaveProperty(property.id!);
      isTrendPropertyLiked[index] = newSaveStatus;
      
      // Synchronize with recommended properties if the same property exists there
      _syncPropertySaveState(property.id!, newSaveStatus);
      
      Get.snackbar(
        newSaveStatus ? 'Property Saved' : 'Property Removed',
        newSaveStatus 
          ? 'Property has been saved to your favorites'
          : 'Property has been removed from your favorites',
        backgroundColor: newSaveStatus ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error toggling trending property save: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isTrendPropertyLiked[index] ? 'remove' : 'save'} property: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Clear loading state
      if (index < isTrendingPropertySaving.length) {
        isTrendingPropertySaving[index] = false;
      }
    }
  }

  /// Toggle save status for recommended property
  Future<void> toggleRecommendedPropertySave(int index) async {
    if (index >= recommendedProperties.length) return;
    
    final property = recommendedProperties[index];
    if (property.id == null) return;

    try {
      // Set loading state for this specific property
      if (index < isRecommendedPropertySaving.length) {
        isRecommendedPropertySaving[index] = true;
      }
      
      final newSaveStatus = await PropertyService.toggleSaveProperty(property.id!);
      isRecommendedPropertyLiked[index] = newSaveStatus;
      
      // Synchronize with trending properties if the same property exists there
      _syncPropertySaveState(property.id!, newSaveStatus);
      
      Get.snackbar(
        newSaveStatus ? 'Property Saved' : 'Property Removed',
        newSaveStatus 
          ? 'Property has been saved to your favorites'
          : 'Property has been removed from your favorites',
        backgroundColor: newSaveStatus ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error toggling recommended property save: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isRecommendedPropertyLiked[index] ? 'remove' : 'save'} property: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Clear loading state
      if (index < isRecommendedPropertySaving.length) {
        isRecommendedPropertySaving[index] = false;
      }
    }
  }

  /// Synchronize save state between recommended and trending properties
  void _syncPropertySaveState(String propertyId, bool newSaveStatus) {
    // Update recommended properties if the same property exists there
    for (int i = 0; i < recommendedProperties.length; i++) {
      if (recommendedProperties[i].id == propertyId) {
        isRecommendedPropertyLiked[i] = newSaveStatus;
        break;
      }
    }
    
    // Update trending properties if the same property exists there
    for (int i = 0; i < trendingProperties.length; i++) {
      if (trendingProperties[i].id == propertyId) {
        isTrendPropertyLiked[i] = newSaveStatus;
        break;
      }
    }
  }

  /// Load ratings for trending properties - OPTIMIZED with parallel loading
  Future<void> _loadRatingsForTrendingProperties() async {
    try {
      // Load all ratings in parallel instead of sequentially
      final ratingFutures = trendingProperties.map((property) {
        if (property.id != null) {
          return ReviewService.getPropertyAverageRating(property.id!);
        }
        return Future.value(0.0);
      }).toList();
      
      final ratings = await Future.wait(ratingFutures);
      trendingPropertyRatings.value = ratings;
    } catch (e) {
      print('❌ Error loading ratings for trending properties: $e');
      trendingPropertyRatings.value = List<double>.generate(trendingProperties.length, (index) => 0.0);
    }
  }

  /// Load ratings for recommended properties - OPTIMIZED with parallel loading
  Future<void> _loadRatingsForRecommendedProperties() async {
    try {
      // Load all ratings in parallel instead of sequentially
      final ratingFutures = recommendedProperties.map((property) {
        if (property.id != null) {
          return ReviewService.getPropertyAverageRating(property.id!);
        }
        return Future.value(0.0);
      }).toList();
      
      final ratings = await Future.wait(ratingFutures);
      recommendedPropertyRatings.value = ratings;
    } catch (e) {
      print('❌ Error loading ratings for recommended properties: $e');
      recommendedPropertyRatings.value = List<double>.generate(recommendedProperties.length, (index) => 0.0);
    }
  }

  RxList<String> propertyOptionList = [
    AppString.buy,
    AppString.rent,
    AppString.plotLand,
    AppString.pg,
    AppString.coWorkingSpace,
    AppString.byCommercial,
    AppString.leaseCommercial,
    // AppString.postAProperty,
  ].obs;

  RxList<String> countryOptionList = [
    AppString.westernMumbai,
    AppString.switzerland,
    AppString.nepal,
    AppString.exploreNew,
  ].obs;

  RxList<String> projectImageList = [
    Assets.images.project1.path,
    Assets.images.project2.path,
    Assets.images.project1.path,
  ].obs;

  RxList<String> projectPriceList = [
    AppString.rupees4Cr,
    AppString.priceOnRequest,
    AppString.priceOnRequest,
  ].obs;

  RxList<String> projectTitleList = [
    AppString.residentialApart,
    AppString.residentialApart2,
    AppString.plot2000ft,
  ].obs;

  RxList<String> projectAddressList = [
    AppString.address1,
    AppString.address2,
    AppString.address3,
  ].obs;

  RxList<String> projectTimingList = [
    AppString.days2Ago,
    AppString.month2Ago,
    AppString.month2Ago,
  ].obs;

  RxList<String> project2ImageList = [
    Assets.images.project3.path,
    Assets.images.project4.path,
    Assets.images.project3.path,
  ].obs;

  RxList<String> project2PriceList = [
    AppString.rupees2Cr,
    AppString.rupees5Cr,
    AppString.rupees2Cr,
  ].obs;

  RxList<String> project2TitleList = [
    AppString.residentialApart,
    AppString.plot2000ft,
    AppString.residentialApart,
  ].obs;

  RxList<String> project2AddressList = [
    AppString.address4,
    AppString.address5,
    AppString.address4,
  ].obs;

  RxList<String> project2TimingList = [
    AppString.days2Ago,
    AppString.month2Ago,
    AppString.days2Ago,
  ].obs;

  RxList<String> responseImageList = [
    Assets.images.response1.path,
    Assets.images.response2.path,
    Assets.images.response3.path,
    Assets.images.response4.path,
  ].obs;

  RxList<String> responseNameList = [
    AppString.rudraProperties,
    AppString.claudeAnderson,
    AppString.rohitBhati,
    AppString.heerKher,
  ].obs;

  RxList<String> responseTimingList = [
    AppString.today,
    AppString.today,
    AppString.yesterday,
    AppString.days4Ago,
  ].obs;

  RxList<String> responseEmailList = [
    AppString.rudraEmail,
    AppString.rudraEmail,
    AppString.rudraEmail,
    AppString.heerEmail,
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.searchProperty1.path,
    Assets.images.searchProperty2.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.semiModernHouse,
    AppString.modernHouse,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.address6,
    AppString.address7,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.rupees22Lakh,
  ].obs;

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point1,
    AppString.sq456,
  ].obs;

  RxList<String> popularBuilderImageList = [
    Assets.images.builder1.path,
    Assets.images.builder2.path,
    Assets.images.builder3.path,
    Assets.images.builder4.path,
    Assets.images.builder5.path,
    Assets.images.builder6.path,
  ].obs;

  RxList<String> popularBuilderTitleList = [
    AppString.sobhaDevelopers,
    AppString.kalpataru,
    AppString.godrej,
    AppString.unitech,
    AppString.casagrand,
    AppString.brigade,
  ].obs;

  RxList<String> upcomingProjectImageList = [
    Assets.images.upcomingProject1.path,
    Assets.images.upcomingProject2.path,
    Assets.images.upcomingProject3.path,
  ].obs;

  RxList<String> upcomingProjectTitleList = [
    AppString.luxuryVilla,
    AppString.shreenathjiResidency,
    AppString.pramukhDevelopersSurat,
  ].obs;

  RxList<String> upcomingProjectAddressList = [
    AppString.address8,
    AppString.address9,
    AppString.address10,
  ].obs;

  RxList<String> upcomingProjectFlatSizeList = [
    AppString.bhk3Apartment,
    AppString.bhk4Apartment,
    AppString.bhk5Apartment,
  ].obs;

  RxList<String> upcomingProjectPriceList = [
    AppString.lakh45,
    AppString.lakh85,
    AppString.lakh85,
  ].obs;

  RxList<String> popularCityImageList = [
    Assets.images.city1.path,
    Assets.images.city2.path,
    Assets.images.city3.path,
    Assets.images.city4.path,
    Assets.images.city5.path,
    Assets.images.city6.path,
    Assets.images.city7.path,
  ].obs;

  RxList<String> popularCityTitleList = [
    AppString.mumbai,
    AppString.newDelhi,
    AppString.gurgaon,
    AppString.noida,
    AppString.bangalore,
    AppString.ahmedabad,
    AppString.kolkata,
  ].obs;

  /// Cache home data for fast loading
  Future<void> _cacheHomeData(List<dynamic> futures) async {
    try {
      final cacheService = Get.find<CacheService>();
      
      final homeData = {
        'recommendedProperties': futures[0] is List<Property>
            ? (futures[0] as List<Property>).map((p) => p.toJson()).toList()
            : [],
        'trendingProperties': futures[1] is List<Property>
            ? (futures[1] as List<Property>).map((p) => p.toJson()).toList()
            : [],
        'upcomingProjects': futures[2],
        'popularCities': futures[3],
        'cachedAt': DateTime.now().toIso8601String(),
      };
      
      await cacheService.preCacheHomeData(homeData);
    } catch (e) {
      print('Error caching home data: $e');
    }
  }
  
  /// Load home data from cache
  void _loadFromCache(Map<String, dynamic> cachedData) {
    try {
      if (cachedData['recommendedProperties'] != null) {
        recommendedProperties.value = (cachedData['recommendedProperties'] as List)
            .map((json) => Property.fromJson(json))
            .toList();
      }
      
      if (cachedData['trendingProperties'] != null) {
        trendingProperties.value = (cachedData['trendingProperties'] as List)
            .map((json) => Property.fromJson(json))
            .toList();
      }
      
      if (cachedData['upcomingProjects'] != null) {
        upcomingProjects.value = List<Map<String, dynamic>>.from(cachedData['upcomingProjects']);
      }
      
      if (cachedData['popularCities'] != null) {
        popularCities.value = List<Map<String, dynamic>>.from(cachedData['popularCities']);
      }
      
      // Initialize liked/saving states
      _initializeLikedStates();
    } catch (e) {
      print('Error loading from cache: $e');
    }
  }
  
  /// Initialize liked/saving states for properties
  void _initializeLikedStates() {
    if (recommendedProperties.isNotEmpty) {
      isRecommendedPropertyLiked.value = List<bool>.generate(
        recommendedProperties.length,
        (index) => false,
      );
      isRecommendedPropertySaving.value = List<bool>.generate(
        recommendedProperties.length,
        (index) => false,
      );
      recommendedPropertyRatings.value = List<double>.generate(
        recommendedProperties.length,
        (index) => 0.0,
      );
    }
    
    if (trendingProperties.isNotEmpty) {
      isTrendPropertyLiked.value = List<bool>.generate(
        trendingProperties.length,
        (index) => false,
      );
      isTrendingPropertySaving.value = List<bool>.generate(
        trendingProperties.length,
        (index) => false,
      );
      trendingPropertyRatings.value = List<double>.generate(
        trendingProperties.length,
        (index) => 0.0,
      );
    }
  }

  /// Pre-cache all visible properties for instant YouTube-style navigation
  void _preCacheVisibleProperties() {
    try {
      // Aggressive: Cache everything ASAP for instant navigation
      final propertyIds = <String>[];
      final imageUrls = <String>[];
      
      for (final property in recommendedProperties) {
        if (property.id != null && property.id!.isNotEmpty) {
          propertyIds.add(property.id!);
          if (property.propertyPhotos.isNotEmpty) {
            imageUrls.add(property.propertyPhotos.first);
          }
        }
      }
      
      for (final property in trendingProperties) {
        if (property.id != null && property.id!.isNotEmpty) {
          propertyIds.add(property.id!);
          if (property.propertyPhotos.isNotEmpty) {
            imageUrls.add(property.propertyPhotos.first);
          }
        }
      }
      
      if (propertyIds.isEmpty) return;
      
      // Pre-cache images FIRST (most important for visual smoothness)
      if (Get.context != null) {
        for (final url in imageUrls) {
          if (url.startsWith('http')) {
            precacheImage(NetworkImage(url), Get.context!).catchError((_) {});
          }
        }
      }
      
      // Then cache property data
      for (final id in propertyIds) {
        preCachePropertyDetails(id);
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Pre-cache property details AND images - INSTANT with memory cache
  Future<void> preCachePropertyDetails(String propertyId) async {
    try {
      // Check instant cache first
      if (_instantCache?.hasProperty(propertyId) == true) return;
      
      // Fetch property
      final property = await PropertyService.getPropertyById(propertyId);
      if (property != null) {
        // Store in INSTANT memory cache
        _instantCache?.setProperty(propertyId, property);
        
        // Store in disk cache (background)
        if (Get.isRegistered<CacheService>()) {
          Get.find<CacheService>().cacheProperty(propertyId, property.toJson()).catchError((_) => false);
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }
}
