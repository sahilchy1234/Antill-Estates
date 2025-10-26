import 'package:flutter/material.dart';
import '../common/shimmer_loading.dart';
import '../configs/app_color.dart';
import '../configs/app_size.dart';

/// Enhanced loading service for interactive loading across all pages
class EnhancedLoadingService {
  
  /// Universal loading wrapper for any page
  static Widget pageLoadingWrapper({
    required Widget child,
    required bool isLoading,
    Widget? customLoadingWidget,
  }) {
    if (isLoading) {
      return customLoadingWidget ?? buildDefaultPageLoading();
    }
    return child;
  }

  /// Default page loading with shimmer
  static Widget buildDefaultPageLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        children: [
          // Header shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          // Content shimmer
          ShimmerLoading.listShimmer(itemCount: 5),
        ],
      ),
    );
  }

  /// Home page specific loading
  static Widget buildHomePageLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section shimmer
          Row(
            children: [
              ShimmerLoading.simpleShimmer(
                child: Container(
                  width: AppSize.appSize40,
                  height: AppSize.appSize40,
                  decoration: BoxDecoration(
                    color: AppColor.descriptionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                  ),
                ),
              ),
              const SizedBox(width: AppSize.appSize16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading.simpleShimmer(
                      child: Container(
                        height: AppSize.appSize16,
                        width: AppSize.appSize100,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.appSize8),
                    ShimmerLoading.simpleShimmer(
                      child: Container(
                        height: AppSize.appSize20,
                        width: AppSize.appSize100,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.appSize24),
          // Search bar shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize24),
          // Featured properties shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          SizedBox(
            height: AppSize.appSize200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: AppSize.appSize250,
                margin: EdgeInsets.only(right: index < 2 ? AppSize.appSize16 : 0),
                child: ShimmerLoading.propertyCardShimmer(),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize24),
          // Recent properties shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          ShimmerLoading.listShimmer(itemCount: 3),
        ],
      ),
    );
  }

  /// Property list page loading
  static Widget buildPropertyListLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        children: [
          // Filter bar shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          // Property cards shimmer
          ShimmerLoading.listShimmer(itemCount: 6),
        ],
      ),
    );
  }

  /// Property details page loading
  static Widget buildPropertyDetailsLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main image shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          // Title and price shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize24,
              width: AppSize.appSize200,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize8),
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          // Features shimmer
          Row(
            children: List.generate(3, (index) => 
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? AppSize.appSize8 : 0),
                  child: ShimmerLoading.simpleShimmer(
                    child: Container(
                      height: AppSize.appSize60,
                      decoration: BoxDecoration(
                        color: AppColor.descriptionColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize24),
          // Description shimmer
          ShimmerLoading.textShimmer(lines: 4),
        ],
      ),
    );
  }

  /// Profile page loading
  static Widget buildProfilePageLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        children: [
          // Profile header shimmer
          Row(
            children: [
              ShimmerLoading.simpleShimmer(
                child: Container(
                  width: AppSize.appSize60,
                  height: AppSize.appSize60,
                  decoration: BoxDecoration(
                    color: AppColor.descriptionColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: AppSize.appSize16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading.simpleShimmer(
                      child: Container(
                        height: AppSize.appSize20,
                        width: AppSize.appSize100,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.appSize8),
                    ShimmerLoading.simpleShimmer(
                      child: Container(
                        height: AppSize.appSize16,
                        width: AppSize.appSize100,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.appSize24),
          // Profile options shimmer
          ShimmerLoading.listShimmer(itemCount: 8),
        ],
      ),
    );
  }

  /// Search page loading
  static Widget buildSearchPageLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize24),
          // Search suggestions shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          ShimmerLoading.listShimmer(itemCount: 5),
          const SizedBox(height: AppSize.appSize24),
          // Recent searches shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          ShimmerLoading.listShimmer(itemCount: 3),
        ],
      ),
    );
  }

  /// Activity page loading
  static Widget buildActivityPageLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity header shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          // Activity items shimmer
          ShimmerLoading.listShimmer(itemCount: 8),
        ],
      ),
    );
  }

  /// Saved properties page loading
  static Widget buildSavedPropertiesLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          // Saved properties shimmer
          ShimmerLoading.listShimmer(itemCount: 6),
        ],
      ),
    );
  }

  /// Login/Register page loading
  static Widget buildAuthPageLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        children: [
          // Logo shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize80,
              width: AppSize.appSize80,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize32),
          // Form fields shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize24),
          // Button shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Post property page loading
  static Widget buildPostPropertyLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize24),
          // Form sections shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          ShimmerLoading.listShimmer(itemCount: 4),
          const SizedBox(height: AppSize.appSize24),
          // Image upload shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gallery page loading
  static Widget buildGalleryLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSize.appSize16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSize.appSize16,
        mainAxisSpacing: AppSize.appSize16,
        childAspectRatio: 1.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerLoading.simpleShimmer(
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.descriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
          ),
        );
      },
    );
  }

  /// Notification page loading
  static Widget buildNotificationLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        children: [
          // Header shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize20,
              width: AppSize.appSize150,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize16),
          // Notification items shimmer
          ShimmerLoading.listShimmer(itemCount: 8),
        ],
      ),
    );
  }

  /// Drawer page loading
  static Widget buildDrawerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        children: [
          // Profile section shimmer
          Row(
            children: [
              ShimmerLoading.simpleShimmer(
                child: Container(
                  width: AppSize.appSize50,
                  height: AppSize.appSize50,
                  decoration: BoxDecoration(
                    color: AppColor.descriptionColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: AppSize.appSize16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading.simpleShimmer(
                      child: Container(
                        height: AppSize.appSize18,
                        width: AppSize.appSize100,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.appSize8),
                    ShimmerLoading.simpleShimmer(
                      child: Container(
                        height: AppSize.appSize14,
                        width: AppSize.appSize80,
                        decoration: BoxDecoration(
                          color: AppColor.descriptionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.appSize24),
          // Menu items shimmer
          ShimmerLoading.listShimmer(itemCount: 10),
        ],
      ),
    );
  }

  /// Loading overlay for any page
  static Widget buildLoadingOverlay({
    required bool isLoading,
    required Widget child,
    String? loadingText,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColor.whiteColor.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(height: AppSize.appSize16),
                    Text(
                      loadingText,
                      style: const TextStyle(
                        color: AppColor.textColor,
                        fontSize: AppSize.appSize16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Skeleton loading for specific content types
  static Widget buildSkeletonLoading({
    required String contentType,
    int itemCount = 3,
  }) {
    switch (contentType.toLowerCase()) {
      case 'property':
        return ShimmerLoading.listShimmer(itemCount: itemCount);
      case 'profile':
        return ShimmerLoading.profileShimmer();
      case 'image':
        return ShimmerLoading.imageShimmer();
      case 'text':
        return ShimmerLoading.textShimmer(lines: itemCount);
      default:
        return ShimmerLoading.listShimmer(itemCount: itemCount);
    }
  }
}
