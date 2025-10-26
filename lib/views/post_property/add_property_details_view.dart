import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/add_property_details_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

class AddPropertyDetailsView extends StatelessWidget {
  AddPropertyDetailsView({super.key});

 final AddPropertyDetailsController addPropertyDetailsController = Get.put(AddPropertyDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAddPropertyFields(),
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
        AppString.addPropertyDetails,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAddPropertyFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.yourPropertyLocated,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          TextFormField(
            controller: addPropertyDetailsController.cityController,
            cursorColor: AppColor.primaryColor,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            onChanged: addPropertyDetailsController.onCityChanged,
            decoration: InputDecoration(
              hintText: AppString.city,
              hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: const BorderSide(
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Obx(() {
            if(addPropertyDetailsController.isCityFilled.value) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: addPropertyDetailsController.localityController,
                    cursorColor: AppColor.primaryColor,
                    style: AppStyle.heading4Regular(color: AppColor.textColor),
                    decoration: InputDecoration(
                      hintText: AppString.locality,
                      hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: BorderSide(
                          color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: BorderSide(
                          color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: const BorderSide(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ).paddingOnly(
                    top: AppSize.appSize10,
                    left: AppSize.appSize16, right: AppSize.appSize16,
                  ),
                  TextFormField(
                    controller: addPropertyDetailsController.subLocalityController,
                    cursorColor: AppColor.primaryColor,
                    style: AppStyle.heading4Regular(color: AppColor.textColor),
                    decoration: InputDecoration(
                      hintText: AppString.subLocality,
                      hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: BorderSide(
                          color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: BorderSide(
                          color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: const BorderSide(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ).paddingOnly(
                    top: AppSize.appSize10,
                    left: AppSize.appSize16, right: AppSize.appSize16,
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Image.asset(
                    Assets.images.gps.path,
                    width: AppSize.appSize16,
                  ).paddingOnly(right: AppSize.appSize6),
                  Text(
                    AppString.detectMyLocation,
                    style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                  ),
                ],
              ).paddingOnly(
                top: AppSize.appSize6,
                left: AppSize.appSize16, right: AppSize.appSize16,
              );
            }
          }),
          Text(
            AppString.addAreaDetails,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          TextFormField(
            controller: addPropertyDetailsController.plotAreaController,
            cursorColor: AppColor.primaryColor,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: AppString.plotArea,
              hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: const BorderSide(
                  color: AppColor.primaryColor,
                ),
              ),
              suffixIcon: SizedBox(
                width: AppSize.appSize95,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      VerticalDivider(
                        color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                        thickness: AppSize.appSizePoint7,
                        width: AppSize.appSize0,
                        indent: AppSize.appSize14,
                        endIndent: AppSize.appSize14,
                      ).paddingOnly(right: AppSize.appSize10),
                      Text(
                        AppString.squareFeet,
                        style: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                      ).paddingOnly(right: AppSize.appSize6),
                      Image.asset(
                        Assets.images.dropdown.path,
                        width: AppSize.appSize18,
                      ),
                    ],
                  ),
                ),
              )
            ),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.addBuiltUpArea,
            style: AppStyle.heading5Regular(color: AppColor.primaryColor),
          ).paddingOnly(
            top: AppSize.appSize6,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.addSuperBuiltUpArea,
            style: AppStyle.heading5Regular(color: AppColor.primaryColor),
          ).paddingOnly(
            top: AppSize.appSize6,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.otherRooms,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Row(
            children: List.generate(addPropertyDetailsController.otherRoomList1.length, (index) {
              return GestureDetector(
                onTap: () {
                  addPropertyDetailsController.updateRoom1(index);
                },
                child: Obx(() => Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    border: Border.all(
                      color: addPropertyDetailsController.selectRoom1.value == index
                          ? AppColor.primaryColor
                          : AppColor.borderColor,
                      width: AppSize.appSize1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      addPropertyDetailsController.otherRoomList1[index],
                      style: AppStyle.heading5Medium(
                        color: addPropertyDetailsController.selectRoom1.value == index
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                  ),
                )),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Row(
            children: List.generate(addPropertyDetailsController.otherRoomList2.length, (index) {
              return GestureDetector(
                onTap: () {
                  addPropertyDetailsController.updateRoom2(index);
                },
                child: Obx(() => Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    border: Border.all(
                      color: addPropertyDetailsController.selectRoom2.value == index
                          ? AppColor.primaryColor
                          : AppColor.borderColor,
                      width: AppSize.appSize1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      addPropertyDetailsController.otherRoomList2[index],
                      style: AppStyle.heading5Medium(
                        color: addPropertyDetailsController.selectRoom2.value == index
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                      ),
                    ),
                  ),
                )),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.floorDetails,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          TextFormField(
            controller: addPropertyDetailsController.totalFloorsController,
            cursorColor: AppColor.primaryColor,
            keyboardType: TextInputType.number,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            decoration: InputDecoration(
              hintText: AppString.totalFloors,
              hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: const BorderSide(
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.noOfBedroomsText,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(addPropertyDetailsController.bedRoomList.length, (index) {
                return GestureDetector(
                  onTap: () {
                    addPropertyDetailsController.updateBedRoom(index);
                  },
                  child: Obx(() => Container(
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: addPropertyDetailsController.selectBedRoom.value == index
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        addPropertyDetailsController.bedRoomList[index],
                        style: AppStyle.heading5Medium(
                          color: addPropertyDetailsController.selectBedRoom.value == index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ),
                  )),
                );
              }),
            ).paddingOnly(top: AppSize.appSize16),
          ),
          Text(
            AppString.noOfBathrooms,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(addPropertyDetailsController.bathRoomsList.length, (index) {
                return GestureDetector(
                  onTap: () {
                    addPropertyDetailsController.updateBathRoom(index);
                  },
                  child: Obx(() => Container(
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: addPropertyDetailsController.selectBathRoom.value == index
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        addPropertyDetailsController.bathRoomsList[index],
                        style: AppStyle.heading5Medium(
                          color: addPropertyDetailsController.selectBathRoom.value == index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ),
                  )),
                );
              }),
            ).paddingOnly(top: AppSize.appSize16),
          ),
          Text(
            AppString.noOfBalconies,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(addPropertyDetailsController.balconiesList.length, (index) {
                return GestureDetector(
                  onTap: () {
                    addPropertyDetailsController.updateBalconies(index);
                  },
                  child: Obx(() => Container(
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: addPropertyDetailsController.selectBalconies.value == index
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        addPropertyDetailsController.balconiesList[index],
                        style: AppStyle.heading5Medium(
                          color: addPropertyDetailsController.selectBalconies.value == index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ),
                  )),
                );
              }),
            ).paddingOnly(top: AppSize.appSize16),
          ),
          Row(
            children: [
              Text(
                AppString.reservedParking,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(right: AppSize.appSize1),
              Text(
                AppString.optional,
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.coveredParking,
                style: AppStyle.heading5Regular(color: AppColor.textColor),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      addPropertyDetailsController.decrement();
                    },
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize22, vertical: AppSize.appSize4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: addPropertyDetailsController.selectedButton.value == AppString.minusText
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                          width: AppSize.appSizePoint7,
                        ),
                      ),
                      child: Text(
                        AppString.minus,
                        style: AppStyle.heading4Regular(
                          color: addPropertyDetailsController.selectedButton.value == AppString.minusText
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    )),
                  ),
                  Obx(() => SizedBox(
                    width: AppSize.appSize44,
                    child: Center(
                      child: Text(
                        '${addPropertyDetailsController.count}',
                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                      ),
                    ),
                  )),
                  GestureDetector(
                    onTap: () {
                      addPropertyDetailsController.increment();
                    },
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize22, vertical: AppSize.appSize4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: addPropertyDetailsController.selectedButton.value == AppString.plusText
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                          width: AppSize.appSizePoint7,
                        ),
                      ),
                      child: Text(
                        AppString.plus,
                        style: AppStyle.heading4Regular(
                          color: addPropertyDetailsController.selectedButton.value == AppString.plusText
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.openParking,
                style: AppStyle.heading5Regular(color: AppColor.textColor),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      addPropertyDetailsController.decrementOpen();
                    },
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize22, vertical: AppSize.appSize4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: addPropertyDetailsController.selectedOpenButton.value == AppString.minusText
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                          width: AppSize.appSizePoint7,
                        ),
                      ),
                      child: Text(
                        AppString.minus,
                        style: AppStyle.heading4Regular(
                          color: addPropertyDetailsController.selectedOpenButton.value == AppString.minusText
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    )),
                  ),
                  Obx(() => SizedBox(
                    width: AppSize.appSize44,
                    child: Center(
                      child: Text(
                        '${addPropertyDetailsController.countOpen}',
                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                      ),
                    ),
                  )),
                  GestureDetector(
                    onTap: () {
                      addPropertyDetailsController.incrementOpen();
                    },
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize22, vertical: AppSize.appSize4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: addPropertyDetailsController.selectedOpenButton.value == AppString.plusText
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                          width: AppSize.appSizePoint7,
                        ),
                      ),
                      child: Text(
                        AppString.plus,
                        style: AppStyle.heading4Regular(
                          color: addPropertyDetailsController.selectedOpenButton.value == AppString.plusText
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.availabilityStatus,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(addPropertyDetailsController.availabilityStatusList.length, (index) {
                return GestureDetector(
                  onTap: () {
                    addPropertyDetailsController.updateStatus(index);
                  },
                  child: Obx(() => Container(
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: addPropertyDetailsController.selectStatus.value == index
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        addPropertyDetailsController.availabilityStatusList[index],
                        style: AppStyle.heading5Medium(
                          color: addPropertyDetailsController.selectStatus.value == index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ),
                  )),
                );
              }),
            ).paddingOnly(
              top: AppSize.appSize16,
              left: AppSize.appSize16, right: AppSize.appSize16,
            ),
          ),
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CommonButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addPhotosAndPricingView);
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
