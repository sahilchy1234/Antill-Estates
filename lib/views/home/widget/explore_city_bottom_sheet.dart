import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/explore_city_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

exploreCityBottomSheet(BuildContext context) {
  ExploreCityController exploreCityController = Get.put(ExploreCityController());
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSize.appSize12),
        topRight: Radius.circular(AppSize.appSize12),
      ),
      borderSide: BorderSide.none,
    ),
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: AppSize.appSize630,
        padding: const EdgeInsets.only(top: AppSize.appSize26),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: AppSize.appSize36,
                  left: AppSize.appSize16, right: AppSize.appSize16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppString.lookingTo,
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                    Row(
                      children: List.generate(exploreCityController.propertyLookingList.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            exploreCityController.updatePropertyLooking(index);
                          },
                          child: Obx(() => Container(
                            margin: const EdgeInsets.only(right: AppSize.appSize16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSize.appSize12),
                              border: Border.all(
                                color: exploreCityController.selectPropertyLooking.value == index
                                    ? AppColor.primaryColor
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                exploreCityController.propertyLookingList[index],
                                style: AppStyle.heading5Medium(
                                  color: exploreCityController.selectPropertyLooking.value == index
                                      ? AppColor.primaryColor
                                      : AppColor.descriptionColor,
                                ),
                              ),
                            ),
                          )),
                        );
                      }),
                    ).paddingOnly(top: AppSize.appSize16),
                    Text(
                      AppString.categories,
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ).paddingOnly(top: AppSize.appSize26),
                    Row(
                      children: List.generate(exploreCityController.categoriesList.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            exploreCityController.updateCategories(index);
                          },
                          child: Obx(() => Container(
                            margin: const EdgeInsets.only(right: AppSize.appSize16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSize.appSize12),
                              border: Border.all(
                                color: exploreCityController.selectCategories.value == index
                                    ? AppColor.primaryColor
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                exploreCityController.categoriesList[index],
                                style: AppStyle.heading5Medium(
                                  color: exploreCityController.selectCategories.value == index
                                      ? AppColor.primaryColor
                                      : AppColor.descriptionColor,
                                ),
                              ),
                            ),
                          )),
                        );
                      }),
                    ).paddingOnly(top: AppSize.appSize16),
                    Text(
                      AppString.typesOfProperty,
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ).paddingOnly(top: AppSize.appSize26),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(exploreCityController.propertyTypeList.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            exploreCityController.updateProperties(index);
                          },
                          child: Obx(() => Container(
                            margin: const EdgeInsets.only(bottom: AppSize.appSize6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSize.appSize12),
                              border: Border.all(
                                color: exploreCityController.selectProperties.value == index
                                    ? AppColor.primaryColor
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                            ),
                            child: Text(
                              exploreCityController.propertyTypeList[index],
                              style: AppStyle.heading5Medium(
                                color: exploreCityController.selectProperties.value == index
                                    ? AppColor.primaryColor
                                    : AppColor.descriptionColor,
                              ),
                            ),
                          )),
                        );
                      }),
                    ).paddingOnly(top: AppSize.appSize16),
                    Text(
                      AppString.viewAllAdd,
                      style: AppStyle.heading6Medium(
                        color: AppColor.primaryColor,
                      ),
                    ),
                    Text(
                      AppString.propertyLocated,
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ).paddingOnly(top: AppSize.appSize26),
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
                        controller: exploreCityController.searchController,
                        cursorColor: AppColor.primaryColor,
                        style: AppStyle.heading4Regular(color: AppColor.textColor),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            top: AppSize.appSize16, bottom: AppSize.appSize16,
                          ),
                          hintText: AppString.searchLocation,
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
                              Assets.images.locationPin.path,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            maxWidth: AppSize.appSize51,
                          ),
                        ),
                      ),
                    ).paddingOnly(top: AppSize.appSize16),
                  ],
                ),
              ),
            ),
            CommonButton(
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.propertyListView);
              },
              backgroundColor: AppColor.primaryColor,
              child: Text(
                AppString.exploreButton,
                style: AppStyle.heading5Medium(color: AppColor.whiteColor),
              ),
            ).paddingOnly(
              bottom: AppSize.appSize26,
              left: AppSize.appSize16, right: AppSize.appSize16,
            ),
          ],
        ),
      ).paddingOnly(bottom: MediaQuery.of(context).viewInsets.bottom);
    },
  );
}
