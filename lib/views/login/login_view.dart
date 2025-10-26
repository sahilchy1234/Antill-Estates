import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/login_controller.dart';
import 'package:antill_estates/controller/login_country_picker_controller.dart';
import 'package:antill_estates/views/login/widgets/login_coutry_picker_bottom_sheet.dart';
import '../../services/enhanced_loading_service.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController loginController = Get.put(LoginController());
  final LoginCountryPickerController loginCountryPickerController =
  Get.put(LoginCountryPickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: buildLoginFields(context),
        ),
      ),
       // bottomNavigationBar: buildTextButton(),

    );
  }

  Widget buildLoginFields(BuildContext context) {
    return Obx(() {
      if (loginController.isLoading.value) {
        return EnhancedLoadingService.buildAuthPageLoading();
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // Top spacing
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),

        // Login title
        Text(
          AppString.login,
          style: AppStyle.heading1(color: AppColor.textColor),
        ),

        // Login subtitle
        Text(
          AppString.loginString,
          style: AppStyle.heading4Regular(color: AppColor.descriptionColor),
        ).paddingOnly(top: AppSize.appSize12),

        // Phone input field with animation
        Obx(() => AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(top: AppSize.appSize36),
          padding: EdgeInsets.only(
            top: loginController.hasFocus.value || loginController.hasInput.value
                ? AppSize.appSize6 : AppSize.appSize14,
            bottom: loginController.hasFocus.value || loginController.hasInput.value
                ? AppSize.appSize8 : AppSize.appSize14,
            left: loginController.hasFocus.value
                ? AppSize.appSize0 : AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              width: loginController.hasFocus.value ? 2 : 1,
              color: loginController.hasFocus.value || loginController.hasInput.value
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label text
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: loginController.hasFocus.value || loginController.hasInput.value
                    ? Text(
                  AppString.phoneNumber,
                  style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                ).paddingOnly(
                  left: loginController.hasInput.value
                      ? (loginController.hasFocus.value
                      ? AppSize.appSize16 : AppSize.appSize0)
                      : AppSize.appSize16,
                  bottom: AppSize.appSize2,
                )
                    : const SizedBox.shrink(),
              ),

              // Phone input row
              Row(
                children: [
                  // Country code picker
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: loginController.hasFocus.value || loginController.hasInput.value
                        ? Container(
                      child: IntrinsicHeight(
                        child: GestureDetector(
                          onTap: () {
                            loginCountryPickerBottomSheet(context);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() {
                                final selectedCountryIndex =
                                    loginCountryPickerController.selectedIndex.value;
                                return Text(
                                  loginCountryPickerController.countries[selectedCountryIndex]
                                  [AppString.codeText] ?? '+91',
                                  style: AppStyle.heading4Regular(color: AppColor.primaryColor),
                                );
                              }),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColor.primaryColor,
                                size: AppSize.appSize16,
                              ).paddingOnly(left: AppSize.appSize4, right: AppSize.appSize8),
                              Container(
                                height: AppSize.appSize24,
                                width: 1,
                                color: AppColor.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).paddingOnly(
                      left: loginController.hasInput.value
                          ? (loginController.hasFocus.value
                          ? AppSize.appSize16 : AppSize.appSize0)
                          : AppSize.appSize16,
                      right: AppSize.appSize12,
                    )
                        : const SizedBox.shrink(),
                  ),

                  // Phone number input field
                  Expanded(
                    child: TextFormField(
                      focusNode: loginController.focusNode,
                      controller: loginController.mobileController,
                      cursorColor: AppColor.primaryColor,
                      keyboardType: TextInputType.phone,
                      style: AppStyle.heading4Regular(color: AppColor.textColor),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSize.appSize16,
                          vertical: AppSize.appSize0,
                        ),
                        isDense: true,
                        hintText: loginController.hasFocus.value
                            ? 'Enter phone number'
                            : AppString.phoneNumber,
                        hintStyle: AppStyle.heading4Regular(
                            color: AppColor.descriptionColor.withOpacity(0.7)
                        ),
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
                ],
              ),
            ],
          ),
        )),

        // Continue button with loading state
        // Updated button with proper validation
        Obx(() {
          bool isButtonEnabled = loginController.isFormValid && !loginController.isLoading.value;

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: AppSize.appSize32),
            child: ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                // Unfocus keyboard before sending OTP
                FocusScope.of(context).unfocus();
                loginController.sendOTP();
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isButtonEnabled
                    ? AppColor.primaryColor
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                ),
                elevation: isButtonEnabled ? 2 : 0,
              ),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: loginController.isLoading.value
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  AppString.continueButton,
                  style: AppStyle.heading5Medium(color: Colors.white),
                ),
              ),
            ),
          );
        }),


        // Bottom spacing
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
      ],
    ).paddingSymmetric(horizontal: AppSize.appSize16);
    });
  }

  // Widget buildTextButton() {
  //   return SafeArea(
  //     child: Container(
  //       padding: EdgeInsets.symmetric(vertical: AppSize.appSize20),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             AppString.dontHaveAccount,
  //             style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
  //           ),
  //           SizedBox(width: AppSize.appSize4),
  //           GestureDetector(
  //             onTap: () {
  //               // Clear form before navigating
  //               loginController.clearForm();
  //               Get.offNamed(AppRoutes.registerView);
  //             },
  //             child: Text(
  //               AppString.registerButton,
  //               style: AppStyle.heading5Medium(color: AppColor.primaryColor),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
