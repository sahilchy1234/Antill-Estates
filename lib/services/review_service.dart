import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/review_model.dart';
import '../services/UserDataController.dart';
import '../services/auth_service.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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

  /// Get user information for reviews
  static Map<String, String> _getUserInfo(String userId) {
    try {
      print('🔍 Getting user info for userId: $userId');
      
      // Try to get UserDataController instance
      if (Get.isRegistered<UserDataController>()) {
        final userDataController = Get.find<UserDataController>();
        final userInfo = {
          'userName': userDataController.fullName.value,
          'userAvatar': userDataController.profileImagePath.value,
        };
        
        print('🔍 Retrieved user info: $userInfo');
        return userInfo;
      } else {
        print('⚠️ UserDataController not registered, using defaults');
      }
    } catch (e) {
      print('❌ Error getting user data from UserDataController: $e');
    }
    
    // Fallback to default values
    return {
      'userName': 'Anonymous User',
      'userAvatar': '',
    };
  }

  /// Add or update a review for a property (one review per user per property)
  static Future<String> addOrUpdateReview({
    required String propertyId,
    required double rating,
    required String comment,
  }) async {
    try {
      final firebaseUserId = _auth.currentUser?.uid;
      final userId = _getFirestoreUserId();
      if (userId == null) throw Exception('User not authenticated');

      // Get user information
      final userInfo = _getUserInfo(userId);

      // Validate rating
      if (rating < 1.0 || rating > 5.0) {
        throw Exception('Rating must be between 1 and 5');
      }

      // Validate comment
      if (comment.trim().isEmpty) {
        throw Exception('Comment cannot be empty');
      }

      // Check if user already has a review for this property
      final existingReviewQuery = await _firestore
          .collection('reviews')
          .where('propertyId', isEqualTo: propertyId)
          .where('userId', isEqualTo: firebaseUserId)
          .limit(1)
          .get();

      final reviewData = {
        'propertyId': propertyId,
        'userId': firebaseUserId,
        'firestoreUserId': userId,
        'userName': userInfo['userName'] ?? 'Anonymous User',
        'userAvatar': userInfo['userAvatar'] ?? '',
        'rating': rating,
        'comment': comment.trim(),
        'isVerified': false,
      };

      String reviewId;

      if (existingReviewQuery.docs.isNotEmpty) {
        // Update existing review
        final existingDoc = existingReviewQuery.docs.first;
        reviewId = existingDoc.id;
        
        reviewData['createdAt'] = existingDoc.data()['createdAt']; // Keep original creation date
        reviewData['updatedAt'] = FieldValue.serverTimestamp(); // Add update timestamp
        
        await _firestore
            .collection('reviews')
            .doc(reviewId)
            .update(reviewData);
        
        print('Review updated successfully with ID: $reviewId');
      } else {
        // Create new review
        reviewData['createdAt'] = FieldValue.serverTimestamp();
        
        final docRef = await _firestore
            .collection('reviews')
            .add(reviewData);
        
        reviewId = docRef.id;
        
        // Update with document ID
        await docRef.update({'id': reviewId});
        
        print('Review added successfully with ID: $reviewId');
      }

      return reviewId;
    } catch (e) {
      print('Add/Update review error: $e');
      throw Exception('Failed to add/update review: $e');
    }
  }

  /// Add a review for a property (legacy method - kept for backward compatibility)
  static Future<String> addReview({
    required String propertyId,
    required double rating,
    required String comment,
  }) async {
    return addOrUpdateReview(
      propertyId: propertyId,
      rating: rating,
      comment: comment,
    );
  }

  /// Get reviews for a specific property
  static Future<List<Review>> getPropertyReviews(String propertyId, {int limit = 10}) async {
    try {
      // print('🔍 Getting reviews for property: $propertyId'); // Commented for performance
      
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('propertyId', isEqualTo: propertyId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final reviews = querySnapshot.docs
          .map((doc) => Review.fromMap(doc.data()))
          .toList();

      print('🔍 Found ${reviews.length} reviews for property: $propertyId');
      return reviews;
    } catch (e) {
      print('❌ Error fetching property reviews: $e');
      return [];
    }
  }

  /// Get average rating for a property
  static Future<double> getPropertyAverageRating(String propertyId) async {
    try {
      print('🔍 Getting average rating for property: $propertyId');
      
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('propertyId', isEqualTo: propertyId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 0.0;
      }

      double totalRating = 0.0;
      int reviewCount = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] ?? 0.0).toDouble();
        totalRating += rating;
        reviewCount++;
      }

      final averageRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;
      print('🔍 Average rating for property $propertyId: $averageRating (from $reviewCount reviews)');
      return averageRating;
    } catch (e) {
      print('❌ Error calculating average rating: $e');
      return 0.0;
    }
  }

  /// Get total review count for a property
  static Future<int> getPropertyReviewCount(String propertyId) async {
    try {
      print('🔍 Getting review count for property: $propertyId');
      
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('propertyId', isEqualTo: propertyId)
          .get();

      final count = querySnapshot.docs.length;
      print('🔍 Review count for property $propertyId: $count');
      return count;
    } catch (e) {
      print('❌ Error getting review count: $e');
      return 0;
    }
  }

  /// Check if user has already reviewed a property
  static Future<bool> hasUserReviewedProperty(String propertyId) async {
    try {
      final firebaseUserId = _auth.currentUser?.uid;
      if (firebaseUserId == null) return false;

      final querySnapshot = await _firestore
          .collection('reviews')
          .where('propertyId', isEqualTo: propertyId)
          .where('userId', isEqualTo: firebaseUserId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking if user reviewed property: $e');
      return false;
    }
  }

  /// Get user's existing review for a property
  static Future<Review?> getUserReviewForProperty(String propertyId) async {
    try {
      final firebaseUserId = _auth.currentUser?.uid;
      if (firebaseUserId == null) return null;

      final querySnapshot = await _firestore
          .collection('reviews')
          .where('propertyId', isEqualTo: propertyId)
          .where('userId', isEqualTo: firebaseUserId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Review.fromMap(doc.data());
      }

      return null;
    } catch (e) {
      print('❌ Error getting user review for property: $e');
      return null;
    }
  }

  /// Delete a review by ID
  static Future<void> deleteReview(String reviewId) async {
    try {
      final firebaseUserId = _auth.currentUser?.uid;
      if (firebaseUserId == null) throw Exception('User not authenticated');

      final doc = await _firestore.collection('reviews').doc(reviewId).get();

      if (!doc.exists || doc.data()?['userId'] != firebaseUserId) {
        throw Exception('Review not found or access denied');
      }

      await _firestore.collection('reviews').doc(reviewId).delete();
      print('Review deleted successfully: $reviewId');
    } catch (e) {
      print('Delete review error: $e');
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Delete user's review for a specific property
  static Future<void> deleteUserReviewForProperty(String propertyId) async {
    try {
      final firebaseUserId = _auth.currentUser?.uid;
      if (firebaseUserId == null) throw Exception('User not authenticated');

      // Find user's review for this property
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('propertyId', isEqualTo: propertyId)
          .where('userId', isEqualTo: firebaseUserId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No review found for this property');
      }

      final reviewDoc = querySnapshot.docs.first;
      await _firestore.collection('reviews').doc(reviewDoc.id).delete();
      print('User review deleted successfully for property: $propertyId');
    } catch (e) {
      print('Delete user review error: $e');
      throw Exception('Failed to delete review: $e');
    }
  }
}
