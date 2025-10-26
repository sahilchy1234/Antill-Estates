import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:antill_estates/model/arts_antiques_model.dart';

class ArtsAntiquesSearchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search arts & antiques items with multiple criteria
  static Future<List<ArtsAntiquesItem>> searchItems({
    String? query,
    String? category,
    String? artist,
    double? minPrice,
    double? maxPrice,
    bool? featured,
    int limit = 20,
  }) async {
    try {
      print('🔍 ArtsAntiquesSearchService: Firestore query filters:');
      if (category != null && category.isNotEmpty) {
        print('   Category filter: $category');
      }
      if (artist != null && artist.isNotEmpty) {
        print('   Artist filter: $artist');
      }
      if (featured != null) {
        print('   Featured filter: $featured');
      }

      Query queryRef = _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active');

      // Apply filters
      if (category != null && category.isNotEmpty) {
        queryRef = queryRef.where('category', isEqualTo: category);
      }

      // Note: status filter is already applied in the initial query above
      // Don't apply it again to avoid duplicate filter error

      if (featured != null) {
        queryRef = queryRef.where('featured', isEqualTo: featured);
      }

      // Order by creation date (newest first)
      queryRef = queryRef.orderBy('createdAt', descending: true);

      // Apply limit
      queryRef = queryRef.limit(limit);

      final querySnapshot = await queryRef.get();
      List<ArtsAntiquesItem> items = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Include the document ID
            return ArtsAntiquesItem.fromFirestore(doc);
          })
          .toList();

      print('🔍 ArtsAntiquesSearchService: Found ${items.length} items from Firestore');

      // Apply text search if query is provided
      if (query != null && query.isNotEmpty) {
        items = _filterByTextSearch(items, query);
      }

      // Filter by artist if provided
      if (artist != null && artist.isNotEmpty) {
        items = items.where((item) => 
          item.artist.toLowerCase().contains(artist.toLowerCase())
        ).toList();
      }

      // Apply price filtering if provided
      if (minPrice != null || maxPrice != null) {
        items = _filterByPrice(items, minPrice, maxPrice);
      }

      print('🔍 ArtsAntiquesSearchService: Found ${items.length} items matching criteria');
      return items;
    } catch (e) {
      print('❌ Error searching arts & antiques items: $e');
      return [];
    }
  }

  /// Filter items by text search
  static List<ArtsAntiquesItem> _filterByTextSearch(List<ArtsAntiquesItem> items, String query) {
    final searchQuery = query.toLowerCase();

    return items.where((item) {
      return item.title.toLowerCase().contains(searchQuery) ||
          item.category.toLowerCase().contains(searchQuery) ||
          item.artist.toLowerCase().contains(searchQuery) ||
          item.description.toLowerCase().contains(searchQuery) ||
          item.materials.toLowerCase().contains(searchQuery) ||
          item.location.toLowerCase().contains(searchQuery);
    }).toList();
  }

  /// Filter items by price range
  static List<ArtsAntiquesItem> _filterByPrice(List<ArtsAntiquesItem> items, double? minPrice, double? maxPrice) {
    print('🔍 Price filtering arts & antiques: minPrice=$minPrice, maxPrice=$maxPrice');

    return items.where((item) {
      final price = item.price;

      if (minPrice != null && price < minPrice) {
        return false;
      }
      if (maxPrice != null && price > maxPrice) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Get items by category
  static Future<List<ArtsAntiquesItem>> getItemsByCategory(String category, {int limit = 10}) async {
    try {
      print('🔍 Getting arts & antiques items by category: $category');

      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final items = querySnapshot.docs
          .map((doc) => ArtsAntiquesItem.fromFirestore(doc))
          .toList();

      print('🔍 Found ${items.length} items in category: $category');
      return items;
    } catch (e) {
      print('❌ Error fetching items by category: $e');
      return [];
    }
  }

  /// Get items by artist
  static Future<List<ArtsAntiquesItem>> getItemsByArtist(String artist, {int limit = 10}) async {
    try {
      print('🔍 Getting arts & antiques items by artist: $artist');

      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('artist', isEqualTo: artist)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final items = querySnapshot.docs
          .map((doc) => ArtsAntiquesItem.fromFirestore(doc))
          .toList();

      print('🔍 Found ${items.length} items by artist: $artist');
      return items;
    } catch (e) {
      print('❌ Error fetching items by artist: $e');
      return [];
    }
  }

  /// Get search suggestions based on available data
  static Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .get();

      final suggestions = <String>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final title = data['title']?.toString() ?? '';
        final artist = data['artist']?.toString() ?? '';
        final category = data['category']?.toString() ?? '';

        if (title.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(title);
        }
        if (artist.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(artist);
        }
        if (category.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(category);
        }
      }

      return suggestions.take(10).toList();
    } catch (e) {
      print('❌ Error getting search suggestions: $e');
      return [];
    }
  }

  /// Get all unique categories from arts & antiques
  static Future<List<String>> getAllCategories() async {
    try {
      print('🔍 Getting all categories from arts & antiques');

      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .get();

      final categories = <String>{};

      for (final doc in querySnapshot.docs) {
        final category = doc.data()['category']?.toString() ?? '';
        if (category.isNotEmpty) {
          categories.add(category);
        }
      }

      final categoryList = categories.toList()..sort();
      print('🔍 Found ${categoryList.length} unique categories');
      return categoryList;
    } catch (e) {
      print('❌ Error getting all categories: $e');
      return [];
    }
  }

  /// Get all unique artists from arts & antiques
  static Future<List<String>> getAllArtists() async {
    try {
      print('🔍 Getting all artists from arts & antiques');

      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .get();

      final artists = <String>{};

      for (final doc in querySnapshot.docs) {
        final artist = doc.data()['artist']?.toString() ?? '';
        if (artist.isNotEmpty) {
          artists.add(artist);
        }
      }

      final artistList = artists.toList()..sort();
      print('🔍 Found ${artistList.length} unique artists');
      return artistList;
    } catch (e) {
      print('❌ Error getting all artists: $e');
      return [];
    }
  }

  /// Get all active items without any filters
  static Future<List<ArtsAntiquesItem>> getAllItems({int limit = 50}) async {
    try {
      print('🔍 Getting all active arts & antiques items without filters');

      final querySnapshot = await _firestore
          .collection('arts_antiques')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final items = querySnapshot.docs
          .map((doc) => ArtsAntiquesItem.fromFirestore(doc))
          .toList();

      print('🔍 Found ${items.length} active items');
      return items;
    } catch (e) {
      print('❌ Error getting all items: $e');
      return [];
    }
  }
}

