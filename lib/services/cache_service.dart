import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

/// Comprehensive caching service for fast app loading
class CacheService extends GetxService {
  static CacheService? _instance;
  SharedPreferences? _prefs;
  
  // Cache configuration
  static const Duration _defaultCacheDuration = Duration(hours: 24);
  static const Duration _imageCacheDuration = Duration(days: 7);
  static const Duration _propertyCacheDuration = Duration(hours: 6);
  static const Duration _userCacheDuration = Duration(hours: 12);
  
  // Cache keys
  static const String _cacheKeyPrefix = 'cache_';
  static const String _cacheTimePrefix = 'cache_time_';
  
  // Memory cache for frequently accessed data
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _memoryCacheTime = {};
  
  static CacheService get instance {
    _instance ??= CacheService._();
    return _instance!;
  }
  
  CacheService._();
  
  /// Initialize cache service
  Future<CacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _cleanExpiredCache();
    return this;
  }
  
  // ==================== String Cache ====================
  
  /// Save string to cache
  Future<bool> saveString(String key, String value, {Duration? duration}) async {
    try {
      await _prefs?.setString('$_cacheKeyPrefix$key', value);
      await _prefs?.setInt(
        '$_cacheTimePrefix$key',
        DateTime.now().millisecondsSinceEpoch,
      );
      
      // Also save to memory cache
      _memoryCache[key] = value;
      _memoryCacheTime[key] = DateTime.now();
      
      return true;
    } catch (e) {
      print('Error saving string to cache: $e');
      return false;
    }
  }
  
  /// Get string from cache
  String? getString(String key, {Duration? maxAge}) {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      if (_isCacheValid(key, maxAge ?? _defaultCacheDuration, useMemory: true)) {
        return _memoryCache[key] as String?;
      }
    }
    
    // Check disk cache
    if (_isCacheValid(key, maxAge ?? _defaultCacheDuration)) {
      final value = _prefs?.getString('$_cacheKeyPrefix$key');
      
      // Update memory cache
      if (value != null) {
        _memoryCache[key] = value;
        _memoryCacheTime[key] = DateTime.now();
      }
      
      return value;
    }
    
    return null;
  }
  
  // ==================== JSON Cache ====================
  
  /// Save JSON object to cache
  Future<bool> saveJson(String key, Map<String, dynamic> data, {Duration? duration}) async {
    try {
      final jsonString = jsonEncode(data);
      return await saveString(key, jsonString, duration: duration);
    } catch (e) {
      print('Error saving JSON to cache: $e');
      return false;
    }
  }
  
  /// Get JSON object from cache
  Map<String, dynamic>? getJson(String key, {Duration? maxAge}) {
    try {
      final jsonString = getString(key, maxAge: maxAge);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting JSON from cache: $e');
    }
    return null;
  }
  
  /// Save list of JSON objects
  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> data, {Duration? duration}) async {
    try {
      final jsonString = jsonEncode(data);
      return await saveString(key, jsonString, duration: duration);
    } catch (e) {
      print('Error saving JSON list to cache: $e');
      return false;
    }
  }
  
  /// Get list of JSON objects from cache
  List<Map<String, dynamic>>? getJsonList(String key, {Duration? maxAge}) {
    try {
      final jsonString = getString(key, maxAge: maxAge);
      if (jsonString != null) {
        final decoded = jsonDecode(jsonString);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Error getting JSON list from cache: $e');
    }
    return null;
  }
  
  // ==================== Property Cache ====================
  
  /// Cache property data
  Future<bool> cacheProperty(String propertyId, Map<String, dynamic> propertyData) async {
    return await saveJson(
      'property_$propertyId',
      propertyData,
      duration: _propertyCacheDuration,
    );
  }
  
  /// Get cached property
  Map<String, dynamic>? getCachedProperty(String propertyId) {
    return getJson('property_$propertyId', maxAge: _propertyCacheDuration);
  }
  
  /// Cache property list
  Future<bool> cachePropertyList(String listKey, List<Map<String, dynamic>> properties) async {
    return await saveJsonList(
      'property_list_$listKey',
      properties,
      duration: _propertyCacheDuration,
    );
  }
  
  /// Get cached property list
  List<Map<String, dynamic>>? getCachedPropertyList(String listKey) {
    return getJsonList('property_list_$listKey', maxAge: _propertyCacheDuration);
  }
  
  // ==================== User Data Cache ====================
  
  /// Cache user data
  Future<bool> cacheUserData(String userId, Map<String, dynamic> userData) async {
    return await saveJson(
      'user_$userId',
      userData,
      duration: _userCacheDuration,
    );
  }
  
  /// Get cached user data
  Map<String, dynamic>? getCachedUserData(String userId) {
    return getJson('user_$userId', maxAge: _userCacheDuration);
  }
  
  // ==================== Search Cache ====================
  
  /// Cache search results
  Future<bool> cacheSearchResults(String query, List<Map<String, dynamic>> results) async {
    return await saveJsonList(
      'search_${query.toLowerCase()}',
      results,
      duration: const Duration(hours: 1),
    );
  }
  
  /// Get cached search results
  List<Map<String, dynamic>>? getCachedSearchResults(String query) {
    return getJsonList('search_${query.toLowerCase()}', maxAge: const Duration(hours: 1));
  }
  
  // ==================== Image Cache ====================
  
  /// Cache image URL mapping
  Future<bool> cacheImageUrl(String imageKey, String url) async {
    return await saveString('image_$imageKey', url, duration: _imageCacheDuration);
  }
  
  /// Get cached image URL
  String? getCachedImageUrl(String imageKey) {
    return getString('image_$imageKey', maxAge: _imageCacheDuration);
  }
  
  // ==================== API Response Cache ====================
  
  /// Cache API response
  Future<bool> cacheApiResponse(String endpoint, Map<String, dynamic> response, {Duration? duration}) async {
    return await saveJson(
      'api_${endpoint.replaceAll('/', '_')}',
      response,
      duration: duration ?? _defaultCacheDuration,
    );
  }
  
  /// Get cached API response
  Map<String, dynamic>? getCachedApiResponse(String endpoint, {Duration? maxAge}) {
    return getJson(
      'api_${endpoint.replaceAll('/', '_')}',
      maxAge: maxAge ?? _defaultCacheDuration,
    );
  }
  
  // ==================== Cache Validation ====================
  
  /// Check if cache is valid
  bool _isCacheValid(String key, Duration maxAge, {bool useMemory = false}) {
    try {
      int? cacheTime;
      
      if (useMemory && _memoryCacheTime.containsKey(key)) {
        cacheTime = _memoryCacheTime[key]!.millisecondsSinceEpoch;
      } else {
        cacheTime = _prefs?.getInt('$_cacheTimePrefix$key');
      }
      
      if (cacheTime == null) return false;
      
      final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      final now = DateTime.now();
      final difference = now.difference(cacheDate);
      
      return difference <= maxAge;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }
  
  /// Check if key exists in cache
  bool hasCache(String key) {
    return _memoryCache.containsKey(key) || 
           _prefs?.containsKey('$_cacheKeyPrefix$key') == true;
  }
  
  // ==================== Cache Management ====================
  
  /// Clear specific cache
  Future<bool> clearCache(String key) async {
    try {
      _memoryCache.remove(key);
      _memoryCacheTime.remove(key);
      
      await _prefs?.remove('$_cacheKeyPrefix$key');
      await _prefs?.remove('$_cacheTimePrefix$key');
      
      return true;
    } catch (e) {
      print('Error clearing cache: $e');
      return false;
    }
  }
  
  /// Clear all cache
  Future<bool> clearAllCache() async {
    try {
      _memoryCache.clear();
      _memoryCacheTime.clear();
      
      final keys = _prefs?.getKeys() ?? {};
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix) || key.startsWith(_cacheTimePrefix)) {
          await _prefs?.remove(key);
        }
      }
      
      return true;
    } catch (e) {
      print('Error clearing all cache: $e');
      return false;
    }
  }
  
  /// Clear expired cache entries
  Future<void> _cleanExpiredCache() async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      final now = DateTime.now();
      
      for (final key in keys) {
        if (key.startsWith(_cacheTimePrefix)) {
          final cacheKey = key.substring(_cacheTimePrefix.length);
          final cacheTime = _prefs?.getInt(key);
          
          if (cacheTime != null) {
            final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
            final difference = now.difference(cacheDate);
            
            // Remove if older than 7 days
            if (difference > const Duration(days: 7)) {
              await clearCache(cacheKey);
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning expired cache: $e');
    }
  }
  
  /// Clear cache by pattern
  Future<void> clearCacheByPattern(String pattern) async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      for (final key in keys) {
        if (key.contains(pattern)) {
          final cacheKey = key.substring(_cacheKeyPrefix.length);
          await clearCache(cacheKey);
        }
      }
      
      // Clear from memory cache
      _memoryCache.removeWhere((key, value) => key.contains(pattern));
      _memoryCacheTime.removeWhere((key, value) => key.contains(pattern));
    } catch (e) {
      print('Error clearing cache by pattern: $e');
    }
  }
  
  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      int size = 0;
      
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix)) {
          final value = _prefs?.getString(key);
          if (value != null) {
            size += value.length;
          }
        }
      }
      
      return size;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }
  
  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      int totalEntries = 0;
      int expiredEntries = 0;
      int totalSize = 0;
      final now = DateTime.now();
      
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix)) {
          totalEntries++;
          
          final value = _prefs?.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
          
          final cacheKey = key.substring(_cacheKeyPrefix.length);
          final cacheTime = _prefs?.getInt('$_cacheTimePrefix$cacheKey');
          
          if (cacheTime != null) {
            final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
            final difference = now.difference(cacheDate);
            
            if (difference > const Duration(days: 7)) {
              expiredEntries++;
            }
          }
        }
      }
      
      return {
        'totalEntries': totalEntries,
        'expiredEntries': expiredEntries,
        'totalSize': totalSize,
        'memoryCacheSize': _memoryCache.length,
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {};
    }
  }
  
  // ==================== Pre-cache Strategies ====================
  
  /// Pre-cache home data
  Future<void> preCacheHomeData(Map<String, dynamic> homeData) async {
    await saveJson('home_data', homeData, duration: _propertyCacheDuration);
  }
  
  /// Get pre-cached home data
  Map<String, dynamic>? getPreCachedHomeData() {
    return getJson('home_data', maxAge: _propertyCacheDuration);
  }
  
  /// Pre-cache featured properties
  Future<void> preCacheFeaturedProperties(List<Map<String, dynamic>> properties) async {
    await saveJsonList('featured_properties', properties, duration: _propertyCacheDuration);
  }
  
  /// Get pre-cached featured properties
  List<Map<String, dynamic>>? getPreCachedFeaturedProperties() {
    return getJsonList('featured_properties', maxAge: _propertyCacheDuration);
  }
}

/// Cache service initializer
Future<CacheService> initCacheService() async {
  return await CacheService.instance.init();
}
