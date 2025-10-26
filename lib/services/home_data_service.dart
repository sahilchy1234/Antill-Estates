import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/property_model.dart';
import 'upcoming_project_service.dart';

class HomeDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get recommended properties for home screen
  static Future<List<Property>> getRecommendedProperties({int limit = 6}) async {
    try {
      print('🔍 Fetching recommended properties');
      
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

      print('🔍 Found ${properties.length} recommended properties');
      return properties;
    } catch (e) {
      print('❌ Error fetching recommended properties: $e');
      return [];
    }
  }

  /// Get trending properties based on search trends
  static Future<List<Property>> getTrendingProperties({int limit = 3}) async {
    try {
      print('🔍 Fetching trending properties');
      
      // For now, we'll get recent properties as trending
      // Later this can be enhanced with actual trending logic
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

      print('🔍 Found ${properties.length} trending properties');
      return properties;
    } catch (e) {
      print('❌ Error fetching trending properties: $e');
      return [];
    }
  }

  /// Get user's listing (first property for display)
  static Future<Property?> getUserListing() async {
    try {
      print('🔍 Fetching user listing');
      
      final querySnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('🔍 No user listings found');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id; // Include the document ID
      final property = Property.fromMap(data);
      print('🔍 Found user listing: ${property.city}');
      return property;
    } catch (e) {
      print('❌ Error fetching user listing: $e');
      return null;
    }
  }

  /// Get recent responses/interactions
  static Future<List<Map<String, dynamic>>> getRecentResponses({int limit = 4}) async {
    try {
      print('🔍 Fetching recent responses');
      
      // For now, we'll get recent properties and create mock responses
      // Later this can be enhanced with actual response/interaction data
      final querySnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final responses = <Map<String, dynamic>>[];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        responses.add({
          'id': doc.id,
          'contactName': data['contactName'] ?? 'Property Owner',
          'contactPhone': data['contactPhone'] ?? '',
          'contactAvatar': data['contactAvatar'] ?? '',
          'propertyTitle': data['description']?.toString().substring(0, 30) ?? 'Property Listing',
          'responseTime': _getRelativeTime(data['createdAt']),
          'buyerType': 'Interested Buyer',
        });
      }

      print('🔍 Found ${responses.length} recent responses');
      return responses;
    } catch (e) {
      print('❌ Error fetching recent responses: $e');
      return [];
    }
  }

  /// Get popular builders (can be enhanced with actual builder data)
  static Future<List<Map<String, dynamic>>> getPopularBuilders({int limit = 6}) async {
    try {
      print('🔍 Fetching popular builders');
      
      // For now, return hardcoded builders
      // Later this can be enhanced with actual builder collection
      final builders = [
        {
          'id': '1',
          'name': 'Sobha Developers',
          'logo': 'assets/images/builder1.png',
          'projectsCount': 45,
        },
        {
          'id': '2',
          'name': 'Kalpataru',
          'logo': 'assets/images/builder2.png',
          'projectsCount': 32,
        },
        {
          'id': '3',
          'name': 'Godrej',
          'logo': 'assets/images/builder3.png',
          'projectsCount': 28,
        },
        {
          'id': '4',
          'name': 'Unitech',
          'logo': 'assets/images/builder4.png',
          'projectsCount': 35,
        },
        {
          'id': '5',
          'name': 'Casagrand',
          'logo': 'assets/images/builder5.png',
          'projectsCount': 41,
        },
        {
          'id': '6',
          'name': 'Brigade',
          'logo': 'assets/images/builder6.png',
          'projectsCount': 38,
        },
      ];

      print('🔍 Found ${builders.length} popular builders');
      return builders;
    } catch (e) {
      print('❌ Error fetching popular builders: $e');
      return [];
    }
  }

  /// Get upcoming projects
  static Future<List<Map<String, dynamic>>> getUpcomingProjects({int limit = 3}) async {
    try {
      print('🔍 Fetching upcoming projects from Firebase');
      
      // Use the dedicated UpcomingProjectService
      final projects = await UpcomingProjectService.getUpcomingProjects(limit: limit);
      
      // Convert UpcomingProject objects to Map format for compatibility
      final projectMaps = projects.map((project) => {
        'id': project.id,
        'title': project.title,
        'address': project.address,
        'flatSize': project.flatSize,
        'price': project.price,
        'image': project.imageUrl ?? 'assets/images/upcomingProject1.png',
        'builder': project.builder,
        'description': project.description ?? '',
        'status': project.status,
        'launchDate': project.launchDate ?? '',
        'completionDate': project.completionDate ?? '',
        'createdAt': project.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'contactInfo': project.contactInfo ?? {
          'phone': '+1 (555) 123-4567',
          'email': 'info@antillestates.com',
        },
      }).toList();

      // If no projects found in Firebase, return fallback data
      if (projectMaps.isEmpty) {
        print('🔍 No projects in Firebase, returning fallback data');
        return [
          {
            'id': '1',
            'title': 'Luxury Villa',
            'address': 'Near IT Park, Sector 45',
            'flatSize': '3 BHK Apartment',
            'price': '₹45 Lakh',
            'image': 'assets/images/upcomingProject1.png',
            'builder': 'Luxury Developers',
            'description': 'Premium residential project with modern amenities',
            'status': 'upcoming',
            'contactInfo': {
              'phone': '+1 (555) 123-4567',
              'email': 'info@antillestates.com',
            },
          },
          {
            'id': '2',
            'title': 'Shreenathji Residency',
            'address': 'Gandhinagar, Gujarat',
            'flatSize': '4 BHK Apartment',
            'price': '₹85 Lakh',
            'image': 'assets/images/upcomingProject2.png',
            'builder': 'Shreenathji Builders',
            'description': 'Spacious apartments with excellent connectivity',
            'status': 'upcoming',
            'contactInfo': {
              'phone': '+1 (555) 123-4567',
              'email': 'info@antillestates.com',
            },
          },
          {
            'id': '3',
            'title': 'Pramukh Developers Surat',
            'address': 'Vesu, Surat',
            'flatSize': '5 BHK Apartment',
            'price': '₹85 Lakh',
            'image': 'assets/images/upcomingProject3.png',
            'builder': 'Pramukh Developers',
            'description': 'Luxury living in the heart of Surat',
            'status': 'upcoming',
            'contactInfo': {
              'phone': '+1 (555) 123-4567',
              'email': 'info@antillestates.com',
            },
          },
        ];
      }

      print('🔍 Found ${projectMaps.length} upcoming projects');
      return projectMaps;
    } catch (e) {
      print('❌ Error fetching upcoming projects: $e');
      // Return fallback data in case of any error
      return [
        {
          'id': '1',
          'title': 'Luxury Villa',
          'address': 'Near IT Park, Sector 45',
          'flatSize': '3 BHK Apartment',
          'price': '₹45 Lakh',
          'image': 'assets/images/upcomingProject1.png',
          'builder': 'Luxury Developers',
          'description': 'Premium residential project with modern amenities',
          'status': 'upcoming',
        },
        {
          'id': '2',
          'title': 'Shreenathji Residency',
          'address': 'Gandhinagar, Gujarat',
          'flatSize': '4 BHK Apartment',
          'price': '₹85 Lakh',
          'image': 'assets/images/upcomingProject2.png',
          'builder': 'Shreenathji Builders',
          'description': 'Spacious apartments with excellent connectivity',
          'status': 'upcoming',
        },
        {
          'id': '3',
          'title': 'Pramukh Developers Surat',
          'address': 'Vesu, Surat',
          'flatSize': '5 BHK Apartment',
          'price': '₹85 Lakh',
          'image': 'assets/images/upcomingProject3.png',
          'builder': 'Pramukh Developers',
          'description': 'Luxury living in the heart of Surat',
          'status': 'upcoming',
        },
      ];
    }
  }

  /// Get popular cities
  static Future<List<Map<String, dynamic>>> getPopularCities({int limit = 7}) async {
    try {
      print('🔍 Fetching popular cities');
      
      // For now, return hardcoded popular cities
      // Later this can be enhanced with actual cities collection
      final cities = [
        {
          'id': '1',
          'name': 'Mumbai',
          'image': 'assets/images/city1.png',
          'propertiesCount': 1250,
        },
        {
          'id': '2',
          'name': 'New Delhi',
          'image': 'assets/images/city2.png',
          'propertiesCount': 980,
        },
        {
          'id': '3',
          'name': 'Gurgaon',
          'image': 'assets/images/city3.png',
          'propertiesCount': 750,
        },
        {
          'id': '4',
          'name': 'Noida',
          'image': 'assets/images/city4.png',
          'propertiesCount': 650,
        },
        {
          'id': '5',
          'name': 'Bangalore',
          'image': 'assets/images/city5.png',
          'propertiesCount': 890,
        },
        {
          'id': '6',
          'name': 'Ahmedabad',
          'image': 'assets/images/city6.png',
          'propertiesCount': 420,
        },
        {
          'id': '7',
          'name': 'Kolkata',
          'image': 'assets/images/city7.png',
          'propertiesCount': 380,
        },
      ];

      print('🔍 Found ${cities.length} popular cities');
      return cities;
    } catch (e) {
      print('❌ Error fetching popular cities: $e');
      return [];
    }
  }

  /// Helper method to get relative time
  static String _getRelativeTime(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Recently';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get property by ID
  static Future<Property?> getPropertyById(String propertyId) async {
    try {
      print('🔍 Fetching property by ID: $propertyId');
      
      final docSnapshot = await _firestore
          .collection('properties')
          .doc(propertyId)
          .get();

      if (!docSnapshot.exists) {
        print('🔍 Property not found with ID: $propertyId');
        return null;
      }

      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id; // Include the document ID
      final property = Property.fromMap(data);
      print('🔍 Found property: ${property.city}');
      return property;
    } catch (e) {
      print('❌ Error fetching property by ID: $e');
      return null;
    }
  }

  /// Get property statistics
  static Future<Map<String, dynamic>> getPropertyStats() async {
    try {
      print('🔍 Fetching property statistics');
      
      final totalPropertiesSnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .get();

      final totalProperties = totalPropertiesSnapshot.docs.length;
      
      // Get properties by type
      final residentialSnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: 'residential')
          .get();

      final commercialSnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: 'commercial')
          .get();

      final stats = {
        'totalProperties': totalProperties,
        'residentialProperties': residentialSnapshot.docs.length,
        'commercialProperties': commercialSnapshot.docs.length,
      };

      print('🔍 Property stats: $stats');
      return stats;
    } catch (e) {
      print('❌ Error fetching property stats: $e');
      return {
        'totalProperties': 0,
        'residentialProperties': 0,
        'commercialProperties': 0,
      };
    }
  }
}
