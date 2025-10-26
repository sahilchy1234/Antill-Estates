import 'package:antill_estates/model/arts_antiques_model.dart';
import 'package:antill_estates/services/cache_service.dart';

/// Instant memory cache + disk cache for Arts & Antiques
class ArtsAntiquesCacheService {
  static final ArtsAntiquesCacheService _instance = ArtsAntiquesCacheService._internal();
  factory ArtsAntiquesCacheService() => _instance;
  ArtsAntiquesCacheService._internal();

  // Memory cache for instant access (0ms)
  final Map<String, ArtsAntiquesItem> _itemCache = {};
  final Map<String, List<ArtsAntiquesItem>> _listCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiry = const Duration(minutes: 30);

  // Disk cache instance
  final CacheService _diskCache = CacheService.instance;

  // Cache keys
  static const String _featuredItemsKey = 'arts_featured_items';
  static const String _trendingItemsKey = 'arts_trending_items';
  static const String _artistsKey = 'arts_artists';
  static const String _categoryPrefix = 'arts_category_';
  static const String _itemPrefix = 'arts_item_';

  // ==================== Featured Items Cache ====================

  /// Get featured items from cache (memory first, then disk)
  Future<List<ArtsAntiquesItem>?> getFeaturedItems() async {
    // Try memory cache first (instant)
    final memoryItems = _getFromMemoryList(_featuredItemsKey);
    if (memoryItems != null && memoryItems.isNotEmpty) {
      print('✅ Featured items from memory cache (0ms)');
      return memoryItems;
    }

    // Try disk cache
    final diskData = _diskCache.getJsonList(_featuredItemsKey, maxAge: const Duration(hours: 6));
    if (diskData != null && diskData.isNotEmpty) {
      try {
        final items = diskData.map((json) => _itemFromJson(json)).toList();
        _setInMemoryList(_featuredItemsKey, items);
        print('✅ Featured items from disk cache (~50ms)');
        return items;
      } catch (e) {
        print('❌ Error parsing featured items from cache: $e');
      }
    }

    return null;
  }

  /// Cache featured items (memory + disk)
  Future<void> cacheFeaturedItems(List<ArtsAntiquesItem> items) async {
    _setInMemoryList(_featuredItemsKey, items);
    final jsonList = items.map((item) => _itemToJson(item)).toList();
    await _diskCache.saveJsonList(_featuredItemsKey, jsonList, duration: const Duration(hours: 6));
    print('✅ Cached ${items.length} featured items');
  }

  // ==================== Trending Items Cache ====================

  /// Get trending items from cache
  Future<List<ArtsAntiquesItem>?> getTrendingItems() async {
    // Memory cache first
    final memoryItems = _getFromMemoryList(_trendingItemsKey);
    if (memoryItems != null && memoryItems.isNotEmpty) {
      print('✅ Trending items from memory cache (0ms)');
      return memoryItems;
    }

    // Disk cache
    final diskData = _diskCache.getJsonList(_trendingItemsKey, maxAge: const Duration(hours: 6));
    if (diskData != null && diskData.isNotEmpty) {
      try {
        final items = diskData.map((json) => _itemFromJson(json)).toList();
        _setInMemoryList(_trendingItemsKey, items);
        print('✅ Trending items from disk cache (~50ms)');
        return items;
      } catch (e) {
        print('❌ Error parsing trending items from cache: $e');
      }
    }

    return null;
  }

  /// Cache trending items
  Future<void> cacheTrendingItems(List<ArtsAntiquesItem> items) async {
    _setInMemoryList(_trendingItemsKey, items);
    final jsonList = items.map((item) => _itemToJson(item)).toList();
    await _diskCache.saveJsonList(_trendingItemsKey, jsonList, duration: const Duration(hours: 6));
    print('✅ Cached ${items.length} trending items');
  }

  // ==================== Category Items Cache ====================

  /// Get items by category from cache
  Future<List<ArtsAntiquesItem>?> getCategoryItems(String category) async {
    final key = '$_categoryPrefix$category';
    
    // Memory cache first
    final memoryItems = _getFromMemoryList(key);
    if (memoryItems != null && memoryItems.isNotEmpty) {
      return memoryItems;
    }

    // Disk cache
    final diskData = _diskCache.getJsonList(key, maxAge: const Duration(hours: 4));
    if (diskData != null && diskData.isNotEmpty) {
      try {
        final items = diskData.map((json) => _itemFromJson(json)).toList();
        _setInMemoryList(key, items);
        return items;
      } catch (e) {
        print('❌ Error parsing category items from cache: $e');
      }
    }

    return null;
  }

  /// Cache items by category
  Future<void> cacheCategoryItems(String category, List<ArtsAntiquesItem> items) async {
    final key = '$_categoryPrefix$category';
    _setInMemoryList(key, items);
    final jsonList = items.map((item) => _itemToJson(item)).toList();
    await _diskCache.saveJsonList(key, jsonList, duration: const Duration(hours: 4));
  }

