import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/services/image_cache_service.dart';
import 'package:antill_estates/services/cache_service.dart';

class CacheUtils {
  static final ImageCacheService _imageCacheService = ImageCacheService.instance;
  static final CacheService _cacheService = CacheService.instance;
  
  /// Clear all cached images
  static Future<void> clearImageCache() async {
    await _imageCacheService.clearCache();
  }
  
  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final imageSize = await _imageCacheService.getCacheSize();
      final dataStats = await _cacheService.getCacheStats();
      
      return {
        'imageCacheSize': imageSize,
        'dataCacheSize': dataStats['totalSize'] ?? 0,
        'totalCacheSize': imageSize + (dataStats['totalSize'] as int? ?? 0),
        'cachedImages': 'N/A',
        'maxCacheSize': 200,
        'cacheExpiration': 7,
      };
    } catch (e) {
      return {
        'imageCacheSize': 0,
        'dataCacheSize': 0,
        'totalCacheSize': 0,
        'error': e.toString(),
      };
    }
  }
  
  /// Check if image URL is from Firebase Storage
  static bool isFirebaseImage(String url) {
    return url.contains('firebasestorage.googleapis.com') ||
           url.contains('firebase') ||
           url.startsWith('gs://');
  }
  
  /// Pre-cache a list of image URLs
  static Future<void> preCacheImages(List<String> imageUrls) async {
    await _imageCacheService.preCacheImages(imageUrls);
  }
  
  /// Get cache size in MB (approximate)
  static Future<double> getCacheSizeInMB() async {
    try {
      final stats = await getCacheStats();
      final totalSize = stats['totalCacheSize'] as int;
      return totalSize / (1024 * 1024);
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0.0;
    }
  }
  
  /// Show cache info dialog
  static Future<void> showCacheInfo() async {
    final stats = await getCacheStats();
    final totalSize = stats['totalCacheSize'] as int;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Cache Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Image Cache: ${_formatBytes(stats['imageCacheSize'] as int)}'),
            Text('Data Cache: ${_formatBytes(stats['dataCacheSize'] as int)}'),
            Text('Total: ${_formatBytes(totalSize)}'),
            const SizedBox(height: 16),
            Text('Cache Expiration: 7 days'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              await clearImageCache();
              await _cacheService.clearAllCache();
              Get.back();
              Get.snackbar(
                'Cache Cleared',
                'All caches have been cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
  
  /// Format bytes to human readable format
  static String _formatBytes(int bytes) {
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
}
