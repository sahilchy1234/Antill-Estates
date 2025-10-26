import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_status_bar.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
// Removed: import 'package:antill_estates/controller/bottom_bar_controller.dart'; - no longer needed
import 'package:antill_estates/controller/home_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';
import 'package:antill_estates/common/shimmer_loading.dart';
import 'package:antill_estates/common/optimized_image_widget.dart';
import 'package:antill_estates/controller/show_property_details_controller.dart';
import 'package:antill_estates/utils/price_formatter.dart';
import '../../services/UserDataController.dart';
import '../../services/enhanced_loading_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  HomeController get homeController => Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    // Load Firebase data when the view is built (only show loading on first load)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.loadHomeData(showLoading: !homeController.hasCachedData());
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: RefreshIndicator(
            onRefresh: () async {
              await homeController.refreshHomeData();
            },
            child: buildHome(context),
          ),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  Widget buildHome(BuildContext context) {

    Get.put(ShowPropertyDetailsController());

    UserDataController controller = Get.find<UserDataController>();

    return Obx(() {
      if (homeController.isLoading.value) {
        return EnhancedLoadingService.buildHomePageLoading();
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.appSize16,
                  vertical: AppSize.appSize12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                          child: Container(
                            width: AppSize.appSize44,
                            height: AppSize.appSize44,
                            // decoration: BoxDecoration(
                            //   color: AppColor.primaryColor.withValues(alpha: 0.1),
                            //   borderRadius: BorderRadius.circular(AppSize.appSize12),
                            // ),
                            child: Center(
                        child: Image.asset(
                          Assets.images.drawer.path,
                                width: AppSize.appSize48,
                                height: AppSize.appSize48,
                      ),
                            ),
                          ),
                        ).paddingOnly(right: AppSize.appSize16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                              "Hi, ${controller.fullName.value}",
                            style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                          )),
                          Text(
                            AppString.welcome,
                              style: AppStyle.heading3SemiBold(color: AppColor.primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                        // Enhanced Notification button
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.notificationView);
                        },
                          child: Container(
                            width: AppSize.appSize44,
                            height: AppSize.appSize44,
                            // decoration: BoxDecoration(
                            //   // color: AppColor.primaryColor.withValues(alpha: 0.1),
                            //   // borderRadius: BorderRadius.circular(AppSize.appSize12),
                            // ),
                            child: Center(
                        child: Image.asset(
                          Assets.images.notification.path,
                                width: AppSize.appSize48,
                                height: AppSize.appSize48,
                              ),
                            ),
                        ),
                      ),
                    ],
                  )
                ],
                ),
              ),
              // Enhanced Property Filter Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.appSize16,
                  vertical: AppSize.appSize20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What are you looking for?",
                      style: AppStyle.heading4SemiBold(color: AppColor.textColor),
                    ).paddingOnly(bottom: AppSize.appSize16),
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(homeController.propertyOptionList.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        homeController.updateProperty(index);
                      },
                      child: Obx(() => Container(
                              height: AppSize.appSize44,
                              margin: const EdgeInsets.only(right: AppSize.appSize12),
                              padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize20),
                        decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSize.appSize22),
                          color: homeController.selectProperty.value == index
                              ? AppColor.primaryColor
                                    : AppColor.whiteColor,
                                border: Border.all(
                                  color: homeController.selectProperty.value == index
                                      ? AppColor.primaryColor
                                      : AppColor.borderColor,
                                  width: AppSize.appSize1,
                                ),
                                boxShadow: homeController.selectProperty.value == index
                                    ? [
                                        BoxShadow(
                                          color: AppColor.primaryColor.withValues(alpha: 0.3),
                                          spreadRadius: 0,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: AppColor.descriptionColor.withValues(alpha: 0.1),
                                          spreadRadius: 0,
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                        ),
                        child: Center(
                          child: Text(
                            homeController.propertyOptionList[index],
                                  style: AppStyle.heading5Medium(
                              color: homeController.selectProperty.value == index
                                  ? AppColor.whiteColor
                                        : AppColor.textColor,
                            ),
                          ),
                        ),
                      )),
                    );
                  }),
              ),
                    ),
                  ],
                ),
              ),
              // Enhanced Search Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.descriptionColor.withValues(alpha: 0.1),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: homeController.searchController,
                  cursorColor: AppColor.primaryColor,
                  style: AppStyle.heading4Regular(color: AppColor.textColor),
                  readOnly: true,
                  onTap: () {
                    Get.toNamed(AppRoutes.searchView);
                  },
                  decoration: InputDecoration(
                    hintText: AppString.searchCity,
                    hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.appSize16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.appSize16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.appSize16),
                      borderSide: BorderSide(
                        color: AppColor.primaryColor,
                        width: AppSize.appSize2,
                      ),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSize.appSize20, right: AppSize.appSize12,
                      ),
                      child: Image.asset(
                        Assets.images.search.path,
                        width: AppSize.appSize20,
                        height: AppSize.appSize20,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      maxWidth: AppSize.appSize60,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSize.appSize16,
                      horizontal: AppSize.appSize20,
                    ),
                  ),
                ),
              ).paddingOnly(bottom: AppSize.appSize20),
              // Enhanced Location Filter Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.appSize16,
                  vertical: AppSize.appSize16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Popular Locations",
                      style: AppStyle.heading4SemiBold(color: AppColor.textColor),
                    ).paddingOnly(bottom: AppSize.appSize16),
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(homeController.countryOptionList.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        homeController.updateCountry(index);
                        if(index == AppSize.size3) {
                          Get.toNamed(AppRoutes.searchView);
                        }
                      },
                      child: Obx(() => Container(
                              height: AppSize.appSize40,
                              padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize20),
                              margin: const EdgeInsets.only(right: AppSize.appSize12),
                        decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSize.appSize20),
                                color: homeController.selectCountry.value == index
                                    ? AppColor.primaryColor
                                    : AppColor.whiteColor,
                                border: Border.all(
                              color: homeController.selectCountry.value == index
                                  ? AppColor.primaryColor
                                  : AppColor.borderColor,
                              width: AppSize.appSize1,
                            ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.descriptionColor.withValues(alpha: 0.1),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: Text(
                            homeController.countryOptionList[index],
                            style: AppStyle.heading5Medium(
                              color: homeController.selectCountry.value == index
                                        ? AppColor.whiteColor
                                  : AppColor.textColor,
                            ),
                          ),
                        ),
                      )),
                    );
                  }),
                      ),
                    ),
                  ],
                ),
              ),
              // Enhanced Section Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppString.recommendedProject,
                    style: AppStyle.heading3SemiBold(color: AppColor.textColor),
                  ),
                  GestureDetector(
                    onTap: () {
                        Get.toNamed(AppRoutes.propertyListView, arguments: {
                          'section': 'recommended',
                          'title': 'Recommended Properties',
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize12,
                          vertical: AppSize.appSize6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                      AppString.viewAll,
                              style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ),
                            const SizedBox(width: AppSize.appSize4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: AppSize.appSize12,
                              color: AppColor.primaryColor,
                  ),
                ],
              ),
                      ),
                    ),
                  ],
                ),
              ).paddingOnly(top: AppSize.appSize24, bottom: AppSize.appSize16),
              // Recommended Projects - Dynamic from Firebase
              Obx(() {
                final recommendedProperties = homeController.recommendedProperties;
                if (recommendedProperties.isEmpty) {
                  return Container(
                    height: AppSize.appSize282,
                    child: Center(
                      child: Text(
                        'No recommended properties available',
                        style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    height: AppSize.appSize282,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: AppSize.appSize16),
                      itemCount: recommendedProperties.length,
                      itemBuilder: (context, index) {
                        final property = recommendedProperties[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to property details
                            if (property.id != null) {
                              Get.toNamed(AppRoutes.propertyDetailsView, arguments: {
                                'propertyId': property.id,
                                'heroTag': 'property-recommended-${property.id}',
                              });
                            } else {
                              Get.snackbar(
                                'Error',
                                'Property ID not available. Cannot view details.',
                                backgroundColor: AppColor.negativeColor,
                                colorText: AppColor.whiteColor,
                              );
                            }
                          },
                          child: Container(
                            width: AppSize.appSize180,
                            margin: const EdgeInsets.only(right: AppSize.appSize16),
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor,
                              borderRadius: BorderRadius.circular(AppSize.appSize16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.descriptionColor.withValues(alpha: 0.1),
                                  spreadRadius: 0,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Property Image with Hero animation and Save button
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(AppSize.appSize16),
                                        topRight: Radius.circular(AppSize.appSize16),
                                      ),
                                      child: property.propertyPhotos.isNotEmpty
                                      ? Hero(
                                          tag: 'property-recommended-${property.id}',
                                          child: Material(
                                            color: Colors.transparent,
                                            child: PropertyImageWidget(
                                              imageUrl: property.propertyPhotos.first,
                                              height: AppSize.appSize130,
                                                  width: AppSize.appSize180,
                                              fit: BoxFit.cover,
                                                  borderRadius: BorderRadius.zero,
                                              isMainImage: false,
                                            ),
                                          ),
                                        )
                                    : Container(
                                        height: AppSize.appSize130,
                                            width: AppSize.appSize180,
                                        color: AppColor.backgroundColor,
                                            child: const Icon(Icons.home, size: 40),
                                          ),
                                    ),
                                    // Save button
                                    Positioned(
                                      right: AppSize.appSize8,
                                      top: AppSize.appSize8,
                                      child: GestureDetector(
                                        onTap: () {
                                          homeController.toggleRecommendedPropertySave(index);
                                        },
                                        child: Container(
                                          width: AppSize.appSize32,
                                          height: AppSize.appSize32,
                                  decoration: BoxDecoration(
                                            color: AppColor.whiteColor.withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(AppSize.appSize16),
                                  ),
                                  child: Center(
                                            child: Obx(() {
                                              final isLiked = index < homeController.isRecommendedPropertyLiked.length 
                                                  ? homeController.isRecommendedPropertyLiked[index] 
                                                  : false;
                                              final isSaving = index < homeController.isRecommendedPropertySaving.length 
                                                  ? homeController.isRecommendedPropertySaving[index] 
                                                  : false;
                                              
                                              if (isSaving) {
                                                return const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                                                  ),
                                                );
                                              }
                                              
                                              return Icon(
                                                isLiked ? Icons.bookmark : Icons.bookmark_add_outlined,
                                                size: AppSize.appSize16,
                                                color: isLiked ? AppColor.negativeColor : AppColor.descriptionColor,
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Property details
                                Padding(
                                  padding: const EdgeInsets.all(AppSize.appSize12),
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      // Price
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSize.appSize8,
                                          vertical: AppSize.appSize4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(AppSize.appSize8),
                                        ),
                                        child: Text(
                                          PriceFormatter.formatPrice(property.expectedPrice),
                                          style: AppStyle.heading5SemiBold(color: AppColor.primaryColor),
                                        ),
                                      ),
                                      const SizedBox(height: AppSize.appSize8),
                                      // Property type and location
                                    Text(
                                      '${property.propertyType} - ${property.propertyLooking}',
                                      style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                      const SizedBox(height: AppSize.appSize4),
                                    Text(
                                      '${property.locality}, ${property.city}',
                                        style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: AppSize.appSize8),
                                      // Rating and time
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Obx(() {
                                            final rating = index < homeController.recommendedPropertyRatings.length 
                                                ? homeController.recommendedPropertyRatings[index] 
                                                : 0.0;
                                            return Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: AppSize.appSize14,
                                                  color: AppColor.primaryColor,
                                                ),
                                                const SizedBox(width: AppSize.appSize2),
                                                Text(
                                                  rating > 0 ? rating.toStringAsFixed(1) : 'New',
                                                  style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                                                ),
                                              ],
                                            );
                                          }),
                                Text(
                                  property.createdAt != null 
                                      ? _getRelativeTime(property.createdAt!)
                                      : 'Recently',
                                  style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ).paddingOnly(top: AppSize.appSize16);
              }),
              // Enhanced Section Header for Trending Properties
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
              Text(
                AppString.basedOnSearchTrends,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.propertyListView, arguments: {
                          'section': 'trending',
                          'title': 'Trending Properties',
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize12,
                          vertical: AppSize.appSize6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppString.viewAll,
                              style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                            ),
                            const SizedBox(width: AppSize.appSize4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: AppSize.appSize12,
                              color: AppColor.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).paddingOnly(top: AppSize.appSize32, bottom: AppSize.appSize16),
              // Trending Properties - Dynamic from Firebase
              Obx(() {
                final trendingProperties = homeController.trendingProperties;
                if (trendingProperties.isEmpty) {
                  return Container(
                    height: AppSize.appSize372,
                    child: Center(
                      child: Text(
                        'No trending properties available',
                        style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: AppSize.appSize372,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(left: AppSize.appSize16),
                    itemCount: trendingProperties.length,
                    itemBuilder: (context, index) {
                      final property = trendingProperties[index];
                      return GestureDetector(
                        onTap: () {
                          if (property.id != null) {
                            Get.toNamed(AppRoutes.propertyDetailsView, arguments: {
                              'propertyId': property.id,
                              'heroTag': 'property-trending-${property.id}',
                            });
                          } else {
                            Get.snackbar(
                              'Error',
                              'Property ID not available. Cannot view details.',
                              backgroundColor: AppColor.negativeColor,
                              colorText: AppColor.whiteColor,
                            );
                          }
                        },
                        child: Container(
                          width: AppSize.appSize320,
                          margin: const EdgeInsets.only(right: AppSize.appSize16),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(AppSize.appSize16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.descriptionColor.withValues(alpha: 0.1),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: [
                                  // Property Image with Hero animation
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(AppSize.appSize16),
                                      topRight: Radius.circular(AppSize.appSize16),
                                    ),
                                    child: property.propertyPhotos.isNotEmpty
                                      ? Hero(
                                          tag: 'property-trending-${property.id}',
                                          child: Material(
                                            color: Colors.transparent,
                                            child: PropertyImageWidget(
                                              imageUrl: property.propertyPhotos.first,
                                              height: AppSize.appSize200,
                                                width: AppSize.appSize320,
                                              fit: BoxFit.cover,
                                                borderRadius: BorderRadius.zero,
                                              isMainImage: true,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: AppSize.appSize200,
                                            width: AppSize.appSize320,
                                          color: AppColor.backgroundColor,
                                            child: const Icon(Icons.home, size: 50),
                                        ),
                                  ),
                                  // Enhanced Save button
                                  Positioned(
                                    right: AppSize.appSize12,
                                    top: AppSize.appSize12,
                                    child: GestureDetector(
                                      onTap: () {
                                        homeController.toggleTrendingPropertySave(index);
                                      },
                                      child: Container(
                                        width: AppSize.appSize36,
                                        height: AppSize.appSize36,
                                        decoration: BoxDecoration(
                                          color: AppColor.whiteColor.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(AppSize.appSize18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColor.descriptionColor.withValues(alpha: 0.2),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Obx(() {
                                            final isLiked = index < homeController.isTrendPropertyLiked.length 
                                                ? homeController.isTrendPropertyLiked[index] 
                                                : false;
                                            final isSaving = index < homeController.isTrendingPropertySaving.length 
                                                ? homeController.isTrendingPropertySaving[index] 
                                                : false;
                                            
                                            if (isSaving) {
                                              return const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                                                ),
                                              );
                                            }
                                            
                                            return Icon(
                                              isLiked ? Icons.bookmark : Icons.bookmark_add_outlined,
                                              size: AppSize.appSize18,
                                              color: isLiked ? AppColor.negativeColor : AppColor.descriptionColor,
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Enhanced Property Details Section
                              Padding(
                                padding: const EdgeInsets.all(AppSize.appSize16),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    // Property type and location
                                  Text(
                                    '${property.propertyType} - ${property.propertyLooking}',
                                    style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                    const SizedBox(height: AppSize.appSize4),
                                  Text(
                                    '${property.locality}, ${property.city}',
                                      style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSize.appSize12),
                                    // Price and Rating Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSize.appSize12,
                                            vertical: AppSize.appSize6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColor.primaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(AppSize.appSize12),
                                          ),
                                          child: Text(
                                    PriceFormatter.formatPrice(property.expectedPrice),
                                            style: AppStyle.heading5SemiBold(color: AppColor.primaryColor),
                                          ),
                                  ),
                                  Obx(() {
                                    final rating = index < homeController.trendingPropertyRatings.length 
                                        ? homeController.trendingPropertyRatings[index] 
                                        : 0.0;
                                    return Row(
                                      children: [
                                              Icon(
                                                Icons.star,
                                                size: AppSize.appSize16,
                                                color: AppColor.primaryColor,
                                              ),
                                              const SizedBox(width: AppSize.appSize4),
                                        Text(
                                                rating > 0 ? rating.toStringAsFixed(1) : 'New',
                                                style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                                    const SizedBox(height: AppSize.appSize12),
                                    // Property Features
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                            horizontal: AppSize.appSize12,
                                      vertical: AppSize.appSize6, 
                                    ),
                                    decoration: BoxDecoration(
                                            color: AppColor.backgroundColor,
                                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                                      border: Border.all(
                                              color: AppColor.borderColor,
                                              width: AppSize.appSize1,
                                      ),
                                    ),
                                    child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                      children: [
                                              Icon(
                                                Icons.bed,
                                                size: AppSize.appSize14,
                                                color: AppColor.primaryColor,
                                              ),
                                              const SizedBox(width: AppSize.appSize4),
                                        Text(
                                          '${property.noOfBedrooms} BHK',
                                                style: AppStyle.heading6Medium(color: AppColor.textColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                            horizontal: AppSize.appSize12,
                                      vertical: AppSize.appSize6, 
                                    ),
                                    decoration: BoxDecoration(
                                            color: AppColor.backgroundColor,
                                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                                      border: Border.all(
                                              color: AppColor.borderColor,
                                              width: AppSize.appSize1,
                                      ),
                                    ),
                                    child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                      children: [
                                              Icon(
                                                Icons.square_foot,
                                                size: AppSize.appSize14,
                                                color: AppColor.primaryColor,
                                              ),
                                              const SizedBox(width: AppSize.appSize4),
                                        Text(
                                          '${property.builtUpArea} sq ft',
                                                style: AppStyle.heading6Medium(color: AppColor.textColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ).paddingOnly(top: AppSize.appSize16);
              }),
              // Enhanced Section Header for Upcoming Projects
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppString.upcomingProject,
                    style: AppStyle.heading3SemiBold(color: AppColor.textColor),
                  ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.upcomingProjectsView);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize12,
                          vertical: AppSize.appSize6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                  Text(
                    AppString.viewAll,
                              style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                            ),
                            const SizedBox(width: AppSize.appSize4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: AppSize.appSize12,
                              color: AppColor.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).paddingOnly(top: AppSize.appSize32, bottom: AppSize.appSize16),
              // Upcoming Projects - Dynamic from Firebase
              Obx(() {
                final projects = homeController.upcomingProjects;
                if (projects.isEmpty) {
                  return Container(
                    height: AppSize.appSize320,
                    child: Center(
                      child: Text(
                        'No upcoming projects available',
                        style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: AppSize.appSize320,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(left: AppSize.appSize16),
                    scrollDirection: Axis.horizontal,
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate directly to project details
                          Get.toNamed(AppRoutes.upcomingProjectDetailsView, arguments: {
                            'project': project,
                          });
                        },
                        child: Container(
                          width: AppSize.appSize343,
                          margin: const EdgeInsets.only(right: AppSize.appSize16),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(AppSize.appSize16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.descriptionColor.withValues(alpha: 0.1),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Project Image
                              project['image'] != null && project['image'].toString().startsWith('http')
                                  ? CachedFirebaseImage(
                                      imageUrl: project['image'],
                                      width: AppSize.appSize343,
                                      height: AppSize.appSize320,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                                      errorWidget: Container(
                                        width: AppSize.appSize343,
                                        height: AppSize.appSize320,
                                        decoration: BoxDecoration(
                                          color: AppColor.backgroundColor,
                                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                                          image: DecorationImage(
                                            image: AssetImage(Assets.images.upcomingProject1.path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: AppSize.appSize343,
                                      height: AppSize.appSize320,
                                      decoration: BoxDecoration(
                                        color: AppColor.backgroundColor,
                                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                                        image: DecorationImage(
                                          image: AssetImage(project['image'] ?? Assets.images.upcomingProject1.path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              // Gradient overlay for better text readability
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Project content
                              Positioned(
                                left: AppSize.appSize10,
                                right: AppSize.appSize10,
                                bottom: AppSize.appSize10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            project['title'] ?? 'Project',
                                            style: AppStyle.heading3(color: AppColor.whiteColor),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          PriceFormatter.formatPrice(project['price'] ?? 'Price on Request'),
                                          style: AppStyle.heading5(color: AppColor.whiteColor),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      project['address'] ?? 'Address',
                                      style: AppStyle.heading5Regular(color: AppColor.whiteColor),
                                    ).paddingOnly(top: AppSize.appSize6),
                                    Text(
                                      project['flatSize'] ?? 'Flat Size',
                                      style: AppStyle.heading6Medium(color: AppColor.whiteColor),
                                    ).paddingOnly(top: AppSize.appSize6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ).paddingOnly(top: AppSize.appSize16);
              }),
              // Enhanced Section Header for Popular Cities
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
              Text(
                AppString.explorePopularCity,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.searchView, arguments: {
                          'section': 'cities',
                          'title': 'Popular Cities',
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize12,
                          vertical: AppSize.appSize6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSize.appSize16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppString.viewAll,
                              style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                            ),
                            const SizedBox(width: AppSize.appSize4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: AppSize.appSize12,
                              color: AppColor.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).paddingOnly(top: AppSize.appSize32, bottom: AppSize.appSize16),
              // Popular Cities - Dynamic from Firebase
              Obx(() {
                final cities = homeController.popularCities;
                if (cities.isEmpty) {
                  return Container(
                    height: AppSize.appSize100,
                    child: Center(
                      child: Text(
                        'No cities available',
                        style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: AppSize.appSize100,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(left: AppSize.appSize16),
                    scrollDirection: Axis.horizontal,
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to search with city filter
                          Get.toNamed(AppRoutes.searchView, arguments: {
                            'city': city['name'],
                            'location': city['name'],
                          });
                        },
                        child: Container(
                          width: AppSize.appSize100,
                          height: AppSize.appSize100,
                          margin: const EdgeInsets.only(right: AppSize.appSize16),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(AppSize.appSize16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.descriptionColor.withValues(alpha: 0.1),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // City Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppSize.appSize16),
                                child: Container(
                                  width: AppSize.appSize100,
                                  height: AppSize.appSize100,
                                  decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(city['image'] ?? Assets.images.city1.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                                ),
                              ),
                              // Gradient overlay
                              Container(
                                width: AppSize.appSize100,
                                height: AppSize.appSize100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSize.appSize16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),
                              // City name
                              Positioned(
                                bottom: AppSize.appSize12,
                                left: AppSize.appSize8,
                                right: AppSize.appSize8,
                            child: Text(
                              city['name'] ?? 'City',
                                  style: AppStyle.heading5SemiBold(color: AppColor.whiteColor),
                              textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                            ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ).paddingOnly(top: AppSize.appSize16);
              }),
            ],
          ).paddingOnly(top: AppSize.appSize50, bottom: AppSize.appSize32),
        );
    });
  }

  /// Build shimmer loading for home screen
  Widget buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading.textShimmer(width: AppSize.appSize100, height: AppSize.appSize16),
                      const SizedBox(height: AppSize.appSize4),
                      ShimmerLoading.textShimmer(width: AppSize.appSize80, height: AppSize.appSize20),
                    ],
                  ),
                ],
              ),
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
            ],
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          
          // Property options shimmer
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(4, (index) => 
                ShimmerLoading.simpleShimmer(
                  child: Container(
                    height: AppSize.appSize37,
                    width: AppSize.appSize80,
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                  ),
                ),
              ),
            ),
          ).paddingOnly(top: AppSize.appSize26),
          
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
          ).paddingOnly(top: AppSize.appSize20, left: AppSize.appSize16, right: AppSize.appSize16),
          
          // Country options shimmer
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: AppSize.appSize16, right: AppSize.appSize16),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(4, (index) => 
                ShimmerLoading.simpleShimmer(
                  child: Container(
                    height: AppSize.appSize25,
                    width: AppSize.appSize80,
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                  ),
                ),
              ),
            ),
          ).paddingOnly(top: AppSize.appSize36),
          
          // Section title shimmer
          ShimmerLoading.textShimmer(width: AppSize.appSize150, height: AppSize.appSize20)
            .paddingOnly(top: AppSize.appSize26, left: AppSize.appSize16, right: AppSize.appSize16),
          
          // Recommended properties shimmer
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: AppSize.appSize282,
              child: Row(
                children: List.generate(3, (index) => 
                  ShimmerLoading.propertyGridShimmer()
                    .paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
                ),
              ),
            ),
          ).paddingOnly(top: AppSize.appSize16),
          
          // Section title shimmer
          ShimmerLoading.textShimmer(width: AppSize.appSize122, height: AppSize.appSize20)
            .paddingOnly(top: AppSize.appSize26, left: AppSize.appSize16, right: AppSize.appSize16),
          
          // Recent responses shimmer
          SizedBox(
            height: AppSize.appSize150,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: 3,
              itemBuilder: (context, index) => 
                ShimmerLoading.simpleShimmer(
                  child: Container(
                    width: AppSize.appSize200,
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                  ),
                ),
            ),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(top: AppSize.appSize50, bottom: AppSize.appSize20),
    );
  }

  /// Helper method to get relative time
  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
