import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
// Removed circular dependency - controller should not be imported here

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');
  
  // Get image URL from message data
  final imageUrl = message.data['imageUrl'] ?? message.data['image_url'];
  if (imageUrl != null) {
    debugPrint('Background notification with image: $imageUrl');
  }
}

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  // NotificationController removed to avoid circular dependency

  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for notifications
      await _requestPermission();

      // Get FCM token
      await _getFCMToken();

      // Configure message handlers
      _configureMessageHandlers();

      // Handle initial message if app was opened from notification
      await _handleInitialMessage();

      _isInitialized = true;
      debugPrint('Firebase Notification Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Notification Service: $e');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'luxury_real_estate_channel',
        'Antill Estates Notifications',
        description: 'Notifications for property updates and messages',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    // Request notification permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // For Android 13+, also request permission through permission_handler
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      debugPrint('Android notification permission: $status');
    }

    // Store permission status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_permission_granted', 
        settings.authorizationStatus == AuthorizationStatus.authorized);
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Store token locally
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        debugPrint('FCM Token refreshed: $token');
        _fcmToken = token;
        _saveTokenToPrefs(token);
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Save FCM token to shared preferences
  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Configure message handlers
  void _configureMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Handle initial message (when app is opened from notification)
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from notification: ${initialMessage.messageId}');
      _processNotificationData(initialMessage.data);
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Message data: ${message.data}');
    debugPrint('Message notification: ${message.notification?.title}');

    // Show local notification for foreground messages
    await _showLocalNotification(message);

    // Add to notification list
    await _addNotificationToList(message);
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Message data: ${message.data}');
    _processNotificationData(message.data);
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _processNotificationData(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Process notification data and navigate accordingly
  void _processNotificationData(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final propertyId = data['property_id'] as String?;
      final userId = data['user_id'] as String?;

      debugPrint('Processing notification - Type: $type, PropertyId: $propertyId, UserId: $userId');

      // Navigate based on notification type
      switch (type) {
        case 'new_property':
          if (propertyId != null) {
            // Navigate to property details
            Get.toNamed('/property_details_view', arguments: {'propertyId': propertyId});
          }
          break;
        case 'message':
          if (userId != null) {
            // Navigate to chat/message screen
            Get.toNamed('/contact_owner_view', arguments: {'userId': userId});
          }
          break;
        case 'interest':
          if (propertyId != null) {
            // Navigate to property details or responses
            Get.toNamed('/property_details_view', arguments: {'propertyId': propertyId});
          }
          break;
        default:
          // Navigate to notifications page
          Get.toNamed('/notification_view');
          break;
      }
    } catch (e) {
      debugPrint('Error processing notification data: $e');
      // Default navigation to notifications page
      Get.toNamed('/notification_view');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Get image URL from multiple possible sources
    final imageUrl = message.data['imageUrl'] ?? 
                     message.data['image_url'] ?? 
                     message.notification?.android?.imageUrl ?? 
                     message.notification?.apple?.imageUrl;

    debugPrint('Showing notification with image: $imageUrl');

    // Download and prepare image if available
    String? bigPicturePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        bigPicturePath = await _downloadAndSaveImage(imageUrl);
        debugPrint('Image downloaded successfully: $bigPicturePath');
      } catch (e) {
        debugPrint('Failed to download notification image: $e');
      }
    }

    // Android notification with image support
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'luxury_real_estate_channel',
      'Antill Estates Notifications',
      channelDescription: 'Notifications for property updates and messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      // Add big picture style if image is available
      styleInformation: bigPicturePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(bigPicturePath),
              contentTitle: notification.title,
              summaryText: notification.body,
              htmlFormatContentTitle: true,
              htmlFormatSummaryText: true,
            )
          : null,
      largeIcon: bigPicturePath != null 
          ? FilePathAndroidBitmap(bigPicturePath)
          : null,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // iOS will show attachments automatically from FCM
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  /// Download and save image for notification
  Future<String?> _downloadAndSaveImage(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String filePath = '$dir/${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);
      
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('Image saved to: $filePath');
      
      return filePath;
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  /// Save notification to local storage
  Future<void> _saveNotificationToStorage(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      // Sanitize message data to remove any non-serializable objects
      final sanitizedData = _sanitizeMessageData(message.data);
      
      final notification = {
        'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'title': message.notification?.title ?? 'New Notification',
        'subtitle': message.notification?.body ?? '',
        'timestamp': _formatTimestamp(DateTime.now()),
        'isRead': false,
        'data': sanitizedData,
        'type': message.data['type'] ?? 'general',
        'imageUrl': message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl,
      };
      
      notificationsJson.insert(0, jsonEncode(notification));
      
      // Keep only last 100 notifications
      if (notificationsJson.length > 100) {
        notificationsJson.removeRange(100, notificationsJson.length);
      }
      
      await prefs.setStringList('notifications', notificationsJson);
      debugPrint('Notification saved to storage');
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }
  
  /// Sanitize message data by converting non-JSON-serializable objects to strings
  Map<String, dynamic> _sanitizeMessageData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (value == null) {
        sanitized[key] = null;
      } else if (value is String || value is num || value is bool) {
        // Primitive types are safe
        sanitized[key] = value;
      } else if (value is Map) {
        // Recursively sanitize nested maps
        try {
          sanitized[key] = _sanitizeMessageData(Map<String, dynamic>.from(value));
        } catch (e) {
          sanitized[key] = value.toString();
        }
      } else if (value is List) {
        // Sanitize lists
        sanitized[key] = value.map((item) {
          if (item == null || item is String || item is num || item is bool) {
            return item;
          } else if (item is Map) {
            try {
              return _sanitizeMessageData(Map<String, dynamic>.from(item));
            } catch (e) {
              return item.toString();
            }
          }
          return item.toString();
        }).toList();
      } else {
        // Convert any other type to string
        sanitized[key] = value.toString();
      }
    });
    
    return sanitized;
  }

  /// Add notification to the notification list
  Future<void> _addNotificationToList(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? 'New Notification';
    final body = notification.body ?? '';

    // Save notification to local storage
    await _saveNotificationToStorage(message);
    
    debugPrint('Notification added: $title - $body');
  }

  /// Format timestamp to readable string
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

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
      
      // Add to saved topics
      final currentTopics = await getSubscribedTopics();
      if (!currentTopics.contains(topic)) {
        currentTopics.add(topic);
        await _saveSubscribedTopics(currentTopics);
      }
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
      
      // Remove from saved topics
      final currentTopics = await getSubscribedTopics();
      currentTopics.remove(topic);
      await _saveSubscribedTopics(currentTopics);
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Get notification permission status
  Future<bool> getNotificationPermissionStatus() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Clear specific notification
  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Get stored FCM token
  Future<String?> getStoredFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_permission_granted') ?? false;
  }

  /// Get list of subscribed topics
  Future<List<String>> getSubscribedTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final topicsJson = prefs.getStringList('subscribed_topics') ?? [];
      return topicsJson;
    } catch (e) {
      debugPrint('Error getting subscribed topics: $e');
      return [];
    }
  }

  /// Get notification analytics data
  Future<Map<String, dynamic>> getNotificationAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      int totalNotifications = notificationsJson.length;
      int unreadCount = 0;
      
      for (final notificationJson in notificationsJson) {
        try {
          final notification = jsonDecode(notificationJson);
          if (notification['isRead'] == false) {
            unreadCount++;
          }
        } catch (e) {
          debugPrint('Error parsing notification for analytics: $e');
        }
      }
      
      return {
        'total_notifications': totalNotifications,
        'unread_count': unreadCount,
        'read_count': totalNotifications - unreadCount,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting notification analytics: $e');
      return {
        'total_notifications': 0,
        'unread_count': 0,
        'read_count': 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Request notification permission (public method)
  Future<void> requestNotificationPermission() async {
    await _requestPermission();
  }

  /// Setup production notification topics
  Future<void> setupProductionTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> productionTopics = [
        'general_notifications',
        'property_updates',
        'new_messages',
        'price_alerts',
        'market_news',
      ];
      
      // Subscribe to production topics
      for (final topic in productionTopics) {
        await subscribeToTopic(topic);
      }
      
      // Save subscribed topics to preferences
      await prefs.setStringList('subscribed_topics', productionTopics);
      
      debugPrint('Production topics setup completed: $productionTopics');
    } catch (e) {
      debugPrint('Error setting up production topics: $e');
    }
  }

  /// Save subscribed topics to preferences
  Future<void> _saveSubscribedTopics(List<String> topics) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('subscribed_topics', topics);
  }

}
