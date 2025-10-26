import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/add_amenities_controller.dart';
import 'package:antill_estates/controller/post_property_controller.dart';
import 'package:antill_estates/controller/add_property_details_controller.dart';
import 'package:antill_estates/controller/add_photo_and_pricing_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/views/post_property/post_property_success_view.dart';
import 'package:antill_estates/services/property_service.dart';

import '../../model/property_model.dart';

class AddAmenitiesView extends StatelessWidget {
  AddAmenitiesView({super.key});

  final AddAmenitiesController addAmenitiesController = Get.put(AddAmenitiesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAddAmenitiesFields(),
      bottomNavigationBar: buildButton(context),
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
        AppString.addAmenities,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAddAmenitiesFields() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppString.amenities,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Text(
                AppString.optional,
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ),
          Wrap(
            runSpacing: AppSize.appSize10,
            spacing: AppSize.appSize16,
            children: List.generate(addAmenitiesController.amenitiesList.length, (index) {
              return GestureDetector(
                onTap: () {
                  addAmenitiesController.updateAmenities(index);
                },
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSize.appSize10,
                      horizontal: AppSize.appSize16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: addAmenitiesController.selectAmenities[index]
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                    child: Text(
                      addAmenitiesController.amenitiesList[index],
                      style: AppStyle.heading5Regular(
                        color: addAmenitiesController.selectAmenities[index]
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                  );
                }),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),

          Row(
            children: [
              Text(
                AppString.waterSource,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Text(
                AppString.optional,
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ).paddingOnly(top: AppSize.appSize36),

          Wrap(
            runSpacing: AppSize.appSize10,
            spacing: AppSize.appSize16,
            children: List.generate(addAmenitiesController.waterSourceList.length, (index) {
              return GestureDetector(
                onTap: () {
                  addAmenitiesController.updateWaterSource(index);
                },
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSize.appSize10,
                      horizontal: AppSize.appSize16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: addAmenitiesController.selectWaterSource[index]
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                    child: Text(
                      addAmenitiesController.waterSourceList[index],
                      style: AppStyle.heading5Regular(
                        color: addAmenitiesController.selectWaterSource[index]
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                  );
                }),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),

          Row(
            children: [
              Text(
                AppString.otherFeature,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Text(
                AppString.optional,
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ).paddingOnly(top: AppSize.appSize36),

          Column(
            children: List.generate(addAmenitiesController.otherFeaturesList.length, (index) {
              return GestureDetector(
                onTap: () {
                  addAmenitiesController.updateOtherFeatures(index);
                },
                child: Row(
                  children: [
                    Obx(() => Image.asset(
                      addAmenitiesController.selectOtherFeatures[index]
                          ? Assets.images.checkbox.path
                          : Assets.images.emptyCheckbox.path,
                      width: AppSize.appSize20,
                    )).paddingOnly(right: AppSize.appSize6),
                    Text(
                      addAmenitiesController.otherFeaturesList[index],
                      style: AppStyle.heading6Regular(color: AppColor.textColor),
                    ),
                  ],
                ).paddingOnly(bottom: AppSize.appSize10),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),

          Row(
            children: [
              Text(
                AppString.locationAdvantages,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Text(
                AppString.optional,
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ).paddingOnly(top: AppSize.appSize36),

          Wrap(
            runSpacing: AppSize.appSize10,
            spacing: AppSize.appSize16,
            children: List.generate(addAmenitiesController.locationAdvantagesList.length, (index) {
              return GestureDetector(
                onTap: () {
                  addAmenitiesController.updateLocationAdvantages(index);
                },
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSize.appSize10,
                      horizontal: AppSize.appSize16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: addAmenitiesController.selectLocationAdvantages[index]
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                    child: Text(
                      addAmenitiesController.locationAdvantagesList[index],
                      style: AppStyle.heading5Regular(
                        color: addAmenitiesController.selectLocationAdvantages[index]
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                  );
                }),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Obx(() => CommonButton(
        onPressed: addAmenitiesController.isLoading.value ? null : () async {
          await postPropertyToFirebase();
        },
        backgroundColor: AppColor.primaryColor,
        child: addAmenitiesController.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          AppString.postPropertyButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      )).paddingOnly(
        left: AppSize.appSize16,
        right: AppSize.appSize16,
        bottom: AppSize.appSize26,
        top: AppSize.appSize10,
      ),
    );
  }

  Future<void> postPropertyToFirebase() async {
    try {
      addAmenitiesController.isLoading.value = true;

      // Get all controllers
      final postPropertyController = Get.find<PostPropertyController>();
      final propertyDetailsController = Get.find<AddPropertyDetailsController>();
      final photoAndPricingController = Get.find<AddPhotoAndPricingController>();

      // Validate required fields
      if (!propertyDetailsController.isFormValid) {
        throw Exception('Please fill in all required property details');
      }

      if (!photoAndPricingController.isFormValid) {
        throw Exception('Please fill in price and description');
      }

      // Upload images first if available
      List<String> imageUrls = [];
      if (photoAndPricingController.selectedImages.isNotEmpty) {
        print('Uploading ${photoAndPricingController.selectedImages.length} images...');
        imageUrls = await PropertyService.uploadPropertyImages(
            photoAndPricingController.selectedImages
        );
        print('Successfully uploaded ${imageUrls.length} images');
      }

      // Collect selected amenities
      List<String> selectedAmenities = [];
      for (int i = 0; i < addAmenitiesController.selectAmenities.length; i++) {
        if (addAmenitiesController.selectAmenities[i]) {
          selectedAmenities.add(addAmenitiesController.amenitiesList[i]);
        }
      }

      // Collect selected water sources
      List<String> selectedWaterSources = [];
      for (int i = 0; i < addAmenitiesController.selectWaterSource.length; i++) {
        if (addAmenitiesController.selectWaterSource[i]) {
          selectedWaterSources.add(addAmenitiesController.waterSourceList[i]);
        }
      }

      // Collect selected other features
      List<String> selectedOtherFeatures = [];
      for (int i = 0; i < addAmenitiesController.selectOtherFeatures.length; i++) {
        if (addAmenitiesController.selectOtherFeatures[i]) {
          selectedOtherFeatures.add(addAmenitiesController.otherFeaturesList[i]);
        }
      }

      // Collect selected location advantages
      List<String> selectedLocationAdvantages = [];
      for (int i = 0; i < addAmenitiesController.selectLocationAdvantages.length; i++) {
        if (addAmenitiesController.selectLocationAdvantages[i]) {
          selectedLocationAdvantages.add(addAmenitiesController.locationAdvantagesList[i]);
        }
      }

      // Get price details
      List<String> priceDetails = [];
      if (photoAndPricingController.selectPriceDetails.value >= 0) {
        priceDetails.add(photoAndPricingController.selectedPriceDetail);
      }

      // Create property object using the enhanced controller methods
      final property = Property(
        propertyLooking: postPropertyController.propertyLookingList[
        postPropertyController.selectPropertyLooking.value
        ],
        category: postPropertyController.categoriesList[
        postPropertyController.selectCategories.value
        ],
        propertyType: postPropertyController.propertyTypeList[
        postPropertyController.selectPropertyType.value
        ],
        city: propertyDetailsController.cityController.text.trim(),
        locality: propertyDetailsController.localityController.text.trim(),
        subLocality: propertyDetailsController.subLocalityController.text.trim(),
        plotArea: propertyDetailsController.plotAreaController.text.trim(),
        plotAreaUnit: 'sq ft',
        builtUpArea: propertyDetailsController.builtUpAreaController.text.trim(),
        superBuiltUpArea: propertyDetailsController.superBuiltUpAreaController.text.trim(),
        otherRooms: propertyDetailsController.selectedOtherRooms,
        totalFloors: propertyDetailsController.totalFloorsController.text.trim(),
        noOfBedrooms: propertyDetailsController.selectedBedrooms?.toString() ?? '1',
        noOfBathrooms: propertyDetailsController.selectedBathrooms?.toString() ?? '1',
        noOfBalconies: propertyDetailsController.selectedBalconies?.toString() ?? '0',
        coveredParking: propertyDetailsController.coveredParking,
        openParking: propertyDetailsController.openParking,
        availabilityStatus: propertyDetailsController.selectedAvailability,
        propertyPhotos: imageUrls,
        ownership: propertyDetailsController.selectedOwnership,
        expectedPrice: photoAndPricingController.expectedPriceController.text.trim(),
        priceDetails: priceDetails,
        description: photoAndPricingController.descriptionController.text.trim(),
        amenities: selectedAmenities,
        waterSource: selectedWaterSources,
        otherFeatures: selectedOtherFeatures,
        locationAdvantages: selectedLocationAdvantages,
        contactName: '', // Will be populated by PropertyService from user data
        contactPhone: postPropertyController.mobileController.text.trim(), // Use phone number from post property controller
        contactAvatar: '', // Will be populated by PropertyService from user data
      );

      print('Posting property to Firebase...');

      // Post to Firebase
      final propertyId = await PropertyService.postProperty(property);

      print('Property posted successfully with ID: $propertyId');

      // Show success dialog
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => postPropertySuccessDialogue(),
      );

      // Clear form data after successful posting
      propertyDetailsController.clearAllData();
      photoAndPricingController.clearData();
      addAmenitiesController.onInit(); // Reset amenities selections

      // Navigate after delay
      await Future.delayed(const Duration(seconds: 3));
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close dialog
      }
      Get.offAllNamed(AppRoutes.showPropertyDetailsView, arguments: propertyId);

    } catch (e) {
      print('Error posting property: $e');
      Get.snackbar(
        'Error',
        'Failed to post property: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      addAmenitiesController.isLoading.value = false;
    }
  }
}
