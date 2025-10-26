import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/edit_property_details_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class EditPropertyDetailsView extends StatelessWidget {
  EditPropertyDetailsView({super.key});

  final EditPropertyDetailsController editPropertyDetailsController =
      Get.put(EditPropertyDetailsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: buildAppBar(),
        body: buildEditPropertyDetailsFields(),
        bottomNavigationBar: buildButton(),
      );
    });
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.appSize40),
        child: SizedBox(
          height: AppSize.appSize40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Row(
                children: List.generate(
                    editPropertyDetailsController.propertyList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      editPropertyDetailsController.updateProperty(index);
                    },
                    child: Obx(() => Container(
                          height: AppSize.appSize25,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: editPropertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                              right: BorderSide(
                                color: index == AppSize.size3
                                    ? Colors.transparent
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              editPropertyDetailsController.propertyList[index],
                              style: AppStyle.heading5Medium(
                                color: editPropertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.textColor,
                              ),
                            ),
                          ),
                        )),
                  );
                }),
              ).paddingOnly(
                top: AppSize.appSize10,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditPropertyDetailsFields() {
    return Obx(() {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSize.appSize20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionContent(),
          ],
        ),
      );
    });
  }

  Widget _buildSectionContent() {
    switch (editPropertyDetailsController.currentSection.value) {
      case 'basic':
        return _buildBasicDetailsSection();
      case 'property':
        return _buildPropertyDetailsSection();
      case 'pricing':
        return _buildPricingSection();
      case 'amenities':
        return _buildAmenitiesSection();
      default:
        return _buildBasicDetailsSection();
    }
  }

