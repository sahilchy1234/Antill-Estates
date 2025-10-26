import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antill_estates/model/notification_model.dart';
import 'package:antill_estates/services/firebase_notification_service.dart';
import 'package:antill_estates/services/user_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class NotificationController extends GetxController {
  FirebaseNotificationService? _notificationService;
  
  // Observable list of notifications
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  
  // Loading state
  RxBool isLoading = false.obs;
  
  // Legacy lists removed - using Firebase notifications only

  // Computed properties
  RxInt get unreadCount => notifications.where((n) => !n.isRead).length.obs;
  RxBool get hasNotifications => notifications.isNotEmpty.obs;

  /// Get notification service safely
  FirebaseNotificationService? get _notificationServiceSafe {
    if (_notificationService == null) {
      try {
        _notificationService = FirebaseNotificationService();
      } catch (e) {
        print('Error getting notification service: $e');
        return null;
      }
    }
    return _notificationService;
  }

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    _initializeFirebaseNotifications();
    _startNotificationListener();
    
    // Sync from Firestore after initial load
    Future.delayed(const Duration(seconds: 1), () {
      _syncNotificationsFromFirestore();
    });
  }

  /// Initialize Firebase notifications
  Future<void> _initializeFirebaseNotifications() async {
    try {
      final service = _notificationServiceSafe;
      if (service != null) {
        await service.initialize();
        
        // Register user for notifications
        final userService = UserNotificationService();
        await userService.registerUserForNotifications();
        
        debugPrint('Firebase notifications initialized successfully');
      }
    } catch (e) {
      print('Error initializing Firebase notifications: $e');
    }
  }

  /// Start listening for notification updates
  void _startNotificationListener() {
    // Listen for Firebase messaging events to refresh notifications
    try {
      // Use a timer to periodically refresh notifications
      // This ensures we catch notifications that arrive while app is in foreground
      Future.delayed(const Duration(seconds: 2), () {
        _loadNotifications();
      });
    } catch (e) {
      print('Error starting notification listener: $e');
    }
  }

  /// Load notifications from local storage
  Future<void> _loadNotifications() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      debugPrint('Loading notifications from storage: ${notificationsJson.length} items');
      
      final loadedNotifications = notificationsJson
          .map((json) {
            try {
              final data = jsonDecode(json);
              return NotificationModel.fromJson(data);
            } catch (e) {
              print('Error parsing notification: $e');
              print('Invalid JSON: $json');
              return null;
            }
          })
          .where((notification) => notification != null)
          .cast<NotificationModel>()
          .toList();
      
      // Sort by timestamp (newest first)
      loadedNotifications.sort((a, b) {
        try {
          // Try to parse timestamps if they're strings
          return b.id.compareTo(a.id); // Use ID as fallback if timestamp parsing fails
        } catch (e) {
          return 0;
        }
      });
      
      notifications.value = loadedNotifications;
      
      debugPrint('✅ Loaded ${notifications.length} notifications from storage');
      debugPrint('Unread notifications: ${unreadCount.value}');
      
      // Debug: Print first 3 notifications
      for (var i = 0; i < notifications.length && i < 3; i++) {
        debugPrint('Notification $i: ${notifications[i].title}');
      }
      
    } catch (e) {
      print('Error loading notifications: $e');
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Sample notifications method removed - using real Firebase notifications only

  /// Add a new notification
  Future<void> addNotification({
    required String title,
    required String subtitle,
    required String timestamp,
    Map<String, dynamic>? data,
    String? type,
    String? imageUrl,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      timestamp: timestamp,
      data: data,
      type: type,
      imageUrl: imageUrl,
    );

    notifications.insert(0, notification);
    await _saveNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    notifications.clear();
    await _saveNotifications();
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  /// Get read notifications
  List<NotificationModel> get readNotifications {
    return notifications.where((n) => n.isRead).toList();
  }

  /// Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications
          .map((n) => jsonEncode(n.toJson()))
          .toList();
      
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await _loadNotifications();
    // Also try to load from Firestore to sync across devices
    await _syncNotificationsFromFirestore();
  }

  /// Sync notifications from Firestore (for cross-device sync)
  Future<void> _syncNotificationsFromFirestore() async {
    try {
      debugPrint('Syncing notifications from Firestore...');
      
      final firestore = FirebaseFirestore.instance;
      
      // Query notifications sent to all users or specific user
      // For now, get recent global notifications
      final querySnapshot = await firestore
          .collection('notifications')
          .where('target', whereIn: ['all', 'all_users'])
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      debugPrint('Found ${querySnapshot.docs.length} notifications in Firestore');

      // Merge with existing notifications
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Check if notification already exists
        final exists = notifications.any((n) => n.id == doc.id);
        if (!exists) {
          // Sanitize data to remove Firestore Timestamp objects
          final sanitizedData = _sanitizeFirestoreData(data);
          
          // Add new notification
          final notification = NotificationModel(
            id: doc.id,
            title: data['title'] ?? 'Notification',
            subtitle: data['body'] ?? '',
            timestamp: _formatTimestamp(data['timestamp']?.toDate() ?? DateTime.now()),
            isRead: false,
            data: sanitizedData,
            type: data['type'] ?? 'general',
            imageUrl: data['imageUrl'],
          );
          
          notifications.insert(0, notification);
          debugPrint('Added notification: ${notification.title}');
        }
      }

      // Save merged notifications
      await _saveNotifications();
      
      debugPrint('✅ Synced notifications from Firestore. Total: ${notifications.length}');
      
    } catch (e) {
      debugPrint('Error syncing from Firestore: $e');
      // Don't fail if Firestore sync doesn't work
    }
  }

  /// Format timestamp
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

  /// Sanitize Firestore data by converting Timestamp objects to ISO strings
  Map<String, dynamic> _sanitizeFirestoreData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (value is Timestamp) {
        // Convert Firestore Timestamp to ISO string
        sanitized[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        // Recursively sanitize nested maps
        sanitized[key] = _sanitizeFirestoreData(Map<String, dynamic>.from(value));
      } else if (value is List) {
        // Sanitize lists
        sanitized[key] = value.map((item) {
          if (item is Timestamp) {
            return item.toDate().toIso8601String();
          } else if (item is Map) {
            return _sanitizeFirestoreData(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
      } else {
        // Keep other values as is
        sanitized[key] = value;
      }
    });
    
    return sanitized;
  }

  /// Load notifications from Firebase service storage
  Future<void> loadNotificationsFromFirebase() async {
    try {
      final service = _notificationServiceSafe;
      if (service != null) {
        // Get notifications from the service's storage
        final prefs = await SharedPreferences.getInstance();
        final notificationsJson = prefs.getStringList('notifications') ?? [];
        
        final loadedNotifications = notificationsJson
            .map((json) {
              try {
                final data = jsonDecode(json);
                return NotificationModel.fromJson(data);
              } catch (e) {
                print('Error parsing notification: $e');
                return null;
              }
            })
            .where((notification) => notification != null)
            .cast<NotificationModel>()
            .toList();
        
        notifications.value = loadedNotifications;
        debugPrint('Loaded ${notifications.length} notifications from Firebase storage');
      }
    } catch (e) {
      print('Error loading notifications from Firebase: $e');
      notifications.clear();
    }
  }

  /// Get notification permission status
  Future<bool> getNotificationPermissionStatus() async {
    final service = _notificationServiceSafe;
    if (service != null) {
      return await service.getNotificationPermissionStatus();
    }
    return false;
  }

  /// Request notification permission
  Future<void> requestNotificationPermission() async {
    final service = _notificationServiceSafe;
    if (service != null) {
      await service.initialize();
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    final service = _notificationServiceSafe;
    if (service != null) {
      await service.subscribeToTopic(topic);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    final service = _notificationServiceSafe;
    if (service != null) {
      await service.unsubscribeFromTopic(topic);
    }
  }

  /// Get FCM token
  String? get fcmToken => _notificationServiceSafe?.fcmToken;

  /// Get notification service (for external access)
  FirebaseNotificationService? get notificationService => _notificationServiceSafe;

  /// Handle notification tap
  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    markAsRead(notification.id);

    // Navigate based on notification type and data
    if (notification.data != null) {
      final type = notification.data!['type'] as String?;
      final propertyId = notification.data!['property_id'] as String?;
      final userId = notification.data!['user_id'] as String?;

      switch (type) {
        case 'new_property':
          if (propertyId != null) {
            Get.toNamed('/property_details_view', arguments: {'propertyId': propertyId});
          }
          break;
        case 'message':
          if (userId != null) {
            Get.toNamed('/contact_owner_view', arguments: {'userId': userId});
          }
          break;
        case 'interest':
          if (propertyId != null) {
            Get.toNamed('/property_details_view', arguments: {'propertyId': propertyId});
          }
          break;
        default:
          // Stay on current page or navigate to home
          break;
      }
    }
  }
}
