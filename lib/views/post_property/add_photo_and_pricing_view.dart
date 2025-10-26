import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/add_photo_and_pricing_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/views/post_property/widgets/photo_tips_bottom_sheet.dart';

class AddPhotoAndPricingView extends StatelessWidget {
  AddPhotoAndPricingView({super.key});

  final AddPhotoAndPricingController addPhotoAndPricingController =
      Get.put(AddPhotoAndPricingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAddPhotoAndPricingFields(context),
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
        AppString.addPhotosAndPricing,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAddPhotoAndPricingFields(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.addPropertyPhotos,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          SizedBox(
            height: AppSize.appSize16,
          ),
          Obx(() {
            final images = addPhotoAndPricingController.images;
            return GestureDetector(
              onTap: addPhotoAndPricingController.pickImages,
              child: DottedBorder(
                options: RectDottedBorderOptions(
                  strokeCap: StrokeCap.round,
                  dashPattern: [10, 5],
                  strokeWidth: 1,
                  padding: EdgeInsets.all(AppSize.appSize5)
                ),
                child: Container(
                  height: AppSize.appSize137,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: AppColor.backgroundColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: images.isEmpty
                      ? Center(
                    child: Text(
                      AppString.addAtleast5Photos,
                      style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                    ),
                  )
                      : GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(images[index].path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => addPhotoAndPricingController.removeImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(2),
                                child: Icon(Icons.close, size: 14, color: Colors.red),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          }),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                photoTipsBottomSheet(context);
              },
              child: Text(
                AppString.photosTips,
                style: AppStyle.heading5Regular(color: AppColor.primaryColor),
              ).paddingOnly(top: AppSize.appSize6),
            ),
          ),
          Text(
            AppString.ownerShip,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize36),
          Wrap(
            runSpacing: AppSize.appSize10,
            spacing: AppSize.appSize16,
            children: List.generate(
                addPhotoAndPricingController.ownershipList.length, (index) {
              return GestureDetector(
                onTap: () {
                  addPhotoAndPricingController.updateOwnership(index);
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
                        color: addPhotoAndPricingController
                                    .selectOwnership.value ==
                                index
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                    child: Text(
                      addPhotoAndPricingController.ownershipList[index],
                      style: AppStyle.heading5Regular(
                        color: addPhotoAndPricingController
                                    .selectOwnership.value ==
                                index
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                  );
                }),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.priceDetails,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize36),
          TextFormField(
            controller: addPhotoAndPricingController.expectedPriceController,
            cursorColor: AppColor.primaryColor,
            keyboardType: TextInputType.number,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            decoration: InputDecoration(
              hintText: AppString.expectedPrice,
              hintStyle:
                  AppStyle.heading4Regular(color: AppColor.descriptionColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: const BorderSide(
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          ).paddingOnly(top: AppSize.appSize16),
          Column(
            children: List.generate(
                addPhotoAndPricingController.priceDetailsList.length, (index) {
              return GestureDetector(
                onTap: () {
                  addPhotoAndPricingController.updatePriceDetails(index);
                },
                child: Row(
                  children: [
                    Obx(() => Image.asset(
                          addPhotoAndPricingController
                                      .selectPriceDetails.value ==
                                  index
                              ? Assets.images.checkbox.path
                              : Assets.images.emptyCheckbox.path,
                          width: AppSize.appSize20,
                        )).paddingOnly(right: AppSize.appSize6),
                    Text(
                      addPhotoAndPricingController.priceDetailsList[index],
                      style:
                          AppStyle.heading6Regular(color: AppColor.textColor),
                    ),
                  ],
                ).paddingOnly(bottom: AppSize.appSize10),
              );
            }),
          ).paddingOnly(top: AppSize.appSize10),
          Row(
            children: [
              Text(
                AppString.descriptions,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Text(
                AppString.optional,
                style:
                    AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ).paddingOnly(top: AppSize.appSize26),
          TextFormField(
            controller: addPhotoAndPricingController.descriptionController,
            cursorColor: AppColor.primaryColor,
            maxLines: AppSize.size4,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            decoration: InputDecoration(
              hintText: AppString.descriptionsString,
              hintStyle:
                  AppStyle.heading5Regular(color: AppColor.descriptionColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: const BorderSide(
                  color: AppColor.primaryColor,
                ),
              ),
            ),
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
      child: CommonButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addAmenitiesView);
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          AppString.nextButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ).paddingOnly(
        left: AppSize.appSize16,
        right: AppSize.appSize16,
        bottom: AppSize.appSize26,
        top: AppSize.appSize10,
      ),
    );
  }
}
