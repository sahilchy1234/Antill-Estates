import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/activity_controller.dart';
import 'package:antill_estates/controller/bottom_bar_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/views/activity/widgets/listings_states_bottom_sheet.dart';
import 'package:antill_estates/views/activity/widgets/sort_by_listing_bottom_sheet.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/common/shimmer_loading.dart';
import 'package:antill_estates/common/optimized_image_widget.dart';

import '../../model/property_model.dart';
import '../../services/enhanced_loading_service.dart';

class ActivityView extends StatelessWidget {
  ActivityView({super.key});

  final ActivityController activityController = Get.put(ActivityController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: activityController.isLoading.value
          ? EnhancedLoadingService.buildActivityPageLoading()
          : activityController.hasError.value
          ? buildErrorView()
          : buildActivityView(context),
    ));
  }

  Widget buildLoadingView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top filter and sort section shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading.simpleShimmer(
                child: Container(
                  height: AppSize.appSize24,
                  width: AppSize.appSize122,
                  decoration: BoxDecoration(
                    color: AppColor.descriptionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                  ),
                ),
              ),
              ShimmerLoading.simpleShimmer(
                child: Container(
                  height: AppSize.appSize20,
                  width: AppSize.appSize80,
                  decoration: BoxDecoration(
                    color: AppColor.descriptionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                  ),
                ),
              ),
            ],
          ),
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
          ).paddingOnly(top: AppSize.appSize26),
          // Properties list shimmer
          Column(
            children: List.generate(5, (index) => ShimmerLoading.propertyCardShimmer()),
          ).paddingOnly(top: AppSize.appSize26),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColor.negativeColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load properties',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            activityController.errorMessage.value,
            textAlign: TextAlign.center,
            style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => activityController.refreshProperties(),
            child: const Text('Retry'),
          ),
        ],
      ).paddingSymmetric(horizontal: 32),
    );
  }

  Widget buildActivityView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => activityController.refreshProperties(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSize.appSize20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top filter and sort section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    listingStatesBottomSheet(context);
                  },
                  child: Row(
                    children: [
                      Text(
                        activityController.deleteShowing.value == true
                            ? AppString.deleteListings
                            : AppString.yourListing,
                        style:
                        AppStyle.heading3SemiBold(color: AppColor.textColor),
                      ).paddingOnly(right: AppSize.appSize6),
                      Image.asset(
                        Assets.images.dropdown.path,
                        width: AppSize.appSize20,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    sortByListingBottomSheet(context);
                  },
                  child: Text(
                    AppString.sortByText,
                    style:
                    AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                )
              ],
            ),
            // Search bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                color: AppColor.whiteColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: AppSize.appSizePoint1,
                    blurRadius: AppSize.appSize2,
                  ),
                ],
              ),
              child: TextFormField(
                controller: activityController.searchListController,
                cursorColor: AppColor.primaryColor,
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                decoration: InputDecoration(
                  hintText: AppString.searchListing,
                  hintStyle:
                  AppStyle.heading4Regular(color: AppColor.descriptionColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSize.appSize16,
                      right: AppSize.appSize16,
                    ),
                    child: Image.asset(
                      Assets.images.search.path,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    maxWidth: AppSize.appSize51,
                  ),
                ),
              ),
            ).paddingOnly(top: AppSize.appSize26),
            // Properties list
            Obx(() {
              if (activityController.searchResults.isEmpty &&
                  !activityController.isLoading.value) {
                return buildEmptyState();
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: AppSize.appSize26),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activityController.searchResults.length,
                itemBuilder: (context, index) {
                  final property = activityController.searchResults[index];
                  return buildPropertyCard(context, property);
                },
              );
            }),
          ],
        ).paddingOnly(
          top: AppSize.appSize10,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.home_outlined,
            size: 64,
            color: AppColor.descriptionColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by posting your first property',
            style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
          ),
        ],
      ),
    );
  }

  Widget buildPropertyCard(BuildContext context, Property property) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.appSize26),
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Row(
        children: [
          // Property image with optimized loading
          SizedBox(
            width: AppSize.appSize90,
            height: AppSize.appSize90,
            child: property.propertyPhotos.isNotEmpty
                ? PropertyImageWidget(
                    imageUrl: property.propertyPhotos.first,
                    width: AppSize.appSize90,
                    height: AppSize.appSize90,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                    isMainImage: false,
                  )
                : Container(
                    color: AppColor.descriptionColor.withOpacity(0.1),
                    child: Icon(
                      Icons.home_outlined,
                      color: AppColor.descriptionColor,
                    ),
                  ),
          ).paddingOnly(right: AppSize.appSize16),
          // Property details
          Expanded(
            child: SizedBox(
              height: AppSize.appSize110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price and delete button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activityController.formatPrice(property.expectedPrice),
                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                      ),
                      if (activityController.deleteShowing.value) ...[
                        GestureDetector(
                          onTap: () {
                            _showDeleteConfirmation(context, property);
                          },
                          child: Text(
                            AppString.deleteButton,
                            style: AppStyle.heading5Medium(color: AppColor.negativeColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Property title
                  Text(
                    activityController.getPropertyTitle(property),
                    style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Property address
                  Text(
                    activityController.getPropertyAddress(property),
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Manage property
                  GestureDetector(
                    onTap: () {
                      _showManagePropertyOptions(context, property);
                    },
                    child: Text(
                      AppString.manageProperty,
                      style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content:
        const Text('Are you sure you want to delete this property? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (property.id != null) {
                activityController.deleteProperty(property.id!);
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColor.negativeColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showManagePropertyOptions(BuildContext context, Property property) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Get.back();
                if (property.id != null) {
                  Get.toNamed(AppRoutes.showPropertyDetailsView, arguments: property.id);
                } else {
                  Get.snackbar(
                    'Error',
                    'Property ID not available. Cannot view details.',
                    backgroundColor: AppColor.negativeColor,
                    colorText: AppColor.whiteColor,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Property'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.editPropertyView, arguments: property);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColor.negativeColor),
              title: Text('Delete Property', style: TextStyle(color: AppColor.negativeColor)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(context, property);
              },
            ),
          ],
        ),
      ),
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
            if (activityController.deleteShowing.value == true) {
              activityController.deleteShowing.value = false;
              activityController.selectListing.value = 0;
            } else {
              BottomBarController bottomBarController = Get.find<BottomBarController>();
              bottomBarController.updateIndex(0);
            }
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      actions: [
        IconButton(
          onPressed: () => activityController.refreshProperties(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
