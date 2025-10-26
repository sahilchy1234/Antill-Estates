import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Removed unused imports
import 'package:antill_estates/model/arts_antiques_model.dart';
import 'package:antill_estates/services/arts_antiques_data_service.dart';
import 'package:antill_estates/services/arts_antiques_cache_service.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:antill_estates/services/review_service.dart';

class ArtsAntiquesController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxInt selectCategory = 0.obs;
  RxList<bool> isTrendItemLiked = <bool>[].obs;

  // Firebase data observables
  RxList<ArtsAntiquesItem> featuredItems = <ArtsAntiquesItem>[].obs;
  RxList<ArtsAntiquesItem> trendingItems = <ArtsAntiquesItem>[].obs;
  RxList<Map<String, dynamic>> artists = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  // Save functionality
  RxList<bool> isTrendingItemSaving = <bool>[].obs;

  // Rating functionality
  RxList<double> trendingItemRatings = <double>[].obs;

  // Lazy loading state
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreFeatured = true.obs;
  RxBool hasMoreTrending = true.obs;

  // Scroll controllers for lazy loading
  ScrollController? featuredScrollController;
  ScrollController? trendingScrollController;

  // Cache service
  final ArtsAntiquesCacheService _cache = ArtsAntiquesCacheService();

  // Prevent multiple simultaneous loads
  bool _isLoadingData = false;

  @override
  void onInit() {
    super.onInit();
    _initializeScrollControllers();
  }

  /// Initialize scroll controllers for lazy loading
  void _initializeScrollControllers() {
    featuredScrollController = ScrollController();
    trendingScrollController = ScrollController();
    
    // Add listeners for lazy loading
    featuredScrollController?.addListener(_onFeaturedScroll);
    trendingScrollController?.addListener(_onTrendingScroll);
  }

  /// Lazy load more featured items when scrolled to end
  void _onFeaturedScroll() {
    if (featuredScrollController == null) return;
    
    final maxScroll = featuredScrollController!.position.maxScrollExtent;
    final currentScroll = featuredScrollController!.position.pixels;
    
    // Load more when 80% scrolled
    if (currentScroll >= maxScroll * 0.8 && !isLoadingMore.value && hasMoreFeatured.value) {
      loadMoreFeaturedItems();
    }
  }

  /// Lazy load more trending items when scrolled to end
  void _onTrendingScroll() {
    if (trendingScrollController == null) return;
    
    final maxScroll = trendingScrollController!.position.maxScrollExtent;
    final currentScroll = trendingScrollController!.position.pixels;
    
    // Load more when 80% scrolled
    if (currentScroll >= maxScroll * 0.8 && !isLoadingMore.value && hasMoreTrending.value) {
      loadMoreTrendingItems();
    }
  }

  /// Load more featured items (pagination)
  Future<void> loadMoreFeaturedItems() async {
    if (isLoadingMore.value || !hasMoreFeatured.value) return;
    
    try {
      isLoadingMore.value = true;
      
      final newItems = await ArtsAntiquesDataService.getFeaturedItems(
        limit: 6,
        loadMore: true,
      );
      
      if (newItems.isEmpty) {
        hasMoreFeatured.value = false;
      } else {
        featuredItems.addAll(newItems);
      }
      
      print('✅ Loaded ${newItems.length} more featured items');
    } catch (e) {
      print('❌ Error loading more featured items: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Load more trending items (pagination)
  Future<void> loadMoreTrendingItems() async {
    if (isLoadingMore.value || !hasMoreTrending.value) return;
    
    try {
      isLoadingMore.value = true;
      
      final newItems = await ArtsAntiquesDataService.getTrendingItems(
        limit: 3,
        loadMore: true,
      );
      
      if (newItems.isEmpty) {
        hasMoreTrending.value = false;
      } else {
        trendingItems.addAll(newItems);
        
        // Load save status and ratings for new items
        await _loadSaveStatusForNewTrendingItems(trendingItems.length - newItems.length, newItems.length);
        await _loadRatingsForNewTrendingItems(trendingItems.length - newItems.length, newItems.length);
      }
      
      print('✅ Loaded ${newItems.length} more trending items');
    } catch (e) {
      print('❌ Error loading more trending items: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void updateCategory(int index) {
    selectCategory.value = index;
    
    // Navigate based on category selection
    switch (index) {
      case 0: // Paintings
        _navigateToCategorySearch('paintings');
        break;
      case 1: // Sculptures
        _navigateToCategorySearch('sculptures');
        break;
      case 2: // Antiques
        _navigateToCategorySearch('antiques');
        break;
      case 3: // Jewelry
        _navigateToCategorySearch('jewelry');
        break;
      case 4: // Collectibles
        _navigateToCategorySearch('collectibles');
        break;
      case 5: // Textiles
        _navigateToCategorySearch('textiles');
        break;
    }
  }

  void _navigateToCategorySearch(String categoryType) {
    // Navigate to arts antiques search view with category filter
    Get.toNamed('/arts_antiques_search_view', arguments: {
      'categoryType': categoryType,
      'selectedCategoryIndex': selectCategory.value,
    });
  }

  /// Load all Firebase data for arts & antiques screen with caching
  Future<void> loadArtsAntiquesData({bool showLoading = true, bool forceRefresh = false}) async {
    // Prevent multiple simultaneous loads
    if (_isLoadingData && !forceRefresh) {
      print('⚠️ Already loading data, skipping...');
      return;
    }
    
    try {
      _isLoadingData = true;
      
      // If we already have cached data displayed, just refresh in background
      if (hasCachedData() && !forceRefresh) {
        _loadFreshDataInBackground();
        return;
      }
      
      // Only show loading if explicitly requested and no cached data exists
      if (showLoading && !hasCachedData()) {
        isLoading.value = true;
      }
      
      // Reset pagination
      if (forceRefresh) {
        ArtsAntiquesDataService.resetFeaturedPagination();
        ArtsAntiquesDataService.resetTrendingPagination();
        hasMoreFeatured.value = true;
        hasMoreTrending.value = true;
      }
      
      // Load all data in parallel for better performance
      final futures = await Future.wait([
        ArtsAntiquesDataService.getFeaturedItems(limit: 6, forceRefresh: forceRefresh),
        ArtsAntiquesDataService.getTrendingItems(limit: 3, forceRefresh: forceRefresh),
        ArtsAntiquesDataService.getArtistsAndDealers(limit: 10, forceRefresh: forceRefresh),
      ]);

      // Update observables with fetched data
      featuredItems.value = futures[0] as List<ArtsAntiquesItem>;
      trendingItems.value = futures[1] as List<ArtsAntiquesItem>;
      artists.value = futures[2] as List<Map<String, dynamic>>;

      // Load save status for trending items
      await _loadSaveStatusForTrendingItems();

      // Load ratings for trending items
      await _loadRatingsForTrendingItems();

      print('✅ Arts & Antiques data loaded successfully');
    } catch (e) {
      print('❌ Error loading arts & antiques data: $e');
      if (showLoading) {
        Get.snackbar('Error', 'Failed to load arts & antiques data');
      }
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
      _isLoadingData = false;
    }
  }

  /// Load fresh data in background without showing loading indicator
  Future<void> _loadFreshDataInBackground() async {
    try {
      // Load fresh data silently
      await loadArtsAntiquesData(showLoading: false, forceRefresh: true);
    } catch (e) {
      print('❌ Error refreshing data in background: $e');
    }
  }

  /// Load save status for new trending items (pagination helper)
  Future<void> _loadSaveStatusForNewTrendingItems(int startIndex, int count) async {
    try {
      final saveStatuses = <bool>[];
      for (int i = startIndex; i < startIndex + count; i++) {
        if (i < trendingItems.length) {
          final item = trendingItems[i];
          if (item.id != null) {
            final isSaved = await PropertyService.isArtsAntiquesSaved(item.id!);
            saveStatuses.add(isSaved);
          } else {
            saveStatuses.add(false);
          }
        }
      }
      isTrendItemLiked.addAll(saveStatuses);
      isTrendingItemSaving.addAll(List<bool>.generate(count, (index) => false));
    } catch (e) {
      print('❌ Error loading save status for new trending items: $e');
    }
  }

  /// Load ratings for new trending items (pagination helper)
  Future<void> _loadRatingsForNewTrendingItems(int startIndex, int count) async {
    try {
      final ratings = <double>[];
      for (int i = startIndex; i < startIndex + count; i++) {
        if (i < trendingItems.length) {
          final item = trendingItems[i];
          if (item.id != null) {
            final rating = await ReviewService.getPropertyAverageRating(item.id!);
            ratings.add(rating);
          } else {
            ratings.add(0.0);
          }
        }
      }
      trendingItemRatings.addAll(ratings);
    } catch (e) {
      print('❌ Error loading ratings for new trending items: $e');
    }
  }

  // Removed _getArtistsData method - now using ArtsAntiquesDataService.getArtistsAndDealers()

  /// Check if we have cached data to show instantly
  bool hasCachedData() {
    return featuredItems.isNotEmpty || 
           trendingItems.isNotEmpty || 
           artists.isNotEmpty;
  }

  /// Load cached data synchronously (instant - no async delay!)
  void loadCachedDataSync() {
    // This runs synchronously to show data immediately
    Future.microtask(() async {
      try {
        final cachedFeatured = await _cache.getFeaturedItems();
        final cachedTrending = await _cache.getTrendingItems();
        final cachedArtists = await _cache.getArtists();
        
        if (cachedFeatured != null && cachedFeatured.isNotEmpty) {
          featuredItems.value = cachedFeatured;
          print('✅ Loaded ${cachedFeatured.length} featured items from cache');
        }
        if (cachedTrending != null && cachedTrending.isNotEmpty) {
          trendingItems.value = cachedTrending;
          // Initialize save status and ratings arrays
          isTrendItemLiked.value = List<bool>.generate(cachedTrending.length, (index) => false);
          isTrendingItemSaving.value = List<bool>.generate(cachedTrending.length, (index) => false);
          trendingItemRatings.value = List<double>.generate(cachedTrending.length, (index) => 0.0);
          print('✅ Loaded ${cachedTrending.length} trending items from cache');
        }
        if (cachedArtists != null && cachedArtists.isNotEmpty) {
          artists.value = cachedArtists;
          print('✅ Loaded ${cachedArtists.length} artists from cache');
        }
      } catch (e) {
        print('❌ Error loading cached data: $e');
      }
    });
  }

  /// Refresh arts & antiques data (pull to refresh)
  Future<void> refreshArtsAntiquesData() async {
    await loadArtsAntiquesData(showLoading: false, forceRefresh: true);
  }

  /// Clear cache and reload (useful for force refresh)
  Future<void> clearCacheAndReload() async {
    await _cache.clearAll();
    await loadArtsAntiquesData(showLoading: true, forceRefresh: true);
  }

  /// Load save status for trending items
  Future<void> _loadSaveStatusForTrendingItems() async {
    try {
      final saveStatuses = <bool>[];
      for (final item in trendingItems) {
        if (item.id != null) {
          final isSaved = await PropertyService.isArtsAntiquesSaved(item.id!);
          saveStatuses.add(isSaved);
        } else {
          saveStatuses.add(false);
        }
      }
      isTrendItemLiked.value = saveStatuses;
      isTrendingItemSaving.value = List<bool>.generate(trendingItems.length, (index) => false);
    } catch (e) {
      print('❌ Error loading save status for trending items: $e');
      isTrendItemLiked.value = List<bool>.generate(trendingItems.length, (index) => false);
      isTrendingItemSaving.value = List<bool>.generate(trendingItems.length, (index) => false);
    }
  }

  /// Toggle save status for trending item
  Future<void> toggleTrendingItemSave(int index) async {
    if (index >= trendingItems.length) return;
    
    final item = trendingItems[index];
    if (item.id == null) return;

    try {
      // Set loading state for this specific item
      if (index < isTrendingItemSaving.length) {
        isTrendingItemSaving[index] = true;
      }
      
      final newSaveStatus = await PropertyService.toggleSaveArtsAntiques(item.id!);
      isTrendItemLiked[index] = newSaveStatus;
      
      Get.snackbar(
        newSaveStatus ? 'Item Saved' : 'Item Removed',
        newSaveStatus 
          ? 'Item has been saved to your favorites'
          : 'Item has been removed from your favorites',
        backgroundColor: newSaveStatus ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error toggling trending item save: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isTrendItemLiked[index] ? 'remove' : 'save'} item: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Clear loading state
      if (index < isTrendingItemSaving.length) {
        isTrendingItemSaving[index] = false;
      }
    }
  }

  /// Load ratings for trending items
  Future<void> _loadRatingsForTrendingItems() async {
    try {
      final ratings = <double>[];
      for (final item in trendingItems) {
        if (item.id != null) {
          final rating = await ReviewService.getPropertyAverageRating(item.id!);
          ratings.add(rating);
        } else {
          ratings.add(0.0);
        }
      }
      trendingItemRatings.value = ratings;
    } catch (e) {
      print('❌ Error loading ratings for trending items: $e');
      trendingItemRatings.value = List<double>.generate(trendingItems.length, (index) => 0.0);
    }
  }

  RxList<String> categoryOptionList = [
    "Paintings",
    "Sculptures", 
    "Antiques",
    "Jewelry",
    "Collectibles",
    "Textiles",
  ].obs;

  @override
  void dispose() {
    searchController.dispose();
    featuredScrollController?.removeListener(_onFeaturedScroll);
    trendingScrollController?.removeListener(_onTrendingScroll);
    featuredScrollController?.dispose();
    trendingScrollController?.dispose();
    _cache.clearExpired(); // Clean up expired cache on dispose
    super.dispose();
  }
}
