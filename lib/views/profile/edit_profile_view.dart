import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/common/common_textfield.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/edit_country_picker_controller.dart';
import 'package:antill_estates/controller/edit_profile_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/services/UserDataController.dart';
import 'package:antill_estates/views/profile/widgets/edit_country_picker_bottom_sheet.dart';
import 'package:antill_estates/views/profile/widgets/edit_second_country_picker_bottom_sheet.dart';
import 'package:antill_estates/common/cached_avatar_image.dart';
import '../../services/enhanced_loading_service.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});

  final EditProfileController editProfileController = Get.put(EditProfileController());
  final EditCountryPickerController editCountryPickerController = Get.put(EditCountryPickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildEditProfileFields(context),
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
        AppString.editProfile,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  UserDataController get controller => Get.find<UserDataController>();

  Widget buildEditProfileFields(BuildContext context) {
    return Obx(() {
      if (editProfileController.isLoading.value) {
        return EnhancedLoadingService.buildProfilePageLoading();
      }
      
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSize.appSize20),
        child: Column(
          children: [
          // Profile Image Section
          Center(
            child: CircleAvatar(
              backgroundColor: AppColor.whiteColor,
              radius: AppSize.appSize62,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(() {
                    if (controller.profileImagePath.value.isNotEmpty) {
                      return CachedAvatarImage(
                        imageUrl: controller.profileImagePath.value,
                        radius: AppSize.appSize50,
                        backgroundColor: AppColor.whiteColor,
                        fallbackIcon: Icon(
                          Icons.person,
                          size: AppSize.appSize50,
                          color: AppColor.descriptionColor,
                        ),
                      );
                    } else {
                      return CircleAvatar(
                        radius: AppSize.appSize50,
                        backgroundColor: AppColor.whiteColor,
                        backgroundImage: AssetImage(
                          Assets.images.francisProfile.path,
                        ),
                      );
                    }
                  }),

                  Positioned(
                    bottom: AppSize.appSize2,
                    right: AppSize.appSize2,
                    child: Obx(() => GestureDetector(
                      onTap: editProfileController.isUploadingImage.value
                          ? null
                          : () {
                        editProfileController.updateProfileImage();
                      },
                      child: CircleAvatar(
                        backgroundColor: AppColor.whiteColor,
                        radius: AppSize.appSize15,
                        child: editProfileController.isUploadingImage.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.primaryColor,
                          ),
                        )
                            : Image.asset(
                          Assets.images.editImage.path,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),

          // Full Name Field
          Obx(() => CommonTextField(
            controller: editProfileController.fullNameController,
            focusNode: editProfileController.focusNode,
            hasFocus: editProfileController.hasFullNameFocus.value,
            hasInput: editProfileController.hasFullNameInput.value,
            hintText: AppString.fullName,
            labelText: AppString.fullName,
          )).paddingOnly(top: AppSize.appSize16),

          // Phone Number Field with Country Picker
          Obx(() => Container(
            padding:  EdgeInsets.only(
              top: editProfileController.hasPhoneNumberFocus.value || editProfileController.hasPhoneNumberInput.value
                  ? AppSize.appSize6 : AppSize.appSize14,
              bottom: editProfileController.hasPhoneNumberFocus.value || editProfileController.hasPhoneNumberInput.value
                  ? AppSize.appSize8 : AppSize.appSize14,
              left: editProfileController.hasPhoneNumberFocus.value
                  ? AppSize.appSize0 : AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: editProfileController.hasPhoneNumberFocus.value || editProfileController.hasPhoneNumberInput.value
                    ? AppColor.primaryColor
                    : AppColor.descriptionColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                editProfileController.hasPhoneNumberFocus.value || editProfileController.hasPhoneNumberInput.value
                    ? Text(
                  AppString.phoneNumber,
                  style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                ).paddingOnly(
                  left: editProfileController.hasPhoneNumberInput.value
                      ? (editProfileController.hasPhoneNumberFocus.value
                      ? AppSize.appSize16 : AppSize.appSize0)
                      : AppSize.appSize16,
                  bottom: editProfileController.hasPhoneNumberInput.value
                      ? AppSize.appSize2 : AppSize.appSize2,
                ) : const SizedBox.shrink(),
                Row(
                  children: [
                    editProfileController.hasPhoneNumberFocus.value || editProfileController.hasPhoneNumberInput.value ? SizedBox(
                      child: IntrinsicHeight(
                        child: GestureDetector(
                          onTap: () {
                            editCountryPickerBottomSheet(context);
                          },
                          child: Row(
                            children: [
                              Obx(() {
                                final selectedCountryIndex =
                                    editCountryPickerController.selectedIndex.value;
                                return Text(
                                  editCountryPickerController.countries[selectedCountryIndex]
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
                      left: editProfileController.hasPhoneNumberInput.value
                          ? (editProfileController.hasPhoneNumberFocus.value
                          ? AppSize.appSize16 : AppSize.appSize0)
                          : AppSize.appSize16,
                    ) : const SizedBox.shrink(),
                    Expanded(
                      child: SizedBox(
                        height: AppSize.appSize27,
                        width: double.infinity,
                        child: TextFormField(
                          focusNode: editProfileController.phoneNumberFocusNode,
                          controller: editProfileController.phoneNumberController,
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
                            hintText: editProfileController.hasPhoneNumberFocus.value ? '' : AppString.phoneNumber,
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

          // Phone Number 2 Field with Country Picker
          Obx(() => Container(
            padding:  EdgeInsets.only(
              top: editProfileController.hasPhoneNumber2Focus.value || editProfileController.hasPhoneNumber2Input.value
                  ? AppSize.appSize6 : AppSize.appSize14,
              bottom: editProfileController.hasPhoneNumber2Focus.value || editProfileController.hasPhoneNumber2Input.value
                  ? AppSize.appSize8 : AppSize.appSize14,
              left: editProfileController.hasPhoneNumber2Focus.value
                  ? AppSize.appSize0 : AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: editProfileController.hasPhoneNumber2Focus.value || editProfileController.hasPhoneNumber2Input.value
                    ? AppColor.primaryColor
                    : AppColor.descriptionColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                editProfileController.hasPhoneNumber2Focus.value || editProfileController.hasPhoneNumber2Input.value
                    ? Text(
                  AppString.phoneNumber,
                  style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                ).paddingOnly(
                  left: editProfileController.hasPhoneNumber2Input.value
                      ? (editProfileController.hasPhoneNumber2Focus.value
                      ? AppSize.appSize16 : AppSize.appSize0)
                      : AppSize.appSize16,
                  bottom: editProfileController.hasPhoneNumber2Input.value
                      ? AppSize.appSize2 : AppSize.appSize2,
                ) : const SizedBox.shrink(),
                Row(
                  children: [
                    editProfileController.hasPhoneNumber2Focus.value || editProfileController.hasPhoneNumber2Input.value ? SizedBox(
                      child: IntrinsicHeight(
                        child: GestureDetector(
                          onTap: () {
                            editSecondCountryPickerBottomSheet(context);
                          },
                          child: Row(
                            children: [
                              Obx(() {
                                final selectedCountryIndex =
                                    editCountryPickerController.selected2Index.value;
                                return Text(
                                  editCountryPickerController.countries[selectedCountryIndex]
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
                      left: editProfileController.hasPhoneNumber2Input.value
                          ? (editProfileController.hasPhoneNumber2Focus.value
                          ? AppSize.appSize16 : AppSize.appSize0)
                          : AppSize.appSize16,
                    ) : const SizedBox.shrink(),
                    Expanded(
                      child: SizedBox(
                        height: AppSize.appSize27,
                        width: double.infinity,
                        child: TextFormField(
                          focusNode: editProfileController.phoneNumber2FocusNode,
                          controller: editProfileController.phoneNumber2Controller,
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
                            hintText: editProfileController.hasPhoneNumber2Focus.value ? '' : AppString.phoneNumber2,
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

          // Email Field
          Obx(() => CommonTextField(
            controller: editProfileController.emailController,
            focusNode: editProfileController.emailFocusNode,
            hasFocus: editProfileController.hasEmailFocus.value,
            hasInput: editProfileController.hasEmailInput.value,
            hintText: AppString.emailAddress,
            labelText: AppString.emailAddress,
            keyboardType: TextInputType.emailAddress,
          )).paddingOnly(top: AppSize.appSize16),

          // About Me Field
          TextFormField(
            controller: editProfileController.aboutMeController,
            cursorColor: AppColor.primaryColor,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            maxLines: AppSize.size3,
            decoration: InputDecoration(
              hintText: AppString.aboutMe,
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

          // What Are You Here Dropdown
          Obx(() => TextFormField(
            controller: editProfileController.whatAreYouHereController,
            cursorColor: AppColor.primaryColor,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            readOnly: true,
            onTap: () {
              editProfileController.toggleWhatAreYouHereExpansion();
            },
            decoration: InputDecoration(
              hintText: AppString.whatAreYouHere,
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
                editProfileController.isWhatAreYouHereExpanded.value
                    ? Assets.images.dropdownExpand.path
                    : Assets.images.dropdown.path,
              ).paddingOnly(right: AppSize.appSize16),
              suffixIconConstraints: const BoxConstraints(
                maxWidth: AppSize.appSize34,
              ),
            ),
          )).paddingOnly(top: AppSize.appSize16),

          // What Are You Here Dropdown Options
          Obx(() => AnimatedContainer(
            duration: const Duration(seconds: AppSize.size1),
            curve: Curves.fastEaseInToSlowEaseOut,
            margin: EdgeInsets.only(
              top: editProfileController.isWhatAreYouHereExpanded.value
                  ? AppSize.appSize16
                  : AppSize.appSize0,
            ),
            height: editProfileController.isWhatAreYouHereExpanded.value
                ? null
                : AppSize.appSize0,
            child: editProfileController.isWhatAreYouHereExpanded.value
                ? GestureDetector(
              onTap: () {},
              child: Container(
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
                  children: List.generate(editProfileController.whatAreYouHereList.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        editProfileController.updateWhatAreYouHere(index);
                        editProfileController.toggleWhatAreYouHereExpansion();
                      },
                      child: Row(
                        children: [
                          Container(
                            width: AppSize.appSize20,
                            height: AppSize.appSize20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColor.textColor,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: editProfileController.isWhatAreYouHereSelect.value == index ? Center(
                              child: Container(
                                width: AppSize.appSize12,
                                height: AppSize.appSize12,
                                decoration: const BoxDecoration(
                                  color: AppColor.textColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ) : const SizedBox.shrink(),
                          ),
                          Text(
                            editProfileController.whatAreYouHereList[index],
                            style: AppStyle.heading5Regular(color: AppColor.textColor),
                          ).paddingOnly(left: AppSize.appSize10),
                        ],
                      ).paddingOnly(bottom: AppSize.appSize16),
                    );
                  }),
                ),
              ),
            ) : const SizedBox.shrink(),
          )),

    Obx(() {
    final fullNameValid = editProfileController.hasFullNameInput.value;
    final phoneValid = editProfileController.hasPhoneNumberInput.value &&
    editProfileController.isValidPhoneNumber(editProfileController.phoneNumberController.text);
    final emailValid = editProfileController.hasEmailInput.value &&
    editProfileController.isValidEmail(editProfileController.emailController.text);

    final isValid = fullNameValid && phoneValid && emailValid;

    return !isValid
    ? Container(
    margin: const EdgeInsets.only(top: AppSize.appSize16),
    padding: const EdgeInsets.all(AppSize.appSize12),
    decoration: BoxDecoration(
    color: Colors.red.shade50,
    borderRadius: BorderRadius.circular(AppSize.appSize8),
    border: Border.all(color: Colors.red.shade200),
    ),
    child: Row(
    children: [
    Icon(
    Icons.error_outline,
    color: Colors.red.shade600,
    size: 20,
    ),
    const SizedBox(width: AppSize.appSize8),
    Expanded(
    child: Text(
    'Please fill in all required fields with valid information',
    style: AppStyle.heading6Regular(color: Colors.red.shade600),
    ),
    ),
    ],
    ),
    )
        : const SizedBox.shrink();
    })

        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
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
        onPressed: () async {
          // Access observables directly in the callback, not in Obx
          if (editProfileController.isUpdating.value) return;

          // Validate form before updating
          if (!editProfileController.isFormValid) {
            Get.snackbar(
              'Validation Error',
              'Please fill in all required fields correctly',
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade800,
              snackPosition: SnackPosition.TOP,
            );
            return;
          }

          // Show confirmation dialog
          bool? shouldUpdate = await Get.dialog<bool>(
            AlertDialog(
              title: Text(
                'Update Profile',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              content: Text(
                'Are you sure you want to update your profile information?',
                style: AppStyle.heading5Regular(color: AppColor.textColor),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text(
                    'Cancel',
                    style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                  ),
                  child: Text(
                    'Update',
                    style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                  ),
                ),
              ],
            ),
          );

          if (shouldUpdate == true) {
            await editProfileController.updateAllProfileData();
          }
        },
        backgroundColor: AppColor.primaryColor,
        // Use Obx only for the child that needs reactive updates
        child: Obx(() => editProfileController.isUpdating.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.whiteColor,
              ),
            ),
            const SizedBox(width: AppSize.appSize8),
            Text(
              'Updating...',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ],
        )
            : Text(
          AppString.updateProfileButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
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