Widget _buildBasicDetailsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ---- Contact Details ----
      Text(
        AppString.yourContactDetails,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),

      // ---- Phone Number Input ----
      Obx(
        () => Container(
          padding: EdgeInsets.only(
            top: editPropertyDetailsController.hasPhoneNumberFocus.value ||
                    editPropertyDetailsController.hasPhoneNumberInput.value
                ? AppSize.appSize6
                : AppSize.appSize14,
            bottom: editPropertyDetailsController.hasPhoneNumberFocus.value ||
                    editPropertyDetailsController.hasPhoneNumberInput.value
                ? AppSize.appSize8
                : AppSize.appSize14,
            left: editPropertyDetailsController.hasPhoneNumberFocus.value
                ? AppSize.appSize0
                : AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              color: editPropertyDetailsController.hasPhoneNumberFocus.value ||
                      editPropertyDetailsController.hasPhoneNumberInput.value
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (editPropertyDetailsController.hasPhoneNumberFocus.value ||
                  editPropertyDetailsController.hasPhoneNumberInput.value)
                Text(
                  AppString.phoneNumber,
                  style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                ).paddingOnly(
                  left: editPropertyDetailsController.hasPhoneNumberInput.value
                      ? (editPropertyDetailsController
                              .hasPhoneNumberFocus.value
                          ? AppSize.appSize16
                          : AppSize.appSize0)
                      : AppSize.appSize16,
                  bottom: AppSize.appSize2,
                ),

              Row(
                children: [
                  if (editPropertyDetailsController.hasPhoneNumberFocus.value ||
                      editPropertyDetailsController.hasPhoneNumberInput.value)
                    SizedBox(
                      child: IntrinsicHeight(
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                AppString.countryCode,
                                style: AppStyle.heading4Regular(
                                    color: AppColor.primaryColor),
                              ),
                              Image.asset(
                                Assets.images.dropdown.path,
                                width: AppSize.appSize16,
                              ).paddingOnly(
                                left: AppSize.appSize8,
                                right: AppSize.appSize3,
                              ),
                              const VerticalDivider(
                                color: AppColor.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).paddingOnly(
                      left: editPropertyDetailsController
                              .hasPhoneNumberInput.value
                          ? (editPropertyDetailsController
                                  .hasPhoneNumberFocus.value
                              ? AppSize.appSize16
                              : AppSize.appSize0)
                          : AppSize.appSize16,
                    ),

                  // ---- Text Field ----
                  Expanded(
                    child: SizedBox(
                      height: AppSize.appSize27,
                      child: TextFormField(
                        focusNode: editPropertyDetailsController.phoneNumberFocusNode,
                        controller:
                            editPropertyDetailsController.mobileNumberController,
                        cursorColor: AppColor.primaryColor,
                        keyboardType: TextInputType.phone,
                        style: AppStyle.heading4Regular(
                            color: AppColor.textColor),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(AppSize.size10),
                        ],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize0,
                            vertical: AppSize.appSize0,
                          ),
                          isDense: true,
                          hintText: editPropertyDetailsController
                                  .hasPhoneNumberFocus.value
                              ? ''
                              : AppString.phoneNumber,
                          hintStyle: AppStyle.heading4Regular(
                              color: AppColor.descriptionColor),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
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
        ),
      ).paddingOnly(top: AppSize.appSize16),

      // ---- Change Account ----
      Align(
        alignment: Alignment.topRight,
        child: Text(
          AppString.changeAccount,
          style: AppStyle.heading5Regular(color: AppColor.primaryColor),
        ),
      ).paddingOnly(top: AppSize.appSize6),

      // ---- Looking To ----
      Text(
        AppString.lookingToText,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ).paddingOnly(top: AppSize.appSize36),

      Row(
        children: List.generate(
          editPropertyDetailsController.propertyLookingList.length,
          (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  editPropertyDetailsController.updatePropertyLooking(index);
                },
                child: Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize16,
                      vertical: AppSize.appSize10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: editPropertyDetailsController
                                    .selectPropertyLooking.value ==
                                index
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        editPropertyDetailsController
                            .propertyLookingList[index],
                        style: AppStyle.heading5Medium(
                          color: editPropertyDetailsController
                                      .selectPropertyLooking.value ==
                                  index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ).paddingOnly(top: AppSize.appSize16),

      // ---- What Kind of Property ----
      Text(
        AppString.whatKindOfProperty,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ).paddingOnly(top: AppSize.appSize36),

      Row(
        children: List.generate(
          editPropertyDetailsController.propertyTypeList.length,
          (index) {
            return GestureDetector(
              onTap: () {
                editPropertyDetailsController.updatePropertyType(index);
              },
              child: Obx(
                () => Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize16,
                    vertical: AppSize.appSize10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    border: Border.all(
                      color:
                          editPropertyDetailsController.selectPropertyType.value ==
                                  index
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                      width: AppSize.appSize1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      editPropertyDetailsController.propertyTypeList[index],
                      style: AppStyle.heading5Medium(
                        color: editPropertyDetailsController
                                    .selectPropertyType.value ==
                                index
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ).paddingOnly(top: AppSize.appSize16),

      // ---- Select Property Type (Grid) ----
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
        itemCount: editPropertyDetailsController.propertyType2List.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              editPropertyDetailsController.updateSelectProperty2(index);
            },
            child: Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.appSize16,
                  vertical: AppSize.appSize10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(
                    color: editPropertyDetailsController
                                .selectPropertyType2.value ==
                            index
                        ? AppColor.primaryColor
                        : AppColor.descriptionColor
                            .withValues(alpha: AppSize.appSizePoint4),
                    width: AppSize.appSizePoint7,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      editPropertyDetailsController
                          .propertyTypeImageList[index],
                      width: AppSize.appSize24,
                      color: editPropertyDetailsController
                                  .selectPropertyType2.value ==
                              index
                          ? AppColor.primaryColor
                          : AppColor.descriptionColor,
                    ),
                    Text(
                      editPropertyDetailsController.propertyType2List[index],
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.heading5Regular(
                        color: editPropertyDetailsController
                                    .selectPropertyType2.value ==
                                index
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ],
  ).paddingOnly(
    top: AppSize.appSize26,
    left: AppSize.appSize16,
    right: AppSize.appSize16,
  );
}


  Widget _buildPropertyDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Details',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        
        // Location fields
        _buildTextField(
          controller: editPropertyDetailsController.cityController,
          label: 'City',
          hint: 'Enter city',
        ).paddingOnly(top: AppSize.appSize16),
        
        _buildTextField(
          controller: editPropertyDetailsController.localityController,
          label: 'Locality',
          hint: 'Enter locality',
        ).paddingOnly(top: AppSize.appSize16),
        
        _buildTextField(
          controller: editPropertyDetailsController.subLocalityController,
          label: 'Sub Locality',
          hint: 'Enter sub locality',
        ).paddingOnly(top: AppSize.appSize16),
        
        // Area fields
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: editPropertyDetailsController.plotAreaController,
                label: 'Plot Area',
                hint: 'Enter area',
              ),
            ),
            const SizedBox(width: AppSize.appSize16),
            Expanded(
              child: _buildTextField(
                controller: editPropertyDetailsController.builtUpAreaController,
                label: 'Built Up Area',
                hint: 'Enter area',
              ),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize16),
        
        // Property specifications
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: editPropertyDetailsController.noOfBedroomsController,
                label: 'Bedrooms',
                hint: 'Enter number',
              ),
            ),
            const SizedBox(width: AppSize.appSize16),
            Expanded(
              child: _buildTextField(
                controller: editPropertyDetailsController.noOfBathroomsController,
                label: 'Bathrooms',
                hint: 'Enter number',
              ),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize16),
        
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: editPropertyDetailsController.noOfBalconiesController,
                label: 'Balconies',
                hint: 'Enter number',
              ),
            ),
            const SizedBox(width: AppSize.appSize16),
            Expanded(
              child: _buildTextField(
                controller: editPropertyDetailsController.totalFloorsController,
                label: 'Total Floors',
                hint: 'Enter number',
              ),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize16),
        
        // Description
        _buildTextField(
          controller: editPropertyDetailsController.descriptionController,
          label: 'Description',
          hint: 'Enter property description',
          maxLines: 3,
        ).paddingOnly(top: AppSize.appSize16),
      ],
    ).paddingOnly(
      top: AppSize.appSize26,
      left: AppSize.appSize16,
      right: AppSize.appSize16,
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Details',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        
        _buildTextField(
          controller: editPropertyDetailsController.expectedPriceController,
          label: 'Expected Price',
          hint: 'Enter expected price',
        ).paddingOnly(top: AppSize.appSize16),
        
        Text(
          'Property Type',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(top: AppSize.appSize36),
        
        Row(
          children: List.generate(
              editPropertyDetailsController.propertyLookingList.length,
              (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  editPropertyDetailsController.updatePropertyLooking(index);
                },
                child: Obx(() => Container(
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize16,
                        vertical: AppSize.appSize10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: editPropertyDetailsController
                                      .selectPropertyLooking.value ==
                                  index
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          editPropertyDetailsController
                              .propertyLookingList[index],
                          style: AppStyle.heading5Medium(
                            color: editPropertyDetailsController
                                        .selectPropertyLooking.value ==
                                    index
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
      ],
    ).paddingOnly(
      top: AppSize.appSize26,
      left: AppSize.appSize16,
      right: AppSize.appSize16,
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        
        Text(
          'Select amenities available in your property',
          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
        ).paddingOnly(top: AppSize.appSize8),
        
        // This would be a comprehensive amenities selection
        // For now, showing a simple list
        Obx(() => Wrap(
          spacing: AppSize.appSize8,
          runSpacing: AppSize.appSize8,
          children: [
            'Swimming Pool',
            'Gym',
            'Parking',
            'Security',
            'Garden',
            'Lift',
            'Power Backup',
            'Water Supply',
          ].map((amenity) => GestureDetector(
            onTap: () {
              if (editPropertyDetailsController.selectedAmenities.contains(amenity)) {
                editPropertyDetailsController.selectedAmenities.remove(amenity);
              } else {
                editPropertyDetailsController.selectedAmenities.add(amenity);
              }
            },
            child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.appSize12,
                vertical: AppSize.appSize6,
              ),
              decoration: BoxDecoration(
                color: editPropertyDetailsController.selectedAmenities.contains(amenity)
                    ? AppColor.primaryColor
                    : AppColor.backgroundColor,
                borderRadius: BorderRadius.circular(AppSize.appSize16),
                border: Border.all(
                  color: editPropertyDetailsController.selectedAmenities.contains(amenity)
                      ? AppColor.primaryColor
                      : AppColor.borderColor,
                ),
              ),
              child: Text(
                amenity,
                style: AppStyle.heading5Medium(
                  color: editPropertyDetailsController.selectedAmenities.contains(amenity)
                      ? AppColor.whiteColor
                      : AppColor.textColor,
                ),
              ),
            )),
          )).toList(),
        )).paddingOnly(top: AppSize.appSize16),
      ],
    ).paddingOnly(
      top: AppSize.appSize26,
      left: AppSize.appSize16,
      right: AppSize.appSize16,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyle.heading5Medium(color: AppColor.textColor),
        ),
        const SizedBox(height: AppSize.appSize8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppStyle.heading4Regular(color: AppColor.textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSize.appSize16,
              vertical: AppSize.appSize12,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButton() {
    return Obx(() => CommonButton(
      onPressed: editPropertyDetailsController.isLoading.value 
          ? null 
          : () {
              editPropertyDetailsController.saveProperty();
            },
      backgroundColor: AppColor.primaryColor,
      child: editPropertyDetailsController.isLoading.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              AppString.saveButton,
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      bottom: AppSize.appSize26,
      top: AppSize.appSize10,
    ));
  }
}
