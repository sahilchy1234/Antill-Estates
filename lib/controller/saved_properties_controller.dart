import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/model/arts_antiques_model.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:antill_estates/services/arts_antiques_data_service.dart';
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
    loadSavedProperties();
    loadSavedArtsAntiques();
  }

  void updateSavedTab(int index) {
    selectSavedTab.value = index;
  }

  // ==================== SAVED PROPERTIES ====================

  // Load saved properties from Firebase
  Future<void> loadSavedProperties() async {
    try {
      isLoadingProperties.value = true;
      print('🔍 Loading saved properties');
      
      final properties = await PropertyService.getSavedProperties();
      savedProperties.value = properties;
      
      // Initialize liked status for each property
      isSimilarPropertyLiked.value = List<bool>.generate(properties.length, (index) => true);
      
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
  Future<void> loadSavedArtsAntiques() async {
    try {
      isLoadingArtsAntiques.value = true;
      print('🔍 Loading saved arts & antiques');
      
      final items = await PropertyService.getSavedArtsAntiques();
      savedArtsAntiques.value = items;
      
      // Initialize liked status for each item
      isArtsAntiquesLiked.value = List<bool>.generate(items.length, (index) => true);
      
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
