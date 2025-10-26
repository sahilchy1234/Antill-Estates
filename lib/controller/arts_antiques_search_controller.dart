import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/model/arts_antiques_model.dart';
import 'package:antill_estates/services/arts_antiques_search_service.dart';
import 'package:antill_estates/services/review_service.dart';

class ArtsAntiquesSearchController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxInt selectCategory = (-1).obs;
  Rx<RangeValues> values = const RangeValues(0, 100000).obs;
  String get startValueText => "₹ ${_formatPrice(values.value.start)}";
  String get endValueText => "₹ ${_formatPrice(values.value.end)}";

  // Search functionality
  RxList<ArtsAntiquesItem> searchResults = <ArtsAntiquesItem>[].obs;
  RxList<ArtsAntiquesItem> filteredItems = <ArtsAntiquesItem>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;
  RxList<String> searchSuggestions = <String>[].obs;

  // Ratings map
  RxMap<String, double> itemRatings = <String, double>{}.obs;

  String _formatPrice(double value) {
    return value.toInt().toString();
  }

  void updateCategory(int index) {
    selectCategory.value = index;
    performSearch(); // Trigger search when filter changes
  }

  void updatePriceRange(RangeValues newValues) {
    values.value = newValues;
  }

  /// Perform search based on current filters and search query
  Future<void> performSearch() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Get search criteria from current selections
      final searchCriteria = _buildSearchCriteria();

      print('🔍 ArtsAntiquesSearchController: Performing search with criteria: $searchCriteria');

      List<ArtsAntiquesItem> results;

      // Always perform search
      results = await ArtsAntiquesSearchService.searchItems(
        query: searchController.text.isNotEmpty ? searchController.text : null,
        category: searchCriteria['category'],
        artist: searchCriteria['artist'],
        featured: searchCriteria['featured'],
        minPrice: searchCriteria['minPrice'],
        maxPrice: searchCriteria['maxPrice'],
      );

      print('🔍 ArtsAntiquesSearchController: Found ${results.length} items');
      searchResults.assignAll(results);
      filteredItems.assignAll(results);

      // Load ratings for all items
      await loadRatingsForItems();

      print('🔍 ArtsAntiquesSearchController: Updated searchResults with ${searchResults.length} items');
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

    // Category filter
    if (selectCategory.value >= 0) {
      final categories = [
        'paintings',
        'sculptures',
        'antiques',
        'jewelry',
        'collectibles',
        'textiles',
      ];
      if (selectCategory.value < categories.length) {
        criteria['category'] = categories[selectCategory.value];
        print('   ✅ Added category: ${criteria['category']}');
      }
    }

    // Price range - apply if user has changed from default values
    if (values.value.start > 0 || values.value.end < 100000) {
      criteria['minPrice'] = values.value.start;
      criteria['maxPrice'] = values.value.end;
      print('   ✅ Added priceRange: ${values.value.start} - ${values.value.end}');
    }

    print('🔍 Final search criteria: $criteria');
    return criteria;
  }

  /// Load ratings for all items
  Future<void> loadRatingsForItems() async {
    try {
      print('🔍 Loading ratings for ${searchResults.length} items');

      // Load all ratings in parallel
      final ratingFutures = searchResults.map((item) async {
        if (item.id != null && item.id!.isNotEmpty) {
          final rating = await ReviewService.getPropertyAverageRating(item.id!);
          return MapEntry(item.id!, rating);
        }
        return null;
      }).toList();

      final entries = await Future.wait(ratingFutures);
      final validEntries = entries.whereType<MapEntry<String, double>>().toList();

      // Build the map from valid entries
      itemRatings.clear();
      for (var entry in validEntries) {
        itemRatings[entry.key] = entry.value;
      }

      print('✅ Loaded ratings for ${itemRatings.length} items');
    } catch (e) {
      print('❌ Error loading ratings: $e');
    }
  }

  /// Get rating for an item
  double getItemRating(String? itemId) {
    if (itemId == null || itemId.isEmpty) {
      return 0.0;
    }
    return itemRatings[itemId] ?? 0.0;
  }

  /// Get search suggestions
  Future<void> getSearchSuggestions(String query) async {
    if (query.isEmpty) {
      searchSuggestions.clear();
      return;
    }

    try {
      final suggestions = await ArtsAntiquesSearchService.getSearchSuggestions(query);
      searchSuggestions.assignAll(suggestions);
    } catch (e) {
      print('Error getting search suggestions: $e');
    }
  }

  /// Clear search results
  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    filteredItems.clear();
    searchSuggestions.clear();
    itemRatings.clear();
  }

  /// Apply filters to search results
  void applyFilters() {
    performSearch();
  }

  /// Check if any filters have been applied
  bool get hasActiveFilters {
    return selectCategory.value >= 0 ||
           values.value.start > 0 ||
           values.value.end < 100000 ||
           searchController.text.isNotEmpty;
  }

  /// Category list for filtering
  RxList<String> get categoryList => [
    'Paintings',
    'Sculptures',
    'Antiques',
    'Jewelry',
    'Collectibles',
    'Textiles',
  ].obs;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }
}