  // ==================== Individual Item Cache ====================

  /// Get single item from cache (memory first)
  Future<ArtsAntiquesItem?> getItem(String itemId) async {
    // Memory cache first (instant)
    final memoryItem = _getFromMemory(itemId);
    if (memoryItem != null) {
      return memoryItem;
    }

    // Disk cache
    final diskData = _diskCache.getJson('$_itemPrefix$itemId', maxAge: const Duration(hours: 12));
    if (diskData != null) {
      try {
        final item = _itemFromJson(diskData);
        _setInMemory(itemId, item);
        return item;
      } catch (e) {
        print('❌ Error parsing item from cache: $e');
      }
    }

    return null;
  }

  /// Cache single item
  Future<void> cacheItem(ArtsAntiquesItem item) async {
    if (item.id == null) return;
    
    _setInMemory(item.id!, item);
    final json = _itemToJson(item);
    await _diskCache.saveJson('$_itemPrefix${item.id}', json, duration: const Duration(hours: 12));
  }

  // ==================== Artists Cache ====================

  /// Get artists from cache
  Future<List<Map<String, dynamic>>?> getArtists() async {
    final diskData = _diskCache.getJsonList(_artistsKey, maxAge: const Duration(hours: 12));
    return diskData;
  }

  /// Cache artists
  Future<void> cacheArtists(List<Map<String, dynamic>> artists) async {
    await _diskCache.saveJsonList(_artistsKey, artists, duration: const Duration(hours: 12));
  }

  // ==================== Memory Cache Helpers ====================

  /// Get item from memory cache
  ArtsAntiquesItem? _getFromMemory(String itemId) {
    final timestamp = _cacheTimestamps[itemId];
    if (timestamp != null) {
      if (DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _itemCache[itemId];
      } else {
        _itemCache.remove(itemId);
        _cacheTimestamps.remove(itemId);
      }
    }
    return null;
  }

  /// Set item in memory cache
  void _setInMemory(String itemId, ArtsAntiquesItem item) {
    _itemCache[itemId] = item;
    _cacheTimestamps[itemId] = DateTime.now();
  }

  /// Get list from memory cache
  List<ArtsAntiquesItem>? _getFromMemoryList(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null) {
      if (DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _listCache[key];
      } else {
        _listCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }

  /// Set list in memory cache
  void _setInMemoryList(String key, List<ArtsAntiquesItem> items) {
    _listCache[key] = items;
    _cacheTimestamps[key] = DateTime.now();
  }

  // ==================== JSON Conversion ====================

  /// Convert item to JSON
  Map<String, dynamic> _itemToJson(ArtsAntiquesItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'category': item.category,
      'artist': item.artist,
      'price': item.price,
      'description': item.description,
      'year': item.year,
      'dimensions': item.dimensions,
      'materials': item.materials,
      'location': item.location,
      'status': item.status,
      'featured': item.featured,
      'images': item.images,
      'views': item.views,
      'rating': item.rating,
      'createdAt': item.createdAt?.toIso8601String(),
      'updatedAt': item.updatedAt?.toIso8601String(),
    };
  }

  /// Convert JSON to item
  ArtsAntiquesItem _itemFromJson(Map<String, dynamic> json) {
    return ArtsAntiquesItem(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      artist: json['artist'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      year: json['year'],
      dimensions: json['dimensions'] ?? '',
      materials: json['materials'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'active',
      featured: json['featured'] ?? false,
      images: List<String>.from(json['images'] ?? []),
      views: json['views'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // ==================== Cache Management ====================

  /// Clear all arts & antiques cache
  Future<void> clearAll() async {
    _itemCache.clear();
    _listCache.clear();
    _cacheTimestamps.clear();
    
    await _diskCache.clearCacheByPattern('arts_');
    print('✅ Cleared all arts & antiques cache');
  }

  /// Clear expired cache entries
  void clearExpired() {
    final now = DateTime.now();
    final toRemove = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiry) {
        toRemove.add(key);
      }
    });

    for (final key in toRemove) {
      _itemCache.remove(key);
      _listCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Invalidate specific category cache
  Future<void> invalidateCategory(String category) async {
    final key = '$_categoryPrefix$category';
    _listCache.remove(key);
    _cacheTimestamps.remove(key);
    await _diskCache.clearCache(key);
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memoryItemsCount': _itemCache.length,
      'memoryListsCount': _listCache.length,
      'totalMemoryEntries': _cacheTimestamps.length,
    };
  }

  /// Pre-cache multiple items for faster access
  void preCacheItems(List<ArtsAntiquesItem> items) {
    final now = DateTime.now();
    for (final item in items) {
      if (item.id != null) {
        _itemCache[item.id!] = item;
        _cacheTimestamps[item.id!] = now;
      }
    }
  }
}

