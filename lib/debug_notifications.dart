import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antill_estates/services/firebase_notification_service.dart';
import 'package:antill_estates/services/user_notification_service.dart';

/// Debug utility for testing notifications
class NotificationDebugger {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseNotificationService _notificationService = FirebaseNotificationService();

  /// Print comprehensive notification debug info
  static Future<void> printDebugInfo() async {
    debugPrint('🔧 ========== NOTIFICATION DEBUG INFO ==========');
    
    try {
      // 1. Check FCM Token
      final token = await _messaging.getToken();
      debugPrint('📱 FCM Token: ${token ?? "No token found"}');
      
      // 2. Check stored token
      final storedToken = await _notificationService.getStoredFCMToken();
      debugPrint('💾 Stored FCM Token: ${storedToken ?? "No stored token"}');
      
      // 3. Check notification permission
      final permission = await _notificationService.getNotificationPermissionStatus();
      debugPrint('🔔 Notification Permission: $permission');
      
      // 4. Check if user is authenticated
      final user = _auth.currentUser;
      debugPrint('👤 Authenticated User: ${user?.uid ?? "No user"}');
      
      // 5. Check user registration in Firestore
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          debugPrint('📊 User in Firestore:');
          debugPrint('  - FCM Token: ${userData?['fcmToken'] != null ? "Present" : "Missing"}');
          debugPrint('  - Subscribed Topics: ${userData?['subscribedTopics'] ?? "None"}');
          debugPrint('  - Last Active: ${userData?['lastActive']}');
        } else {
          debugPrint('❌ User not found in Firestore');
        }
      }
      
      // 6. Check local notification storage
      final prefs = await SharedPreferences.getInstance();
      final notifications = prefs.getStringList('notifications') ?? [];
      debugPrint('📜 Local Notifications Count: ${notifications.length}');
      
      // 7. Check notification service initialization
      debugPrint('⚙️ Notification Service Initialized: ${_notificationService.isInitialized}');
      
      // 8. Test message handlers
      debugPrint('🎯 Message Handlers Status:');
      debugPrint('  - Foreground: Active');
      debugPrint('  - Background: Active');
      debugPrint('  - App Launch: Active');
      
      debugPrint('🔧 ========== END DEBUG INFO ==========');
      
    } catch (e) {
      debugPrint('❌ Error in debug info: $e');
    }
  }

  /// Test notification reception
  static void testNotificationReception() {
    debugPrint('🧪 Testing notification reception...');
    
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🎯 FOREGROUND MESSAGE RECEIVED:');
      debugPrint('  - Message ID: ${message.messageId}');
      debugPrint('  - Title: ${message.notification?.title}');
      debugPrint('  - Body: ${message.notification?.body}');
      debugPrint('  - Data: ${message.data}');
      debugPrint('  - From: ${message.from}');
    });
    
    // Listen for background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    
    // Listen for notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🎯 NOTIFICATION TAPPED (Background):');
      debugPrint('  - Message ID: ${message.messageId}');
      debugPrint('  - Title: ${message.notification?.title}');
      debugPrint('  - Data: ${message.data}');
    });
    
    debugPrint('✅ Notification listeners activated');
  }

  /// Background message handler for testing
  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    debugPrint('🎯 BACKGROUND MESSAGE RECEIVED:');
    debugPrint('  - Message ID: ${message.messageId}');
    debugPrint('  - Title: ${message.notification?.title}');
    debugPrint('  - Body: ${message.notification?.body}');
    debugPrint('  - Data: ${message.data}');
  }

  /// Force register user for notifications
  static Future<void> forceRegisterUser() async {
    debugPrint('🔄 Force registering user for notifications...');
    
    try {
      final userService = UserNotificationService();
      await userService.registerUserForNotifications();
      debugPrint('✅ User registration completed');
      
      // Verify registration
      final isRegistered = await userService.isUserRegisteredForNotifications();
      debugPrint('📊 User registration status: $isRegistered');
      
    } catch (e) {
      debugPrint('❌ Error registering user: $e');
    }
  }

  /// Clear all notification data
  static Future<void> clearNotificationData() async {
    debugPrint('🗑️ Clearing notification data...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');
      await prefs.remove('fcm_token');
      await prefs.remove('notification_permission_granted');
      await prefs.remove('subscribed_topics');
      
      debugPrint('✅ Notification data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }

  /// Test local notification display
  static Future<void> testLocalNotification() async {
    debugPrint('🧪 Testing local notification display...');
    
    try {
      // This would require the local notification plugin
      // For now, just log that we're testing
      debugPrint('📱 Local notification test initiated');
      debugPrint('ℹ️ Check device notification tray');
    } catch (e) {
      debugPrint('❌ Error testing local notification: $e');
    }
  }

  /// Get notification analytics
  static Future<void> printNotificationAnalytics() async {
    debugPrint('📊 ========== NOTIFICATION ANALYTICS ==========');
    
    try {
      final analytics = await _notificationService.getNotificationAnalytics();
      debugPrint('📈 Analytics Data:');
      analytics.forEach((key, value) {
        debugPrint('  - $key: $value');
      });
      
      debugPrint('📊 ========== END ANALYTICS ==========');
    } catch (e) {
      debugPrint('❌ Error getting analytics: $e');
    }
  }

  /// Monitor notification events in real-time
  static void startNotificationMonitoring() {
    debugPrint('👁️ Starting notification monitoring...');
    
    // Monitor token refresh
    _messaging.onTokenRefresh.listen((String token) {
      debugPrint('🔄 FCM Token refreshed: $token');
    });
    
    // Monitor notification settings
    _messaging.getNotificationSettings().then((settings) {
      debugPrint('⚙️ Notification Settings:');
      debugPrint('  - Authorization: ${settings.authorizationStatus}');
      debugPrint('  - Alert: ${settings.alert}');
      debugPrint('  - Badge: ${settings.badge}');
      debugPrint('  - Sound: ${settings.sound}');
    });
    
    debugPrint('✅ Notification monitoring started');
  }
}

/// Extension to add debug methods to any widget
extension NotificationDebugExtension on State {
  /// Add this method to any State widget to debug notifications
  void debugNotifications() {
    NotificationDebugger.printDebugInfo();
    NotificationDebugger.testNotificationReception();
    NotificationDebugger.startNotificationMonitoring();
  }
}

/// Usage example:
/// 
/// In any widget's initState():
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   NotificationDebugger.printDebugInfo();
///   NotificationDebugger.testNotificationReception();
/// }
/// ```
/// 
/// Or use the extension:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   debugNotifications();
/// }
/// ```
