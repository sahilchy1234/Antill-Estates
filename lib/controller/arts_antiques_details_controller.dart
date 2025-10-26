import 'package:get/get.dart';
import 'package:antill_estates/model/arts_antiques_model.dart';
import 'package:antill_estates/model/review_model.dart';
import 'package:antill_estates/services/arts_antiques_data_service.dart';
import 'package:antill_estates/services/arts_antiques_cache_service.dart';
import 'package:antill_estates/services/review_service.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:flutter/material.dart';

class ArtsAntiquesDetailsController extends GetxController {
  // Observable state
  Rx<ArtsAntiquesItem?> item = Rx<ArtsAntiquesItem?>(null);
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;
  
  // Related items
  RxList<ArtsAntiquesItem> similarItems = <ArtsAntiquesItem>[].obs;
  RxBool isLoadingSimilarItems = false.obs;
  
  // Reviews
  RxList<Review> reviews = <Review>[].obs;
  RxBool isLoadingReviews = false.obs;
  RxDouble averageRating = 0.0.obs;
  RxInt totalReviews = 0.obs;
  
  // Save/favorite status
  RxBool isSaved = false.obs;
  RxBool isSaving = false.obs;
  
  // Image gallery
  RxInt currentImageIndex = 0.obs;
  
  // Contact owner dialog
  RxBool showContactDialog = false.obs;

  // Cache service
  final ArtsAntiquesCacheService _cache = ArtsAntiquesCacheService();

  /// Initialize with item ID
  Future<void> initializeWithItemId(String itemId) async {
    print('🎨 ArtsAntiquesDetailsController initializing with item ID: $itemId');
    await loadItemDetails(itemId);
  }

