import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_status_bar.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/arts_antiques_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';
import 'package:antill_estates/controller/show_property_details_controller.dart';
import 'package:antill_estates/common/shimmer_loading.dart';
import 'package:antill_estates/configs/app_design.dart';
import 'package:antill_estates/utils/price_formatter.dart';

class ArtsAntiquesView extends StatelessWidget {
  const ArtsAntiquesView({super.key});

  ArtsAntiquesController get artsAntiquesController => Get.put(ArtsAntiquesController());

  @override
  Widget build(BuildContext context) {
    // Pre-load cached data immediately (synchronous - instant!)
    if (!artsAntiquesController.hasCachedData()) {
      artsAntiquesController.loadCachedDataSync();
    }
    
    // Load fresh data in background (no loading indicator if cache exists)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      artsAntiquesController.loadArtsAntiquesData(showLoading: false);
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: RefreshIndicator(
            onRefresh: () async {
              await artsAntiquesController.refreshArtsAntiquesData();
            },
            child: buildArtsAntiques(context),
          ),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  Widget buildArtsAntiques(BuildContext context) {
    Get.put(ShowPropertyDetailsController());

    return Obx(() {
      if (artsAntiquesController.isLoading.value) {
        return _buildShimmerLoading(context);
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Arts & Antiques",
              style: AppStyle.heading3Medium(color: AppColor.primaryColor),
            ).paddingOnly(
              left: AppSize.appSize16, right: AppSize.appSize16,
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(artsAntiquesController.categoryOptionList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      artsAntiquesController.updateCategory(index);
                    },
                    child: Obx(() => Container(
                      height: AppSize.appSize37,
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        color: artsAntiquesController.selectCategory.value == index
                            ? AppColor.primaryColor
                            : AppColor.backgroundColor,
                      ),
                      child: Center(
                        child: Text(
                          artsAntiquesController.categoryOptionList[index],
                          style: AppStyle.heading5Regular(
                            color: artsAntiquesController.selectCategory.value == index
                                ? AppColor.whiteColor
                                : AppColor.descriptionColor,
                          ),
                        ),
                      ),
                    )),
                  );
                }),
              ).paddingOnly(top: AppSize.appSize26),
            ),
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
                controller: artsAntiquesController.searchController,
                cursorColor: AppColor.primaryColor,
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                readOnly: true,
                onTap: () {
                  Get.toNamed(AppRoutes.artsAntiquesSearchView);
                },
                decoration: InputDecoration(
                  hintText: "Search Arts & Antiques",
                  hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
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
                      left: AppSize.appSize16, right: AppSize.appSize16,
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
            ).paddingOnly(
              top: AppSize.appSize20,
              left: AppSize.appSize16, right: AppSize.appSize16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Featured Items",
                  style: AppStyle.heading3SemiBold(color: AppColor.textColor),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.propertyListView);
                  },
                  child: Text(
                    AppString.viewAll,
                    style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                  ),
                ),
              ],
            ).paddingOnly(
              top: AppSize.appSize26,
              left: AppSize.appSize16, right: AppSize.appSize16,
            ),
            // Featured Items - Dynamic from Firebase with lazy loading
            Obx(() {
              final featuredItems = artsAntiquesController.featuredItems;
              if (featuredItems.isEmpty) {
                return Container(
                  height: AppSize.appSize282,
                  child: Center(
                    child: Text(
                      'No featured items available',
                      style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: AppSize.appSize282,
                child: ListView.builder(
                  controller: artsAntiquesController.featuredScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: AppSize.appSize16),
                  itemCount: featuredItems.length + (artsAntiquesController.hasMoreFeatured.value ? 1 : 0),
                  cacheExtent: 500.0, // Cache items for better performance
                  itemBuilder: (context, index) {
                    // Show loading indicator at the end
                    if (index >= featuredItems.length) {
                      return Container(
                        width: 80,
                        child: Center(
                          child: Obx(() => artsAntiquesController.isLoadingMore.value
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const SizedBox.shrink()),
                        ),
                      );
                    }
                    
                    final item = featuredItems[index];
                    return RepaintBoundary(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to arts & antiques item details
                          if (item.id != null) {
                            Get.toNamed(AppRoutes.artsAntiquesDetailsView, arguments: item.id);
                          } else {
                            Get.snackbar(
                              'Error',
                              'Item ID not available. Cannot view details.',
                              backgroundColor: AppColor.negativeColor,
                              colorText: AppColor.whiteColor,
                            );
                          }
                        },
                        child: Container(
                          padding: AppDesign.mediumPadding,
                          margin: const EdgeInsets.only(right: AppSize.appSize16),
                          decoration: AppDesign.card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Item Image
                                    item.images.isNotEmpty
                                        ? CachedFirebaseImage(
                                            imageUrl: item.images.first,
                                      height: AppSize.appSize130,
                                      width: AppSize.appSize160,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(AppSize.appSize8),
                                      cacheWidth: 320, // 2x for better quality on retina displays
                                      cacheHeight: 260,
                                      showLoadingIndicator: true,
                                      errorWidget: Container(
                                        height: AppSize.appSize130,
                                        width: AppSize.appSize160,
                                        color: AppColor.backgroundColor,
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    )
                                  : Container(
                                      height: AppSize.appSize130,
                                      width: AppSize.appSize160,
                                      color: AppColor.backgroundColor,
                                      child: const Icon(Icons.palette),
                                    ),
                              Container(
                                padding: const EdgeInsets.all(AppSize.appSize6),
                                decoration: AppDesign.accentContainer,
                                child: Center(
                                  child: Text(
                                    _formatPrice(item.price),
                                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.artist,
                                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                                  ).paddingOnly(top: AppSize.appSize6),
                                ],
                              ),
                              Text(
                                item.createdAt != null 
                                    ? _getRelativeTime(item.createdAt!)
                                    : 'Recently',
                                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).paddingOnly(top: AppSize.appSize16);
            }),
            Text(
              "Trending Collections",
              style: AppStyle.heading3SemiBold(color: AppColor.textColor),
            ).paddingOnly(
              top: AppSize.appSize26,
              left: AppSize.appSize16, right: AppSize.appSize16,
            ),
            // Trending Collections - Dynamic from Firebase with lazy loading
            Obx(() {
              final trendingItems = artsAntiquesController.trendingItems;
              if (trendingItems.isEmpty) {
                return Container(
                  height: AppSize.appSize372,
                  child: Center(
                    child: Text(
                      'No trending collections available',
                      style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: AppSize.appSize372,
                child: ListView.builder(
                  controller: artsAntiquesController.trendingScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: AppSize.appSize16),
                  itemCount: trendingItems.length + (artsAntiquesController.hasMoreTrending.value ? 1 : 0),
                  cacheExtent: 500.0, // Cache items for better performance
                  itemBuilder: (context, index) {
                    // Show loading indicator at the end
                    if (index >= trendingItems.length) {
                      return Container(
                        width: 80,
                        child: Center(
                          child: Obx(() => artsAntiquesController.isLoadingMore.value
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const SizedBox.shrink()),
                        ),
                      );
                    }
                    
                    final item = trendingItems[index];
                    return RepaintBoundary(
                      child: GestureDetector(
                      onTap: () {
                        if (item.id != null) {
                          Get.toNamed(AppRoutes.artsAntiquesDetailsView, arguments: item.id);
                        } else {
                          Get.snackbar(
                            'Error',
                            'Item ID not available. Cannot view details.',
                            backgroundColor: AppColor.negativeColor,
                            colorText: AppColor.whiteColor,
                          );
                        }
                      },
                      child: Container(
                        width: AppSize.appSize300,
                        padding: AppDesign.mediumPadding,
                        margin: const EdgeInsets.only(right: AppSize.appSize16),
                        decoration: AppDesign.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                // Item Image
                                    item.images.isNotEmpty
                                        ? CachedFirebaseImage(
                                            imageUrl: item.images.first,
                                        height: AppSize.appSize200,
                                        width: AppSize.appSize300,
                                        fit: BoxFit.cover,
                                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                                        cacheWidth: 600, // 2x for better quality on retina displays
                                        cacheHeight: 400,
                                        showLoadingIndicator: true,
                                        errorWidget: Container(
                                          height: AppSize.appSize200,
                                          width: AppSize.appSize300,
                                          color: AppColor.backgroundColor,
                                          child: const Icon(Icons.image_not_supported),
                                        ),
                                      )
                                    : Container(
                                        height: AppSize.appSize200,
                                        width: AppSize.appSize300,
                                        color: AppColor.backgroundColor,
                                        child: const Icon(Icons.palette),
                                      ),
                                Positioned(
                                  right: AppSize.appSize6,
                                  top: AppSize.appSize6,
                                  child: GestureDetector(
                                    onTap: () {
                                      artsAntiquesController.toggleTrendingItemSave(index);
                                    },
                                    child: Container(
                                      width: AppSize.appSize32,
                                      height: AppSize.appSize32,
                                      decoration: BoxDecoration(
                                        color: AppColor.whiteColor.withOpacity(0.95),
                                        borderRadius: AppDesign.smallRadius,
                                        boxShadow: AppDesign.cardShadow,
                                      ),
                                      child: Center(
                                        child: Obx(() {
                                          final isLiked = index < artsAntiquesController.isTrendItemLiked.length 
                                              ? artsAntiquesController.isTrendItemLiked[index] 
                                              : false;
                                          final isSaving = index < artsAntiquesController.isTrendingItemSaving.length 
                                              ? artsAntiquesController.isTrendingItemSaving[index] 
                                              : false;
                                          
                                          // Show loading indicator when saving
                                          if (isSaving) {
                                            return const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                              ),
                                            );
                                          }
                                          
                                          return Image.asset(
                                            isLiked ? Assets.images.saved.path : Assets.images.save.path,
                                            width: AppSize.appSize24,
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.artist,
                                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                                  ).paddingOnly(top: AppSize.appSize6),
                                ],
                              ).paddingOnly(top: AppSize.appSize8),
                              Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatPrice(item.price),
                                  style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                                ),
                                Obx(() {
                                  final rating = index < artsAntiquesController.trendingItemRatings.length 
                                      ? artsAntiquesController.trendingItemRatings[index] 
                                      : 0.0;
                                  return Row(
                                    children: [
                                      Text(
                                        rating > 0 ? rating.toStringAsFixed(1) : 'No Rating',
                                        style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                                      ).paddingOnly(right: AppSize.appSize6),
                                      Image.asset(
                                        Assets.images.star.path,
                                        width: AppSize.appSize18,
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ).paddingOnly(top: AppSize.appSize6),
                            Divider(
                              color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint3),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSize.appSize6, 
                                    horizontal: AppSize.appSize16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                                    border: Border.all(
                                      color: AppColor.primaryColor,
                                      width: AppSize.appSizePoint50,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.category,
                                        size: 18,
                                        color: AppColor.primaryColor,
                                      ).paddingOnly(right: AppSize.appSize6),
                                      Text(
                                        item.category,
                                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSize.appSize6, 
                                    horizontal: AppSize.appSize16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                                    border: Border.all(
                                      color: AppColor.primaryColor,
                                      width: AppSize.appSizePoint50,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: AppColor.primaryColor,
                                      ).paddingOnly(right: AppSize.appSize6),
                                      Text(
                                        item.createdAt != null 
                                            ? _getRelativeTime(item.createdAt!)
                                            : 'New',
                                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ),
                    );
                  },
                ),
              ).paddingOnly(top: AppSize.appSize16);
            }),
            RepaintBoundary(
              child: Text(
                "Artists & Dealers",
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
            ),
            // Artists & Dealers - Dynamic from Firebase
            Obx(() {
              final artists = artsAntiquesController.artists;
              if (artists.isEmpty) {
                return Container(
                  height: AppSize.appSize95,
                  child: Center(
                    child: Text(
                      'No artists available',
                      style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                    ),
                  ),
                );
              }

              return RepaintBoundary(
                child: SizedBox(
                  height: AppSize.appSize95,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: AppSize.appSize16),
                    itemCount: artists.length,
                    cacheExtent: 300.0,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      return RepaintBoundary(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to artist details
                            Get.toNamed(AppRoutes.agentsListView);
                          },
                          child: Container(
                        width: AppSize.appSize160,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSize.appSize16, 
                          horizontal: AppSize.appSize10,
                        ),
                        margin: const EdgeInsets.only(right: AppSize.appSize16),
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(
                              child: Container(
                                width: AppSize.appSize30,
                                height: AppSize.appSize30,
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  borderRadius: BorderRadius.circular(AppSize.appSize15),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColor.whiteColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                artist['name'] ?? 'Artist',
                                style: AppStyle.heading5Medium(color: AppColor.textColor),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                        ),
                      );
                    },
                  ),
                ).paddingOnly(top: AppSize.appSize16),
              );
            }),
          ],
        ).paddingOnly(top: AppSize.appSize50, bottom: AppSize.appSize20),
      );
    });
  }

  /// Format price safely using PriceFormatter
  static String _formatPrice(double price) {
    return PriceFormatter.formatNumericPrice(price);
  }

  /// Build shimmer loading effect for Arts & Antiques page
  Widget _buildShimmerLoading(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section (title only)
          ShimmerLoading.textShimmer(
            width: AppSize.appSize150,
            height: AppSize.appSize18,
          ).paddingOnly(
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          // Category chips shimmer
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            child: Row(
              children: List.generate(6, (index) {
                return ShimmerLoading.simpleShimmer(
                  child: Container(
                    height: AppSize.appSize37,
                    width: AppSize.appSize100,
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.descriptionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                  ),
                );
              }),
            ).paddingOnly(top: AppSize.appSize26),
          ),
          // Search bar shimmer
          ShimmerLoading.simpleShimmer(
            child: Container(
              height: AppSize.appSize56,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
            ),
          ).paddingOnly(
            top: AppSize.appSize20,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          // Featured Items section title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading.textShimmer(
                width: AppSize.appSize150,
                height: AppSize.appSize20,
              ),
              ShimmerLoading.textShimmer(
                width: AppSize.appSize60,
                height: AppSize.appSize16,
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          // Featured Items shimmer
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: AppSize.appSize282,
              child: Row(
                children: List.generate(3, (index) {
                  return Container(
                    width: AppSize.appSize180,
                    padding: const EdgeInsets.all(AppSize.appSize10),
                    margin: EdgeInsets.only(
                      left: index == 0 ? AppSize.appSize16 : 0,
                      right: AppSize.appSize16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerLoading.imageShimmer(
                          height: AppSize.appSize130,
                          width: AppSize.appSize160,
                          borderRadius: BorderRadius.circular(AppSize.appSize8),
                        ),
                        ShimmerLoading.simpleShimmer(
                          child: Container(
                            height: AppSize.appSize35,
                            decoration: BoxDecoration(
                              color: AppColor.descriptionColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSize.appSize12),
                              border: Border.all(
                                color: AppColor.descriptionColor.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading.textShimmer(
                              width: double.infinity,
                              height: AppSize.appSize16,
                            ),
                            const SizedBox(height: AppSize.appSize6),
                            ShimmerLoading.textShimmer(
                              width: AppSize.appSize100,
                              height: AppSize.appSize14,
                            ),
                          ],
                        ),
                        ShimmerLoading.textShimmer(
                          width: AppSize.appSize80,
                          height: AppSize.appSize12,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ).paddingOnly(top: AppSize.appSize16),
          // Trending Collections section title
          ShimmerLoading.textShimmer(
            width: AppSize.appSize200,
            height: AppSize.appSize20,
          ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          // Trending Collections shimmer
          SizedBox(
            height: AppSize.appSize372,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  width: AppSize.appSize300,
                  padding: const EdgeInsets.all(AppSize.appSize10),
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerLoading.imageShimmer(
                        height: AppSize.appSize200,
                        width: AppSize.appSize300,
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoading.textShimmer(
                            width: double.infinity,
                            height: AppSize.appSize16,
                          ),
                          const SizedBox(height: AppSize.appSize6),
                          ShimmerLoading.textShimmer(
                            width: AppSize.appSize150,
                            height: AppSize.appSize14,
                          ),
                        ],
                      ).paddingOnly(top: AppSize.appSize8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerLoading.textShimmer(
                            width: AppSize.appSize100,
                            height: AppSize.appSize16,
                          ),
                          ShimmerLoading.textShimmer(
                            width: AppSize.appSize60,
                            height: AppSize.appSize16,
                          ),
                        ],
                      ).paddingOnly(top: AppSize.appSize6),
                      Divider(
                        color: AppColor.descriptionColor.withOpacity(0.3),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerLoading.simpleShimmer(
                            child: Container(
                              height: AppSize.appSize30,
                              width: AppSize.appSize100,
                              decoration: BoxDecoration(
                                color: AppColor.descriptionColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSize.appSize12),
                                border: Border.all(
                                  color: AppColor.descriptionColor.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                          ShimmerLoading.simpleShimmer(
                            child: Container(
                              height: AppSize.appSize30,
                              width: AppSize.appSize100,
                              decoration: BoxDecoration(
                                color: AppColor.descriptionColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSize.appSize12),
                                border: Border.all(
                                  color: AppColor.descriptionColor.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
          // Artists & Dealers section title
          ShimmerLoading.textShimmer(
            width: AppSize.appSize180,
            height: AppSize.appSize20,
          ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          // Artists & Dealers shimmer
          SizedBox(
            height: AppSize.appSize95,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: AppSize.appSize160,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSize.appSize16, 
                    horizontal: AppSize.appSize10,
                  ),
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerLoading.simpleShimmer(
                        child: Container(
                          width: AppSize.appSize30,
                          height: AppSize.appSize30,
                          decoration: BoxDecoration(
                            color: AppColor.descriptionColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSize.appSize15),
                          ),
                        ),
                      ),
                      ShimmerLoading.textShimmer(
                        width: AppSize.appSize100,
                        height: AppSize.appSize14,
                      ),
                    ],
                  ),
                );
              },
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
