import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:antill_estates/services/in_app_notification_service.dart';
import 'package:antill_estates/model/notification_model.dart';
import 'package:antill_estates/views/notification/in_app_notification_detail_view.dart';

/// Controller for managing in-app notifications
/// Handles checking for new notifications and displaying them
class InAppNotificationController extends GetxController {
  final InAppNotificationService _service = InAppNotificationService();
  
  // Observable list of unviewed notifications
  RxList<NotificationModel> unviewedNotifications = <NotificationModel>[].obs;
  
  // Loading state
  RxBool isLoading = false.obs;
  
  // Has checked on this session
  RxBool hasCheckedThisSession = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Check for notifications on initialization
    checkForNewNotifications();
  }

  /// Check for new notifications
  Future<void> checkForNewNotifications() async {
    if (hasCheckedThisSession.value) {
      debugPrint('Already checked for notifications this session');
      return;
    }
    
    try {
      isLoading.value = true;
      debugPrint('🔍 Checking for new in-app notifications...');
      
      final notifications = await _service.getUnviewedNotifications();
      
      if (notifications.isNotEmpty) {
        debugPrint('✅ Found ${notifications.length} unviewed notifications');
        
        // Convert to NotificationModel
        unviewedNotifications.value = notifications.map((data) {
          return NotificationModel(
            id: data['id'] ?? '',
            title: data['title'] ?? '',
            subtitle: data['subtitle'] ?? '',
            timestamp: data['timestamp'] ?? '',
            isViewed: false,
            itemId: data['itemId'],
            itemType: data['itemType'],
            imageUrl: data['imageUrl'],
            images: data['images'] != null 
                ? List<String>.from(data['images']) 
                : null,
            price: data['price'],
            location: data['location'],
            actionText: data['actionText'],
            actionUrl: data['actionUrl'],
            data: data['data'],
            type: data['itemType'],
          );
        }).toList();
        
        hasCheckedThisSession.value = true;
        
        // Show the first notification after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          showNextNotification();
        });
      } else {
        debugPrint('No unviewed notifications found');
        hasCheckedThisSession.value = true;
      }
      
    } catch (e) {
      debugPrint('Error checking for notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Show the next notification in queue
  void showNextNotification() {
    if (unviewedNotifications.isEmpty) {
      debugPrint('No more notifications to show');
      return;
    }
    
    final notification = unviewedNotifications.first;
    debugPrint('📱 Showing notification: ${notification.title}');
    
    // Navigate to full-page notification detail view
    Get.to(
      () => InAppNotificationDetailView(
        notification: notification,
        onViewed: () {
          _onNotificationViewed(notification.id);
        },
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Called when a notification is viewed
  void _onNotificationViewed(String notificationId) {
    debugPrint('✅ Notification $notificationId viewed');
    
    // Remove from unviewed list
    unviewedNotifications.removeWhere((n) => n.id == notificationId);
    
    // If there are more notifications, show the next one after a delay
    if (unviewedNotifications.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 800), () {
        // Check if user closed the notification view
        if (Get.isDialogOpen == false) {
          showNextNotification();
        }
      });
    }
  }

  /// Get count of unviewed notifications
  Future<int> getUnviewedCount() async {
    return await _service.getUnviewedCount();
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    hasCheckedThisSession.value = false;
    await checkForNewNotifications();
  }

  /// Clear viewed notifications (for testing)
  Future<void> clearViewedNotifications() async {
    await _service.clearViewedNotifications();
    hasCheckedThisSession.value = false;
    await checkForNewNotifications();
  }

  /// Mark notification as viewed manually
  Future<void> markAsViewed(String notificationId) async {
    await _service.markNotificationAsViewed(notificationId);
    unviewedNotifications.removeWhere((n) => n.id == notificationId);
  }
}

