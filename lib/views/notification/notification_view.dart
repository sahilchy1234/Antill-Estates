import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/notification_controller.dart';
import 'package:antill_estates/model/notification_model.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import '../../services/enhanced_loading_service.dart';

class NotificationView extends StatelessWidget {
  NotificationView({super.key});

  NotificationController get notificationController => Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: Obx(() => buildNotificationsList()),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        AppString.notifications,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
      actions: [
        // Notification settings button
        IconButton(
          icon: const Icon(Icons.settings, color: AppColor.primaryColor),
          onPressed: () {
            _showNotificationSettings();
          },
          tooltip: 'Notification Settings',
        ),
        if (notificationController.unreadCount.value > 0)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColor.textColor),
            onSelected: (value) async {
              switch (value) {
                case 'mark_all_read':
                  await notificationController.markAllAsRead();
                  Get.snackbar(
                    'Success',
                    'All notifications marked as read',
                    backgroundColor: AppColor.primaryColor,
                    colorText: AppColor.whiteColor,
                  );
                  break;
                case 'clear_all':
                  await _showClearAllDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, color: AppColor.primaryColor),
                    SizedBox(width: 8),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: AppColor.errorColor),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildNotificationsList() {
    if (notificationController.isLoading.value) {
      return EnhancedLoadingService.buildNotificationLoading();
    }
    
    if (notificationController.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await notificationController.refreshNotifications();
      },
      child: ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
          top: AppSize.appSize10,
          bottom: AppSize.appSize20,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notificationController.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationController.notifications[index];
          return _buildNotificationItem(notification, index);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    return GestureDetector(
      onTap: () {
        notificationController.handleNotificationTap(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSize.appSize8),
        padding: const EdgeInsets.all(AppSize.appSize16),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? AppColor.whiteColor 
              : AppColor.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSize.appSize12),
          border: Border.all(
            color: notification.isRead 
                ? AppColor.descriptionColor.withValues(alpha: 0.2)
                : AppColor.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title,
              style: AppStyle.heading5Medium(
                      color: notification.isRead
                          ? AppColor.textColor.withValues(alpha: 0.8)
                    : AppColor.textColor,
              ),
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: AppSize.appSize8,
                    height: AppSize.appSize8,
                    decoration: const BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSize.appSize6),
            Text(
              notification.subtitle,
              style: AppStyle.heading5Regular(
                color: notification.isRead
                    ? AppColor.descriptionColor.withValues(alpha: 0.7)
                    : AppColor.descriptionColor,
              ),
            ),
            const SizedBox(height: AppSize.appSize8),
            Row(
              children: [
                _buildNotificationTypeChip(notification.type),
                const Spacer(),
                Text(
                  notification.timestamp,
                style: AppStyle.heading6Regular(
                    color: AppColor.descriptionColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeChip(String? type) {
    Color chipColor;
    String label;
    
    switch (type) {
      case 'promotion':
        chipColor = AppColor.primaryColor;
        label = 'Promotion';
        break;
      case 'info':
        chipColor = AppColor.infoColor;
        label = 'Info';
        break;
      case 'location':
        chipColor = AppColor.successColor;
        label = 'Location';
        break;
      case 'interest':
        chipColor = AppColor.warningColor;
        label = 'Interest';
        break;
      case 'firebase':
        chipColor = AppColor.successColor;
        label = 'Firebase';
        break;
      default:
        chipColor = AppColor.descriptionColor;
        label = 'General';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.appSize8,
        vertical: AppSize.appSize4,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppStyle.heading6Regular(color: chipColor),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.images.notification.path,
            width: AppSize.appSize100,
            height: AppSize.appSize100,
          ),
          const SizedBox(height: AppSize.appSize24),
          Text(
            'No notifications yet',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize8),
          Text(
            'We\'ll notify you when something important happens',
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.appSize24),
          ElevatedButton.icon(
            onPressed: () async {
              await notificationController.requestNotificationPermission();
              Get.snackbar(
                'Permission Requested',
                'Please check your device notification settings',
                backgroundColor: AppColor.primaryColor,
                colorText: AppColor.whiteColor,
              );
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Enable Notifications'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: AppColor.whiteColor,
            ),
          ),
          const SizedBox(height: AppSize.appSize12),
          TextButton.icon(
            onPressed: () {
              _showNotificationSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Notification Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearAllDialog() async {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await notificationController.clearAllNotifications();
                Get.back();
                Get.snackbar(
                  'Success',
                  'All notifications cleared',
                  backgroundColor: AppColor.successColor,
                  colorText: AppColor.whiteColor,
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColor.errorColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNotificationSettings() async {
    final service = notificationController.notificationService;
    if (service == null) return;

    final permissionStatus = await service.getNotificationPermissionStatus();
    final subscribedTopics = await service.getSubscribedTopics();
    final analytics = await service.getNotificationAnalytics();

    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Permission Status
                Row(
                  children: [
                    Icon(
                      permissionStatus ? Icons.check_circle : Icons.cancel,
                      color: permissionStatus ? AppColor.successColor : AppColor.errorColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      permissionStatus ? 'Notifications Enabled' : 'Notifications Disabled',
                      style: AppStyle.heading5Medium(
                        color: permissionStatus ? AppColor.successColor : AppColor.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // FCM Token
                const Text('FCM Token:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                SelectableText(
                  service.fcmToken ?? 'Not available',
                  style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                ),
                const SizedBox(height: 16),

                // Subscribed Topics
                const Text('Subscribed Topics:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...subscribedTopics.map((topic) => Chip(
                  label: Text(topic),
                  backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
                )).toList(),
                const SizedBox(height: 16),

                // Analytics
                const Text('Analytics:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Total: ${analytics['total_notifications'] ?? 0}'),
                Text('Unread: ${analytics['unread_count'] ?? 0}'),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await service.requestNotificationPermission();
                        Get.back();
                        Get.snackbar(
                          'Permission Requested',
                          'Please check your notification settings',
                          backgroundColor: AppColor.primaryColor,
                          colorText: AppColor.whiteColor,
                        );
                      },
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Request Permission'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await service.setupProductionTopics();
                        Get.back();
                        Get.snackbar(
                          'Topics Updated',
                          'Production notification topics configured',
                          backgroundColor: AppColor.successColor,
                          colorText: AppColor.whiteColor,
                        );
                      },
                      icon: const Icon(Icons.cloud_sync),
                      label: const Text('Sync Topics'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

}
