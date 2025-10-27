import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_rich_text.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/property_list_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/text_segment_model.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/enhanced_loading_service.dart';
import '../../utils/price_formatter.dart';

class PropertyListView extends StatelessWidget {
  const PropertyListView({super.key});

  PropertyListController get propertyListController => Get.put(PropertyListController());

  @override
  Widget build(BuildContext context) {
    // Initialize property list if not already loaded and no search results provided
    if (propertyListController.searchResults.isEmpty && !propertyListController.hasSearchResults) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🔍 PropertyListView: PostFrameCallback triggered - loading all properties');
        propertyListController.loadAllProperties();
      });
    }
    
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildPropertyList(context),
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
      actions: [
        GestureDetector(
          onTap: () {
            final shareText = '''
🏘️ Discover Amazing Properties!

Find your dream home with ${AppString.appName}

✨ Browse thousands of properties
🏡 Residential & Commercial listings  
💰 Best prices & deals
📍 Properties across all locations

Download ${AppString.appName} now!
''';

            Share.share(
              shareText,
              subject: 'Find Your Dream Property',
            );
          },
          child: Image.asset(
            Assets.images.share.path,
            width: AppSize.appSize24,
          ),
        ).paddingOnly(right: AppSize.appSize16),
      ],
    );
  }

  Widget buildPropertyList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        print('🔍 PropertyListView: RefreshIndicator triggered');
        // Only refresh if we don't have search results
        if (!propertyListController.hasSearchResults) {
          await propertyListController.loadAllProperties();
        } else {
          print('🔍 PropertyListView: Skipping refresh - search results present');
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSize.appSize10),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            print('🔍 PropertyListView: searchResults.length = ${propertyListController.searchResults.length}');
            print('🔍 PropertyListView: isLoading = ${propertyListController.isLoading.value}');
            print('🔍 PropertyListView: hasError = ${propertyListController.hasError.value}');
            
            if (propertyListController.isLoading.value) {
              return EnhancedLoadingService.buildPropertyListLoading();
            }

            if (propertyListController.hasError.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${propertyListController.errorMessage.value}',
                      style: AppStyle.heading4Regular(color: AppColor.negativeColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSize.appSize16),
                    ElevatedButton(
                      onPressed: () {
                        propertyListController.loadAllProperties();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (propertyListController.searchResults.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No properties found',
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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: propertyListController.searchResults.length,
              itemBuilder: (context, index) {
                final property = propertyListController.getPropertyAtIndex(index);
                if (property == null) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () {
                    propertyListController.navigateToPropertyDetails(property.id ?? '');
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
                            // Use property image if available, otherwise use placeholder
                            property.propertyPhotos.isNotEmpty
                                ? Image.network(
                                    property.propertyPhotos.first,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        Assets.images.searchProperty1.path,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    Assets.images.searchProperty1.path,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSize.appSize8,
                                    vertical: AppSize.appSize4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                                  ),
                                  child: Text(
                                    property.category.toUpperCase(),
                                    style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                                  ),
                                ),
                                const SizedBox(width: AppSize.appSize8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSize.appSize8,
                                    vertical: AppSize.appSize4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.secondaryColor,
                                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                                  ),
                                  child: Text(
                                    property.propertyLooking.toUpperCase(),
                                    style: AppStyle.heading6Medium(color: AppColor.textColor),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              property.propertyType,
                              style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                            ).paddingOnly(top: AppSize.appSize8),
                            Text(
                              '${property.locality}, ${property.city}',
                              style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                            ).paddingOnly(top: AppSize.appSize6),
                            Text(
                              property.subLocality.isNotEmpty ? property.subLocality : property.locality,
                              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                            ).paddingOnly(top: AppSize.appSize6),
                          ],
                        ).paddingOnly(top: AppSize.appSize16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              PriceFormatter.formatPrice(property.expectedPrice),
                              style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                            ),
                            Obx(() {
                              final rating = propertyListController.getPropertyRating(property.id);
                              final ratingText = rating > 0 ? rating.toStringAsFixed(1) : '0.0';
                              return Row(
                                children: [
                                  Text(
                                    ratingText,
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
                        ).paddingOnly(top: AppSize.appSize16),
                        Divider(
                          color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint3),
                          height: AppSize.appSize0,
                        ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize16),
                        Row(
                          children: [
                            if (property.noOfBedrooms.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSize.appSize6, horizontal: AppSize.appSize14,
                                ),
                                margin: const EdgeInsets.only(right: AppSize.appSize16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                                  border: Border.all(
                                    color: AppColor.primaryColor,
                                    width: AppSize.appSizePoint50,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      Assets.images.bed.path,
                                      width: AppSize.appSize18,
                                      height: AppSize.appSize18,
                                    ).paddingOnly(right: AppSize.appSize6),
                                    Text(
                                      property.noOfBedrooms,
                                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                                    ),
                                  ],
                                ),
                              ),
                            if (property.noOfBathrooms.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSize.appSize6, horizontal: AppSize.appSize14,
                                ),
                                margin: const EdgeInsets.only(right: AppSize.appSize16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                                  border: Border.all(
                                    color: AppColor.primaryColor,
                                    width: AppSize.appSizePoint50,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      Assets.images.bath.path,
                                      width: AppSize.appSize18,
                                      height: AppSize.appSize18,
                                    ).paddingOnly(right: AppSize.appSize6),
                                    Text(
                                      property.noOfBathrooms,
                                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (property.builtUpArea.isNotEmpty || property.superBuiltUpArea.isNotEmpty)
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                if (property.builtUpArea.isNotEmpty)
                                  CommonRichText(
                                    segments: [
                                      TextSegment(
                                        text: property.builtUpArea,
                                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                                      ),
                                      TextSegment(
                                        text: ' sq ft',
                                        style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                                      ),
                                    ],
                                  ),
                                if (property.builtUpArea.isNotEmpty && property.superBuiltUpArea.isNotEmpty)
                                  const VerticalDivider(
                                    color: AppColor.descriptionColor,
                                    width: AppSize.appSize0,
                                    indent: AppSize.appSize2,
                                    endIndent: AppSize.appSize2,
                                  ).paddingOnly(left: AppSize.appSize8, right: AppSize.appSize8),
                                if (property.superBuiltUpArea.isNotEmpty)
                                  CommonRichText(
                                    segments: [
                                      TextSegment(
                                        text: property.superBuiltUpArea,
                                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                                      ),
                                      TextSegment(
                                        text: ' sq ft',
                                        style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                                      ),
                                    ],
                                  ),
                              ],
                            ).paddingOnly(top: AppSize.appSize10),
                          ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: AppSize.appSize35,
                          child: ElevatedButton(
                            onPressed: () {
                              propertyListController.launchDialer(property.contactPhone);
                            },
                            style: ButtonStyle(
                              elevation: const WidgetStatePropertyAll(AppSize.appSize0),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                                  side: const BorderSide(
                                    color: AppColor.primaryColor,
                                    width: AppSize.appSizePoint7
                                  ),
                                ),
                              ),
                              backgroundColor: WidgetStateColor.transparent,
                            ),
                            child: Text(
                              AppString.getCallbackButton,
                              style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                            ),
                          ),
                        ).paddingOnly(top: AppSize.appSize26),
                      ],
                    ),
                  ),
                );
              },
            ).paddingOnly(top: AppSize.appSize16);
          }),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
    ),
    );
  }
}
