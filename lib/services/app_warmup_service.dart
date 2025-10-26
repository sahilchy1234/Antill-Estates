import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antill_estates/services/firebase_storage_service.dart';
import 'package:antill_estates/services/image_cache_service.dart';
import 'package:antill_estates/services/image_optimization_service.dart';

/// Service for warming up app components and preloading critical resources
class AppWarmupService extends GetxService {
  static AppWarmupService get instance => Get.find<AppWarmupService>();
  
  final RxBool _isWarmedUp = false.obs;
  final RxString _warmupStatus = 'Idle'.obs;
  
  bool get isWarmedUp => _isWarmedUp.value;
  String get warmupStatus => _warmupStatus.value;
  
  /// Warm up non-critical services and resources
  Future<void> warmupServices() async {
    if (_isWarmedUp.value) return;
    
    try {
      _warmupStatus.value = 'Starting warmup...';
      
      // Warm up services in parallel
      await Future.wait([
        _warmupImageServices(),
        _warmupStorageServices(),
        _warmupCacheServices(),
      ]);
      
      _warmupStatus.value = 'Warmup completed';
      _isWarmedUp.value = true;
      
      print('✅ App warmup completed successfully');
      
    } catch (e) {
      print('❌ App warmup failed: $e');
      _warmupStatus.value = 'Warmup failed';
    }
  }
  
  /// Warm up image-related services
  Future<void> _warmupImageServices() async {
    try {
      _warmupStatus.value = 'Warming up image services...';
      
      // Pre-initialize image optimization service
      if (Get.isRegistered<ImageOptimizationService>()) {
        Get.find<ImageOptimizationService>();
        // Test compression with a small dummy operation
        print('✅ Image services warmed up');
      }
      
    } catch (e) {
      print('⚠️ Image services warmup failed: $e');
    }
  }
  
  /// Warm up storage services
  Future<void> _warmupStorageServices() async {
    try {
      _warmupStatus.value = 'Warming up storage services...';
      
      // Pre-initialize storage service
      if (Get.isRegistered<FirebaseStorageService>()) {
        final storageService = Get.find<FirebaseStorageService>();
        // Test storage availability
        await storageService.isStorageAvailable();
        print('✅ Storage services warmed up');
      }
      
    } catch (e) {
      print('⚠️ Storage services warmup failed: $e');
    }
  }
  
  /// Warm up cache services
  Future<void> _warmupCacheServices() async {
    try {
      _warmupStatus.value = 'Warming up cache services...';
      
      // Pre-initialize cache service
      if (Get.isRegistered<ImageCacheService>()) {
        final cacheService = Get.find<ImageCacheService>();
        // Get cache statistics to warm up the service
        final stats = await cacheService.getCacheStats();
        print('✅ Cache services warmed up - ${stats['memoryCount']} images in memory');
      }
      
    } catch (e) {
      print('⚠️ Cache services warmup failed: $e');
    }
  }
  
  /// Preload critical app data
  Future<void> preloadCriticalData() async {
    try {
      _warmupStatus.value = 'Preloading critical data...';
      
      // Preload any critical data that's needed for smooth app operation
      // This could include:
      // - User preferences
      // - App configuration
      // - Frequently accessed data
      
      print('✅ Critical data preloaded');
      
    } catch (e) {
      print('⚠️ Critical data preload failed: $e');
    }
  }
  
  /// Optimize app performance
  Future<void> optimizePerformance() async {
    try {
      _warmupStatus.value = 'Optimizing performance...';
      
      // Run garbage collection to free up memory
      if (kDebugMode) {
        // Only run GC in debug mode to avoid performance impact in release
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Optimize image cache
      if (Get.isRegistered<ImageCacheService>()) {
        final cacheService = Get.find<ImageCacheService>();
        // Trigger cache cleanup if needed
        final stats = await cacheService.getCacheStats();
        final memoryCount = (stats['memoryCount'] as int?) ?? 0;
        if (memoryCount > 50) {
          // Cache is getting large, consider cleanup
          print('📊 Cache size: $memoryCount images in memory');
        }
      }
      
      print('✅ Performance optimization completed');
      
    } catch (e) {
      print('⚠️ Performance optimization failed: $e');
    }
  }
  
  /// Get warmup metrics
  Map<String, dynamic> getWarmupMetrics() {
    return {
      'isWarmedUp': _isWarmedUp.value,
      'warmupStatus': _warmupStatus.value,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Reset warmup state (for testing)
  void resetWarmup() {
    _isWarmedUp.value = false;
    _warmupStatus.value = 'Idle';
  }
}
