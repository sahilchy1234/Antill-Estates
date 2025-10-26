import 'package:antill_estates/model/property_model.dart';

/// Memory cache for INSTANT property access (faster than disk cache)
class InstantCacheService {
  static final InstantCacheService _instance = InstantCacheService._internal();
  factory InstantCacheService() => _instance;
  InstantCacheService._internal();

  // Memory cache for instant access
  final Map<String, Property> _propertyCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiry = const Duration(minutes: 30);

  /// Get property from memory (INSTANT - 0ms)
  Property? getProperty(String propertyId) {
    final timestamp = _cacheTimestamps[propertyId];
    if (timestamp != null) {
      if (DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _propertyCache[propertyId];
      } else {
        // Expired - remove
        _propertyCache.remove(propertyId);
        _cacheTimestamps.remove(propertyId);
      }
    }
    return null;
  }

  /// Set property in memory (INSTANT)
  void setProperty(String propertyId, Property property) {
    _propertyCache[propertyId] = property;
    _cacheTimestamps[propertyId] = DateTime.now();
  }

  /// Pre-cache multiple properties
  void setProperties(Map<String, Property> properties) {
    final now = DateTime.now();
    properties.forEach((id, property) {
      _propertyCache[id] = property;
      _cacheTimestamps[id] = now;
    });
  }

  /// Check if property is cached
  bool hasProperty(String propertyId) {
    return getProperty(propertyId) != null;
  }

  /// Clear expired cache
  void clearExpired() {
    final now = DateTime.now();
    final toRemove = <String>[];
    
    _cacheTimestamps.forEach((id, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiry) {
        toRemove.add(id);
      }
    });

    for (final id in toRemove) {
      _propertyCache.remove(id);
      _cacheTimestamps.remove(id);
    }
  }

  /// Clear all cache
  void clear() {
    _propertyCache.clear();
    _cacheTimestamps.clear();
  }
}

