import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:antill_estates/services/cache_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedPropertiesController extends GetxController {
  RxInt selectSavedTab = 0.obs; // 0 = Properties, 1 = Arts & Antiques

  // Saved Properties
  RxList<Property> savedProperties = <Property>[].obs;
  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;
  RxBool isLoadingProperties = false.obs;

  // Saved Arts & Antiques
  RxList<Map<String, dynamic>> savedArtsAntiques = <Map<String, dynamic>>[].obs;
  RxList<bool> isArtsAntiquesLiked = <bool>[].obs;
  RxBool isLoadingArtsAntiques = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load cached data instantly if available
    loadCachedDataSync();
    // Then load fresh data; only show loading if nothing cached
    loadSavedProperties(showLoading: !hasCachedData());
    loadSavedArtsAntiques(showLoading: !hasCachedData());
  }

  void updateSavedTab(int index) {
    selectSavedTab.value = index;
  }

  // ==================== SAVED PROPERTIES ====================

  // Load saved properties from Firebase
  Future<void> loadSavedProperties({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoadingProperties.value = true;
      }
      print('🔍 Loading saved properties');
      
      final properties = await PropertyService.getSavedProperties();
      savedProperties.value = properties;
      
      // Initialize liked status for each property
      isSimilarPropertyLiked.value = List<bool>.generate(properties.length, (index) => true);
      
      // Cache results for instant next load
      try {
        final cacheService = Get.find<CacheService>();
        await cacheService.saveJsonList(
          'saved_properties',
          properties.map((p) => p.toJson()).toList(),
          duration: const Duration(hours: 6),
        );
      } catch (_) {}
      
      // Precache images for instant display
      _precachePropertyImages(properties);
      
      print('✅ Loaded ${properties.length} saved properties');
    } catch (e) {
      print('❌ Error loading saved properties: $e');
      savedProperties.value = [];
      isSimilarPropertyLiked.value = [];
      Get.snackbar(
        'Error',
        'Failed to load saved properties',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProperties.value = false;
    }
  }

  // Refresh saved properties
  Future<void> refreshSavedProperties() async {
    try {
      print('🔄 Refreshing saved properties');
      
      final properties = await PropertyService.getSavedProperties();
      savedProperties.value = properties;
      
      isSimilarPropertyLiked.value = List<bool>.generate(properties.length, (index) => true);
      
      print('✅ Refreshed ${properties.length} saved properties');
    } catch (e) {
      print('❌ Error refreshing saved properties: $e');
    }
  }

  // Navigate to property details
  void navigateToPropertyDetails(String propertyId) {
    Get.toNamed(AppRoutes.propertyDetailsView, arguments: propertyId);
  }

  // Remove property from saved list
  Future<void> unsaveProperty(String propertyId, int index) async {
    try {
      await PropertyService.unsaveProperty(propertyId);
      savedProperties.removeAt(index);
      isSimilarPropertyLiked.removeAt(index);
      
      Get.snackbar(
        'Property Removed',
        'Property has been removed from your saved properties',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error removing saved property: $e');
      Get.snackbar(
        'Error',
        'Failed to remove property',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================== SAVED ARTS & ANTIQUES ====================

  // Load saved arts & antiques from Firebase
  Future<void> loadSavedArtsAntiques({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoadingArtsAntiques.value = true;
      }
      print('🔍 Loading saved arts & antiques');
      
      final items = await PropertyService.getSavedArtsAntiques();
      savedArtsAntiques.value = items;
      
      // Initialize liked status for each item
      isArtsAntiquesLiked.value = List<bool>.generate(items.length, (index) => true);
      
      // Cache results for instant next load
      try {
        final cacheService = Get.find<CacheService>();
        await cacheService.saveJsonList(
          'saved_arts_antiques',
          items.cast<Map<String, dynamic>>(),
          duration: const Duration(hours: 6),
        );
      } catch (_) {}
      
      // Precache images for instant display
      _precacheArtsAntiquesImages(items);
      
      print('✅ Loaded ${items.length} saved arts & antiques');
    } catch (e) {
      print('❌ Error loading saved arts & antiques: $e');
      savedArtsAntiques.value = [];
      isArtsAntiquesLiked.value = [];
    } finally {
      isLoadingArtsAntiques.value = false;
    }
  }

  // Refresh saved arts & antiques
  Future<void> refreshSavedArtsAntiques() async {
    try {
      print('🔄 Refreshing saved arts & antiques');
      
      final items = await PropertyService.getSavedArtsAntiques();
      savedArtsAntiques.value = items;
      
      isArtsAntiquesLiked.value = List<bool>.generate(items.length, (index) => true);
      
      print('✅ Refreshed ${items.length} saved arts & antiques');
    } catch (e) {
      print('❌ Error refreshing saved arts & antiques: $e');
    }
  }

  // Navigate to arts & antiques details
  void navigateToArtsAntiquesDetails(String itemId) {
    Get.toNamed(AppRoutes.artsAntiquesDetailsView, arguments: itemId);
  }

  // Remove arts & antiques from saved list
  Future<void> unsaveArtsAntiques(String itemId, int index) async {
    try {
      await PropertyService.unsaveArtsAntiques(itemId);
      savedArtsAntiques.removeAt(index);
      isArtsAntiquesLiked.removeAt(index);
      
      Get.snackbar(
        'Item Removed',
        'Item has been removed from your saved items',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error removing saved item: $e');
      Get.snackbar(
        'Error',
        'Failed to remove item',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void launchDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  // ==================== CACHING ====================

  /// Check if we already have cached data to show instantly
  bool hasCachedData() {
    return savedProperties.isNotEmpty || savedArtsAntiques.isNotEmpty;
  }

  /// Load cached saved items instantly if available
  void loadCachedDataSync() {
    try {
      final cacheService = Get.find<CacheService>();
      // Load properties
      final cachedProps = cacheService.getJsonList('saved_properties');
      if (cachedProps != null && cachedProps.isNotEmpty) {
        final props = cachedProps.map((e) => Property.fromJson(e)).toList();
        savedProperties.value = props;
        isSimilarPropertyLiked.value = List<bool>.generate(props.length, (index) => true);
        print('✅ Loaded ${props.length} saved properties from cache');
        // Precache images from cached data
        _precachePropertyImages(props);
      }
      // Load arts & antiques
      final cachedArts = cacheService.getJsonList('saved_arts_antiques');
      if (cachedArts != null && cachedArts.isNotEmpty) {
        savedArtsAntiques.value = cachedArts;
        isArtsAntiquesLiked.value = List<bool>.generate(cachedArts.length, (index) => true);
        print('✅ Loaded ${cachedArts.length} saved arts & antiques from cache');
        // Precache images from cached data
        _precacheArtsAntiquesImages(cachedArts);
      }
    } catch (e) {
      // Cache service not registered or other error — ignore silently
    }
  }

  // ==================== IMAGE PRECACHING ====================

  /// Precache property images for instant display
  void _precachePropertyImages(List<Property> properties) {
    try {
      if (Get.context == null) return;
      
      for (final property in properties) {
        if (property.propertyPhotos.isNotEmpty) {
          // Precache first image of each property
          final imageUrl = property.propertyPhotos.first;
          if (imageUrl.isNotEmpty) {
            precacheImage(NetworkImage(imageUrl), Get.context!).catchError((_) {
              // Silently fail - image will load on demand
            });
          }
        }
      }
    } catch (e) {
      // Silently fail - images will load on demand
    }
  }

  /// Precache arts & antiques images for instant display
  void _precacheArtsAntiquesImages(List<Map<String, dynamic>> items) {
    try {
      if (Get.context == null) return;
      
      for (final item in items) {
        final images = item['images'] as List?;
        if (images != null && images.isNotEmpty) {
          // Precache first image of each item
          final imageUrl = images.first as String;
          if (imageUrl.isNotEmpty) {
            precacheImage(NetworkImage(imageUrl), Get.context!).catchError((_) {
              // Silently fail - image will load on demand
            });
          }
        }
      }
    } catch (e) {
      // Silently fail - images will load on demand
    }
  }

  // ==================== LEGACY CODE (for backward compatibility) ====================

  RxList<String> savedPropertyList = [
    AppString.properties3,
    'Arts & Antiques',
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.searchProperty1.path,
    Assets.images.savedProperty1.path,
    Assets.images.savedProperty2.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.semiModernHouse,
    AppString.vijayVRX,
    AppString.yashasviSiddhi,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.address6,
    AppString.templeSquare,
    AppString.schinnerVillage,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.rupees58Lakh,
    AppString.rupee65Lakh,
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
}
