import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:antill_estates/configs/app_color.dart';

import '../model/property_model.dart';

class ActivityController extends GetxController {
  TextEditingController searchListController = TextEditingController();

  RxInt selectListing = 0.obs;
  RxInt selectSorting = 0.obs;
  RxBool deleteShowing = false.obs;
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  RxList<Property> allProperties = <Property>[].obs;
  RxList<Property> filteredProperties = <Property>[].obs;
  RxList<Property> searchResults = <Property>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProperties();

    searchListController.addListener(() {
      searchProperties(searchListController.text);
    });
  }

  Future<void> loadUserProperties() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final properties = await PropertyService.getUserProperties();
      allProperties.assignAll(properties);
      applyFiltersAndSorting();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProperties() async {
    await loadUserProperties();
  }

  void applyFiltersAndSorting() {
    List<Property> filtered = List.from(allProperties);

    // Filter by listing status
    switch (selectListing.value) {
      case 0:
        filtered = filtered.where((p) => p.isActive).toList();
        break;
      case 2:
        filtered = filtered.where((p) => !p.isActive).toList();
        break;
    // Add other filters as needed
    }

    // Sort listings
    switch (selectSorting.value) {
      case 0:
        filtered.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        break;
      case 1:
        filtered.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        break;
    // Add other sorting as needed
    }

    filteredProperties.assignAll(filtered);

    if (searchListController.text.isNotEmpty) {
      searchProperties(searchListController.text);
    } else {
      searchResults.assignAll(filteredProperties);
    }
  }

  void searchProperties(String query) {
    if (query.isEmpty) {
      searchResults.assignAll(filteredProperties);
      return;
    }
    final q = query.toLowerCase();
    final results = filteredProperties.where((property) {
      return (property.propertyLooking.toLowerCase() + ' ' + property.propertyType.toLowerCase()).contains(q) ||
          property.city.toLowerCase().contains(q) ||
          property.locality.toLowerCase().contains(q);
    }).toList();
    searchResults.assignAll(results);
  }

  Future<void> deleteProperty(String propertyId) async {
    try {
      await PropertyService.deleteProperty(propertyId);
      await refreshProperties();
      Get.snackbar('Success', 'Property deleted successfully', backgroundColor: AppColor.positiveColor);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete property: $e', backgroundColor: AppColor.negativeColor);
    }
  }

  String formatPrice(String price) {
    try {
      final num val = num.parse(price);
      if (val >= 10000000) return '₹${(val / 10000000).toStringAsFixed(1)} Cr';
      if (val >= 100000) return '₹${(val / 100000).toStringAsFixed(1)} L';
      return '₹${val.toStringAsFixed(0)}';
    } catch (_) {
      return price.isNotEmpty ? '₹$price' : 'Price not set';
    }
  }

  String getPropertyTitle(Property property) => '${property.propertyLooking} ${property.propertyType}';

  String getPropertyAddress(Property property) {
    List<String> parts = [];
    if (property.locality.isNotEmpty) parts.add(property.locality);
    if (property.city.isNotEmpty) parts.add(property.city);
    return parts.join(', ');
  }

  void updateListing(int index) {
    selectListing.value = index;
    applyFiltersAndSorting();
  }

  void updateSorting(int index) {
    selectSorting.value = index;
    applyFiltersAndSorting();
  }

  RxList<String> listingStatesList = [
    AppString.active,
    AppString.expired,
    AppString.deleted,
    AppString.underScreening,
  ].obs;

  RxList<String> sortListingList = [
    AppString.newestFirst,
    AppString.oldestFirst,
    AppString.expiringFirst,
    AppString.expiringLast,
  ].obs;

  @override
  void dispose() {
    searchListController.dispose();
    super.dispose();
  }
}
