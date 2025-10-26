import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/services/search_service.dart';

enum SearchContentType {
  searchFilter,
  search,
}

class SearchFilterController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxInt selectProperty = 0.obs;
  RxInt selectPropertyLooking = (-1).obs;
  RxInt selectBedrooms = (-1).obs;
  RxInt selectLookingFor = (-1).obs;
  RxInt selectTypesOfProperty = (-1).obs;
  Rx<RangeValues> values = const RangeValues(50, 500).obs;
  String get startValueText => "₹ ${convertToText(values.value.start)}";
  String get endValueText => "₹ ${convertToText(values.value.end)}";
  Rx<SearchContentType> contentType = SearchContentType.searchFilter.obs;

  // Search functionality
  RxList<Property> searchResults = <Property>[].obs;
  RxList<Property> filteredProperties = <Property>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;
  RxList<String> searchSuggestions = <String>[].obs;

  String convertToText(double value) {
    if (value >= 100) {
      return "${(value / 100).toStringAsFixed(2)} crores";
    } else {
      return "${value.toStringAsFixed(2)} lakhs";
    }
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  void updatePropertyLooking(int index) {
    selectPropertyLooking.value = index;
    performSearch(); // Trigger search when filter changes
  }

  void updateBedrooms(int index) {
    selectBedrooms.value = index;
    performSearch(); // Trigger search when filter changes
  }

  void updateLookingFor(int index) {
    selectLookingFor.value = index;
    performSearch(); // Trigger search when filter changes
  }

  void updateTypesOfProperty(int index) {
    selectTypesOfProperty.value = index;
    performSearch(); // Trigger search when filter changes
  }

  void updateValues(RangeValues newValues) {
    values.value = newValues;
    performSearch(); // Trigger search when price range changes
  }

  void setContent(SearchContentType type) {
    contentType.value = type;
  }

  RxList<String> propertyList = [
    "residential",
    "commercial",
  ].obs;

  RxList<String> propertyLookingList = [
    "buy",
    "rent",
    "pg",
  ].obs;

  RxList<String> propertyTypeList = [
    "apartment",
    "independent_house",
    "plot_land",
  ].obs;

  RxList<String> bedroomsList = [
    "1",
    "2", 
    "3",
    "4",
    "5",
  ].obs;

  RxList<String> propertyLookingForList = [
    "Yes",
    "No",
  ].obs;

  RxList<String> recentSearchedList = [
    AppString.amroli,
    AppString.palanpura,
  ].obs;

  RxList<String> recentSearched2List = [
    AppString.vesu,
    AppString.palanpura,
    AppString.pal,
    AppString.adajan,
    AppString.althana,
    AppString.dindoli,
    AppString.vipRoad,
    AppString.piplod,
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize search controller listener
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        getSearchSuggestions(searchController.text);
      } else {
        searchSuggestions.clear();
      }
    });
    // Don't perform initial search - let user apply filters first
    // performSearch();
  }

  /// Perform search based on current filters and search query
  Future<void> performSearch() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Get search criteria from current selections
      final searchCriteria = _buildSearchCriteria();
      
      print('🔍 SearchFilterController: Performing search with criteria: $searchCriteria');
      
      List<Property> results;
      
      // Always perform search - let SearchService handle the logic
      results = await SearchService.searchProperties(
        query: searchController.text.isNotEmpty ? searchController.text : null,
        city: searchCriteria['city'],
        propertyType: searchCriteria['propertyType'],
        propertyLooking: searchCriteria['propertyLooking'],
        category: searchCriteria['category'],
        noOfBedrooms: searchCriteria['noOfBedrooms'],
        availabilityStatus: searchCriteria['availabilityStatus'],
        minPrice: searchCriteria['minPrice'],
        maxPrice: searchCriteria['maxPrice'],
      );

      print('🔍 SearchFilterController: Found ${results.length} properties');
      searchResults.assignAll(results);
      filteredProperties.assignAll(results);
      
      print('🔍 SearchFilterController: Updated searchResults with ${searchResults.length} properties');
      print('🔍 SearchFilterController: Updated filteredProperties with ${filteredProperties.length} properties');
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error performing search: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Build search criteria from current filter selections
  Map<String, dynamic> _buildSearchCriteria() {
    final criteria = <String, dynamic>{};

    print('🔍 Current filter selections:');
    print('   selectPropertyLooking: ${selectPropertyLooking.value}');
    print('   selectTypesOfProperty: ${selectTypesOfProperty.value}');
    print('   selectBedrooms: ${selectBedrooms.value}');
    print('   selectLookingFor: ${selectLookingFor.value}');
    print('   priceRange: ${values.value.start} - ${values.value.end}');

    // Property looking (Buy/Rent/PG) - apply if user has made a selection
    if (selectPropertyLooking.value >= 0 && selectPropertyLooking.value < propertyLookingList.length) {
      criteria['propertyLooking'] = propertyLookingList[selectPropertyLooking.value];
      print('   ✅ Added propertyLooking: ${propertyLookingList[selectPropertyLooking.value]}');
    }

    // Property type - apply if user has made a selection  
    if (selectTypesOfProperty.value >= 0 && selectTypesOfProperty.value < propertyTypeList.length) {
      criteria['propertyType'] = propertyTypeList[selectTypesOfProperty.value];
      print('   ✅ Added propertyType: ${propertyTypeList[selectTypesOfProperty.value]}');
    }

    // Number of bedrooms - apply if user has made a selection
    if (selectBedrooms.value >= 0 && selectBedrooms.value < bedroomsList.length) {
      criteria['noOfBedrooms'] = bedroomsList[selectBedrooms.value];
      print('   ✅ Added noOfBedrooms: ${bedroomsList[selectBedrooms.value]}');
    }

    // Ready to move - apply if user has made a selection
    if (selectLookingFor.value >= 0 && selectLookingFor.value < propertyLookingForList.length) {
      final readyToMove = propertyLookingForList[selectLookingFor.value];
      criteria['availabilityStatus'] = readyToMove == 'Yes' ? 'Ready to Move' : 'Under Construction';
      print('   ✅ Added availabilityStatus: ${criteria['availabilityStatus']}');
    }

    // Price range - apply if user has changed from default values
    if (values.value.start > 50 || values.value.end < 500) {
      criteria['minPrice'] = values.value.start;
      criteria['maxPrice'] = values.value.end;
      print('   ✅ Added priceRange: ${values.value.start} - ${values.value.end}');
    }

    print('🔍 Final search criteria: $criteria');
    return criteria;
  }

  /// Get search suggestions
  Future<void> getSearchSuggestions(String query) async {
    if (query.isEmpty) {
      searchSuggestions.clear();
      return;
    }

    try {
      final suggestions = await SearchService.getSearchSuggestions(query);
      searchSuggestions.assignAll(suggestions);
    } catch (e) {
      print('Error getting search suggestions: $e');
    }
  }

  /// Clear search results
  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    filteredProperties.clear();
    searchSuggestions.clear();
  }

  /// Apply filters to search results
  void applyFilters() {
    // This method can be used to apply additional filters to search results
    // For now, we'll just trigger a new search
    performSearch();
  }

  /// Check if any filters have been applied
  bool get hasActiveFilters {
    return selectPropertyLooking.value >= 0 ||
           selectTypesOfProperty.value >= 0 ||
           selectBedrooms.value >= 0 ||
           selectLookingFor.value >= 0 ||
           values.value.start > 50 ||
           values.value.end < 500 ||
           searchController.text.isNotEmpty;
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }
}
