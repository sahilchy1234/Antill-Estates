import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/model/notification_model.dart';
import 'package:antill_estates/services/in_app_notification_service.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';

/// Full-page notification detail view
/// Shows detailed information about new listings from admin panel
/// Once viewed, the notification will never appear again
class InAppNotificationDetailView extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback? onViewed;

  const InAppNotificationDetailView({
    Key? key,
    required this.notification,
    this.onViewed,
  }) : super(key: key);

  @override
  State<InAppNotificationDetailView> createState() => _InAppNotificationDetailViewState();
}

class _InAppNotificationDetailViewState extends State<InAppNotificationDetailView> {
  final InAppNotificationService _notificationService = InAppNotificationService();
  int _currentImageIndex = 0;
  bool _isMarkedAsViewed = false;

  @override
  void initState() {
    super.initState();
    // Mark as viewed after a short delay to ensure user sees it
    Future.delayed(const Duration(milliseconds: 500), () {
      _markAsViewed();
    });
  }

  Future<void> _markAsViewed() async {
    if (!_isMarkedAsViewed) {
      await _notificationService.markNotificationAsViewed(widget.notification.id);
      _isMarkedAsViewed = true;
      widget.onViewed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Carousel
                    _buildImageCarousel(),
                    
                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(AppSize.appSize16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type Badge
                          _buildTypeBadge(),
                          
                          const SizedBox(height: AppSize.appSize12),
                          
                          // Title
                          Text(
                            widget.notification.title,
                            style: AppStyle.heading3Medium(color: AppColor.textColor),
                          ),
                          
                          const SizedBox(height: AppSize.appSize8),
                          
                          // Location
                          if (widget.notification.location != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColor.primaryColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.notification.location!,
                                    style: AppStyle.heading5Regular(
                                      color: AppColor.descriptionColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          
                          const SizedBox(height: AppSize.appSize12),
                          
                          // Price
                          if (widget.notification.price != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSize.appSize12,
                                vertical: AppSize.appSize8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSize.appSize8),
                              ),
                              child: Text(
                                widget.notification.price!,
                                style: AppStyle.heading4Medium(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: AppSize.appSize16),
                          
                          // Divider
                          const Divider(),
                          
                          const SizedBox(height: AppSize.appSize16),
                          
                          // Description
                          Text(
                            'Details',
                            style: AppStyle.heading4Medium(color: AppColor.textColor),
                          ),
                          
                          const SizedBox(height: AppSize.appSize8),
                          
                          Text(
                            widget.notification.subtitle,
                            style: AppStyle.heading5Regular(
                              color: AppColor.descriptionColor,
                            ),
                          ),
                          
                          const SizedBox(height: AppSize.appSize16),
                          
                          // Timestamp
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColor.descriptionColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Added ${widget.notification.timestamp}',
                                style: AppStyle.heading6Regular(
                                  color: AppColor.descriptionColor,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSize.appSize32),
                          
                          // Action Buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.appSize16,
        vertical: AppSize.appSize12,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              padding: const EdgeInsets.all(AppSize.appSize8),
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColor.textColor,
              ),
            ),
          ),
          const SizedBox(width: AppSize.appSize12),
          Expanded(
            child: Text(
              'New Listing',
              style: AppStyle.heading4Medium(color: AppColor.textColor),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.appSize12,
              vertical: AppSize.appSize6,
            ),
            decoration: BoxDecoration(
              color: AppColor.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: AppColor.successColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fiber_new,
                  color: AppColor.successColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'NEW',
                  style: AppStyle.heading6Medium(color: AppColor.successColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.notification.images ?? 
                   (widget.notification.imageUrl != null ? [widget.notification.imageUrl!] : []);
    
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: AppColor.descriptionColor.withValues(alpha: 0.1),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: AppColor.descriptionColor,
          ),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedFirebaseImage(
                imageUrl: images[index],
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        
        // Image Counter
        if (images.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeBadge() {
    String label;
    Color color;
    IconData icon;
    
    switch (widget.notification.itemType) {
      case 'property':
        label = 'Property';
        color = AppColor.primaryColor;
        icon = Icons.home;
        break;
      case 'project':
        label = 'Upcoming Project';
        color = AppColor.infoColor;
        icon = Icons.apartment;
        break;
      case 'arts_antiques':
        label = 'Arts & Antiques';
        color = AppColor.warningColor;
        icon = Icons.palette;
        break;
      default:
        label = 'New Listing';
        color = AppColor.descriptionColor;
        icon = Icons.new_releases;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.appSize12,
        vertical: AppSize.appSize8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSize.appSize8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppStyle.heading6Medium(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              _navigateToItem();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: AppColor.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.notification.actionText ?? 'View Details',
                  style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppSize.appSize12),
        
        // Secondary Action Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColor.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
            child: Text(
              'Close',
              style: AppStyle.heading5Medium(color: AppColor.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToItem() {
    // Navigate based on item type
    switch (widget.notification.itemType) {
      case 'property':
        if (widget.notification.itemId != null) {
          Get.back();
          Get.toNamed('/property_details_view', arguments: {
            'propertyId': widget.notification.itemId,
          });
        }
        break;
      case 'project':
        if (widget.notification.itemId != null) {
          Get.back();
          Get.toNamed('/upcoming_project_details_view', arguments: {
            'projectId': widget.notification.itemId,
          });
        }
        break;
      case 'arts_antiques':
        if (widget.notification.itemId != null) {
          Get.back();
          Get.toNamed('/arts_antiques_details_view', arguments: {
            'itemId': widget.notification.itemId,
          });
        }
        break;
      default:
        Get.back();
    }
  }
}

