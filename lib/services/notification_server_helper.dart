import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Server helper for sending notifications via Firebase Admin SDK
/// This class provides methods to send notifications to your backend server
/// which will then use Firebase Admin SDK to send push notifications
class NotificationServerHelper {
  static const String _baseUrl = 'https://your-server.com/api'; // Replace with your server URL
  
  /// Send notification to specific user
  static Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/send-to-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // Replace with your API key
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent to user $userId successfully');
        return true;
      } else {
        debugPrint('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending notification to user: $e');
      return false;
    }
  }

  /// Send notification to topic subscribers
  static Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/send-to-topic'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // Replace with your API key
        },
        body: jsonEncode({
          'topic': topic,
          'title': title,
          'body': body,
          'data': data ?? {},
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent to topic $topic successfully');
        return true;
      } else {
        debugPrint('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending notification to topic: $e');
      return false;
    }
  }

  /// Send notification to all users
  static Future<bool> sendNotificationToAll({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    return await sendNotificationToTopic(
      topic: 'all_users',
      title: title,
      body: body,
      data: data,
      imageUrl: imageUrl,
    );
  }

  /// Send property-related notification
  static Future<bool> sendPropertyNotification({
    required String propertyId,
    required String title,
    required String body,
    String type = 'new_property',
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'type': type,
      'property_id': propertyId,
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    };

    return await sendNotificationToTopic(
      topic: 'property_updates',
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send message notification
  static Future<bool> sendMessageNotification({
    required String userId,
    required String senderName,
    required String message,
  }) async {
    return await sendNotificationToUser(
      userId: userId,
      title: 'New message from $senderName',
      body: message,
      data: {
        'type': 'message',
        'sender_name': senderName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send price alert notification
  static Future<bool> sendPriceAlertNotification({
    required String propertyId,
    required String propertyTitle,
    required String oldPrice,
    required String newPrice,
  }) async {
    return await sendNotificationToTopic(
      topic: 'price_alerts',
      title: 'Price Alert: $propertyTitle',
      body: 'Price changed from $oldPrice to $newPrice',
      data: {
        'type': 'price_alert',
        'property_id': propertyId,
        'old_price': oldPrice,
        'new_price': newPrice,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send market update notification
  static Future<bool> sendMarketUpdateNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    return await sendNotificationToTopic(
      topic: 'market_news',
      title: title,
      body: body,
      data: {
        'type': 'market_update',
        'timestamp': DateTime.now().toIso8601String(),
      },
      imageUrl: imageUrl,
    );
  }

  /// Send urgent notification
  static Future<bool> sendUrgentNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return await sendNotificationToTopic(
      topic: 'urgent_notifications',
      title: title,
      body: body,
      data: {
        'type': 'urgent',
        'priority': 'high',
        'timestamp': DateTime.now().toIso8601String(),
        ...?data,
      },
    );
  }

  /// Get notification statistics
  static Future<Map<String, dynamic>?> getNotificationStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/stats'),
        headers: {
          'Authorization': 'Bearer YOUR_API_KEY', // Replace with your API key
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to get notification stats: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting notification stats: $e');
      return null;
    }
  }
}

/// Production notification templates
class NotificationTemplates {
  static const Map<String, Map<String, String>> templates = {
    'new_property': {
      'title': 'New Property Available',
      'body': 'A new {property_type} in {location} is now available for {price}',
    },
    'price_drop': {
      'title': 'Price Drop Alert',
      'body': 'The price of {property_title} has dropped to {new_price}',
    },
    'new_message': {
      'title': 'New Message',
      'body': '{sender_name} sent you a message',
    },
    'property_interest': {
      'title': 'New Interest',
      'body': 'Someone is interested in your property {property_title}',
    },
    'market_update': {
      'title': 'Market Update',
      'body': '{update_title} - {update_description}',
    },
    'urgent_alert': {
      'title': 'Urgent Alert',
      'body': '{alert_message}',
    },
  };

  /// Format notification template with data
  static String formatTemplate(String templateKey, Map<String, String> data) {
    final template = templates[templateKey];
    if (template == null) return '';

    String title = template['title'] ?? '';
    String body = template['body'] ?? '';

    data.forEach((key, value) {
      title = title.replaceAll('{$key}', value);
      body = body.replaceAll('{$key}', value);
    });

    return '$title|$body';
  }
}
