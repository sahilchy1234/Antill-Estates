import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/common/common_rich_text.dart';
import 'package:antill_estates/common/common_status_bar.dart';
import 'package:antill_estates/common/common_textfield.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/register_controller.dart';
import 'package:antill_estates/controller/register_country_picker_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/text_segment_model.dart';
import 'package:antill_estates/views/drawer/terms_of_use/about_us_view.dart';
import 'package:antill_estates/views/drawer/terms_of_use/privacy_policy_view.dart';
import 'package:antill_estates/views/register/widgets/register_country_picker_bottom_sheet.dart';
import '../../services/enhanced_loading_service.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final RegisterController registerController = Get.put(RegisterController());
  final RegisterCountryPickerController registerCountryPickerController =
  Get.put(RegisterCountryPickerController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: _buildRegisterFields(context),
          // bottomNavigationBar: _buildSignInPrompt(),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  Widget _buildRegisterFields(BuildContext context) {
    return Obx(() {
      if (registerController.isLoading.value) {
        return EnhancedLoadingService.buildAuthPageLoading();
      }
      
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSize.appSize20,
            vertical: AppSize.appSize16,
          ),
          child: Column(
            children: [
            _buildProfileImageSection(),
            const SizedBox(height: AppSize.appSize32),
            // Align the rest of the form to the left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSize.appSize24),
                _buildFullNameField(),
                const SizedBox(height: AppSize.appSize16),
                _buildPhoneNumberField(context),
                const SizedBox(height: AppSize.appSize16),
                _buildEmailField(),
                const SizedBox(height: AppSize.appSize20),
                _buildRealEstateAgentSection(),
                const SizedBox(height: AppSize.appSize20),
                _buildTermsAndConditions(),
                const SizedBox(height: AppSize.appSize32),
                _buildContinueButton(),
                const SizedBox(height: AppSize.appSize16),
              ],
            ),
          ],
        ),
      ),
    );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Account",
          style: AppStyle.heading1(color: AppColor.textColor),
        ),
        const SizedBox(height: AppSize.appSize8),
        Text(
          "Join our luxury real estate community and discover premium properties",
          style: AppStyle.heading4Regular(color: AppColor.descriptionColor),
        ),
      ],
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Obx(() => GestureDetector(
            onTap: () => registerController.showImagePickerOptions(),
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                color: AppColor.whiteColor,
              ),
              child: registerController.selectedImage.value != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Image.file(
                  registerController.selectedImage.value!,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: AppColor.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add Photo',
                    style: AppStyle.heading6Regular(
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: AppSize.appSize8),
          Obx(() => registerController.isImageUploading.value
              ? Column(
            children: [
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor:
                  AppColor.descriptionColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.primaryColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                registerController.imageUploadProgress.value,
                style: AppStyle.heading6Regular(
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildFullNameField() {
    return Obx(() => CommonTextField(
      controller: registerController.fullNameController,
      focusNode: registerController.focusNode,
      hasFocus: registerController.hasFullNameFocus.value,
      hasInput: registerController.hasFullNameInput.value,
      hintText: "Enter your full name",
      labelText: "Full Name",
    ));
  }

  Widget _buildPhoneNumberField(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.appSize16,
        vertical: registerController.hasPhoneNumberFocus.value ||
            registerController.hasPhoneNumberInput.value
            ? AppSize.appSize12
            : AppSize.appSize16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(
          color: AppColor.descriptionColor.withOpacity(0.5),
          width: 1,
        ),
        color: AppColor.descriptionColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Phone Number",
            style: AppStyle.heading6Regular(
              color: AppColor.descriptionColor,
            ),
          ),
          const SizedBox(height: AppSize.appSize8),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  registerCountryPickerBottomSheet(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize8,
                    vertical: AppSize.appSize4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize6),
                    color: AppColor.whiteColor,
                    border: Border.all(
                      color: AppColor.descriptionColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        final selectedCountryIndex =
                            registerCountryPickerController
                                .selectedIndex.value;
                        return Text(
                          registerCountryPickerController.countries[
                          selectedCountryIndex][AppString.codeText] ??
                              '+1',
                          style: AppStyle.heading5Regular(
                              color: AppColor.textColor),
                        );
                      }),
                      const SizedBox(width: AppSize.appSize4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColor.descriptionColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSize.appSize12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize12,
                    vertical: AppSize.appSize8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize6),
                    color: AppColor.descriptionColor.withOpacity(0.1),
                  ),
                  child: Text(
                    "Phone verification not required",
                    style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildEmailField() {
    return Obx(() => CommonTextField(
      controller: registerController.emailController,
      focusNode: registerController.emailFocusNode,
      hasFocus: registerController.hasEmailFocus.value,
      hasInput: registerController.hasEmailInput.value,
      hintText: "Enter your email address",
      labelText: "Email Address",
    ));
  }

  Widget _buildRealEstateAgentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.areYouARealEstateAgent,
          style: AppStyle.heading5Regular(color: AppColor.textColor),
        ),
        const SizedBox(height: AppSize.appSize12),
        Row(
          children: List.generate(2, (index) {
            final options = ['Yes', 'No'];
            return GestureDetector(
              onTap: () {
                registerController.updateOption(index);
              },
              child: Obx(() => Container(
                margin: const EdgeInsets.only(right: AppSize.appSize16),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.appSize20,
                  vertical: AppSize.appSize10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize8),
                  border: Border.all(
                    color: registerController.selectOption.value == index
                        ? AppColor.primaryColor
                        : AppColor.descriptionColor.withOpacity(0.5),
                    width: registerController.selectOption.value == index
                        ? 2
                        : 1,
                  ),
                  color: registerController.selectOption.value == index
                      ? AppColor.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Text(
                  options[index],
                  style: AppStyle.heading5Regular(
                    color: registerController.selectOption.value == index
                        ? AppColor.primaryColor
                        : AppColor.descriptionColor,
                  ),
                ),
              )),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            registerController.toggleCheckbox();
          },
          child: Obx(() => Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            child: Image.asset(
              registerController.isChecked.value
                  ? Assets.images.checkbox.path
                  : Assets.images.emptyCheckbox.path,
              width: AppSize.appSize20,
            ),
          )),
        ),
        const SizedBox(width: AppSize.appSize12),
        Expanded(
          child: CommonRichText(
            segments: [
              TextSegment(
                text: "I agree to the ",
                style: AppStyle.heading6Regular(
                    color: AppColor.descriptionColor),
              ),
              TextSegment(
                  text: "Terms of Service",
                  style: AppStyle.heading6Regular(
                      color: AppColor.primaryColor),
                  onTap: () {
                    Get.to(() => AboutUsView());
                  }),
              TextSegment(
                text: " and ",
                style: AppStyle.heading6Regular(
                    color: AppColor.descriptionColor),
              ),
              TextSegment(
                  text: "Privacy Policy",
                  style: AppStyle.heading6Regular(
                      color: AppColor.primaryColor),
                  onTap: () {
                    Get.to(() => PrivacyPolicyView());
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => CommonButton(
        onPressed: registerController.isLoading.value
            ? null // Disable button when loading
            : () {
          registerController.registerUser();
        },
        child: registerController.isLoading.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColor.whiteColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Creating Account...",
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ],
        )
            : Text(
          "Create Account",
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      )),
    );
  }

// Widget _buildSignInPrompt() {
//   return Container(
//     padding: const EdgeInsets.only(bottom: AppSize.appSize26),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "Already have an account? ",
//           style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
//         ),
//         GestureDetector(
//           onTap: () {
//             Get.offNamed(AppRoutes.loginView);
//           },
//           child: Text(
//             "Sign In",
//             style: AppStyle.heading5Medium(color: AppColor.primaryColor),
//           ),
//         ),
//       ],
//     ),
//   );
// }
}
