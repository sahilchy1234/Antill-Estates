import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:antill_estates/model/property_model.dart';

class SearchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search properties with multiple criteria
  static Future<List<Property>> searchProperties({
    String? query,
    String? city,
    String? propertyType,
    String? propertyLooking,
    String? category,
    String? noOfBedrooms,
    String? availabilityStatus,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
  }) async {
    try {
      print('🔍 SearchService: Firestore query filters:');
      if (city != null && city.isNotEmpty) {
        print('   City filter: $city');
      }
      if (propertyType != null && propertyType.isNotEmpty) {
        print('   Property Type filter: $propertyType');
      }
      if (propertyLooking != null && propertyLooking.isNotEmpty) {
        print('   Property Looking filter: $propertyLooking');
      }
      if (category != null && category.isNotEmpty) {
        print('   Category filter: $category');
      }
      if (noOfBedrooms != null && noOfBedrooms.isNotEmpty) {
        print('   Bedrooms filter: $noOfBedrooms');
      }
      if (availabilityStatus != null && availabilityStatus.isNotEmpty) {
        print('   Availability filter: $availabilityStatus');
      }

      Query queryRef = _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (city != null && city.isNotEmpty) {
        queryRef = queryRef.where('city', isEqualTo: city);
      }

      if (propertyType != null && propertyType.isNotEmpty) {
        queryRef = queryRef.where('propertyType', isEqualTo: propertyType);
      }

      if (propertyLooking != null && propertyLooking.isNotEmpty) {
        queryRef = queryRef.where('propertyLooking', isEqualTo: propertyLooking);
      }

      if (category != null && category.isNotEmpty) {
        queryRef = queryRef.where('category', isEqualTo: category);
      }

      if (noOfBedrooms != null && noOfBedrooms.isNotEmpty) {
        queryRef = queryRef.where('noOfBedrooms', isEqualTo: noOfBedrooms);
      }

      if (availabilityStatus != null && availabilityStatus.isNotEmpty) {
        queryRef = queryRef.where('availabilityStatus', isEqualTo: availabilityStatus);
      }

      // Order by creation date (newest first)
      queryRef = queryRef.orderBy('createdAt', descending: true);

      // Apply limit
      queryRef = queryRef.limit(limit);

      final querySnapshot = await queryRef.get();
      List<Property> properties = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Include the document ID
            return Property.fromMap(data);
          })
          .toList();

      print('🔍 SearchService: Found ${properties.length} properties from Firestore');
      
      // Debug: Log first property data if available
      if (properties.isNotEmpty) {
        final firstProperty = properties.first;
        print('🔍 Sample property data:');
        print('   ID: ${firstProperty.id}');
        print('   Property Looking: "${firstProperty.propertyLooking}"');
        print('   Category: "${firstProperty.category}"');
        print('   Property Type: "${firstProperty.propertyType}"');
        print('   City: "${firstProperty.city}"');
        print('   Bedrooms: "${firstProperty.noOfBedrooms}"');
        print('   Availability: "${firstProperty.availabilityStatus}"');
        print('   Price: "${firstProperty.expectedPrice}"');
      } else {
        print('🔍 No properties found with current filters');
        print('🔍 Let me check what properties exist without filters...');
        
        // Get all properties without filters to see what's in the database
        final allPropertiesQuery = _firestore
            .collection('properties')
            .where('isActive', isEqualTo: true)
            .limit(5);
        
        final allPropertiesSnapshot = await allPropertiesQuery.get();
        if (allPropertiesSnapshot.docs.isNotEmpty) {
          print('🔍 Found ${allPropertiesSnapshot.docs.length} properties in database:');
          for (int i = 0; i < allPropertiesSnapshot.docs.length; i++) {
            final doc = allPropertiesSnapshot.docs[i];
            final data = doc.data();
            print('   Property ${i + 1}:');
            print('     ID: ${doc.id}');
            print('     Property Looking: "${data['propertyLooking']}"');
            print('     Category: "${data['category']}"');
            print('     Property Type: "${data['propertyType']}"');
            print('     City: "${data['city']}"');
            print('     Bedrooms: "${data['noOfBedrooms']}"');
            print('     Availability: "${data['availabilityStatus']}"');
            print('     Price: "${data['expectedPrice']}"');
          }
        } else {
          print('🔍 No properties found in database at all');
        }
      }

      // Apply text search if query is provided
      if (query != null && query.isNotEmpty) {
        properties = _filterByTextSearch(properties, query);
      }

      // Apply price filtering if provided
      if (minPrice != null || maxPrice != null) {
        properties = _filterByPrice(properties, minPrice, maxPrice);
      }

      print('🔍 Found ${properties.length} properties matching criteria');
      return properties;
    } catch (e) {
      print('❌ Error searching properties: $e');
      return [];
    }
  }

  /// Filter properties by text search
  static List<Property> _filterByTextSearch(List<Property> properties, String query) {
    final searchQuery = query.toLowerCase();
    
    return properties.where((property) {
      return property.city.toLowerCase().contains(searchQuery) ||
          property.locality.toLowerCase().contains(searchQuery) ||
          property.subLocality.toLowerCase().contains(searchQuery) ||
          property.propertyType.toLowerCase().contains(searchQuery) ||
          property.description.toLowerCase().contains(searchQuery) ||
          property.amenities.any((amenity) => amenity.toLowerCase().contains(searchQuery)) ||
          property.locationAdvantages.any((advantage) => advantage.toLowerCase().contains(searchQuery));
    }).toList();
  }

  /// Filter properties by price range
  static List<Property> _filterByPrice(List<Property> properties, double? minPrice, double? maxPrice) {
    print('🔍 Price filtering: minPrice=$minPrice, maxPrice=$maxPrice');
    
    return properties.where((property) {
      try {
        // Extract numeric value from expectedPrice string
        final priceString = property.expectedPrice.replaceAll(RegExp(r'[^\d.]'), '');
        final price = double.tryParse(priceString);
        
        print('🔍 Property ${property.id}: expectedPrice="${property.expectedPrice}", parsed price=$price');
        
        if (price == null) {
          print('🔍 Property ${property.id}: Could not parse price, excluding');
          return false;
        }
        
        if (minPrice != null && price < minPrice) {
          print('🔍 Property ${property.id}: Price $price < minPrice $minPrice, excluding');
          return false;
        }
        if (maxPrice != null && price > maxPrice) {
          print('🔍 Property ${property.id}: Price $price > maxPrice $maxPrice, excluding');
          return false;
        }
        
        print('🔍 Property ${property.id}: Price $price within range, including');
        return true;
      } catch (e) {
        print('⚠️ Error parsing price for property ${property.id}: $e');
        return false;
      }
    }).toList();
  }

  /// Get properties by city
  static Future<List<Property>> getPropertiesByCity(String city, {int limit = 10}) async {
    try {
      print('🔍 Getting properties by city: $city');
      
      final querySnapshot = await _firestore
          .collection('properties')
          .where('city', isEqualTo: city)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final properties = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Include the document ID
            return Property.fromMap(data);
          })
          .toList();

      print('🔍 Found ${properties.length} properties in city: $city');
      return properties;
    } catch (e) {
      print('❌ Error fetching properties by city: $e');
      return [];
    }
  }

  /// Get properties by property type
  static Future<List<Property>> getPropertiesByType(String propertyType, {int limit = 10}) async {
    try {
      print('🔍 Getting properties by type: $propertyType');
      
      final querySnapshot = await _firestore
          .collection('properties')
          .where('propertyType', isEqualTo: propertyType)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final properties = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Include the document ID
            return Property.fromMap(data);
          })
          .toList();

      print('🔍 Found ${properties.length} properties of type: $propertyType');
      return properties;
    } catch (e) {
      print('❌ Error fetching properties by type: $e');
      return [];
    }
  }

  /// Get recent searches (mock implementation - can be enhanced with actual user search history)
  static List<String> getRecentSearches() {
    return [
      'Mumbai',
      'Delhi',
      'Bangalore',
      'Chennai',
      'Pune',
      'Hyderabad',
      'Kolkata',
      'Ahmedabad',
    ];
  }

  /// Get search suggestions based on available data
  static Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final querySnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .get();

      final suggestions = <String>{};
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final city = data['city']?.toString() ?? '';
        final locality = data['locality']?.toString() ?? '';
        final subLocality = data['subLocality']?.toString() ?? '';
        
        if (city.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(city);
        }
        if (locality.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(locality);
        }
        if (subLocality.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(subLocality);
        }
      }
      
      return suggestions.take(10).toList();
    } catch (e) {
      print('❌ Error getting search suggestions: $e');
      return [];
    }
  }

  /// Get all unique cities from properties
  static Future<List<String>> getAllCities() async {
    try {
      print('🔍 Getting all cities from properties');
      
      final querySnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .get();

      final cities = <String>{};
      
      for (final doc in querySnapshot.docs) {
        final city = doc.data()['city']?.toString() ?? '';
        if (city.isNotEmpty) {
          cities.add(city);
        }
      }
      
      final cityList = cities.toList()..sort();
      print('🔍 Found ${cityList.length} unique cities');
      return cityList;
    } catch (e) {
      print('❌ Error getting all cities: $e');
      return [];
    }
  }

  /// Get all unique property types from properties
  static Future<List<String>> getAllPropertyTypes() async {
    try {
      print('🔍 Getting all property types from properties');
      
      final querySnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .get();

      final propertyTypes = <String>{};
      
      for (final doc in querySnapshot.docs) {
        final propertyType = doc.data()['propertyType']?.toString() ?? '';
        if (propertyType.isNotEmpty) {
          propertyTypes.add(propertyType);
        }
      }
      
      final propertyTypeList = propertyTypes.toList()..sort();
      print('🔍 Found ${propertyTypeList.length} unique property types');
      return propertyTypeList;
    } catch (e) {
      print('❌ Error getting all property types: $e');
      return [];
    }
  }

  /// Get all active properties without any filters
  static Future<List<Property>> getAllProperties({int limit = 50}) async {
    try {
      print('🔍 Getting all active properties without filters');
      
      final querySnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final properties = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Include the document ID
            return Property.fromMap(data);
          })
          .toList();

      print('🔍 Found ${properties.length} active properties');
      return properties;
    } catch (e) {
      print('❌ Error getting all properties: $e');
      return [];
    }
  }
}
