import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:antill_estates/model/arts_antiques_model.dart';
import 'package:antill_estates/services/arts_antiques_cache_service.dart';

/// Arts & Antiques data service with caching and pagination support
class ArtsAntiquesDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ArtsAntiquesCacheService _cache = ArtsAntiquesCacheService();

  // Pagination state
  static DocumentSnapshot? _lastFeaturedDoc;
  static DocumentSnapshot? _lastTrendingDoc;
  static DocumentSnapshot? _lastCategoryDoc;

  /// Get featured arts & antiques items with caching and pagination
  static Future<List<ArtsAntiquesItem>> getFeaturedItems({
    int limit = 6, 
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    try {
      // Try cache first if not force refresh and not loading more
      if (!forceRefresh && !loadMore) {
        final cachedItems = await _cache.getFeaturedItems();
        if (cachedItems != null && cachedItems.isNotEmpty) {
          return cachedItems;
        }
      }

      // Build query
      Query query = _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .where('featured', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      // Add pagination if loading more
      if (loadMore && _lastFeaturedDoc != null) {
        query = query.startAfterDocument(_lastFeaturedDoc!);
      }

      query = query.limit(limit);
      
      // Execute query
      final querySnapshot = forceRefresh
          ? await query.get(const GetOptions(source: Source.server))
          : await query.get();

      // Update pagination state
      if (querySnapshot.docs.isNotEmpty) {
        _lastFeaturedDoc = querySnapshot.docs.last;
      }

      final items = querySnapshot.docs.map((doc) => ArtsAntiquesItem.fromFirestore(doc)).toList();
      
      // Cache the results if not loading more
      if (!loadMore && items.isNotEmpty) {
        await _cache.cacheFeaturedItems(items);
        _cache.preCacheItems(items);
      }

      return items;
    } catch (e) {
      print('❌ Error getting featured items: $e');
      return [];
    }
  }

  /// Reset featured items pagination
  static void resetFeaturedPagination() {
    _lastFeaturedDoc = null;
  }

  /// Get trending arts & antiques items with caching and pagination
  static Future<List<ArtsAntiquesItem>> getTrendingItems({
    int limit = 3, 
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    try {
      // Try cache first if not force refresh and not loading more
      if (!forceRefresh && !loadMore) {
        final cachedItems = await _cache.getTrendingItems();
        if (cachedItems != null && cachedItems.isNotEmpty) {
          return cachedItems;
        }
      }

      // Build query
      Query query = _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .orderBy('views', descending: true);

      // Add pagination if loading more
      if (loadMore && _lastTrendingDoc != null) {
        query = query.startAfterDocument(_lastTrendingDoc!);
      }

      query = query.limit(limit);
      
      final querySnapshot = forceRefresh
          ? await query.get(const GetOptions(source: Source.server))
          : await query.get();

      // Update pagination state
      if (querySnapshot.docs.isNotEmpty) {
        _lastTrendingDoc = querySnapshot.docs.last;
      }

      final items = querySnapshot.docs.map((doc) => ArtsAntiquesItem.fromFirestore(doc)).toList();
      
      // Cache the results if not loading more
      if (!loadMore && items.isNotEmpty) {
        await _cache.cacheTrendingItems(items);
        _cache.preCacheItems(items);
      }

      return items;
    } catch (e) {
      print('❌ Error getting trending items: $e');
      return [];
    }
  }

  /// Reset trending items pagination
  static void resetTrendingPagination() {
    _lastTrendingDoc = null;
  }

  /// Get items by category with caching and pagination
  static Future<List<ArtsAntiquesItem>> getItemsByCategory(
    String category, {
    int limit = 10,
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    try {
      // Try cache first if not force refresh and not loading more
      if (!forceRefresh && !loadMore) {
        final cachedItems = await _cache.getCategoryItems(category);
        if (cachedItems != null && cachedItems.isNotEmpty) {
          return cachedItems;
        }
      }

      // Build query
      Query query = _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true);

      // Add pagination if loading more
      if (loadMore && _lastCategoryDoc != null) {
        query = query.startAfterDocument(_lastCategoryDoc!);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      // Update pagination state
      if (querySnapshot.docs.isNotEmpty) {
        _lastCategoryDoc = querySnapshot.docs.last;
      }

      final items = querySnapshot.docs.map((doc) => ArtsAntiquesItem.fromFirestore(doc)).toList();
      
      // Cache the results if not loading more
      if (!loadMore && items.isNotEmpty) {
        await _cache.cacheCategoryItems(category, items);
        _cache.preCacheItems(items);
      }

      return items;
    } catch (e) {
      print('❌ Error getting items by category: $e');
      return [];
    }
  }

  /// Reset category pagination
  static void resetCategoryPagination() {
    _lastCategoryDoc = null;
  }

  /// Get all arts & antiques items (cached automatically by Firestore)
  static Future<List<ArtsAntiquesItem>> getAllItems({int limit = 20, bool forceRefresh = false}) async {
    try {
      final query = _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      final querySnapshot = forceRefresh
          ? await query.get(const GetOptions(source: Source.server))
          : await query.get();

      return querySnapshot.docs.map((doc) => ArtsAntiquesItem.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error getting all items: $e');
      return [];
    }
  }

  /// Get artists and dealers data with caching
  static Future<List<Map<String, dynamic>>> getArtistsAndDealers({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    try {
      // Try cache first if not force refresh
      if (!forceRefresh) {
        final cachedArtists = await _cache.getArtists();
        if (cachedArtists != null && cachedArtists.isNotEmpty) {
          return cachedArtists;
        }
      }

      // For now, we'll extract unique artists from the arts_antiques collection
      // In a real implementation, you might have a separate artists collection
      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .get();

      final Map<String, Map<String, dynamic>> uniqueArtists = {};
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final artistName = data['artist'] as String?;
        if (artistName != null && artistName.isNotEmpty) {
          uniqueArtists[artistName] = {
            'name': artistName,
            'type': data['category'] ?? 'Artist',
            'itemCount': (uniqueArtists[artistName]?['itemCount'] ?? 0) + 1,
          };
        }
      }

      final artists = uniqueArtists.values.take(limit).toList();
      
      // Cache the results
      if (artists.isNotEmpty) {
        await _cache.cacheArtists(artists);
      }

      return artists;
    } catch (e) {
      print('❌ Error getting artists and dealers: $e');
      return [];
    }
  }

  /// Get items by artist name (basic filter from collection)
  static Future<List<Map<String, dynamic>>> getItemsByArtist(String artistName) async {
    try {
      if (artistName.isEmpty) return [];
      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .where('artist', isEqualTo: artistName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting items by artist: $e');
      return [];
    }
  }

  /// Search arts & antiques items
  static Future<List<ArtsAntiquesItem>> searchItems(String searchTerm, {int limit = 20}) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - for better search, consider using Algolia or Elasticsearch
      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Get more to filter client-side
          .get();

      final items = querySnapshot.docs.map((doc) => ArtsAntiquesItem.fromFirestore(doc)).toList();

      // Filter client-side (basic implementation)
      final filteredItems = items.where((item) {
        final searchLower = searchTerm.toLowerCase();
        return item.title.toLowerCase().contains(searchLower) ||
               item.description.toLowerCase().contains(searchLower) ||
               item.category.toLowerCase().contains(searchLower);
      }).take(limit).toList();

      return filteredItems;
    } catch (e) {
      print('❌ Error searching items: $e');
      return [];
    }
  }

  /// Get item by ID with memory and disk caching
  static Future<ArtsAntiquesItem?> getItemById(String itemId, {bool forceRefresh = false}) async {
    try {
      // Try cache first if not force refresh
      if (!forceRefresh) {
        final cachedItem = await _cache.getItem(itemId);
        if (cachedItem != null) {
          print('✅ Item $itemId from cache (0-50ms)');
          return cachedItem;
        }
      }

      // Fetch from Firestore
      final docRef = _firestore.collection('arts_antiques').doc(itemId);
      
      final docSnapshot = forceRefresh
          ? await docRef.get(const GetOptions(source: Source.server))
          : await docRef.get();

      if (docSnapshot.exists) {
        final item = ArtsAntiquesItem.fromFirestore(docSnapshot);
        
        // Cache the item
        await _cache.cacheItem(item);
        
        print('✅ Item $itemId fetched and cached');
        return item;
      }
      return null;
    } catch (e) {
      print('❌ Error getting item by ID: $e');
      return null;
    }
  }

  /// Increment view count for an item
  static Future<void> incrementViewCount(String itemId) async {
    try {
      await _firestore
          .collection('arts_antiques')
          .doc(itemId)
          .update({
        'views': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error incrementing view count: $e');
    }
  }

  /// Update item rating
  static Future<void> updateItemRating(String itemId, double rating) async {
    try {
      await _firestore
          .collection('arts_antiques')
          .doc(itemId)
          .update({
        'rating': rating,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error updating item rating: $e');
    }
  }
}
