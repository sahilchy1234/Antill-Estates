import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/arts_antiques_search_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';
import '../../services/enhanced_loading_service.dart';
import 'package:antill_estates/utils/price_formatter.dart';

class ArtsAntiquesSearchListView extends StatelessWidget {
  const ArtsAntiquesSearchListView({super.key});

  ArtsAntiquesSearchController get searchController => Get.put(ArtsAntiquesSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildSearchResults(context),
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
        'Search Arts & Antiques',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildSearchResults(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await searchController.performSearch();
      },
      child: Obx(() {
        if (searchController.isLoading.value && searchController.searchResults.isEmpty) {
          return EnhancedLoadingService.buildPropertyListLoading();
        }

        if (searchController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${searchController.errorMessage.value}',
                  style: AppStyle.heading4Regular(color: AppColor.negativeColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSize.appSize16),
                ElevatedButton(
                  onPressed: () {
                    searchController.performSearch();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (searchController.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No items found',
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Try adjusting your search criteria',
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSize.appSize16),
          itemCount: searchController.searchResults.length,
          itemBuilder: (context, index) {
            final item = searchController.searchResults[index];
            if (item.id == null) return const SizedBox.shrink();

            return GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.artsAntiquesDetailsView, arguments: item.id);
              },
              child: Container(
                padding: const EdgeInsets.all(AppSize.appSize10),
                margin: const EdgeInsets.only(bottom: AppSize.appSize16),
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Image
                    Container(
                      width: AppSize.appSize100,
                      height: AppSize.appSize100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                        color: AppColor.backgroundColor,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                        child: item.images.isNotEmpty
                            ? CachedFirebaseImage(
                                imageUrl: item.images.first,
                                width: AppSize.appSize100,
                                height: AppSize.appSize100,
                                fit: BoxFit.cover,
                                cacheWidth: 200, // 2x for better quality on retina displays
                                cacheHeight: 200,
                                showLoadingIndicator: true,
                                errorWidget: Container(
                                  color: AppColor.backgroundColor,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              )
                            : Container(
                                color: AppColor.backgroundColor,
                                child: const Icon(Icons.palette),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSize.appSize12),
                    // Item Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.artist,
                            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).paddingOnly(top: AppSize.appSize4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize8,
                              vertical: AppSize.appSize4,
                            ),
                            margin: EdgeInsets.only(top: AppSize.appSize8),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSize.appSize4),
                            ),
                            child: Text(
                              item.category,
                              style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                            ),
                          ),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatPrice(item.price),
                                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                              ),
                              Obx(() {
                                final rating = searchController.getItemRating(item.id);
                                final ratingText = rating > 0 ? rating.toStringAsFixed(1) : 'No Rating';
                                return Row(
                                  children: [
                                    Text(
                                      ratingText,
                                      style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                                    ).paddingOnly(right: AppSize.appSize6),
                                    Image.asset(
                                      Assets.images.star.path,
                                      width: AppSize.appSize16,
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ).paddingOnly(top: AppSize.appSize8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// Format price safely using PriceFormatter
  String _formatPrice(double price) {
    return PriceFormatter.formatNumericPrice(price);
  }
}

