import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/show_property_details_controller.dart';
import 'package:antill_estates/controller/gallery_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowPropertyDetailsView extends StatelessWidget {
  ShowPropertyDetailsView({super.key});

  final ShowPropertyDetailsController showPropertyDetailsController =
  Get.put(ShowPropertyDetailsController());

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with the property ID from arguments
    final propertyId = Get.arguments;
    if (propertyId != null && propertyId is String) {
      // Only initialize if not already loading (prevents multiple initializations)
      if (!showPropertyDetailsController.isLoading.value && 
          showPropertyDetailsController.property.value == null) {
        showPropertyDetailsController.initializeWithPropertyId(propertyId);
      }
    }
    
    return Obx(() =>
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: buildAppBar(),
          body: showPropertyDetailsController.isLoading.value
              ? buildLoadingView()
              : showPropertyDetailsController.hasError.value
              ? buildErrorView()
              : buildShowPropertyDetails(context),
        ));
  }

  Widget buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
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
            'Failed to load property',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            showPropertyDetailsController.errorMessage.value,
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
        Padding(
          padding: const EdgeInsets.only(right: AppSize.appSize16),
          child: GestureDetector(
            onTap: () {
              if (showPropertyDetailsController.property.value != null) {
                Get.toNamed(AppRoutes.editPropertyView,
                    arguments: showPropertyDetailsController.property.value);
              }
            },
            child: Image.asset(
              Assets.images.edit.path,
              width: AppSize.appSize24,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildShowPropertyDetails(BuildContext context) {
    final property = showPropertyDetailsController.property.value;
    if (property == null) return buildErrorView();


    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSize.appSize30),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          buildPropertyImage(property),

          // Price
          Text(
            showPropertyDetailsController.getPropertyPrice(),
            style: AppStyle.heading4Medium(color: AppColor.primaryColor),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),

          // Status and Furnishing
          IntrinsicHeight(
            child: Row(
              children: [
                Text(
                  property.availabilityStatus,
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
                  property.category,
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

          // Property Title
          Text(
            showPropertyDetailsController.getPropertyTitle(),
            style: AppStyle.heading5SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize8,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),

          // Address
          Text(
            showPropertyDetailsController.getPropertyAddress(),
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(
            top: AppSize.appSize4,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),

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

          // Property Features
          buildPropertyFeatures(property),

          // Key Highlights
          buildKeyHighlights(property),

          // Property Details
          buildPropertyDetailsSection(property),

          // Photos Section
          buildPhotosSection(),

          // Furnishing Details
          buildFurnishingDetails(),

          // Facilities
          buildFacilities(property),

          // About Property
          buildAboutProperty(property),

          // Contact Form
          buildContactForm(context),

          // Reviews Section
          buildReviewsSection(),

          // Similar Properties Section
          buildSimilarPropertiesSection(),
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  Widget buildPropertyImage(property) {
    final images = showPropertyDetailsController.getPropertyImages();
    return Container(
      height: AppSize.appSize200,
      child: images[0].startsWith('http')
          ? CachedFirebaseImage(
              imageUrl: images[0],
              height: AppSize.appSize200,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              errorWidget: Container(
                height: AppSize.appSize200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  color: AppColor.backgroundColor,
                ),
                child: const Icon(Icons.image_not_supported),
              ),
            )
          : Container(
              height: AppSize.appSize200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                image: DecorationImage(
                  image: AssetImage(images[0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
    ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16);
  }

  Widget buildPropertyFeatures(property) {
    return Column(
      children: [
        Row(
          children: [
            buildFeatureChip(
                Assets.images.bed.path, '${property.noOfBedrooms}'),
            buildFeatureChip(
                Assets.images.bath.path, '${property.noOfBathrooms}'),
            buildFeatureChip(
                Assets.images.plot.path, '${property.builtUpArea}'),
          ],
        ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
        Row(
          children: [
            buildFeatureChip(Assets.images.plot.path,
                '${property.plotArea} ${property.plotAreaUnit}'),
            buildFeatureChip(
                Assets.images.indianRupee.path, '₹ ${property.expectedPrice}'),
          ],
        ).paddingOnly(
          top: AppSize.appSize10,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ],
    );
  }

  Widget buildFeatureChip(String iconPath, String text) {
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
            iconPath,
            width: AppSize.appSize18,
            height: AppSize.appSize18,
          ).paddingOnly(right: AppSize.appSize6),
          Text(
            text,
            style: AppStyle.heading5Medium(color: AppColor.textColor),
          ),
        ],
      ),
    );
  }

  Widget buildKeyHighlights(property) {
    List<String> highlights = [];

    // Parse string properties to int safely
    int coveredParking = int.tryParse(property.coveredParking.toString()) ?? 0;
    int openParking = int.tryParse(property.openParking.toString()) ?? 0;
    int noOfBalconies = int.tryParse(property.noOfBalconies.toString()) ?? 0;

    if (coveredParking > 0 || openParking > 0) {
      highlights.add('Parking: ${coveredParking + openParking} spaces');
    }
    if (noOfBalconies > 0) {
      highlights.add('Balconies: $noOfBalconies');
    }
    highlights.add('${property.propertyType}');
    highlights.add('${property.category}');

    return Container(
      width: Get.width,
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
            children: List.generate(highlights.length, (index) {
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
                  Expanded(
                    child: Text(
                      highlights[index],
                      style: AppStyle.heading5Regular(color: AppColor.whiteColor),
                    ).paddingOnly(left: AppSize.appSize10),
                  ),
                ],
              ).paddingOnly(top: AppSize.appSize10);
            }),
          ).paddingOnly(top: AppSize.appSize6),
        ],
      ),
    );
  }

  Widget buildPropertyDetailsSection(property) {
    final details = {
      'Property Type': property.propertyType,
      'Ownership': property.ownership,
      'Built-Up Area': property.builtUpArea,
      'Super Built-Up Area': property.superBuiltUpArea,
      'Plot Area': '${property.plotArea} ${property.plotAreaUnit}',
      'Total Floors': property.totalFloors,
      'Water Source': property.waterSource.join(', '),
      'Availability': property.availabilityStatus,
      'Category': property.category,
    };

    return Container(
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
            children: details.entries.map((entry) {
              final isLast = entry == details.entries.last;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: AppStyle.heading5Regular(
                              color: AppColor.descriptionColor),
                        ).paddingOnly(right: AppSize.appSize10),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppStyle.heading5Regular(
                              color: AppColor.textColor),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
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
            }).toList(),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(
        left: AppSize.appSize16,
        right: AppSize.appSize16,
        top: AppSize.appSize16,
        bottom: AppSize.appSize16,
      ),
    );
  }

  Widget buildPhotosSection() {
    return Obx(() {
      final propertyImages = showPropertyDetailsController.getPropertyImages();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.takeATourOfOurProperty,
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          GestureDetector(
            onTap: () {
              // Initialize gallery with property photos before navigating
              final galleryController = Get.put(GalleryController());
              galleryController.initializeGallery(propertyImages);
              Get.toNamed(AppRoutes.galleryView);
            },
            child: Container(
              height: AppSize.appSize150,
              margin: const EdgeInsets.only(top: AppSize.appSize16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                image: DecorationImage(
                  image: propertyImages.isNotEmpty
                      ? (propertyImages[0].startsWith('http')
                          ? NetworkImage(propertyImages[0]) as ImageProvider
                          : AssetImage(propertyImages[0]))
                      : AssetImage(Assets.images.hall.path),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: Get.width,
                  height: AppSize.appSize75,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppSize.appSize13),
                      bottomRight: Radius.circular(AppSize.appSize13),
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '${propertyImages.length} Photos',
                      style: AppStyle.heading3Medium(color: AppColor.whiteColor),
                    ),
                  ).paddingOnly(
                      left: AppSize.appSize16, bottom: AppSize.appSize16),
                ),
              ),
            ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          ),
        ],
      );
    });
  }

  Widget buildFurnishingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            itemCount: showPropertyDetailsController
                .furnishingDetailsImageList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: AppSize.appSize16),
                padding: const EdgeInsets.all(AppSize.appSize16),
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      showPropertyDetailsController
                          .furnishingDetailsImageList[index],
                      width: AppSize.appSize24,
                      color: AppColor.descriptionColor,
                    ),
                    Text(
                      showPropertyDetailsController
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
      ],
    );
  }

  Widget buildFacilities(property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.facilities,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        SizedBox(
          height: AppSize.appSize110,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            itemCount: property.amenities.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: AppSize.appSize16),
                padding: const EdgeInsets.all(AppSize.appSize16),
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColor.primaryColor,
                      size: AppSize.appSize40,
                    ),
                    const SizedBox(height: AppSize.appSize8),
                    Text(
                      property.amenities[index],
                      style:
                      AppStyle.heading5Regular(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            },
          ),
        ).paddingOnly(top: AppSize.appSize16),
      ],
    );
  }

  Widget buildAboutProperty(property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.aboutProperty,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        Container(
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
                showPropertyDetailsController.getPropertyTitle(),
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
                      showPropertyDetailsController.getFullAddress(),
                      style: AppStyle.heading5Regular(
                          color: AppColor.descriptionColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        Text(
          property.description.isEmpty
              ? AppString.aboutPropertyString
              : property.description,
          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ],
    );
  }

  Widget buildContactForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.contactToOwner,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        Container(
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
          child: Obx(() => Row(
            children: [
              // Owner Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSize.appSize32),
                child: showPropertyDetailsController.ownerAvatar.value.isNotEmpty
                    ? Image.network(
                        showPropertyDetailsController.ownerAvatar.value,
                        width: AppSize.appSize64,
                        height: AppSize.appSize64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            Assets.images.francisProfile.path,
                            width: AppSize.appSize64,
                            height: AppSize.appSize64,
                          );
                        },
                      )
                    : Image.asset(
                        Assets.images.francisProfile.path,
                        width: AppSize.appSize64,
                        height: AppSize.appSize64,
                      ),
              ).paddingOnly(right: AppSize.appSize12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showPropertyDetailsController.ownerName.value.isNotEmpty
                          ? showPropertyDetailsController.ownerName.value
                          : AppString.francisZieme,
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ).paddingOnly(bottom: AppSize.appSize4),
                    Text(
                      AppString.owner,
                      style: AppStyle.heading5Medium(
                          color: AppColor.descriptionColor),
                    ),
                    if (showPropertyDetailsController.ownerPhone.value.isNotEmpty) ...[
                      Text(
                        showPropertyDetailsController.ownerPhone.value,
                        style: AppStyle.heading6Regular(
                            color: AppColor.primaryColor),
                      ).paddingOnly(top: AppSize.appSize4),
                    ],
                  ],
                ),
              ),
            ],
          )),
        ),
        // Contact buttons
        Row(
          children: [
            Expanded(
              child: CommonButton(
                onPressed: () {
                  _callOwner();
                },
                backgroundColor: AppColor.primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      color: AppColor.whiteColor,
                      size: AppSize.appSize16,
                    ).paddingOnly(right: AppSize.appSize8),
                    Text(
                      'Call',
                      style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: AppSize.appSize12),
            Expanded(
              child: CommonButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.contactOwnerView);
                },
                backgroundColor: AppColor.secondaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message,
                      color: AppColor.primaryColor,
                      size: AppSize.appSize16,
                    ).paddingOnly(right: AppSize.appSize8),
                    Text(
                      'Message',
                      style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
          top: AppSize.appSize16,
        ),
      ],
    );
  }



  Widget buildReviewsSection() {
    return Obx(() {
      if (showPropertyDetailsController.isLoadingReviews.value) {
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
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Row(
                children: [
                  if (showPropertyDetailsController.reviewCount.value > 0)
                    Text(
                      '${showPropertyDetailsController.reviewCount.value} reviews',
                      style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    ),
                  SizedBox(width: AppSize.appSize8),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.addPropertyReviewView);
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
                        'Add Review',
                        style: AppStyle.heading6Medium(color: AppColor.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          
          // Average rating display
          if (showPropertyDetailsController.reviewCount.value > 0)
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
                    '${showPropertyDetailsController.averageRating.value.toStringAsFixed(1)}',
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
          if (showPropertyDetailsController.propertyReviews.isNotEmpty)
            SizedBox(
              height: AppSize.appSize200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(left: AppSize.appSize16),
                itemCount: showPropertyDetailsController.propertyReviews.length,
                itemBuilder: (context, index) {
                  final review = showPropertyDetailsController.propertyReviews[index];
                  return Container(
                    width: AppSize.appSize300,
                    padding: const EdgeInsets.all(AppSize.appSize16),
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: AppSize.appSize16,
                              backgroundImage: review.userAvatar.isNotEmpty
                                  ? NetworkImage(review.userAvatar)
                                  : null,
                              child: review.userAvatar.isEmpty
                                  ? Icon(Icons.person, size: AppSize.appSize16)
                                  : null,
                            ),
                            SizedBox(width: AppSize.appSize8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.userName,
                                    style: AppStyle.heading5Medium(color: AppColor.textColor),
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
                            ),
                          ],
                        ),
                        SizedBox(height: AppSize.appSize8),
                        Text(
                          review.comment,
                          style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ).paddingOnly(top: AppSize.appSize16)
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
    });
  }

  Widget buildSimilarPropertiesSection() {
    return Obx(() {
      if (showPropertyDetailsController.similarProperties.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Similar Homes for You',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: showPropertyDetailsController.similarProperties.length,
              itemBuilder: (context, index) {
                final property = showPropertyDetailsController.similarProperties[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to property details
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
                  child: Container(
                    width: AppSize.appSize250,
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property image
                        Container(
                          height: AppSize.appSize100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppSize.appSize12),
                              topRight: Radius.circular(AppSize.appSize12),
                            ),
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
                                    image: AssetImage(Assets.images.property3.path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        // Property details
                        Padding(
                          padding: const EdgeInsets.all(AppSize.appSize12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${property.noOfBedrooms} BHK ${property.propertyType}',
                                style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                              ),
                              SizedBox(height: AppSize.appSize4),
                              Text(
                                '${property.locality}, ${property.city}',
                                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                              ),
                              SizedBox(height: AppSize.appSize4),
                              Text(
                                property.expectedPrice,
                                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
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
          ).paddingOnly(top: AppSize.appSize16),
        ],
      );
    });
  }

  /// Call the property owner
  void _callOwner() async {
    final phoneNumber = showPropertyDetailsController.ownerPhone.value;
    if (phoneNumber.isNotEmpty) {
      // Clean the phone number (remove spaces, dashes, etc.)
      final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Show confirmation dialog
      final shouldCall = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Call Owner'),
          content: Text('Call ${showPropertyDetailsController.ownerName.value} at $phoneNumber?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Call'),
            ),
          ],
        ),
      );
      
      if (shouldCall == true) {
        try {
          // Create the phone URL
          final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhoneNumber);
          
          // Check if the device can make phone calls
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
            Get.snackbar(
              'Calling Owner',
              'Opening dialer for $phoneNumber',
              backgroundColor: AppColor.primaryColor,
              colorText: AppColor.whiteColor,
            );
          } else {
            Get.snackbar(
              'Cannot Make Call',
              'Unable to open phone dialer',
              backgroundColor: Colors.red,
              colorText: AppColor.whiteColor,
            );
          }
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to make call: $e',
            backgroundColor: Colors.red,
            colorText: AppColor.whiteColor,
          );
        }
      }
    } else {
      Get.snackbar(
        'No Phone Number',
        'Phone number not available for this owner',
        backgroundColor: Colors.red,
        colorText: AppColor.whiteColor,
      );
    }
  }
}
