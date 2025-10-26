import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:antill_estates/services/image_optimization_service.dart';
import 'package:antill_estates/services/firebase_storage_service.dart';

/// Enhanced image service that combines compression, caching, and optimization
class EnhancedImageService extends GetxService {
  late final ImageOptimizationService _imageOptimizationService;
  late final FirebaseStorageService _firebaseStorageService;
  
  // Cache for processed images
  final Map<String, Uint8List> _imageCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache settings
  static const Duration _cacheExpiry = Duration(hours: 24);
  static const int _maxCacheSize = 50; // Maximum number of cached images
  
  @override
  void onInit() {
    super.onInit();
    _imageOptimizationService = Get.find<ImageOptimizationService>();
    _firebaseStorageService = Get.find<FirebaseStorageService>();
    
    // Clean up expired cache periodically
    _scheduleCacheCleanup();
  }
  
  /// Process and upload image with automatic optimization
  Future<String?> processAndUploadImage({
    required File imageFile,
    required String userId,
    String folder = 'properties',
    ImageUseCase useCase = ImageUseCase.propertyMain,
    bool createThumbnail = true,
    bool enableCompression = true,
  }) async {
    try {
      print('🖼️ Processing image: ${imageFile.path}');
      
      // Validate image first
      final validation = await _imageOptimizationService.validateImage(imageFile);
      if (!validation.isValid) {
        throw Exception('Image validation failed: ${validation.error}');
      }
      
      // Process image based on use case
      Uint8List processedBytes;
      if (enableCompression) {
        processedBytes = await _imageOptimizationService.optimizeForUseCase(
          imageFile: imageFile,
          useCase: useCase,
        );
      } else {
        processedBytes = await imageFile.readAsBytes();
      }
      
      // Upload to Firebase Storage
      final downloadUrl = await _firebaseStorageService.uploadOptimizedImage(
        imageFile: imageFile,
        userId: userId,
        folder: folder,
        useCase: useCase,
        createThumbnail: createThumbnail,
      );
      
      // Cache the processed image
      if (downloadUrl != null) {
        _cacheImage(downloadUrl, processedBytes);
      }
      
      return downloadUrl;
      
    } catch (e) {
      print('❌ Error processing image: $e');
      throw e;
    }
  }
  
