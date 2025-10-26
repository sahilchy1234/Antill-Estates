import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/common/common_textfield.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/feedback_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class FeedbackView extends StatelessWidget {
  FeedbackView({super.key});

  final FeedbackController feedbackController = Get.put(FeedbackController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildFeedbackFields(context),
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
        AppString.feedback,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildFeedbackFields(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        children: [
          Obx(() => TextFormField(
            controller: feedbackController.selectFeedbackController,
            cursorColor: AppColor.primaryColor,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            readOnly: true,
            onTap: () {
              feedbackController.toggleSelectFeedbackExpansion();
            },
            decoration: InputDecoration(
              hintText: AppString.selectFeedback,
              hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: const BorderSide(
                  color: AppColor.primaryColor,
                ),
              ),
              suffixIcon: Image.asset(
                feedbackController.isSelectFeedbackExpanded.value
                    ? Assets.images.dropdownExpand.path
                    : Assets.images.dropdown.path,
              ).paddingOnly(right: AppSize.appSize16),
              suffixIconConstraints: const BoxConstraints(
                maxWidth: AppSize.appSize34,
              ),
            ),
          )),
          Obx(() => AnimatedContainer(
            duration: const Duration(seconds: AppSize.size1),
            curve: Curves.fastEaseInToSlowEaseOut,
            margin: EdgeInsets.only(
              top: feedbackController.isSelectFeedbackExpanded.value
                  ? AppSize.appSize16
                  : AppSize.appSize0,
            ),
            height: feedbackController.isSelectFeedbackExpanded.value
                ? null
                : AppSize.appSize0,
            child: feedbackController.isSelectFeedbackExpanded.value
                ? GestureDetector(
              onTap: () {
                // editProfileController.toggleWhatAreYouHereExpansion();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(feedbackController.selectFeedbackList.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        feedbackController.updateSelectFeedback(index);
                        feedbackController.toggleSelectFeedbackExpansion();
                      },
                      child: Text(
                        feedbackController.selectFeedbackList[index],
                        style: AppStyle.heading5Regular(
                          color: feedbackController.isSelectFeedback.value == index
                              ? AppColor.primaryColor
                              : AppColor.textColor,
                        ),
                      ).paddingOnly(left: AppSize.appSize10).paddingOnly(bottom: AppSize.appSize16),
                    );
                  }),
                ),
              ),
            ) : const SizedBox.shrink(),
          )),
          TextFormField(
            controller: feedbackController.aboutFeedbackController,
            cursorColor: AppColor.primaryColor,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            maxLines: AppSize.size3,
            decoration: InputDecoration(
              hintText: AppString.aboutYourFeedback,
              hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint7),
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
          Obx(() => CommonTextField(
            controller: feedbackController.fullNameController,
            focusNode: feedbackController.focusNode,
            hasFocus: feedbackController.hasFullNameFocus.value,
            hasInput: feedbackController.hasFullNameInput.value,
            hintText: AppString.fullName,
            labelText: AppString.fullName,
          )).paddingOnly(top: AppSize.appSize16),
          Obx(() => CommonTextField(
            controller: feedbackController.phoneNumberController,
            focusNode: feedbackController.phoneNumberFocusNode,
            hasFocus: feedbackController.hasPhoneNumberFocus.value,
            hasInput: feedbackController.hasPhoneNumberInput.value,
            hintText: AppString.phoneNumber,
            labelText: AppString.phoneNumber,
            keyboardType: TextInputType.phone,
          )).paddingOnly(top: AppSize.appSize16),
          Obx(() => CommonTextField(
            controller: feedbackController.emailController,
            focusNode: feedbackController.emailFocusNode,
            hasFocus: feedbackController.hasEmailFocus.value,
            hasInput: feedbackController.hasEmailInput.value,
            hintText: AppString.emailAddress,
            labelText: AppString.emailAddress,
            keyboardType: TextInputType.emailAddress,
          )).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
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
          Get.back();
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          AppString.submitButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ).paddingOnly(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26, top: AppSize.appSize10,
      ),
    );
  }
}
