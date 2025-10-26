import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/common/common_rich_text.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/registration_otp_controller.dart';
import 'package:antill_estates/model/text_segment_model.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:pinput/pinput.dart';

otpVerificationBottomSheet(BuildContext context) {
  RegistrationOtpController registrationOtpController = Get.put(RegistrationOtpController());
  return showModalBottomSheet(
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
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: AppSize.appSize375,
          padding: const EdgeInsets.only(
            top: AppSize.appSize26,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          decoration: const BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSize.appSize12),
              topRight: Radius.circular(AppSize.appSize12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonRichText(
                    segments: [
                      TextSegment(
                        text: AppString.verifyYourMobileNumber,
                        style: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                      ),
                      TextSegment(
                        text: AppString.contactNumber,
                        style: AppStyle.heading4Medium(color: AppColor.primaryColor),
                      ),
                    ],
                  ).paddingOnly(top: AppSize.appSize12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize24),
                    child: Pinput(
                      keyboardType: TextInputType.number,
                      length: AppSize.size4,
                      controller: registrationOtpController.pinController,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      defaultPinTheme: PinTheme(
                        height: AppSize.appSize51,
                        width: AppSize.appSize51,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.descriptionColor,
                          ),
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                        ),
                        textStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                      ),
                      focusedPinTheme: PinTheme(
                        height: AppSize.appSize51,
                        width: AppSize.appSize51,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                        ),
                        textStyle: AppStyle.heading4Regular(color: AppColor.primaryColor),
                      ),
                      followingPinTheme: PinTheme(
                        height: AppSize.appSize51,
                        width: AppSize.appSize51,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                        ),
                        textStyle: AppStyle.heading4Regular(color: AppColor.primaryColor),
                      ),
                    ).paddingOnly(top: AppSize.appSize36),
                  ),
                  Center(
                    child: Obx(() => CommonRichText(
                      segments: [
                        TextSegment(
                          text: AppString.didNotReceiveTheCode,
                          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                        ),
                        TextSegment(
                          text: registrationOtpController.countdown.value == AppSize.size0
                              ? AppString.resendCodeButton
                              : registrationOtpController.formattedCountdown,
                          style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                          onTap: registrationOtpController.countdown.value == AppSize.size0 ? () {
                            registrationOtpController.startCountdown();
                          } : null,
                        ),
                      ],
                    )).paddingOnly(top: AppSize.appSize12),
                  ),
                  CommonButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.bottomBarView);
                    },
                    child: Text(
                      AppString.verifyButton,
                      style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                    ),
                  ).paddingOnly(top: AppSize.appSize36),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppString.orText,
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Text(
                      AppString.verifyViaMissedCallButton,
                      style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ),
                  ),
                ],
              ).paddingOnly(bottom: AppSize.appSize26)
            ],
          ),
        ),
      );
    },
  );
}
