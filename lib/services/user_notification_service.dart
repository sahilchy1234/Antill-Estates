import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:antill_estates/services/firebase_notification_service.dart';

class UserNotificationService {
  static final UserNotificationService _instance = UserNotificationService._internal();
  factory UserNotificationService() => _instance;
  UserNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseNotificationService _notificationService = FirebaseNotificationService();

  /// Register user for notifications
  Future<void> registerUserForNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return;
      }

      // Get FCM token
      final fcmToken = await _notificationService.getStoredFCMToken();
      if (fcmToken == null) {
        debugPrint('No FCM token available');
        return;
      }

      // Subscribe to default topics
      await _subscribeToDefaultTopics();

      // Save user data to Firestore
      await _saveUserToFirestore(user.uid, fcmToken);

      debugPrint('User registered for notifications successfully');
    } catch (e) {
      debugPrint('Error registering user for notifications: $e');
    }
  }

  /// Subscribe to default notification topics
  Future<void> _subscribeToDefaultTopics() async {
    try {
      // Subscribe to all default topics
      await _notificationService.subscribeToTopic('all_users');
      await _notificationService.subscribeToTopic('property_updates');
      await _notificationService.subscribeToTopic('market_news');
      await _notificationService.subscribeToTopic('new_properties');
      await _notificationService.subscribeToTopic('price_alerts');
      await _notificationService.subscribeToTopic('urgent_notifications');

      debugPrint('Subscribed to default topics');
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore(String userId, String fcmToken) async {
    try {
      final userData = {
        'fcmToken': fcmToken,
        'subscribedTopics': [
          'all_users',
          'property_updates',
          'market_news',
          'new_properties',
          'price_alerts',
          'urgent_notifications'
        ],
        'notificationPreferences': {
          'property_updates': true,
          'market_news': true,
          'new_properties': true,
          'price_alerts': true,
          'urgent_notifications': true,
        },
        'lastActive': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
      debugPrint('User data saved to Firestore');
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
    }
  }

  /// Update user notification preferences
  Future<void> updateNotificationPreferences(Map<String, bool> preferences) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'notificationPreferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local subscriptions based on preferences
      for (final entry in preferences.entries) {
        if (entry.value) {
          await _notificationService.subscribeToTopic(entry.key);
        } else {
          await _notificationService.unsubscribeFromTopic(entry.key);
        }
      }

      debugPrint('Notification preferences updated');
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
    }
  }

  /// Get user notification preferences
  Future<Map<String, bool>> getUserNotificationPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final preferences = data['notificationPreferences'] as Map<String, dynamic>?;
        if (preferences != null) {
          return preferences.map((key, value) => MapEntry(key, value as bool));
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
      return {};
    }
  }

  /// Update FCM token when it refreshes
  Future<void> updateFCMToken(String newToken) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FCM token updated in Firestore');
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  /// Unregister user from notifications
  Future<void> unregisterUserFromNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Remove FCM token from Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Unsubscribe from all topics
      await _notificationService.unsubscribeFromTopic('all_users');
      await _notificationService.unsubscribeFromTopic('property_updates');
      await _notificationService.unsubscribeFromTopic('market_news');
      await _notificationService.unsubscribeFromTopic('new_properties');
      await _notificationService.unsubscribeFromTopic('price_alerts');
      await _notificationService.unsubscribeFromTopic('urgent_notifications');

      debugPrint('User unregistered from notifications');
    } catch (e) {
      debugPrint('Error unregistering user: $e');
    }
  }

  /// Check if user is registered for notifications
  Future<bool> isUserRegisteredForNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fcmToken'] != null;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking user registration: $e');
      return false;
    }
  }

  /// Get user notification analytics
  Future<Map<String, dynamic>> getUserNotificationAnalytics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'fcmToken': data['fcmToken'],
          'subscribedTopics': data['subscribedTopics'] ?? [],
          'notificationPreferences': data['notificationPreferences'] ?? {},
          'lastActive': data['lastActive'],
          'createdAt': data['createdAt'],
        };
      }
      return {};
    } catch (e) {
      debugPrint('Error getting user analytics: $e');
      return {};
    }
  }
}
