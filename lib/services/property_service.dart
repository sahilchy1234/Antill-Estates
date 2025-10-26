import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/property_model.dart';
import '../services/UserDataController.dart';
import '../services/auth_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/image_optimization_service.dart';

class PropertyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get user contact information from UserDataController
  static Map<String, String> _getUserContactInfo(String userId) {
    try {
      print('🔍 Getting user contact info for userId: $userId');
      print('🔍 UserDataController registered: ${Get.isRegistered<UserDataController>()}');
      
      // Try to get UserDataController instance
      if (Get.isRegistered<UserDataController>()) {
        final userDataController = Get.find<UserDataController>();
        final contactInfo = {
          'contactName': userDataController.fullName.value,
          'contactPhone': userDataController.phoneNumber.value,
          'contactAvatar': userDataController.profileImagePath.value,
        };
        
        print('🔍 Retrieved contact info: $contactInfo');
        return contactInfo;
      } else {
        print('⚠️ UserDataController not registered, falling back to Firestore query');
      }
    } catch (e) {
      print('❌ Error getting user data from UserDataController: $e');
    }
    
    // Fallback to Firestore query if UserDataController is not available
    return _getUserContactInfoFromFirestore(userId);
  }

  /// Get the correct user ID (Firestore document ID) instead of Firebase Auth ID
  static String? _getFirestoreUserId() {
    try {
      // Try to get from AuthService first
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        if (authService.userId.value.isNotEmpty) {
          print('🔍 Using Firestore user ID from AuthService: ${authService.userId.value}');
          return authService.userId.value;
        }
      }
      
      // Try to get from SharedPreferences as fallback
      final prefs = GetStorage();
      final storedUserId = prefs.read('userId');
      if (storedUserId != null && storedUserId.toString().isNotEmpty) {
        print('🔍 Using Firestore user ID from storage: $storedUserId');
        return storedUserId.toString();
      }
      
      print('⚠️ No Firestore user ID found, using Firebase Auth ID');
      return _auth.currentUser?.uid;
    } catch (e) {
      print('❌ Error getting Firestore user ID: $e');
      return _auth.currentUser?.uid;
    }
  }

  /// Fallback method to get user contact info from Firestore
  static Map<String, String> _getUserContactInfoFromFirestore(String userId) {
    try {
      print('🔍 Fetching user data from Firestore for userId: $userId');
      // This will be called asynchronously in the postProperty method
      return {
        'contactName': '',
        'contactPhone': '',
        'contactAvatar': '',
      };
    } catch (e) {
      print('❌ Error in Firestore fallback: $e');
      return {
        'contactName': '',
        'contactPhone': '',
        'contactAvatar': '',
      };
    }
  }

  // Get property by ID
  static Future<Property?> getPropertyById(String propertyId) async {
    try {
      // print('🔍 Loading property data for ID: $propertyId'); // Commented for performance
      
      final docSnapshot = await _firestore
          .collection('properties')
          .doc(propertyId)
          .get();

      if (!docSnapshot.exists) {
        print('⚠️ Property not found in properties collection, checking arts_antiques...');
        // Try fetching from arts & antiques collection
        return await _getArtsAntiquesAsProperty(propertyId);
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('Property data is null for ID: $propertyId');
        return null;
      }

      // Check if property is active
      if (data['isActive'] != true) {
        print('Property is not active: $propertyId');
        return null;
      }

      // Add the document ID to the data
      data['id'] = docSnapshot.id;
      return Property.fromMap(data);
    } catch (e) {
      print('Error fetching property by ID: $e');
      throw Exception('Failed to get property: $e');
    }
  }

  /// Helper method to fetch arts & antiques item and convert to Property format
  static Future<Property?> _getArtsAntiquesAsProperty(String itemId) async {
    try {
      print('🎨 Fetching arts & antiques item with ID: $itemId');
      
      final docSnapshot = await _firestore
          .collection('arts_antiques')
          .doc(itemId)
          .get();

      if (!docSnapshot.exists) {
        print('❌ Arts & antiques item not found with ID: $itemId');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('❌ Arts & antiques data is null for ID: $itemId');
        return null;
      }

      // Check if item is active
      if (data['status'] != 'active') {
        print('❌ Arts & antiques item is not active: $itemId');
        return null;
      }

      print('✅ Found arts & antiques item: ${data['title']}');

      // Convert arts & antiques item to Property format
      return Property(
        id: docSnapshot.id,
        propertyLooking: 'buy',
        category: 'Arts & Antiques',
        propertyType: data['category'] ?? 'Art',
        city: data['location'] ?? 'Not specified',
        locality: 'Arts & Antiques',
        subLocality: data['artist'] ?? 'Unknown Artist',
        plotArea: data['dimensions'] ?? 'N/A',
        plotAreaUnit: 'sqft',
        builtUpArea: data['dimensions'] ?? 'N/A',
        totalFloors: '1',
        noOfBedrooms: data['category'] ?? 'Art',
        noOfBathrooms: 'N/A',
        noOfBalconies: '0',
        coveredParking: 0,
        openParking: 0,
        availabilityStatus: 'available',
        propertyPhotos: List<String>.from(data['images'] ?? []),
        ownership: 'freehold',
        expectedPrice: '₹ ${(data['price'] ?? 0).toInt()}',
        description: data['description'] ?? '',
        amenities: [],
        contactName: data['artist'] ?? 'Gallery',
        contactPhone: '',
        contactAvatar: '',
        isActive: true,
        createdAt: data['createdAt'] != null 
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null 
            ? (data['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error fetching arts & antiques as property: $e');
      return null;
    }
  }

  // Upload optimized images to Firebase Storage
  static Future<List<String>> uploadPropertyImages(List<File> images) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (images.isEmpty) return [];

      // Get the optimized storage service
      final storageService = Get.find<FirebaseStorageService>();
      List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        if (!file.existsSync()) {
          throw Exception('Image file does not exist at index $i');
        }

        try {
          // Use optimized upload for property images
          final downloadUrl = await storageService.uploadOptimizedImage(
            imageFile: file,
            userId: userId,
            folder: 'properties',
            useCase: i == 0 ? ImageUseCase.propertyMain : ImageUseCase.propertyGallery,
            createThumbnail: true,
          );

          if (downloadUrl != null) {
            imageUrls.add(downloadUrl);
            print('✅ Successfully uploaded optimized image ${i + 1}/${images.length}');
          } else {
            throw Exception('Upload returned null URL');
          }
        } catch (uploadError) {
          print('❌ Failed to upload image $i: $uploadError');
          throw Exception('Failed to upload image ${i + 1}: $uploadError');
        }
      }

      return imageUrls;
    } catch (e) {
      print('Upload images error: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  // Post property to Firestore
  static Future<String> postProperty(Property property) async {
    try {
      final firebaseUserId = _auth.currentUser?.uid;
      final userId = _getFirestoreUserId();
      if (userId == null) throw Exception('User not authenticated');
      
      print('🔍 Firebase Auth User ID: $firebaseUserId');
      print('🔍 Firestore User ID: $userId');

      // Validate required fields
      if (property.city.isEmpty || property.expectedPrice.isEmpty) {
        throw Exception('City and Expected Price are required');
      }

      // Get user contact information
      String contactName = '';
      String contactPhone = '';
      String contactAvatar = '';
      
      if (Get.isRegistered<UserDataController>()) {
        // Use local UserDataController if available
        final contactInfo = _getUserContactInfo(userId);
        contactName = contactInfo['contactName'] ?? '';
        contactPhone = contactInfo['contactPhone'] ?? '';
        contactAvatar = contactInfo['contactAvatar'] ?? '';
      } else {
        // Fallback to Firestore query
        print('⚠️ UserDataController not available, querying Firestore directly');
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          contactName = userData?['fullName'] ?? '';
          contactPhone = userData?['phoneNumber'] ?? '';
          contactAvatar = userData?['profileImageUrl'] ?? '';
          print('🔍 Retrieved from Firestore - Name: $contactName, Phone: $contactPhone, Avatar: $contactAvatar');
        } else {
          print('❌ User document not found in Firestore for userId: $userId');
        }
      }

      // Create property with user ID and timestamps
      final propertyData = {
        'userId': firebaseUserId, // Use Firebase Auth ID for authentication
        'firestoreUserId': userId, // Store Firestore user ID for reference
        'propertyLooking': property.propertyLooking,
        'category': property.category,
        'propertyType': property.propertyType,
        'city': property.city,
        'locality': property.locality,
        'subLocality': property.subLocality,
        'plotArea': property.plotArea,
        'plotAreaUnit': property.plotAreaUnit,
        'builtUpArea': property.builtUpArea,
        'superBuiltUpArea': property.superBuiltUpArea,
        'otherRooms': property.otherRooms,
        'totalFloors': property.totalFloors,
        'noOfBedrooms': property.noOfBedrooms,
        'noOfBathrooms': property.noOfBathrooms,
        'noOfBalconies': property.noOfBalconies,
        'coveredParking': property.coveredParking,
        'openParking': property.openParking,
        'availabilityStatus': property.availabilityStatus,
        'propertyPhotos': property.propertyPhotos,
        'ownership': property.ownership,
        'expectedPrice': property.expectedPrice,
        'priceDetails': property.priceDetails,
        'description': property.description,
        'amenities': property.amenities,
        'waterSource': property.waterSource,
        'otherFeatures': property.otherFeatures,
        'locationAdvantages': property.locationAdvantages,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'contactAvatar': contactAvatar,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      print('🔍 Property data being saved:');
      print('   Contact Name: $contactName');
      print('   Contact Phone: $contactPhone');
      print('   Contact Avatar: $contactAvatar');
      print('   User ID: $userId');

      // Add to Firestore
      final docRef = await _firestore
          .collection('properties')
          .add(propertyData);

      // Update with document ID
      await docRef.update({'id': docRef.id});

      print('Property posted successfully with ID: ${docRef.id}');
      return docRef.id;

    } catch (e) {
      print('Post property error: $e');
      throw Exception('Failed to post property: $e');
    }
  }

  // Get user properties
  static Future<List<Property>> getUserProperties() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final querySnapshot = await _firestore
          .collection('properties')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add the document ID to the data
            return Property.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get user properties: $e');
    }
  }

  // Delete property (soft delete)
  static Future<void> deleteProperty(String propertyId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final doc = await _firestore.collection('properties').doc(propertyId).get();

      if (!doc.exists || doc.data()?['userId'] != userId) {
        throw Exception('Property not found or access denied');
      }

      // Soft delete by setting isActive to false
      await _firestore.collection('properties').doc(propertyId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  // Update property
  static Future<void> updateProperty(String propertyId, Property property) async {
    try {
      final firebaseUserId = _auth.currentUser?.uid;
      final userId = _getFirestoreUserId();
      if (userId == null) throw Exception('User not authenticated');
      
      print('🔍 Firebase Auth User ID: $firebaseUserId');
      print('🔍 Firestore User ID: $userId');

      final doc = await _firestore.collection('properties').doc(propertyId).get();

      if (!doc.exists || doc.data()?['userId'] != userId) {
        throw Exception('Property not found or access denied');
      }

      // Get user contact information
      String contactName = '';
      String contactPhone = '';
      String contactAvatar = '';
      
      if (Get.isRegistered<UserDataController>()) {
        // Use local UserDataController if available
        final contactInfo = _getUserContactInfo(userId);
        contactName = contactInfo['contactName'] ?? '';
        contactPhone = contactInfo['contactPhone'] ?? '';
        contactAvatar = contactInfo['contactAvatar'] ?? '';
      } else {
        // Fallback to Firestore query
        print('⚠️ UserDataController not available, querying Firestore directly');
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          contactName = userData?['fullName'] ?? '';
          contactPhone = userData?['phoneNumber'] ?? '';
          contactAvatar = userData?['profileImageUrl'] ?? '';
          print('🔍 Retrieved from Firestore - Name: $contactName, Phone: $contactPhone, Avatar: $contactAvatar');
        } else {
          print('❌ User document not found in Firestore for userId: $userId');
        }
      }

      final propertyData = {
        'userId': firebaseUserId, // Use Firebase Auth ID for authentication
        'firestoreUserId': userId, // Store Firestore user ID for reference
        'propertyLooking': property.propertyLooking,
        'category': property.category,
        'propertyType': property.propertyType,
        'city': property.city,
        'locality': property.locality,
        'subLocality': property.subLocality,
        'plotArea': property.plotArea,
        'plotAreaUnit': property.plotAreaUnit,
        'builtUpArea': property.builtUpArea,
        'superBuiltUpArea': property.superBuiltUpArea,
        'otherRooms': property.otherRooms,
        'totalFloors': property.totalFloors,
        'noOfBedrooms': property.noOfBedrooms,
        'noOfBathrooms': property.noOfBathrooms,
        'noOfBalconies': property.noOfBalconies,
        'coveredParking': property.coveredParking,
        'openParking': property.openParking,
        'availabilityStatus': property.availabilityStatus,
        'propertyPhotos': property.propertyPhotos,
        'ownership': property.ownership,
        'expectedPrice': property.expectedPrice,
        'priceDetails': property.priceDetails,
        'description': property.description,
        'amenities': property.amenities,
        'waterSource': property.waterSource,
        'otherFeatures': property.otherFeatures,
        'locationAdvantages': property.locationAdvantages,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'contactAvatar': contactAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('properties').doc(propertyId).update(propertyData);
      print('Property updated successfully: $propertyId');
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  /// Get property owner contact information
  static Future<Map<String, String>?> getPropertyOwnerContactInfo(String propertyId) async {
    try {
      print('🔍 Getting owner contact info for property: $propertyId');
      
      final docSnapshot = await _firestore
          .collection('properties')
          .doc(propertyId)
          .get();

      if (!docSnapshot.exists) {
        print('❌ Property not found with ID: $propertyId');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('❌ Property data is null for ID: $propertyId');
        return null;
      }

      // Extract contact information from property data
      final contactInfo = <String, String>{
        'contactName': data['contactName']?.toString() ?? '',
        'contactPhone': data['contactPhone']?.toString() ?? '',
        'contactAvatar': data['contactAvatar']?.toString() ?? '',
        'contactEmail': data['contactEmail']?.toString() ?? '',
        'ownerName': data['contactName']?.toString() ?? '',
        'ownerPhone': data['contactPhone']?.toString() ?? '',
        'ownerAvatar': data['contactAvatar']?.toString() ?? '',
        'ownerEmail': data['contactEmail']?.toString() ?? '',
      };

      print('🔍 Retrieved owner contact info: $contactInfo');
      return contactInfo;
    } catch (e) {
      print('❌ Error fetching property owner contact info: $e');
      return null;
    }
  }

  /// Get similar properties based on current property
  static Future<List<Property>> getSimilarProperties(String currentPropertyId, {int limit = 5}) async {
    try {
      // print('🔍 Getting similar properties for: $currentPropertyId'); // Commented for performance
      
      // First get the current property to understand its characteristics
      final currentProperty = await getPropertyById(currentPropertyId);
      if (currentProperty == null) {
        print('❌ Current property not found');
        return [];
      }

      // Query for similar properties based on:
      // 1. Same city
      // 2. Same property type
      // 3. Exclude current property
      // Note: Price filtering can be added later if needed

      final querySnapshot = await _firestore
          .collection('properties')
          .where('city', isEqualTo: currentProperty.city)
          .where('propertyType', isEqualTo: currentProperty.propertyType)
          .where('isActive', isEqualTo: true)
          .limit(limit + 1) // Get one extra to account for current property
          .get();

      // Filter out current property and convert to Property objects
      final similarProperties = querySnapshot.docs
          .where((doc) => doc.id != currentPropertyId)
          .take(limit)
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add the document ID to the data
            return Property.fromMap(data);
          })
          .toList();

      print('🔍 Found ${similarProperties.length} similar properties');
      return similarProperties;
    } catch (e) {
      print('❌ Error fetching similar properties: $e');
      return [];
    }
  }

  /// Get all active properties (for general browsing)
  static Future<List<Property>> getAllActiveProperties({int limit = 10}) async {
    try {
      print('🔍 Getting all active properties');
      
      final querySnapshot = await _firestore
          .collection('properties')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final properties = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add the document ID to the data
            return Property.fromMap(data);
          })
          .toList();

      print('🔍 Found ${properties.length} active properties');
      return properties;
    } catch (e) {
      print('❌ Error fetching all properties: $e');
      return [];
    }
  }

  /// Get property tour images (all property photos)
  static Future<List<String>> getPropertyTourImages(String propertyId) async {
    try {
      print('🔍 Getting tour images for property: $propertyId');
      
      final property = await getPropertyById(propertyId);
      if (property == null) {
        print('❌ Property not found: $propertyId');
        return [];
      }

      final images = property.propertyPhotos;
      print('🔍 Found ${images.length} tour images for property: $propertyId');
      return images;
    } catch (e) {
      print('❌ Error fetching property tour images: $e');
      return [];
    }
  }

  /// Get properties by city (for similar properties)
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
            data['id'] = doc.id; // Add the document ID to the data
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

  /// Get properties by property type (for similar properties)
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
            data['id'] = doc.id; // Add the document ID to the data
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

  /// Save a property to user's saved properties
  static Future<void> saveProperty(String propertyId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      print('🔍 Saving property $propertyId for user $userId');

      // Check if property exists and is active
      final propertyDoc = await _firestore.collection('properties').doc(propertyId).get();
      if (!propertyDoc.exists || propertyDoc.data()?['isActive'] != true) {
        throw Exception('Property not found or not available');
      }

      // Check if already saved
      final savedDoc = await _firestore
          .collection('saved_properties')
          .doc('${userId}_$propertyId')
          .get();

      if (savedDoc.exists) {
        throw Exception('Property already saved');
      }

      // Save property reference
      await _firestore.collection('saved_properties').doc('${userId}_$propertyId').set({
        'userId': userId,
        'propertyId': propertyId,
        'savedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      print('✅ Property saved successfully: $propertyId');
    } catch (e) {
      print('❌ Error saving property: $e');
      throw Exception('Failed to save property: $e');
    }
  }

  /// Remove a property from user's saved properties
  static Future<void> unsaveProperty(String propertyId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      print('🔍 Removing saved property $propertyId for user $userId');

      // Remove the saved property document
      await _firestore
          .collection('saved_properties')
          .doc('${userId}_$propertyId')
          .delete();

      print('✅ Property removed from saved successfully: $propertyId');
    } catch (e) {
      print('❌ Error removing saved property: $e');
      throw Exception('Failed to remove saved property: $e');
    }
  }

  /// Check if a property is saved by the current user
  static Future<bool> isPropertySaved(String propertyId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final savedDoc = await _firestore
          .collection('saved_properties')
          .doc('${userId}_$propertyId')
          .get();

      return savedDoc.exists;
    } catch (e) {
      print('❌ Error checking if property is saved: $e');
      return false;
    }
  }

  /// BATCH: Check save status for multiple properties at once (MUCH faster than individual checks)
  static Future<Map<String, bool>> arePropertiesSaved(List<String> propertyIds) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      if (propertyIds.isEmpty) return {};

      // Firestore 'in' queries are limited to 10 items, so we batch them
      final results = <String, bool>{};
      final batchSize = 10;
      
      for (var i = 0; i < propertyIds.length; i += batchSize) {
        final batch = propertyIds.skip(i).take(batchSize).toList();
        
        // Create document IDs for the batch
        final docIds = batch.map((id) => '${userId}_$id').toList();
        
        // Query all at once
        final futures = docIds.map((docId) => 
          _firestore.collection('saved_properties').doc(docId).get()
        ).toList();
        
        final snapshots = await Future.wait(futures);
        
        // Map results
        for (var j = 0; j < batch.length; j++) {
          results[batch[j]] = snapshots[j].exists;
        }
      }

      print('✅ Batch checked ${propertyIds.length} properties save status');
      return results;
    } catch (e) {
      print('❌ Error batch checking property save status: $e');
      return {};
    }
  }

  /// Get all saved properties for the current user
  static Future<List<Property>> getSavedProperties() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      print('🔍 Getting saved properties for user $userId');

      // Get saved property references
      final savedQuery = await _firestore
          .collection('saved_properties')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('savedAt', descending: true)
          .get();

      if (savedQuery.docs.isEmpty) {
        print('🔍 No saved properties found');
        return [];
      }

      // Extract property IDs
      final propertyIds = savedQuery.docs
          .map((doc) => doc.data()['propertyId'] as String)
          .toList();

      print('🔍 Found ${propertyIds.length} saved property references');

      // Get actual property documents
      final properties = <Property>[];
      for (final propertyId in propertyIds) {
        try {
          final property = await getPropertyById(propertyId);
          if (property != null) {
            properties.add(property);
          }
        } catch (e) {
          print('⚠️ Could not fetch property $propertyId: $e');
          // Property might be deleted, remove from saved
          await unsaveProperty(propertyId);
        }
      }

      print('🔍 Retrieved ${properties.length} valid saved properties');
      return properties;
    } catch (e) {
      print('❌ Error getting saved properties: $e');
      throw Exception('Failed to get saved properties: $e');
    }
  }

  /// Toggle save status of a property (save if not saved, unsave if saved)
  static Future<bool> toggleSaveProperty(String propertyId) async {
    try {
      final isSaved = await isPropertySaved(propertyId);
      
      if (isSaved) {
        await unsaveProperty(propertyId);
        return false; // Property is now unsaved
      } else {
        await saveProperty(propertyId);
        return true; // Property is now saved
      }
    } catch (e) {
      print('❌ Error toggling save status: $e');
      throw Exception('Failed to toggle save status: $e');
    }
  }

  // ==================== ARTS & ANTIQUES SAVE METHODS ====================

  /// Save an arts & antiques item
  static Future<void> saveArtsAntiques(String itemId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      print('🔍 Saving arts & antiques item $itemId for user $userId');

      // Check if item exists and is active
      final itemDoc = await _firestore.collection('arts_antiques').doc(itemId).get();
      if (!itemDoc.exists || itemDoc.data()?['status'] != 'active') {
        throw Exception('Item not found or not available');
      }

      // Check if already saved
      final savedDoc = await _firestore
          .collection('saved_arts_antiques')
          .doc('${userId}_$itemId')
          .get();

      if (savedDoc.exists) {
        throw Exception('Item already saved');
      }

      // Save item reference
      await _firestore.collection('saved_arts_antiques').doc('${userId}_$itemId').set({
        'userId': userId,
        'itemId': itemId,
        'savedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      print('✅ Arts & antiques item saved successfully: $itemId');
    } catch (e) {
      print('❌ Error saving arts & antiques item: $e');
      throw Exception('Failed to save item: $e');
    }
  }

  /// Remove an arts & antiques item from user's saved items
  static Future<void> unsaveArtsAntiques(String itemId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      print('🔍 Removing saved arts & antiques item $itemId for user $userId');

      // Remove the saved item document
      await _firestore
          .collection('saved_arts_antiques')
          .doc('${userId}_$itemId')
          .delete();

      print('✅ Item removed from saved successfully: $itemId');
    } catch (e) {
      print('❌ Error removing saved item: $e');
      throw Exception('Failed to remove saved item: $e');
    }
  }

  /// Check if an arts & antiques item is saved by the current user
  static Future<bool> isArtsAntiquesSaved(String itemId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final savedDoc = await _firestore
          .collection('saved_arts_antiques')
          .doc('${userId}_$itemId')
          .get();

      return savedDoc.exists;
    } catch (e) {
      print('❌ Error checking if item is saved: $e');
      return false;
    }
  }

  /// Get all saved arts & antiques items for the current user
  static Future<List<Map<String, dynamic>>> getSavedArtsAntiques() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      print('🔍 Getting saved arts & antiques for user $userId');

      // Get saved item references
      final savedQuery = await _firestore
          .collection('saved_arts_antiques')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('savedAt', descending: true)
          .get();

      if (savedQuery.docs.isEmpty) {
        print('🔍 No saved arts & antiques found');
        return [];
      }

      // Extract item IDs
      final itemIds = savedQuery.docs
          .map((doc) => doc.data()['itemId'] as String)
          .toList();

      print('🔍 Found ${itemIds.length} saved item references');

      // Get actual item documents
      final items = <Map<String, dynamic>>[];
      for (final itemId in itemIds) {
        try {
          final itemDoc = await _firestore.collection('arts_antiques').doc(itemId).get();
          if (itemDoc.exists && itemDoc.data()?['status'] == 'active') {
            // Convert to Map and add item ID
            final itemData = itemDoc.data() as Map<String, dynamic>;
            itemData['id'] = itemId;
            items.add(itemData);
          } else {
            // Item might be deleted, remove from saved
            await unsaveArtsAntiques(itemId);
          }
        } catch (e) {
          print('⚠️ Could not fetch item $itemId: $e');
        }
      }

      print('🔍 Retrieved ${items.length} valid saved arts & antiques');
      return items;
    } catch (e) {
      print('❌ Error getting saved arts & antiques: $e');
      return [];
    }
  }

  /// Toggle save status of an arts & antiques item
  static Future<bool> toggleSaveArtsAntiques(String itemId) async {
    try {
      final isSaved = await isArtsAntiquesSaved(itemId);
      
      if (isSaved) {
        await unsaveArtsAntiques(itemId);
        return false; // Item is now unsaved
      } else {
        await saveArtsAntiques(itemId);
        return true; // Item is now saved
      }
    } catch (e) {
      print('❌ Error toggling save status: $e');
      throw Exception('Failed to toggle save status: $e');
    }
  }
}