  /// Load item details with caching
  Future<void> loadItemDetails(String itemId, {bool forceRefresh = false}) async {
    try {
      // Try cache first for instant display
      if (!forceRefresh) {
        final cachedItem = await _cache.getItem(itemId);
        if (cachedItem != null) {
          item.value = cachedItem;
          print('✅ Item loaded from cache (0-50ms)');
          
          // Load additional data in background
          _loadAdditionalDataInBackground(itemId);
          
          // If item is displayed from cache, fetch fresh data in background
          _refreshItemInBackground(itemId);
          return;
        }
      }

      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Load item details
      final itemData = await ArtsAntiquesDataService.getItemById(itemId, forceRefresh: forceRefresh);

      if (itemData != null) {
        item.value = itemData;
        
        // Cache the item
        await _cache.cacheItem(itemData);
        
        // Increment view count
        ArtsAntiquesDataService.incrementViewCount(itemId);
        
        // Load additional data in parallel
        await Future.wait([
          loadSimilarItems(itemId),
          loadReviews(itemId),
          loadSaveStatus(itemId),
        ]);
        
        print('✅ Arts & Antiques item details loaded successfully');
      } else {
        hasError.value = true;
        errorMessage.value = 'Item not found';
        print('❌ Arts & Antiques item not found');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('❌ Error loading arts & antiques item details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load additional data in background without showing loading
  Future<void> _loadAdditionalDataInBackground(String itemId) async {
    try {
      await Future.wait([
        loadSimilarItems(itemId),
        loadReviews(itemId),
        loadSaveStatus(itemId),
      ]);
    } catch (e) {
      print('❌ Error loading additional data in background: $e');
    }
  }

  /// Refresh item data in background
  Future<void> _refreshItemInBackground(String itemId) async {
    try {
      final freshItem = await ArtsAntiquesDataService.getItemById(itemId, forceRefresh: true);
      if (freshItem != null) {
        item.value = freshItem;
        await _cache.cacheItem(freshItem);
      }
    } catch (e) {
      print('❌ Error refreshing item in background: $e');
    }
  }

  /// Load similar items with caching
  Future<void> loadSimilarItems(String currentItemId) async {
    try {
      isLoadingSimilarItems.value = true;
      
      final currentItem = item.value;
      if (currentItem == null) return;
      
      // Try cache first
      final cachedItems = await _cache.getCategoryItems(currentItem.category);
      if (cachedItems != null && cachedItems.isNotEmpty) {
        // Filter out current item
        similarItems.value = cachedItems.where((i) => i.id != currentItemId).take(5).toList();
        print('✅ Similar items from cache');
        
        // Load fresh data in background
        _refreshSimilarItemsInBackground(currentItemId, currentItem.category);
        return;
      }
      
      // Get items from the same category
      final items = await ArtsAntiquesDataService.getItemsByCategory(
        currentItem.category,
        limit: 10,
      );
      
      // Filter out current item
      similarItems.value = items.where((i) => i.id != currentItemId).take(5).toList();
      
      print('✅ Loaded ${similarItems.length} similar items');
    } catch (e) {
      print('❌ Error loading similar items: $e');
    } finally {
      isLoadingSimilarItems.value = false;
    }
  }

  /// Refresh similar items in background
  Future<void> _refreshSimilarItemsInBackground(String currentItemId, String category) async {
    try {
      final freshItems = await ArtsAntiquesDataService.getItemsByCategory(
        category,
        limit: 10,
        forceRefresh: true,
      );
      
      // Filter out current item
      final filtered = freshItems.where((i) => i.id != currentItemId).take(5).toList();
      if (filtered.isNotEmpty) {
        similarItems.value = filtered;
      }
    } catch (e) {
      print('❌ Error refreshing similar items: $e');
    }
  }

  /// Load reviews
  Future<void> loadReviews(String itemId) async {
    try {
      isLoadingReviews.value = true;
      
      // Get reviews from review service
      reviews.value = await ReviewService.getPropertyReviews(itemId);
      totalReviews.value = reviews.length;
      
      // Get average rating
      averageRating.value = await ReviewService.getPropertyAverageRating(itemId);
      
      print('✅ Loaded ${reviews.length} reviews, average rating: ${averageRating.value}');
    } catch (e) {
      print('❌ Error loading reviews: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  /// Load save status
  Future<void> loadSaveStatus(String itemId) async {
    try {
      isSaved.value = await PropertyService.isArtsAntiquesSaved(itemId);
    } catch (e) {
      print('❌ Error loading save status: $e');
      isSaved.value = false;
    }
  }

  /// Toggle save/favorite status
  Future<void> toggleSave() async {
    if (item.value == null || item.value!.id == null) return;
    
    try {
      isSaving.value = true;
      final newStatus = await PropertyService.toggleSaveArtsAntiques(item.value!.id!);
      isSaved.value = newStatus;
      
      Get.snackbar(
        newStatus ? 'Saved' : 'Removed',
        newStatus 
          ? 'Item added to your favorites'
          : 'Item removed from your favorites',
        backgroundColor: newStatus ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error toggling save: $e');
      Get.snackbar(
        'Error',
        'Failed to update favorite status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Add a review
  Future<void> addReview(double rating, String comment) async {
    if (item.value == null || item.value!.id == null) return;
    
    try {
      await ReviewService.addReview(
        propertyId: item.value!.id!,
        rating: rating,
        comment: comment,
      );
      
      // Reload reviews
      await loadReviews(item.value!.id!);
      
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

  /// Change current image
  void changeImage(int index) {
    currentImageIndex.value = index;
  }

  /// Show contact dialog
  void toggleContactDialog() {
    showContactDialog.value = !showContactDialog.value;
  }

  /// Format price
  String getFormattedPrice() {
    if (item.value == null) return '₹ 0';
    return '₹ ${item.value!.price.toInt()}';
  }

  /// Get year display
  String getYearDisplay() {
    if (item.value?.year == null) return 'Year not specified';
    return '${item.value!.year}';
  }

  @override
  void onClose() {
    // Clean up
    super.onClose();
  }
}