  /// Get optimized image with caching
  Future<Uint8List?> getOptimizedImage({
    required String imageUrl,
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      // Check cache first
      final cacheKey = '${imageUrl}_${maxWidth ?? 0}_${maxHeight ?? 0}_$quality';
      if (_imageCache.containsKey(cacheKey)) {
        final timestamp = _cacheTimestamps[cacheKey];
        if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
          print('📦 Using cached image: $cacheKey');
          return _imageCache[cacheKey];
        } else {
          // Remove expired cache
          _imageCache.remove(cacheKey);
          _cacheTimestamps.remove(cacheKey);
        }
      }
      
      // Download and process image
      // Note: In a real implementation, you would download the image here
      // For now, we'll return null to indicate cache miss
      print('🔄 Cache miss for image: $imageUrl');
      return null;
      
    } catch (e) {
      print('❌ Error getting optimized image: $e');
      return null;
    }
  }
  
  /// Preload images for better performance
  Future<void> preloadImages(List<String> imageUrls) async {
    try {
      print('🚀 Preloading ${imageUrls.length} images...');
      
      for (final url in imageUrls) {
        try {
          // Preload with different sizes for responsive loading
          await getOptimizedImage(imageUrl: url, maxWidth: 300, quality: 80);
          await getOptimizedImage(imageUrl: url, maxWidth: 600, quality: 85);
          await getOptimizedImage(imageUrl: url, maxWidth: 1200, quality: 90);
        } catch (e) {
          print('⚠️ Failed to preload image: $url - $e');
        }
      }
      
      print('✅ Image preloading completed');
      
    } catch (e) {
      print('❌ Error preloading images: $e');
    }
  }
  
  /// Get image dimensions without loading full image
  Future<Map<String, int>?> getImageDimensions(String imageUrl) async {
    try {
      // This would typically involve downloading just the image header
      // For now, return null to indicate not implemented
      return null;
    } catch (e) {
      print('❌ Error getting image dimensions: $e');
      return null;
    }
  }
  
  /// Generate responsive image URLs
  List<String> generateResponsiveUrls(String baseUrl, List<int> sizes) {
    return sizes.map((size) => '${baseUrl}?w=$size&q=85').toList();
  }
  
  /// Cache image data
  void _cacheImage(String key, Uint8List imageBytes) {
    try {
      // Check cache size limit
      if (_imageCache.length >= _maxCacheSize) {
        _cleanupOldestCache();
      }
      
      _imageCache[key] = imageBytes;
      _cacheTimestamps[key] = DateTime.now();
      
      print('💾 Cached image: $key (${(imageBytes.length / 1024).toStringAsFixed(1)} KB)');
      
    } catch (e) {
      print('❌ Error caching image: $e');
    }
  }
  
  /// Clean up oldest cache entries
  void _cleanupOldestCache() {
    try {
      if (_cacheTimestamps.isEmpty) return;
      
      // Find oldest entry
      String? oldestKey;
      DateTime? oldestTime;
      
      for (final entry in _cacheTimestamps.entries) {
        if (oldestTime == null || entry.value.isBefore(oldestTime)) {
          oldestTime = entry.value;
          oldestKey = entry.key;
        }
      }
      
      if (oldestKey != null) {
        _imageCache.remove(oldestKey);
        _cacheTimestamps.remove(oldestKey);
        print('🗑️ Removed oldest cache entry: $oldestKey');
      }
      
    } catch (e) {
      print('❌ Error cleaning up cache: $e');
    }
  }
  
  /// Schedule periodic cache cleanup
  void _scheduleCacheCleanup() {
    // Run cleanup every hour
    Future.delayed(const Duration(hours: 1), () {
      _cleanupExpiredCache();
      _scheduleCacheCleanup();
    });
  }
  
  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];
      
      for (final entry in _cacheTimestamps.entries) {
        if (now.difference(entry.value) > _cacheExpiry) {
          expiredKeys.add(entry.key);
        }
      }
      
      for (final key in expiredKeys) {
        _imageCache.remove(key);
        _cacheTimestamps.remove(key);
      }
      
      if (expiredKeys.isNotEmpty) {
        print('🗑️ Cleaned up ${expiredKeys.length} expired cache entries');
      }
      
    } catch (e) {
      print('❌ Error cleaning up expired cache: $e');
    }
  }
  
  /// Clear all cache
  void clearCache() {
    _imageCache.clear();
    _cacheTimestamps.clear();
    print('🧹 Cleared all image cache');
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedImages': _imageCache.length,
      'maxCacheSize': _maxCacheSize,
      'cacheExpiry': _cacheExpiry.inHours,
      'totalCacheSize': _imageCache.values
          .fold<int>(0, (sum, bytes) => sum + bytes.length),
    };
  }

  /// Create high-quality thumbnail for better visual quality
  Future<Uint8List?> createHighQualityThumbnail({
    required File imageFile,
    int size = 400,
    int quality = 90,
  }) async {
    try {
      print('🖼️ Creating high-quality thumbnail: ${imageFile.path}');
      
      final thumbnailBytes = await _imageOptimizationService.createThumbnail(
        imageFile: imageFile,
        size: size,
        quality: quality,
      );
      
      print('✅ High-quality thumbnail created: ${(thumbnailBytes.length / 1024).toStringAsFixed(1)} KB');
      return thumbnailBytes;
      
    } catch (e) {
      print('❌ Error creating high-quality thumbnail: $e');
      return null;
    }
  }
  
  /// Optimize image for specific display size
  Future<Uint8List?> optimizeForDisplay({
    required String imageUrl,
    required double displayWidth,
    required double displayHeight,
    double devicePixelRatio = 2.0,
  }) async {
    try {
      // Calculate optimal dimensions
      final optimalDimensions = _imageOptimizationService.getOptimalDimensions(
        displayWidth: displayWidth,
        displayHeight: displayHeight,
        devicePixelRatio: devicePixelRatio,
      );
      
      return await getOptimizedImage(
        imageUrl: imageUrl,
        maxWidth: optimalDimensions['width'],
        maxHeight: optimalDimensions['height'],
        quality: optimalDimensions['quality'] as int,
      );
      
    } catch (e) {
      print('❌ Error optimizing image for display: $e');
      return null;
    }
  }
  
  /// Batch process multiple images
  Future<List<String?>> batchProcessImages({
    required List<File> imageFiles,
    required String userId,
    String folder = 'properties',
    ImageUseCase useCase = ImageUseCase.propertyGallery,
  }) async {
    try {
      print('📦 Batch processing ${imageFiles.length} images...');
      
      final results = <String?>[];
      
      for (int i = 0; i < imageFiles.length; i++) {
        try {
          final url = await processAndUploadImage(
            imageFile: imageFiles[i],
            userId: userId,
            folder: folder,
            useCase: useCase,
            createThumbnail: i == 0, // Create thumbnail for first image only
          );
          results.add(url);
          print('✅ Processed image ${i + 1}/${imageFiles.length}');
        } catch (e) {
          print('❌ Failed to process image ${i + 1}: $e');
          results.add(null);
        }
      }
      
      print('📦 Batch processing completed: ${results.where((url) => url != null).length}/${imageFiles.length} successful');
      return results;
      
    } catch (e) {
      print('❌ Error in batch processing: $e');
      return List.filled(imageFiles.length, null);
    }
  }
}
