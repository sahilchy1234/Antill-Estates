import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/bottom_bar_controller.dart';
import 'package:antill_estates/controller/saved_properties_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/utils/price_formatter.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';

class SavedPropertiesView extends StatelessWidget {
  const SavedPropertiesView({super.key});

  SavedPropertiesController get savedPropertiesController => Get.put(SavedPropertiesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildTabBar(),
          Expanded(
            child: Obx(() {
              if (savedPropertiesController.selectSavedTab.value == 0) {
                return buildSavedPropertyList();
              } else {
                return buildSavedArtsAntiquesList();
              }
            }),
          ),
        ],
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
            BottomBarController bottomBarController = Get.find<BottomBarController>();
            bottomBarController.updateIndex(0);
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        'Saved Items',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildTabBar() {
    return Container(
      height: AppSize.appSize50,
      color: AppColor.whiteColor,
      child: Row(
        children: List.generate(savedPropertiesController.savedPropertyList.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                savedPropertiesController.updateSavedTab(index);
              },
              child: Obx(() => Container(
                height: AppSize.appSize50,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: savedPropertiesController.selectSavedTab.value == index
                          ? AppColor.primaryColor
                          : AppColor.borderColor,
                      width: AppSize.appSize2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${_stripCountLabel(savedPropertiesController.savedPropertyList[index])} (${index == 0 ? savedPropertiesController.savedProperties.length : savedPropertiesController.savedArtsAntiques.length})',
                    style: AppStyle.heading5Medium(
                      color: savedPropertiesController.selectSavedTab.value == index
                          ? AppColor.primaryColor
                          : AppColor.textColor,
                    ),
                  ),
                ),
              )),
            ),
          );
        }),
      ).paddingOnly(
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
    );
  }

  Widget buildSavedPropertyList() {
    return Obx(() {
      if (savedPropertiesController.isLoadingProperties.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (savedPropertiesController.savedProperties.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            await savedPropertiesController.refreshSavedProperties();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(Get.context!).size.height - 250,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.images.searchProperty1.path,
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Saved Properties',
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Properties you save will appear here',
                      style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () async {
          await savedPropertiesController.refreshSavedProperties();
        },
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(
            bottom: AppSize.appSize20,
            top: AppSize.appSize10,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: savedPropertiesController.savedProperties.length,
          itemBuilder: (context, index) {
            final property = savedPropertiesController.savedProperties[index];
            return buildPropertyCard(property, index);
          },
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      );
    });
  }

  Widget buildPropertyCard(dynamic property, int index) {
    return GestureDetector(
      onTap: () {
        savedPropertiesController.navigateToPropertyDetails(property.id ?? '');
      },
      child: Container(
        padding: const EdgeInsets.all(AppSize.appSize10),
        margin: const EdgeInsets.only(bottom: AppSize.appSize16),
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          borderRadius: BorderRadius.circular(AppSize.appSize12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  child: property.propertyPhotos.isNotEmpty
                      ? CachedFirebaseImage(
                          imageUrl: property.propertyPhotos.first,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          cacheHeight: 400,
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                          showLoadingIndicator: true,
                          errorWidget: Image.asset(
                            Assets.images.searchProperty1.path,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          Assets.images.searchProperty1.path,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  right: AppSize.appSize6,
                  top: AppSize.appSize6,
                  child: GestureDetector(
                    onTap: () {
                      savedPropertiesController.unsaveProperty(property.id ?? '', index);
                    },
                    child: Container(
                      width: AppSize.appSize32,
                      height: AppSize.appSize32,
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor.withValues(alpha: AppSize.appSizePoint50),
                        borderRadius: BorderRadius.circular(AppSize.appSize6),
                      ),
                      child: Center(
                        child: Image.asset(
                          Assets.images.saved.path,
                          width: AppSize.appSize24,
                        ),
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
                  property.category,
                  style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                ),
                Text(
                  property.propertyType,
                  style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                ).paddingOnly(top: AppSize.appSize6),
                Text(
                  '${property.locality}, ${property.city}',
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ).paddingOnly(top: AppSize.appSize16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatPriceDynamic(property.expectedPrice),
                  style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                ),
                Row(
                  children: [
                    Text(
                      '${property.noOfBedrooms} BHK',
                      style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ).paddingOnly(right: AppSize.appSize6),
                    Image.asset(
                      Assets.images.bed.path,
                      width: AppSize.appSize18,
                    ),
                  ],
                ),
              ],
            ).paddingOnly(top: AppSize.appSize16),
            // Additional property details...
          ],
        ),
      ),
    );
  }

  Widget buildSavedArtsAntiquesList() {
    return Obx(() {
      if (savedPropertiesController.isLoadingArtsAntiques.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (savedPropertiesController.savedArtsAntiques.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            await savedPropertiesController.refreshSavedArtsAntiques();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(Get.context!).size.height - 250,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.collections_outlined,
                      size: 100,
                      color: AppColor.descriptionColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Saved Arts & Antiques',
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arts & antiques you save will appear here',
                      style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () async {
          await savedPropertiesController.refreshSavedArtsAntiques();
        },
        child: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(
            bottom: AppSize.appSize20,
            top: AppSize.appSize10,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: savedPropertiesController.savedArtsAntiques.length,
          itemBuilder: (context, index) {
            final item = savedPropertiesController.savedArtsAntiques[index];
            return buildArtsAntiquesCard(item, index);
          },
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      );
    });
  }

  Widget buildArtsAntiquesCard(Map<String, dynamic> item, int index) {
    final itemData = item;
    
    return GestureDetector(
      onTap: () {
        savedPropertiesController.navigateToArtsAntiquesDetails(itemData['id'] ?? '');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          borderRadius: BorderRadius.circular(AppSize.appSize12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSize.appSize12),
                    ),
                    child: (itemData['images'] as List?)?.isNotEmpty == true
                        ? CachedFirebaseImage(
                            imageUrl: (itemData['images'] as List).first,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 400,
                            cacheHeight: 400,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppSize.appSize12),
                            ),
                            showLoadingIndicator: true,
                            errorWidget: Container(
                              color: AppColor.borderColor,
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColor.descriptionColor,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColor.borderColor,
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColor.descriptionColor,
                            ),
                          ),
                  ),
                  Positioned(
                    right: AppSize.appSize6,
                    top: AppSize.appSize6,
                    child: GestureDetector(
                      onTap: () {
                        savedPropertiesController.unsaveArtsAntiques(
                          itemData['id'] ?? '',
                          index,
                        );
                      },
                      child: Container(
                        width: AppSize.appSize28,
                        height: AppSize.appSize28,
                        decoration: BoxDecoration(
                          color: AppColor.whiteColor.withValues(alpha: AppSize.appSizePoint50),
                          borderRadius: BorderRadius.circular(AppSize.appSize6),
                        ),
                        child: Center(
                          child: Image.asset(
                            Assets.images.saved.path,
                            width: AppSize.appSize20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSize.appSize10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemData['category'] ?? 'Art',
                    style: AppStyle.heading7Regular(color: AppColor.primaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itemData['title'] ?? 'Untitled',
                    style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                                     Text(
                     itemData['artist'] ?? '',
                     style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPriceDynamic(itemData['price']),
                        style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                      ),
                      if (itemData['rating'] != null && itemData['rating'] > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            Text(
                              '${itemData['rating']}',
                              style: AppStyle.heading6Medium(color: AppColor.textColor),
                            ),
                          ],
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
  }

  /// Format dynamic price values (num or String) using Indian Rupee formatting
  String _formatPriceDynamic(dynamic price) {
    if (price == null) return '₹0';
    if (price is num) {
      return PriceFormatter.formatNumericPrice(price.toDouble());
    }
    if (price is String) {
      return PriceFormatter.formatPrice(price);
    }
    return '₹0';
  }

  /// Remove any existing trailing count in parentheses from a label
  String _stripCountLabel(String label) {
    final regex = RegExp(r"\s*\(\d+\)\s*$");
    return label.replaceAll(regex, "").trim();
  }
}
