import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/common/common_rich_text.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/otp_controller.dart';
import 'package:antill_estates/model/text_segment_model.dart';
import 'package:pinput/pinput.dart';

class OtpView extends StatelessWidget {
  OtpView({super.key});

  final OtpController otpController = Get.put(OtpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: buildOTPField(),
      bottomNavigationBar: buildTextButton(),
    );
  }

  Widget buildOTPField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppString.otpVerification,
          style: AppStyle.heading1(color: AppColor.textColor),
        ),
        CommonRichText(
          segments: [
            TextSegment(
              text: AppString.verifyYourMobileNumber,
              style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
            ),
            TextSegment(
              text: otpController.phoneNumber,
              style: AppStyle.heading6Medium(color: AppColor.primaryColor),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize12),

        // Enhanced Pinput widget with Firebase integration
        Obx(() => Pinput(
          keyboardType: TextInputType.number,
          length: AppSize.size6,
          controller: otpController.pinController,
          autofocus: true,
          enabled: !otpController.isLoading.value, // Disable during loading
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          // Auto-verify when OTP is complete
          onCompleted: (value) {
            otpController.verifyOTP();
          },

          // Listen to changes for validation
          onChanged: (value) {
            otpController.validateOTP(value);
          },

          // Default pin theme
          defaultPinTheme: PinTheme(
            height: AppSize.appSize51,
            width: AppSize.appSize51,
            decoration: BoxDecoration(
              border: Border.all(
                color: otpController.isLoading.value
                    ? AppColor.descriptionColor.withOpacity(0.5)
                    : AppColor.descriptionColor,
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            textStyle: AppStyle.heading6Regular(
              color: otpController.isLoading.value
                  ? AppColor.descriptionColor.withOpacity(0.5)
                  : AppColor.descriptionColor,
            ),
          ),

          // Focused pin theme
          focusedPinTheme: PinTheme(
            height: AppSize.appSize51,
            width: AppSize.appSize51,
            decoration: BoxDecoration(
              border: Border.all(
                color: otpController.isLoading.value
                    ? AppColor.primaryColor.withOpacity(0.5)
                    : AppColor.primaryColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            textStyle: AppStyle.heading6Regular(
              color: otpController.isLoading.value
                  ? AppColor.primaryColor.withOpacity(0.5)
                  : AppColor.primaryColor,
            ),
          ),

          // Following pin theme
          followingPinTheme: PinTheme(
            height: AppSize.appSize51,
            width: AppSize.appSize51,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.primaryColor,
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            textStyle: AppStyle.heading6Regular(color: AppColor.primaryColor),
          ),

          // Submitted pin theme (for completed OTP)
          submittedPinTheme: PinTheme(
            height: AppSize.appSize51,
            width: AppSize.appSize51,
            decoration: BoxDecoration(
              border: Border.all(
                color: otpController.isOTPValid.value
                    ? Colors.green
                    : AppColor.primaryColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              color: otpController.isOTPValid.value
                  ? Colors.green.withOpacity(0.1)
                  : null,
            ),
            textStyle: AppStyle.heading6Regular(
              color: otpController.isOTPValid.value
                  ? Colors.green
                  : AppColor.primaryColor,
            ),
          ),

          // Error pin theme
          errorPinTheme: PinTheme(
            height: AppSize.appSize51,
            width: AppSize.appSize51,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            textStyle: AppStyle.heading6Regular(color: Colors.red),
          ),

          // Show cursor
          showCursor: true,
          cursor: Container(
            height: 20,
            width: 2,
            color: AppColor.primaryColor,
          ),
        )).paddingOnly(top: AppSize.appSize36),

        // Enhanced resend code section
        Center(
          child: Obx(() => CommonRichText(
            segments: [
              TextSegment(
                text: AppString.didNotReceiveTheCode,
                style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
              TextSegment(
                text: otpController.countdown.value == AppSize.size0
                    ? AppString.resendCodeButton
                    : otpController.formattedCountdown,
                style: AppStyle.heading5Medium(
                  color: otpController.countdown.value == AppSize.size0
                      ? AppColor.primaryColor
                      : AppColor.descriptionColor,
                ),
                onTap: otpController.countdown.value == AppSize.size0
                    ? () => otpController.resendOTP()
                    : null,
              ),
            ],
          )).paddingOnly(top: AppSize.appSize12),
        ),

        // Enhanced verify button with loading state
        Obx(() => CommonButton(
          onPressed: otpController.isLoading.value
              ? null
              : () => otpController.verifyOTP(),
          child: otpController.isLoading.value
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: AppColor.whiteColor,
              strokeWidth: 2,
            ),
          )
              : Text(
            AppString.verifyButton,
            style: AppStyle.heading5Medium(color: AppColor.whiteColor),
          ),
        )).paddingOnly(top: AppSize.appSize36),

        // Loading overlay (optional)
        Obx(() => otpController.isLoading.value
            ? Container(
          margin: EdgeInsets.only(top: AppSize.appSize16),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: AppSize.appSize8),
                Text(
                  'Verifying OTP...',
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                ),
              ],
            ),
          ),
        )
            : const SizedBox.shrink(),
        ),
      ],
    ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16);
  }

  Widget buildTextButton() {
    return Obx(() => GestureDetector(
      onTap: otpController.isLoading.value
          ? null
          : () {
        // Handle missed call verification if needed
        // You can implement this functionality later
        Get.snackbar('Info', 'Missed call verification not implemented yet');
      },
      child: Text(
        AppString.verifyViaMissedCallButton,
        textAlign: TextAlign.center,
        style: AppStyle.heading6Regular(
          color: otpController.isLoading.value
              ? AppColor.primaryColor.withOpacity(0.5)
              : AppColor.primaryColor,
        ),
      ),
    )).paddingOnly(bottom: AppSize.appSize26);
  }
}
