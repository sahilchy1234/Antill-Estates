import 'package:get/get.dart';
import 'cache_service.dart';
import 'image_cache_service.dart';

/// Centralized cache management utility
class CacheManager extends GetxService {
  static CacheManager get instance => Get.find<CacheManager>();
  
  final CacheService _dataCache = CacheService.instance;
  final ImageCacheService _imageCache = ImageCacheService.instance;
  
  // Cache statistics
  final RxMap<String, int> cacheHits = <String, int>{}.obs;
  final RxMap<String, int> cacheMisses = <String, int>{}.obs;
  final RxInt totalCacheSize = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _updateCacheStats();
  }
  
  // ==================== Quick Access ====================
  
  /// Clear all caches
  Future<void> clearAllCaches() async {
    await _dataCache.clearAllCache();
    await _imageCache.clearCache();
    await _updateCacheStats();
    
    if (Get.context != null) {
      Get.snackbar(
        'Cache Cleared',
        'All caches have been cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  /// Clear expired caches only
  Future<void> clearExpiredCaches() async {
    // Data cache cleans itself on init
    await _imageCache.clearCache();
    await _updateCacheStats();
  }
  
  /// Clear image cache only
  Future<void> clearImageCache() async {
    await _imageCache.clearCache();
    await _updateCacheStats();
    
    if (Get.context != null) {
      Get.snackbar(
        'Image Cache Cleared',
        'Image cache has been cleared',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  /// Clear data cache only
  Future<void> clearDataCache() async {
    await _dataCache.clearAllCache();
    await _updateCacheStats();
    
    if (Get.context != null) {
      Get.snackbar(
        'Data Cache Cleared',
        'Data cache has been cleared',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  /// Clear property caches
  Future<void> clearPropertyCaches() async {
    await _dataCache.clearCacheByPattern('property');
    await _dataCache.clearCacheByPattern('properties');
    await _updateCacheStats();
  }
  
  /// Clear arts & antiques caches
  Future<void> clearArtsAntiquesCache() async {
    await _dataCache.clearCacheByPattern('arts');
    await _dataCache.clearCacheByPattern('trending');
    await _dataCache.clearCacheByPattern('featured');
    await _updateCacheStats();
  }
  
  /// Clear user data cache
  Future<void> clearUserCache(String userId) async {
    await _dataCache.clearCache('user_$userId');
    await _updateCacheStats();
  }
  
  // ==================== Cache Statistics ====================
  
  /// Update cache statistics
  Future<void> _updateCacheStats() async {
    try {
      final stats = await _dataCache.getCacheStats();
      totalCacheSize.value = stats['totalSize'] as int? ?? 0;
    } catch (e) {
      print('Error updating cache stats: $e');
    }
  }
  
  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    final dataStats = await _dataCache.getCacheStats();
    final imageCacheSize = await _imageCache.getCacheSize();
    
    return {
      'dataCacheSize': dataStats['totalSize'] ?? 0,
      'imageCacheSize': imageCacheSize,
      'totalCacheSize': (dataStats['totalSize'] ?? 0) + imageCacheSize,
      'totalEntries': dataStats['totalEntries'] ?? 0,
      'expiredEntries': dataStats['expiredEntries'] ?? 0,
      'memoryCacheSize': dataStats['memoryCacheSize'] ?? 0,
    };
  }
  
  /// Get formatted cache size
  String getFormattedCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // ==================== Pre-cache Strategies ====================
  
  /// Pre-cache home data
  Future<void> precacheHomeData() async {
    // Implement based on your home data structure
    print('🚀 Pre-caching home data...');
  }
  
  /// Pre-cache featured content
  Future<void> precacheFeaturedContent() async {
    print('🚀 Pre-caching featured content...');
    // Featured properties, arts, etc. will be cached on first load
  }
  
  /// Pre-cache images for a list of URLs
  Future<void> precacheImages(List<String> imageUrls) async {
    print('🚀 Pre-caching ${imageUrls.length} images...');
    await _imageCache.preCacheImages(imageUrls);
  }
  
  
  // ==================== Smart Cache ====================
  
  /// Optimize cache (remove low-value entries)
  Future<void> optimizeCache() async {
    final stats = await _dataCache.getCacheStats();
    final totalSize = stats['totalSize'] as int? ?? 0;
    
    // If cache is larger than 20MB, clean it
    if (totalSize > 20 * 1024 * 1024) {
      await clearExpiredCaches();
      await _updateCacheStats();
      
      if (Get.context != null) {
        Get.snackbar(
          'Cache Optimized',
          'Cache has been optimized',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
  
  /// Warm up cache (pre-load frequently accessed data)
  Future<void> warmUpCache() async {
    print('🔥 Warming up cache...');
    
    // This will be called on app startup to pre-load critical data
    await precacheFeaturedContent();
  }
  
  // ==================== Cache Health ====================
  
  /// Check cache health
  Future<Map<String, dynamic>> checkCacheHealth() async {
    final stats = await getCacheStatistics();
    final totalSize = stats['totalCacheSize'] as int;
    final expiredEntries = stats['expiredEntries'] as int;
    
    String health = 'Good';
    List<String> recommendations = [];
    
    // Check size
    if (totalSize > 50 * 1024 * 1024) {
      health = 'Warning';
      recommendations.add('Cache size is large (>50MB). Consider clearing old data.');
    }
    
    // Check expired entries
    if (expiredEntries > 10) {
      recommendations.add('You have $expiredEntries expired cache entries. Run optimization.');
    }
    
    return {
      'health': health,
      'recommendations': recommendations,
      'stats': stats,
    };
  }
}

