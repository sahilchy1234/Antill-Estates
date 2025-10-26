import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/edit_property_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/routes/app_routes.dart';

class EditPropertyView extends StatelessWidget {
  EditPropertyView({super.key});

  final EditPropertyController editPropertyController = Get.put(EditPropertyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildEditProperty(),
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
        AppString.editing,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildEditProperty() {
    return Obx(() {
      if (editPropertyController.property.value == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final property = editPropertyController.property.value!;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property ID and basic info
          Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(AppSize.appSize6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Property ID: ${property.id ?? 'N/A'}',
                  style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                ),
                Text(
                  '${property.propertyType} in ${property.locality}, ${property.city}',
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ).paddingOnly(top: AppSize.appSize8),
                Text(
                  '₹${property.expectedPrice}',
                  style: AppStyle.heading3Medium(color: AppColor.primaryColor),
                ).paddingOnly(top: AppSize.appSize4),
              ],
            ),
          ),
          
          // Edit sections
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: AppSize.appSize16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: editPropertyController.editPropertyTitleList.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(AppSize.appSize16),
                margin: const EdgeInsets.only(bottom: AppSize.appSize16),
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editPropertyController.editPropertyTitleList[index],
                          style: AppStyle.heading4Medium(color: AppColor.textColor),
                        ),
                        GestureDetector(
                          onTap: () {
                            _navigateToEditSection(index, property);
                          },
                          child: Image.asset(
                            Assets.images.edit.path,
                            width: AppSize.appSize20,
                            color: AppColor.descriptionColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _getSectionPreview(index, property),
                      style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    ).paddingOnly(top: AppSize.appSize6),
                  ],
                ),
              );
            },
          ),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, 
        right: AppSize.appSize16,
      );
    });
  }

  String _getSectionPreview(int index, Property property) {
    switch (index) {
      case 0: // Basic Details
        return '${property.propertyLooking} • ${property.category} • ${property.propertyType}';
      case 1: // Property Details
        return '${property.noOfBedrooms} BHK • ${property.plotArea} ${property.plotAreaUnit} • ${property.locality}';
      case 2: // Price Details
        return '₹${property.expectedPrice} • ${property.ownership}';
      case 3: // Amenities
        return '${property.amenities.length} amenities selected';
      default:
        return editPropertyController.editPropertySubtitleList[index];
    }
  }

  void _navigateToEditSection(int index, Property property) {
    switch (index) {
      case 0: // Basic Details
        Get.toNamed(AppRoutes.editPropertyDetailsView, arguments: {
          'property': property,
          'section': 'basic'
        });
        break;
      case 1: // Property Details
        Get.toNamed(AppRoutes.editPropertyDetailsView, arguments: {
          'property': property,
          'section': 'property'
        });
        break;
      case 2: // Price Details
        Get.toNamed(AppRoutes.editPropertyDetailsView, arguments: {
          'property': property,
          'section': 'pricing'
        });
        break;
      case 3: // Amenities
        Get.toNamed(AppRoutes.editPropertyDetailsView, arguments: {
          'property': property,
          'section': 'amenities'
        });
        break;
    }
  }
}
