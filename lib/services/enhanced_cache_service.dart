import 'package:get/get.dart';
import 'cache_service.dart';

/// Enhanced caching service with automatic cache refresh and intelligent pre-loading
class EnhancedCacheService extends GetxService {
  static EnhancedCacheService get instance => Get.find<EnhancedCacheService>();
  
  final CacheService _baseCache = CacheService.instance;
  
  // Cache refresh flags
  final RxBool isRefreshing = false.obs;
  final RxMap<String, DateTime> lastRefreshTime = <String, DateTime>{}.obs;
  
  // Pre-loading queue
  final List<Future<void> Function()> _preloadQueue = [];
  bool _isPreloading = false;
  
  // Cache hit/miss tracking for optimization
  final Map<String, int> _cacheHits = {};
  final Map<String, int> _cacheMisses = {};
  
  @override
  void onInit() {
    super.onInit();
    _startBackgroundRefresh();
  }
  
  // ==================== Smart Caching ====================
  
  /// Get data with automatic refresh
  Future<T?> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetchFunction,
    T? Function(dynamic)? fromCache,
    dynamic Function(T)? toCache,
    Duration maxAge = const Duration(hours: 6),
    bool forceRefresh = false,
  }) async {
    // Try cache first unless force refresh
    if (!forceRefresh) {
      final cached = await _getFromCache<T>(key, fromCache, maxAge);
      if (cached != null) {
        _trackCacheHit(key);
        
        // Background refresh if cache is older than half the maxAge
        if (_shouldBackgroundRefresh(key, maxAge)) {
          _backgroundRefresh(key, fetchFunction, toCache);
        }
        
        return cached;
      }
    }
    
    // Fetch fresh data
    _trackCacheMiss(key);
    try {
      final data = await fetchFunction();
      if (data != null) {
        await _saveToCache(key, data, toCache);
        lastRefreshTime[key] = DateTime.now();
      }
      return data;
    } catch (e) {
      print('Error fetching data for $key: $e');
      // Try to return stale cache if available
      return await _getFromCache<T>(key, fromCache, const Duration(days: 30));
    }
  }
  
  /// Get from cache
  Future<T?> _getFromCache<T>(
    String key,
    T? Function(dynamic)? fromCache,
    Duration maxAge,
  ) async {
    final cached = _baseCache.getJson(key, maxAge: maxAge);
    if (cached != null && fromCache != null) {
      try {
        return fromCache(cached);
      } catch (e) {
        print('Error parsing cached data for $key: $e');
        return null;
      }
    }
    return null;
  }
  
  /// Save to cache
  Future<void> _saveToCache<T>(
    String key,
    T data,
    dynamic Function(T)? toCache,
  ) async {
    try {
      if (toCache != null) {
        final cacheData = toCache(data);
        if (cacheData is Map<String, dynamic>) {
          await _baseCache.saveJson(key, cacheData);
        } else if (cacheData is List) {
          await _baseCache.saveJsonList(key, cacheData.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      print('Error saving to cache for $key: $e');
    }
  }
  
  /// Check if background refresh is needed
  bool _shouldBackgroundRefresh(String key, Duration maxAge) {
    final lastRefresh = lastRefreshTime[key];
    if (lastRefresh == null) return false;
    
    final halfMaxAge = Duration(milliseconds: maxAge.inMilliseconds ~/ 2);
    final timeSinceRefresh = DateTime.now().difference(lastRefresh);
    
    return timeSinceRefresh > halfMaxAge;
  }
  
  /// Background refresh
  void _backgroundRefresh<T>(
    String key,
    Future<T> Function() fetchFunction,
    dynamic Function(T)? toCache,
  ) {
    Future.microtask(() async {
      try {
        final data = await fetchFunction();
        if (data != null) {
          await _saveToCache(key, data, toCache);
          lastRefreshTime[key] = DateTime.now();
        }
      } catch (e) {
        print('Error in background refresh for $key: $e');
      }
    });
  }
  
  // ==================== Pre-loading ====================
  
  /// Add to pre-load queue
  void addToPreloadQueue(Future<void> Function() preloadFunction) {
    _preloadQueue.add(preloadFunction);
    if (!_isPreloading) {
      _processPreloadQueue();
    }
  }
  
  /// Process pre-load queue
  Future<void> _processPreloadQueue() async {
    if (_isPreloading || _preloadQueue.isEmpty) return;
    
    _isPreloading = true;
    
    while (_preloadQueue.isNotEmpty) {
      final task = _preloadQueue.removeAt(0);
      try {
        await task();
      } catch (e) {
        print('Error in preload task: $e');
      }
      
      // Small delay to not block UI
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    _isPreloading = false;
  }
  
  /// Pre-load home data
  Future<void> preloadHomeData(
    Future<Map<String, dynamic>> Function() fetchHomeData,
  ) async {
    addToPreloadQueue(() async {
      await getOrFetch(
        key: 'home_data_complete',
        fetchFunction: fetchHomeData,
        maxAge: const Duration(hours: 6),
      );
    });
  }
  
  /// Pre-load popular properties
  Future<void> preloadPopularProperties(
    Future<List<Map<String, dynamic>>> Function() fetchProperties,
  ) async {
    addToPreloadQueue(() async {
      final properties = await fetchProperties();
      await _baseCache.saveJsonList('popular_properties', properties);
    });
  }
  
  /// Pre-load arts & antiques
  Future<void> preloadArtsAntiques(
    Future<List<Map<String, dynamic>>> Function() fetchArts,
  ) async {
    addToPreloadQueue(() async {
      final arts = await fetchArts();
      await _baseCache.saveJsonList('arts_antiques_list', arts);
    });
  }
  
  // ==================== Background Refresh ====================
  
  /// Start background refresh for critical data
  void _startBackgroundRefresh() {
    // Refresh every 30 minutes
    Future.delayed(const Duration(minutes: 30), () {
      _refreshCriticalData();
      _startBackgroundRefresh(); // Restart timer
    });
  }
  
  /// Refresh critical data in background
  Future<void> _refreshCriticalData() async {
    if (isRefreshing.value) return;
    
    isRefreshing.value = true;
    
    try {
      // Refresh home data if user is likely to navigate there
      final stats = await _baseCache.getCacheStats();
      print('Cache stats: $stats');
      
      // Clean expired cache
      await _baseCache.clearCacheByPattern('expired_');
      
    } catch (e) {
      print('Error in background refresh: $e');
    } finally {
      isRefreshing.value = false;
    }
  }
  
  // ==================== Cache Analytics ====================
  
  /// Track cache hit
  void _trackCacheHit(String key) {
    _cacheHits[key] = (_cacheHits[key] ?? 0) + 1;
  }
  
  /// Track cache miss
  void _trackCacheMiss(String key) {
    _cacheMisses[key] = (_cacheMisses[key] ?? 0) + 1;
  }
  
  /// Get cache hit rate
  double getCacheHitRate(String key) {
    final hits = _cacheHits[key] ?? 0;
    final misses = _cacheMisses[key] ?? 0;
    final total = hits + misses;
    
    return total > 0 ? hits / total : 0.0;
  }
  
  /// Get all cache statistics
  Map<String, dynamic> getCacheAnalytics() {
    final totalHits = _cacheHits.values.fold(0, (sum, val) => sum + val);
    final totalMisses = _cacheMisses.values.fold(0, (sum, val) => sum + val);
    final totalRequests = totalHits + totalMisses;
    
    return {
      'totalHits': totalHits,
      'totalMisses': totalMisses,
      'totalRequests': totalRequests,
      'hitRate': totalRequests > 0 ? totalHits / totalRequests : 0.0,
      'topCachedKeys': _getTopCachedKeys(),
    };
  }
  
  /// Get top cached keys
  List<Map<String, dynamic>> _getTopCachedKeys() {
    final entries = _cacheHits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return entries.take(10).map((e) => {
      'key': e.key,
      'hits': e.value,
      'misses': _cacheMisses[e.key] ?? 0,
      'hitRate': getCacheHitRate(e.key),
    }).toList();
  }
  
  // ==================== Smart Cache Management ====================
  
  /// Invalidate cache for specific pattern
  Future<void> invalidate(String pattern) async {
    await _baseCache.clearCacheByPattern(pattern);
    lastRefreshTime.removeWhere((key, value) => key.contains(pattern));
  }
  
  /// Invalidate all property caches
  Future<void> invalidateProperties() async {
    await invalidate('property_');
    await invalidate('properties_');
  }
  
  /// Invalidate user data cache
  Future<void> invalidateUserData(String userId) async {
    await invalidate('user_$userId');
  }
  
  /// Clear old cache intelligently
  Future<void> smartCleanCache() async {
    final stats = await _baseCache.getCacheStats();
    final totalSize = stats['totalSize'] as int? ?? 0;
    
    // If cache is larger than 10MB, clean less frequently accessed data
    if (totalSize > 10 * 1024 * 1024) {
      // Remove entries with low hit rates
      for (final entry in _cacheHits.entries) {
        if (getCacheHitRate(entry.key) < 0.3) {
          await _baseCache.clearCache(entry.key);
        }
      }
    }
  }
}

