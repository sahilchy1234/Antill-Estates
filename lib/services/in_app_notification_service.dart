import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service to manage in-app notifications and track which ones have been viewed
/// Once a notification is viewed, it will never be shown again to the user
class InAppNotificationService {
  static const String _viewedNotificationsKey = 'viewed_notifications';
  static const String _lastCheckKey = 'last_notification_check';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Get list of viewed notification IDs
  Future<Set<String>> getViewedNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewedList = prefs.getStringList(_viewedNotificationsKey) ?? [];
      return viewedList.toSet();
    } catch (e) {
      debugPrint('Error getting viewed notifications: $e');
      return {};
    }
  }
  
  /// Mark a notification as viewed (permanently)
  Future<void> markNotificationAsViewed(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewedList = prefs.getStringList(_viewedNotificationsKey) ?? [];
      
      if (!viewedList.contains(notificationId)) {
        viewedList.add(notificationId);
        await prefs.setStringList(_viewedNotificationsKey, viewedList);
        debugPrint('✅ Notification $notificationId marked as viewed');
      }
    } catch (e) {
      debugPrint('Error marking notification as viewed: $e');
    }
  }
  
  /// Check if a notification has been viewed
  Future<bool> isNotificationViewed(String notificationId) async {
    final viewedIds = await getViewedNotificationIds();
    return viewedIds.contains(notificationId);
  }
  
  /// Get unviewed notifications from Firestore
  Future<List<Map<String, dynamic>>> getUnviewedNotifications() async {
    try {
      debugPrint('🔍 Fetching unviewed notifications...');
      
      // Get viewed notification IDs
      final viewedIds = await getViewedNotificationIds();
      debugPrint('Already viewed: ${viewedIds.length} notifications');
      
      // Query in-app notifications from Firestore
      final querySnapshot = await _firestore
          .collection('in_app_notifications')
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      debugPrint('Found ${querySnapshot.docs.length} active notifications in Firestore');
      
      // Filter out viewed notifications
      final unviewedNotifications = <Map<String, dynamic>>[];
      
      for (final doc in querySnapshot.docs) {
        if (!viewedIds.contains(doc.id)) {
          final data = doc.data();
          data['id'] = doc.id;
          
          // Convert Firestore timestamp to DateTime string
          if (data['createdAt'] is Timestamp) {
            final timestamp = data['createdAt'] as Timestamp;
            data['timestamp'] = _formatTimestamp(timestamp.toDate());
            data['createdAtDate'] = timestamp.toDate().toIso8601String();
          }
          
          unviewedNotifications.add(data);
        }
      }
      
      debugPrint('✅ Found ${unviewedNotifications.length} unviewed notifications');
      return unviewedNotifications;
      
    } catch (e) {
      debugPrint('Error getting unviewed notifications: $e');
      return [];
    }
  }
  
  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  /// Get last check timestamp
  Future<DateTime?> getLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastCheckKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      debugPrint('Error getting last check time: $e');
    }
    return null;
  }
  
  /// Update last check timestamp
  Future<void> updateLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error updating last check time: $e');
    }
  }
  
  /// Clear all viewed notifications (for testing/debugging)
  Future<void> clearViewedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_viewedNotificationsKey);
      debugPrint('✅ Cleared all viewed notifications');
    } catch (e) {
      debugPrint('Error clearing viewed notifications: $e');
    }
  }
  
  /// Get count of unviewed notifications
  Future<int> getUnviewedCount() async {
    final unviewed = await getUnviewedNotifications();
    return unviewed.length;
  }
  
  /// Create a new in-app notification (for admin use)
  Future<String?> createInAppNotification({
    required String title,
    required String subtitle,
    required String itemType,
    String? itemId,
    String? imageUrl,
    List<String>? images,
    String? price,
    String? location,
    String? actionText,
    String? actionUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'title': title,
        'subtitle': subtitle,
        'itemType': itemType,
        'itemId': itemId,
        'imageUrl': imageUrl,
        'images': images ?? [],
        'price': price,
        'location': location,
        'actionText': actionText ?? 'View Details',
        'actionUrl': actionUrl,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'data': additionalData ?? {},
      };
      
      final docRef = await _firestore.collection('in_app_notifications').add(data);
      debugPrint('✅ Created in-app notification: ${docRef.id}');
      return docRef.id;
      
    } catch (e) {
      debugPrint('Error creating in-app notification: $e');
      return null;
    }
  }
  
  /// Deactivate a notification (soft delete)
  Future<void> deactivateNotification(String notificationId) async {
    try {
      await _firestore.collection('in_app_notifications').doc(notificationId).update({
        'active': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Deactivated notification: $notificationId');
    } catch (e) {
      debugPrint('Error deactivating notification: $e');
    }
  }
}

