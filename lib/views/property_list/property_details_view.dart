import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/gallery_controller.dart';
import 'package:antill_estates/controller/owner_country_picker_controller.dart';
import 'package:antill_estates/controller/property_details_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:antill_estates/utils/price_formatter.dart';
import '../../services/enhanced_loading_service.dart';
import '../../common/shimmer_loading.dart';

class PropertyDetailsView extends StatelessWidget {
  PropertyDetailsView({super.key});

  final PropertyDetailsController propertyDetailsController =
      Get.put(PropertyDetailsController());
  final OwnerCountryPickerController ownerCountryPickerController =
      Get.put(OwnerCountryPickerController());

  @override
  Widget build(BuildContext context) {
    // Initialize similar property liked list when similar properties are loaded
    if (propertyDetailsController.similarProperties.isNotEmpty) {
      propertyDetailsController.isSimilarPropertyLiked.value =
          List<bool>.generate(
              propertyDetailsController.similarProperties.length, (index) => false);
    }
    return Obx(() {
      if (propertyDetailsController.isLoading.value) {
        return Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: buildAppBar(),
          body: EnhancedLoadingService.buildPropertyDetailsLoading(),
        );
      }
      
      if (propertyDetailsController.propertyId == null || propertyDetailsController.propertyId!.isEmpty) {
        return Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: buildAppBar(),
          body: Center(
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
                  'Property not found',
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'No property ID provided',
                  textAlign: TextAlign.center,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ).paddingSymmetric(horizontal: 32),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
      }
      
      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: buildAppBar(),
        body: buildPropertyDetails(context),
        bottomNavigationBar: buildButton(),
      );
    });
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
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.searchView);
              },
              child: Image.asset(
                Assets.images.search.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            Obx(() => GestureDetector(
              onTap: () {
                if (!propertyDetailsController.isSaving.value) {
                  propertyDetailsController.toggleSaveProperty();
                }
              },
              child: propertyDetailsController.isSaving.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ).paddingOnly(right: AppSize.appSize26)
                  : Icon(
                      propertyDetailsController.isPropertySaved.value
                          ? Icons.bookmark
                          : Icons.bookmark_add_outlined,
                      size: AppSize.appSize24,
                      color: propertyDetailsController.isPropertySaved.value
                          ? AppColor.primaryColor
                          : AppColor.descriptionColor,
                    ).paddingOnly(right: AppSize.appSize26),
            )),
            GestureDetector(
              onTap: () {
                final property = propertyDetailsController.currentProperty.value;
                if (property != null) {
                  final propertyType = property.propertyType;
                  final price = property.expectedPrice;
                  final location = '${property.city}, ${property.locality}';
                  final bedrooms = property.noOfBedrooms;
                  final bathrooms = property.noOfBathrooms;
                  final area = property.builtUpArea;
                  final lookingFor = property.propertyLooking;
                  
                  final shareText = '''
🏡 $propertyType for $lookingFor

💰 Price: ₹$price
📍 Location: $location
🛏️ Bedrooms: $bedrooms | 🚿 Bathrooms: $bathrooms
📐 Area: $area sq ft

Explore this amazing property on ${AppString.appName}!

Download ${AppString.appName} to discover more properties.
''';

                  Share.share(
                    shareText,
                    subject: '$propertyType for $lookingFor in $location',
                  );
                } else {
                  Share.share(
                    'Check out amazing properties on ${AppString.appName}!',
                  );
                }
              },
              child: Image.asset(
                Assets.images.share.path,
                width: AppSize.appSize24,
              ),
            ),
          ],
        ).paddingOnly(right: AppSize.appSize16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.appSize40),
        child: SizedBox(
          height: AppSize.appSize40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Row(
                children: List.generate(
                    propertyDetailsController.propertyList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      propertyDetailsController.updateProperty(index);
                    },
                    child: Obx(() => Container(
                          height: AppSize.appSize25,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: propertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                              right: BorderSide(
                                color: index == AppSize.size6
                                    ? Colors.transparent
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              propertyDetailsController.propertyList[index],
                              style: AppStyle.heading5Medium(
                                color: propertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.textColor,
                              ),
                            ),
                          ),
                        )),
                  );
                }),
              ).paddingOnly(
                top: AppSize.appSize10,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPropertyDetails(BuildContext context) {
    return Obx(() => SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSize.appSize30),
      physics: const ClampingScrollPhysics(),
      child: _buildTabContent(context, propertyDetailsController.selectProperty.value),
    ));
  }

  Widget _buildTabContent(BuildContext context, int selectedIndex) {
    switch (selectedIndex) {
      case 0: // Overview
        return _buildOverviewTab();
      case 1: // Highlights
        return _buildHighlightsTab();
      case 2: // Property Details
        return _buildPropertyDetailsTab();
      case 3: // Photos
        return _buildPhotosTab();
      case 4: // About
        return _buildAboutTab();
      case 5: // Owner
        return _buildOwnerTab();
      case 6: // Articles
        return _buildArticlesTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
            final property = propertyDetailsController.currentProperty.value;
            if (property == null) {
              return Container(
                height: AppSize.appSize200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  color: AppColor.backgroundColor,
                ),
                child: const Center(
                  child: Text('No property data available'),
                ),
              ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16);
            }
            
            return Column(
              children: [
                Hero(
                  tag: propertyDetailsController.heroTag ?? 'property-${property.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      child: property.propertyPhotos.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: property.propertyPhotos.first,
                              height: AppSize.appSize200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => ShimmerLoading.imageShimmer(
                                height: AppSize.appSize200,
                                width: double.infinity,
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: AppSize.appSize200,
                                color: AppColor.backgroundColor,
                                child: Icon(Icons.image_not_supported, size: 50),
                              ),
                            )
                          : Container(
                              height: AppSize.appSize200,
                              color: AppColor.backgroundColor,
                              child: Icon(Icons.home, size: 50),
                            ),
                    ),
                  ),
                ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
                Text(
                  PriceFormatter.formatPrice(property.expectedPrice),
                  style: AppStyle.heading4Medium(color: AppColor.primaryColor),
                ).paddingOnly(
                  top: AppSize.appSize16,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                ),
              ],
            );
          }),
          Obx(() {
            final property = propertyDetailsController.currentProperty.value;
            if (property == null) return const SizedBox.shrink();
            
            return Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Text(
                        property.propertyLooking.isNotEmpty 
                            ? property.propertyLooking 
                            : AppString.readyToMove,
                        style: AppStyle.heading6Regular(
                            color: AppColor.descriptionColor),
                      ),
                      VerticalDivider(
                        color: AppColor.descriptionColor
                            .withValues(alpha: AppSize.appSizePoint4),
                        thickness: AppSize.appSizePoint7,
                        width: AppSize.appSize22,
                        indent: AppSize.appSize2,
                        endIndent: AppSize.appSize2,
                      ),
                      Text(
                        property.otherFeatures.isNotEmpty 
                            ? property.otherFeatures.first 
                            : AppString.semiFurnished,
                        style: AppStyle.heading6Regular(
                            color: AppColor.descriptionColor),
                      ),
                    ],
                  ),
                ).paddingOnly(
                  top: AppSize.appSize16,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                ),
                Text(
                  '${property.propertyType} - ${property.propertyLooking}',
                  style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                ).paddingOnly(
                  top: AppSize.appSize8,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                ),
                Text(
                  '${property.locality}, ${property.city}',
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ).paddingOnly(
                  top: AppSize.appSize4,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                ),
              ],
            );
          }),
          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingOnly(
            top: AppSize.appSize16,
            bottom: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() {
            final property = propertyDetailsController.currentProperty.value;
            if (property == null) return const SizedBox.shrink();
            
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSize.appSize6,
                    horizontal: AppSize.appSize14,
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
                        '${property.noOfBathrooms} Bath',
                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSize.appSize6,
                    horizontal: AppSize.appSize14,
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
                        '${property.noOfBedrooms} BHK',
                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSize.appSize6,
                    horizontal: AppSize.appSize14,
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
                        Assets.images.plot.path,
                        width: AppSize.appSize18,
                        height: AppSize.appSize18,
                      ).paddingOnly(right: AppSize.appSize6),
                      Text(
                        '${property.builtUpArea} sq ft',
                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                      ),
                    ],
                  ),
                ),
              ],
            ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16);
          }),
          Row(
            children: List.generate(
                propertyDetailsController.searchProperty2TitleList.length,
                (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.appSize6,
                  horizontal: AppSize.appSize14,
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
                      propertyDetailsController.searchProperty2ImageList[index],
                      width: AppSize.appSize18,
                      height: AppSize.appSize18,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      propertyDetailsController.searchProperty2TitleList[index],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            margin: const EdgeInsets.only(
              top: AppSize.appSize36,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.keyHighlights,
                  style: AppStyle.heading4SemiBold(color: AppColor.whiteColor),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                      propertyDetailsController.keyHighlightsTitleList.length,
                      (index) {
                    return Row(
                      children: [
                        Container(
                          width: AppSize.appSize5,
                          height: AppSize.appSize5,
                          margin:
                              const EdgeInsets.only(left: AppSize.appSize10),
                          decoration: const BoxDecoration(
                            color: AppColor.whiteColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          propertyDetailsController
                              .keyHighlightsTitleList[index],
                          style: AppStyle.heading5Regular(
                              color: AppColor.whiteColor),
                        ).paddingOnly(left: AppSize.appSize10),
                      ],
                    ).paddingOnly(top: AppSize.appSize10);
                  }),
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: AppSize.appSize36,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              color: AppColor.secondaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.propertyDetails,
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                Column(
                  children: List.generate(
                      propertyDetailsController.propertyDetailsTitleList.length,
                      (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                propertyDetailsController
                                    .propertyDetailsTitleList[index],
                                style: AppStyle.heading5Regular(
                                    color: AppColor.descriptionColor),
                              ).paddingOnly(right: AppSize.appSize10),
                            ),
                            Expanded(
                              child: Text(
                                propertyDetailsController
                                    .propertyDetailsSubTitleList[index],
                                style: AppStyle.heading5Regular(
                                    color: AppColor.textColor),
                              ),
                            ),
                          ],
                        ),
                        if (index <
                            propertyDetailsController
                                    .propertyDetailsTitleList.length -
                                AppSize.size1) ...[
                          Divider(
                            color: AppColor.descriptionColor
                                .withValues(alpha: AppSize.appSizePoint4),
                            thickness: AppSize.appSizePoint7,
                            height: AppSize.appSize0,
                          ).paddingOnly(
                              top: AppSize.appSize16,
                              bottom: AppSize.appSize16),
                        ],
                      ],
                    );
                  }),
                ).paddingOnly(top: AppSize.appSize16),
              ],
            ).paddingOnly(
              left: AppSize.appSize16,
              right: AppSize.appSize16,
              top: AppSize.appSize16,
              bottom: AppSize.appSize16,
            ),
          ),
          Text(
            AppString.takeATourOfOurProperty,
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() {
            final property = propertyDetailsController.currentProperty.value;
            final images = property?.propertyPhotos ?? [];
            
            return GestureDetector(
              onTap: () {
                // Initialize gallery with property photos
                final galleryController = Get.put(GalleryController());
                galleryController.initializeGallery(images);
                Get.toNamed(AppRoutes.galleryView);
              },
              child: Container(
                height: AppSize.appSize150,
                margin: const EdgeInsets.only(top: AppSize.appSize16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  image: images.isNotEmpty
                      ? (images[0].startsWith('http')
                          ? DecorationImage(
                              image: NetworkImage(images[0]),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: AssetImage(images[0]),
                              fit: BoxFit.cover,
                            ))
                      : DecorationImage(
                          image: AssetImage(Assets.images.hall.path),
                          fit: BoxFit.cover,
                        ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: AppSize.appSize75,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppSize.appSize13),
                        bottomRight: Radius.circular(AppSize.appSize13),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '${images.length} Photos',
                        style:
                            AppStyle.heading3Medium(color: AppColor.whiteColor),
                      ),
                    ).paddingOnly(
                        left: AppSize.appSize16, bottom: AppSize.appSize16),
                  ),
                ),
              ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.furnishingDetails,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.furnishingDetailsView);
                },
                child: Text(
                  AppString.viewAll,
                  style:
                      AppStyle.heading5Medium(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize85,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount:
                  propertyDetailsController.furnishingDetailsImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                    top: AppSize.appSize16,
                    bottom: AppSize.appSize16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        propertyDetailsController
                            .furnishingDetailsImageList[index],
                        width: AppSize.appSize24,
                      ),
                      Text(
                        propertyDetailsController
                            .furnishingDetailsTitleList[index],
                        style:
                            AppStyle.heading5Regular(color: AppColor.textColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            'Amenities',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() {
            final property = propertyDetailsController.currentProperty.value;
            if (property == null || property.amenities.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Wrap(
              spacing: AppSize.appSize12,
              runSpacing: AppSize.appSize12,
              children: property.amenities.map((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize16,
                    vertical: AppSize.appSize10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                    border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    amenity,
                    style: AppStyle.heading5Regular(color: AppColor.textColor),
                  ),
                );
              }).toList(),
            ).paddingOnly(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            );
          }),
          Text(
            AppString.aboutProperty,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() {
            final property = propertyDetailsController.currentProperty.value;
            if (property == null) {
              return const SizedBox.shrink();
            }
            
            return Container(
              padding: const EdgeInsets.all(AppSize.appSize10),
              margin: const EdgeInsets.only(
                top: AppSize.appSize16,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint50),
                ),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${property.propertyType} - ${property.propertyLooking}',
                    style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                  ).paddingOnly(bottom: AppSize.appSize8),
                  Row(
                    children: [
                      Image.asset(
                        Assets.images.locationPin.path,
                        width: AppSize.appSize18,
                      ).paddingOnly(right: AppSize.appSize6),
                      Expanded(
                        child: Text(
                          '${property.locality}, ${property.city}',
                          style: AppStyle.heading5Regular(
                              color: AppColor.descriptionColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
            top: AppSize.appSize16,
            bottom: AppSize.appSize16,
          ),
          Obx(() {
            final property = propertyDetailsController.currentProperty.value;
            if (property == null || property.description.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Text(
              property.description,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ).paddingOnly(
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.propertyVisitTime,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Text(
                AppString.openNow,
                style: AppStyle.heading5Medium(color: AppColor.positiveColor),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          GestureDetector(
            onTap: () {
              propertyDetailsController.toggleVisitExpansion();
            },
            child: Obx(() => Container(
                  padding: const EdgeInsets.all(AppSize.appSize16),
                  margin: const EdgeInsets.only(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.descriptionColor
                          .withValues(alpha: AppSize.appSizePoint50),
                    ),
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppString.monday,
                        style: AppStyle.heading4Regular(
                            color: AppColor.descriptionColor),
                      ),
                      Image.asset(
                        propertyDetailsController.isVisitExpanded.value
                            ? Assets.images.dropdownExpand.path
                            : Assets.images.dropdown.path,
                        width: AppSize.appSize18,
                      ),
                    ],
                  ),
                )),
          ),
          Obx(() => AnimatedContainer(
                duration: const Duration(seconds: AppSize.size1),
                curve: Curves.fastEaseInToSlowEaseOut,
                margin: EdgeInsets.only(
                  top: propertyDetailsController.isVisitExpanded.value
                      ? AppSize.appSize16
                      : AppSize.appSize0,
                ),
                height: propertyDetailsController.isVisitExpanded.value
                    ? null
                    : AppSize.appSize0,
                child: propertyDetailsController.isVisitExpanded.value
                    ? GestureDetector(
                        onTap: () {
                          propertyDetailsController.toggleVisitExpansion();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: AppSize.appSize16,
                            right: AppSize.appSize16,
                          ),
                          padding: const EdgeInsets.only(
                            left: AppSize.appSize16,
                            right: AppSize.appSize16,
                            top: AppSize.appSize16,
                            bottom: AppSize.appSize6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                            color: AppColor.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: AppSize.appSizePoint1,
                                blurRadius: AppSize.appSize2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: List.generate(
                                propertyDetailsController.dayList.length,
                                (index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    propertyDetailsController.dayList[index],
                                    style: AppStyle.heading5Regular(
                                        color: AppColor.descriptionColor),
                                  ),
                                  Text(
                                    propertyDetailsController.timingList[index],
                                    style: AppStyle.heading5Regular(
                                        color: AppColor.textColor),
                                  ),
                                ],
                              ).paddingOnly(bottom: AppSize.appSize10);
                            }),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
          Text(
            AppString.contactToOwner,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() => Container(
            padding: const EdgeInsets.all(AppSize.appSize10),
            margin: const EdgeInsets.only(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize32),
                  child: propertyDetailsController.ownerAvatar.value.isNotEmpty
                      ? Image.network(
                          propertyDetailsController.ownerAvatar.value,
                          width: AppSize.appSize64,
                          height: AppSize.appSize64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              Assets.images.response1.path,
                              width: AppSize.appSize64,
                              height: AppSize.appSize64,
                            );
                          },
                        )
                      : Image.asset(
                          Assets.images.response1.path,
                          width: AppSize.appSize64,
                          height: AppSize.appSize64,
                        ),
                ).paddingOnly(right: AppSize.appSize12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        propertyDetailsController.ownerName.value.isNotEmpty
                            ? propertyDetailsController.ownerName.value
                            : AppString.rudraProperties,
                        style:
                            AppStyle.heading4Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize4),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Text(
                              AppString.broker,
                              style: AppStyle.heading5Medium(
                                  color: AppColor.descriptionColor),
                            ),
                            VerticalDivider(
                              color: AppColor.descriptionColor
                                  .withValues(alpha: AppSize.appSizePoint4),
                              thickness: AppSize.appSizePoint7,
                              width: AppSize.appSize20,
                              indent: AppSize.appSize2,
                              endIndent: AppSize.appSize2,
                            ),
                            Text(
                              propertyDetailsController.ownerPhone.value.isNotEmpty
                                  ? propertyDetailsController.ownerPhone.value
                                  : AppString.brokerNumber,
                              style: AppStyle.heading5Medium(
                                  color: AppColor.descriptionColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          CommonButton(
            onPressed: () {
              Get.toNamed(AppRoutes.contactOwnerView, arguments: propertyDetailsController.propertyId);
            },
            backgroundColor: AppColor.primaryColor,
            child: Text(
              AppString.viewPhoneNumberButton,
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
            top: AppSize.appSize26,
          ),
          Obx(() {
            if (propertyDetailsController.isLoadingReviews.value) {
              return Container(
                height: AppSize.appSize100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ).paddingOnly(top: AppSize.appSize36);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews & Ratings',
                      style: AppStyle.heading3SemiBold(color: AppColor.textColor),
                    ),
                    Row(
                      children: [
                        if (propertyDetailsController.reviewCount.value > 0)
                          Text(
                            '${propertyDetailsController.reviewCount.value} reviews',
                            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                          ),
                        SizedBox(width: AppSize.appSize8),
                        Obx(() => GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.addReviewsForPropertyView, arguments: propertyDetailsController.propertyId);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize12,
                              vertical: AppSize.appSize6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              borderRadius: BorderRadius.circular(AppSize.appSize16),
                            ),
                            child: Text(
                              propertyDetailsController.hasUserReviewed.value 
                                ? 'Edit Review' 
                                : 'Add Review',
                              style: AppStyle.heading6Medium(color: AppColor.whiteColor),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ],
                ).paddingOnly(
                  top: AppSize.appSize36,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                ),
                
                // Average rating display
                if (propertyDetailsController.reviewCount.value > 0)
                  Container(
                    margin: const EdgeInsets.only(
                      top: AppSize.appSize16,
                      left: AppSize.appSize16,
                      right: AppSize.appSize16,
                    ),
                    padding: const EdgeInsets.all(AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${propertyDetailsController.averageRating.value.toStringAsFixed(1)}',
                          style: AppStyle.heading3SemiBold(color: AppColor.primaryColor),
                        ),
                        SizedBox(width: AppSize.appSize8),
                        Icon(
                          Icons.star,
                          color: AppColor.primaryColor,
                          size: AppSize.appSize20,
                        ),
                        SizedBox(width: AppSize.appSize8),
                        Text(
                          'Average Rating',
                          style: AppStyle.heading5Regular(color: AppColor.textColor),
                        ),
                      ],
                    ),
                  ),

                // Reviews list
                if (propertyDetailsController.propertyReviews.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: propertyDetailsController.propertyReviews.length,
                    itemBuilder: (context, index) {
                      final review = propertyDetailsController.propertyReviews[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSize.appSize16),
                        padding: const EdgeInsets.all(AppSize.appSize16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSize.appSize16),
                          border: Border.all(
                            color: AppColor.descriptionColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                  style: AppStyle.heading6Regular(
                                      color: AppColor.descriptionColor),
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppColor.primaryColor,
                                      size: AppSize.appSize14,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: AppSize.appSize18,
                                      backgroundImage: review.userAvatar.isNotEmpty
                                          ? NetworkImage(review.userAvatar)
                                          : null,
                                      child: review.userAvatar.isEmpty
                                          ? Icon(Icons.person, size: AppSize.appSize18)
                                          : null,
                                    ),
                                    Text(
                                      review.userName,
                                      style: AppStyle.heading5Medium(
                                          color: AppColor.textColor),
                                    ).paddingOnly(left: AppSize.appSize6),
                                  ],
                                ),
                                // Show delete button if this is the user's review
                                Obx(() {
                                  // Check if this review belongs to the current user
                                  final isUserReview = propertyDetailsController.hasUserReviewed.value && 
                                      propertyDetailsController.propertyReviews.any((r) => r.id == review.id);
                                  
                                  if (!isUserReview) return const SizedBox.shrink();
                                  
                                  return GestureDetector(
                                    onTap: () async {
                                      final confirmed = await Get.dialog<bool>(
                                        AlertDialog(
                                          title: const Text('Delete Review'),
                                          content: const Text('Are you sure you want to delete your review? This action cannot be undone.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(result: false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Get.back(result: true),
                                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirmed == true) {
                                        await propertyDetailsController.deleteUserReview();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(AppSize.appSize8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: AppSize.appSize16,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ).paddingOnly(top: AppSize.appSize10),
                            Text(
                              review.comment,
                              style:
                                  AppStyle.heading5Regular(color: AppColor.textColor),
                            ).paddingOnly(top: AppSize.appSize10),
                          ],
                        ),
                      );
                    },
                  ).paddingOnly(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                  )
                else
                  Container(
                    height: AppSize.appSize100,
                    child: Center(
                      child: Text(
                        'No reviews yet',
                        style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                      ),
                    ),
                  ).paddingOnly(top: AppSize.appSize16),
              ],
            );
          }),
          Obx(() {
            if (propertyDetailsController.similarProperties.isEmpty) {
              return SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Similar Homes for You',
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ).paddingOnly(
                  top: AppSize.appSize20,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                ),
                SizedBox(
                  height: AppSize.appSize372,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(left: AppSize.appSize16),
                    itemCount: propertyDetailsController.similarProperties.length,
                    itemBuilder: (context, index) {
                      final property = propertyDetailsController.similarProperties[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to property details
                          if (property.id != null) {
                            Get.toNamed(AppRoutes.propertyDetailsView, arguments: property.id);
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
                              Stack(
                                children: [
                                  Container(
                                    height: AppSize.appSize200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSize.appSize8),
                                      image: property.propertyPhotos.isNotEmpty
                                          ? (property.propertyPhotos[0].startsWith('http')
                                              ? DecorationImage(
                                                  image: NetworkImage(property.propertyPhotos[0]),
                                                  fit: BoxFit.cover,
                                                )
                                              : DecorationImage(
                                                  image: AssetImage(property.propertyPhotos[0]),
                                                  fit: BoxFit.cover,
                                                ))
                                          : DecorationImage(
                                              image: AssetImage(Assets.images.alexaneFranecki.path),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    right: AppSize.appSize6,
                                    top: AppSize.appSize6,
                                    child: GestureDetector(
                                      onTap: () {
                                        propertyDetailsController.toggleSimilarPropertySave(index);
                                      },
                                      child: Container(
                                        width: AppSize.appSize32,
                                        height: AppSize.appSize32,
                                        decoration: BoxDecoration(
                                          color: AppColor.whiteColor.withValues(
                                              alpha: AppSize.appSizePoint50),
                                          borderRadius:
                                              BorderRadius.circular(AppSize.appSize6),
                                        ),
                                        child: Center(
                                          child: Obx(() {
                                            final isLiked = propertyDetailsController.isSimilarPropertyLiked[index];
                                            final isSaving = index < propertyDetailsController.isSimilarPropertySaving.length 
                                                ? propertyDetailsController.isSimilarPropertySaving[index] 
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
                                            
                                            return Icon(
                                              isLiked ? Icons.bookmark : Icons.bookmark_add_outlined,
                                              size: AppSize.appSize24,
                                              color: isLiked ? AppColor.primaryColor : AppColor.descriptionColor,
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
                                    '${property.noOfBedrooms} BHK ${property.propertyType}',
                                    style: AppStyle.heading5SemiBold(
                                        color: AppColor.textColor),
                                  ),
                                  Text(
                                    '${property.locality}, ${property.city}',
                                    style: AppStyle.heading5Regular(
                                        color: AppColor.descriptionColor),
                                  ).paddingOnly(top: AppSize.appSize6),
                                ],
                              ).paddingOnly(top: AppSize.appSize8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    PriceFormatter.formatPrice(property.expectedPrice),
                                    style: AppStyle.heading5Medium(
                                        color: AppColor.primaryColor),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '4.5',
                                        style: AppStyle.heading5Medium(
                                            color: AppColor.primaryColor),
                                      ).paddingOnly(right: AppSize.appSize6),
                                      Image.asset(
                                        Assets.images.star.path,
                                        width: AppSize.appSize18,
                                      ),
                                    ],
                                  ),
                                ],
                              ).paddingOnly(top: AppSize.appSize6),
                              Divider(
                                color: AppColor.descriptionColor
                                    .withValues(alpha: AppSize.appSizePoint3),
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
                                      borderRadius:
                                          BorderRadius.circular(AppSize.appSize12),
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
                                          '${property.noOfBedrooms} BHK',
                                          style: AppStyle.heading5Medium(
                                              color: AppColor.textColor),
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
                                      borderRadius:
                                          BorderRadius.circular(AppSize.appSize12),
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
                                          '${property.noOfBathrooms} Bath',
                                          style: AppStyle.heading5Medium(
                                              color: AppColor.textColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ).paddingOnly(top: AppSize.appSize16),
              ],
            );
          }),
        ],
      );
    }

  Widget _buildHighlightsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Key Highlights Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSize.appSize16),
          margin: const EdgeInsets.all(AppSize.appSize16),
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppString.keyHighlights,
                style: AppStyle.heading4SemiBold(color: AppColor.whiteColor),
              ),
              Obx(() {
                final property = propertyDetailsController.currentProperty.value;
                if (property == null) return const SizedBox.shrink();
                
                final highlights = <String>[];
                if (property.amenities.isNotEmpty) highlights.addAll(property.amenities.take(3));
                if (property.otherFeatures.isNotEmpty) highlights.addAll(property.otherFeatures.take(2));
                if (property.locationAdvantages.isNotEmpty) highlights.add(property.locationAdvantages.first);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: highlights.take(4).map((highlight) {
                    return Row(
                      children: [
                        Container(
                          width: AppSize.appSize5,
                          height: AppSize.appSize5,
                          margin: const EdgeInsets.only(left: AppSize.appSize10),
                          decoration: const BoxDecoration(
                            color: AppColor.whiteColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          highlight,
                          style: AppStyle.heading5Regular(color: AppColor.whiteColor),
                        ).paddingOnly(left: AppSize.appSize10),
                      ],
                    ).paddingOnly(top: AppSize.appSize10);
                  }).toList(),
                ).paddingOnly(top: AppSize.appSize6);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetailsTab() {
    return Obx(() {
      final property = propertyDetailsController.currentProperty.value;
      if (property == null) {
        return Center(child: Text('No property data available'));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              color: AppColor.secondaryColor,
            ),
            child: Column(
              children: [
                _buildDetailRow('Property Type', property.propertyType),
                _buildDetailRow('Category', property.category),
                _buildDetailRow('Floor', 'Floor ${property.totalFloors}'),
                _buildDetailRow('Bedrooms', '${property.noOfBedrooms} BHK'),
                _buildDetailRow('Bathrooms', property.noOfBathrooms),
                _buildDetailRow('Balconies', property.noOfBalconies),
                _buildDetailRow('Built-up Area', '${property.builtUpArea} sq ft'),
                _buildDetailRow('Super Built-up', '${property.superBuiltUpArea} sq ft'),
                _buildDetailRow('Plot Area', '${property.plotArea} ${property.plotAreaUnit}'),
                _buildDetailRow('Covered Parking', '${property.coveredParking}'),
                _buildDetailRow('Open Parking', '${property.openParking}'),
                _buildDetailRow('Availability', property.availabilityStatus),
                _buildDetailRow('Ownership', property.ownership),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSize.appSize16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppStyle.heading5Regular(color: AppColor.textColor),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint4),
          thickness: AppSize.appSizePoint7,
          height: AppSize.appSize0,
          indent: AppSize.appSize16,
          endIndent: AppSize.appSize16,
        ),
      ],
    );
  }

  Widget _buildPhotosTab() {
    return Obx(() {
      final property = propertyDetailsController.currentProperty.value;
      if (property == null || property.propertyPhotos.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSize.appSize32),
            child: Text(
              'No photos available',
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSize.appSize16,
          mainAxisSpacing: AppSize.appSize16,
        ),
        padding: const EdgeInsets.all(AppSize.appSize16),
        itemCount: property.propertyPhotos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              final galleryController = Get.put(GalleryController());
              galleryController.initializeGallery(property.propertyPhotos);
              Get.toNamed(AppRoutes.galleryView);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              child: CachedNetworkImage(
                imageUrl: property.propertyPhotos[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => ShimmerLoading.imageShimmer(
                  height: double.infinity,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColor.backgroundColor,
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildAboutTab() {
    return Obx(() {
      final property = propertyDetailsController.currentProperty.value;
      if (property == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (property.description.isNotEmpty) ...[
            Text(
              'Description',
              style: AppStyle.heading4Medium(color: AppColor.textColor),
            ).paddingOnly(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            Text(
              property.description,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ).paddingOnly(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
          ],
          if (property.amenities.isNotEmpty) ...[
            Text(
              'Amenities',
              style: AppStyle.heading4Medium(color: AppColor.textColor),
            ).paddingOnly(
              top: AppSize.appSize36,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            Wrap(
              spacing: AppSize.appSize12,
              runSpacing: AppSize.appSize12,
              children: property.amenities.map((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize16,
                    vertical: AppSize.appSize10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                    border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    amenity,
                    style: AppStyle.heading5Regular(color: AppColor.textColor),
                  ),
                );
              }).toList(),
            ).paddingOnly(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
          ],
        ],
      );
    });
  }

  Widget _buildOwnerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final property = propertyDetailsController.currentProperty.value;
          return Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            margin: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize32),
                  child: propertyDetailsController.ownerAvatar.value.isNotEmpty
                      ? Image.network(
                          propertyDetailsController.ownerAvatar.value,
                          width: AppSize.appSize64,
                          height: AppSize.appSize64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              Assets.images.response1.path,
                              width: AppSize.appSize64,
                              height: AppSize.appSize64,
                            );
                          },
                        )
                      : Image.asset(
                          Assets.images.response1.path,
                          width: AppSize.appSize64,
                          height: AppSize.appSize64,
                        ),
                ).paddingOnly(right: AppSize.appSize12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        propertyDetailsController.ownerName.value.isNotEmpty
                            ? propertyDetailsController.ownerName.value
                            : (property?.contactName ?? 'Property Owner'),
                        style: AppStyle.heading4Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize4),
                      Text(
                        AppString.broker,
                        style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                      ),
                      if (propertyDetailsController.ownerPhone.value.isNotEmpty)
                        Text(
                          propertyDetailsController.ownerPhone.value,
                          style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                        ).paddingOnly(top: AppSize.appSize4),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildArticlesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSize.appSize32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColor.descriptionColor,
            ),
            const SizedBox(height: AppSize.appSize16),
            Text(
              'No articles available',
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () {
        _showOwnerDetailsBottomSheet();
      },
      backgroundColor: AppColor.primaryColor,
      child: Text(
        AppString.ownerDetailsButton,
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      bottom: AppSize.appSize26,
      top: AppSize.appSize10,
    );
  }

  void _showOwnerDetailsBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSize.appSize20),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize20),
            topRight: Radius.circular(AppSize.appSize20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: AppSize.appSize40,
                height: AppSize.appSize4,
                decoration: BoxDecoration(
                  color: AppColor.descriptionColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSize.appSize2),
                ),
              ),
            ),
            const SizedBox(height: AppSize.appSize20),
            
            // Title
            Text(
              'Owner Details',
              style: AppStyle.heading3SemiBold(color: AppColor.textColor),
            ),
            const SizedBox(height: AppSize.appSize16),
            
            // Owner information
            Obx(() {
              final property = propertyDetailsController.currentProperty.value;
              return Column(
                children: [
                  // Owner Avatar and Basic Info
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSize.appSize30),
                        child: propertyDetailsController.ownerAvatar.value.isNotEmpty
                            ? Image.network(
                                propertyDetailsController.ownerAvatar.value,
                                width: AppSize.appSize60,
                                height: AppSize.appSize60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    Assets.images.response1.path,
                                    width: AppSize.appSize60,
                                    height: AppSize.appSize60,
                                  );
                                },
                              )
                            : Image.asset(
                                Assets.images.response1.path,
                                width: AppSize.appSize60,
                                height: AppSize.appSize60,
                              ),
                      ),
                      const SizedBox(width: AppSize.appSize16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              propertyDetailsController.ownerName.value.isNotEmpty
                                  ? propertyDetailsController.ownerName.value
                                  : 'Property Owner',
                              style: AppStyle.heading4SemiBold(color: AppColor.textColor),
                            ),
                            const SizedBox(height: AppSize.appSize4),
                            Text(
                              AppString.broker,
                              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.appSize20),
                  
                  // Contact Information
                  Container(
                    padding: const EdgeInsets.all(AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                        ),
                        const SizedBox(height: AppSize.appSize12),
                        
                        // Phone Number
                        if (propertyDetailsController.ownerPhone.value.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: AppColor.primaryColor,
                                size: AppSize.appSize18,
                              ),
                              const SizedBox(width: AppSize.appSize12),
                              Text(
                                propertyDetailsController.ownerPhone.value,
                                style: AppStyle.heading5Regular(color: AppColor.textColor),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Get.back(); // Close bottom sheet
                                  _launchDialer(propertyDetailsController.ownerPhone.value);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSize.appSize12,
                                    vertical: AppSize.appSize6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor,
                                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                                  ),
                                  child: Text(
                                    'Call',
                                    style: AppStyle.heading6Medium(color: AppColor.whiteColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        if (propertyDetailsController.ownerPhone.value.isNotEmpty)
                          const SizedBox(height: AppSize.appSize12),
                        
                        // Email
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: AppColor.primaryColor,
                              size: AppSize.appSize18,
                            ),
                            const SizedBox(width: AppSize.appSize12),
                            Expanded(
                              child: Text(
                                property?.contactEmail.isNotEmpty == true
                                    ? property!.contactEmail
                                    : 'contact@luxuryrealestate.com',
                                style: AppStyle.heading5Regular(color: AppColor.textColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSize.appSize20),
                  
                  // Property Information
                  Container(
                    padding: const EdgeInsets.all(AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Information',
                          style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                        ),
                        const SizedBox(height: AppSize.appSize12),
                        
                        if (property != null) ...[
                          _buildInfoRow('Property Type', property.propertyType),
                          _buildInfoRow('Location', '${property.locality}, ${property.city}'),
                          _buildInfoRow('Price', PriceFormatter.formatPrice(property.expectedPrice)),
                          _buildInfoRow('Built-up Area', '${property.builtUpArea} sq ft'),
                          _buildInfoRow('Bedrooms', '${property.noOfBedrooms} BHK'),
                          _buildInfoRow('Bathrooms', '${property.noOfBathrooms}'),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }),
            
            const SizedBox(height: AppSize.appSize20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.contactOwnerView, arguments: propertyDetailsController.propertyId);
                    },
                    backgroundColor: AppColor.secondaryColor,
                    child: Text(
                      'Contact Owner',
                      style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.appSize12),
                Expanded(
                  child: CommonButton(
                    onPressed: () {
                      Get.back();
                      if (propertyDetailsController.ownerPhone.value.isNotEmpty) {
                        _launchDialer(propertyDetailsController.ownerPhone.value);
                      }
                    },
                    backgroundColor: AppColor.primaryColor,
                    child: Text(
                      'Call Now',
                      style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.appSize8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSize.appSize100,
            child: Text(
              label,
              style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppStyle.heading6Regular(color: AppColor.textColor),
            ),
          ),
        ],
      ),
    );
  }

  void _launchDialer(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch dialer',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
