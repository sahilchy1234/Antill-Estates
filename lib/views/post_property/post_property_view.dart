import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/post_property_controller.dart';
import 'package:antill_estates/controller/post_property_country_picker_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/views/post_property/widgets/change_account_bottom_sheet.dart';
import 'package:antill_estates/views/post_property/widgets/post_property_country_picker_bottom_sheet.dart';
import '../../services/enhanced_loading_service.dart';

class PostPropertyView extends StatelessWidget {
  PostPropertyView({super.key});

  final PostPropertyController postPropertyController = Get.put(PostPropertyController());
  final PostPropertyCountryPickerController postPropertyCountryPickerController = Get.put(PostPropertyCountryPickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildPostProperty(context),
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
        AppString.postProperty,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildPostProperty(BuildContext context) {
    return Obx(() {
      if (postPropertyController.isLoading.value) {
        return EnhancedLoadingService.buildPostPropertyLoading();
      }
      
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSize.appSize20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            AppString.yourContactsDetails,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          Obx(() => Container(
            padding:  EdgeInsets.only(
              top: postPropertyController.hasFocus.value || postPropertyController.hasInput.value
                  ? AppSize.appSize6 : AppSize.appSize14,
              bottom: postPropertyController.hasFocus.value || postPropertyController.hasInput.value
                  ? AppSize.appSize8 : AppSize.appSize14,
              left: postPropertyController.hasFocus.value
                  ? AppSize.appSize0 : AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: postPropertyController.hasFocus.value || postPropertyController.hasInput.value
                    ? AppColor.primaryColor
                    : AppColor.descriptionColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                postPropertyController.hasFocus.value || postPropertyController.hasInput.value
                    ? Text(
                  AppString.phoneNumber,
                  style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                ).paddingOnly(
                  left: postPropertyController.hasInput.value
                      ? (postPropertyController.hasFocus.value
                      ? AppSize.appSize16 : AppSize.appSize0)
                      : AppSize.appSize16,
                  bottom: postPropertyController.hasInput.value
                      ? AppSize.appSize2 : AppSize.appSize2,
                ) : const SizedBox.shrink(),
                Row(
                  children: [
                    postPropertyController.hasFocus.value || postPropertyController.hasInput.value ? SizedBox(
                      // width: AppSize.appSize78,
                      child: IntrinsicHeight(
                        child: GestureDetector(
                          onTap: () {
                            postPropertyCountryPickerBottomSheet(context);
                          },
                          child: Row(
                            children: [
                              Obx(() {
                                final selectedCountryIndex =
                                    postPropertyCountryPickerController.selectedIndex.value;
                                return Text(
                                  postPropertyCountryPickerController.countries[selectedCountryIndex]
                                  [AppString.codeText] ?? '',
                                  style: AppStyle.heading4Regular(color: AppColor.primaryColor),
                                );
                              }),
                              Image.asset(
                                Assets.images.dropdown.path,
                                width: AppSize.appSize16,
                              ).paddingOnly(left: AppSize.appSize8, right: AppSize.appSize3),
                              const VerticalDivider(
                                color: AppColor.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).paddingOnly(
                      left: postPropertyController.hasInput.value
                          ? (postPropertyController.hasFocus.value
                          ? AppSize.appSize16 : AppSize.appSize0)
                          : AppSize.appSize16,
                    ) : const SizedBox.shrink(),
                    Expanded(
                      child: SizedBox(
                        height: AppSize.appSize27,
                        width: double.infinity,
                        child: TextFormField(
                          focusNode: postPropertyController.focusNode,
                          controller: postPropertyController.mobileController,
                          cursorColor: AppColor.primaryColor,
                          keyboardType: TextInputType.phone,
                          style: AppStyle.heading4Regular(color: AppColor.textColor),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(AppSize.size10),
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize0, vertical: AppSize.appSize0,
                            ),
                            isDense: true,
                            hintText: postPropertyController.hasFocus.value ? '' : AppString.phoneNumber,
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )).paddingOnly(top: AppSize.appSize16),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                changeAccountBottomSheet(context);
              },
              child: Text(
                AppString.changeAccount,
                style: AppStyle.heading5Regular(color: AppColor.primaryColor),
              ).paddingOnly(top: AppSize.appSize6),
            ),
          ),
          Text(
            AppString.lookingToText,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize36),
          Row(
            children: List.generate(postPropertyController.propertyLookingList.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    postPropertyController.updatePropertyLooking(index);
                  },
                  child: Obx(() => Container(
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: postPropertyController.selectPropertyLooking.value == index
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        postPropertyController.propertyLookingList[index],
                        style: AppStyle.heading5Medium(
                          color: postPropertyController.selectPropertyLooking.value == index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ),
                  )),
                ),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.whatKindOfProperty,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize36),
          Row(
            children: List.generate(postPropertyController.categoriesList.length, (index) {
              return GestureDetector(
                onTap: () {
                  postPropertyController.updateCategories(index);
                },
                child: Obx(() => Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    border: Border.all(
                      color: postPropertyController.selectCategories.value == index
                          ? AppColor.primaryColor
                          : AppColor.borderColor,
                      width: AppSize.appSize1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      postPropertyController.categoriesList[index],
                      style: AppStyle.heading5Medium(
                        color: postPropertyController.selectCategories.value == index
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
            AppString.selectPropertyType,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize36),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppSize.size2,
              crossAxisSpacing: AppSize.appSize16,
              mainAxisSpacing: AppSize.appSize16,
              mainAxisExtent: AppSize.appSize72,
            ),
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: AppSize.appSize16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: postPropertyController.propertyTypeImageList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  postPropertyController.updateSelectProperty(index);
                },
                child: Obx(() => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    border: Border.all(
                      color: postPropertyController.selectPropertyType.value == index
                          ? AppColor.primaryColor
                          : AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                      width: AppSize.appSizePoint7,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        postPropertyController.propertyTypeImageList[index],
                        width: AppSize.appSize24,
                        color: postPropertyController.selectPropertyType.value == index
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                      Text(
                        postPropertyController.propertyTypeList[index],
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.heading5Regular(
                          color: postPropertyController.selectPropertyType.value == index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ],
                  ),
                )),
              );
            },
          ),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
    );
    });
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CommonButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addPropertyDetailsView);
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          AppString.nextButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ).paddingOnly(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26, top: AppSize.appSize10,
      ),
    );
  }
}
