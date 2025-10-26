import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/bottom_bar_controller.dart';
import 'package:antill_estates/controller/contact_owner_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';

class ContactOwnerView extends StatelessWidget {
  ContactOwnerView({super.key});

 final ContactOwnerController contactOwnerController = Get.put(ContactOwnerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildContactOwner(),
      bottomNavigationBar: buildButton(),
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
        AppString.contactOwner,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
      actions: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.searchView);
              },
              child: Image.asset(
                Assets.images.search.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.back();
                Get.back();
                Get.back();
                Future.delayed(const Duration(milliseconds: AppSize.size400), () {
                  BottomBarController bottomBarController = Get.put(BottomBarController());
                  bottomBarController.pageController.jumpToPage(AppSize.size3);
                },);
              },
              child: Image.asset(
                Assets.images.save.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            GestureDetector(
              onTap: () {
                SharePlus.instance.share(
                  ShareParams(
                    text: AppString.appName,
                  ),
                );
              },
              child: Image.asset(
                Assets.images.share.path,
                width: AppSize.appSize24,
              ),
            ),
          ],
        ).paddingOnly(right: AppSize.appSize16),
      ],
    );
  }

  Widget buildContactOwner() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Container(
            padding: const EdgeInsets.all(AppSize.appSize10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                width: AppSize.appSizePoint7,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSize.appSize10),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Row(
                    children: [
                      // Owner Avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSize.appSize32),
                        child: contactOwnerController.ownerAvatar.value.isNotEmpty
                            ? Image.network(
                                contactOwnerController.ownerAvatar.value,
                                width: AppSize.appSize64,
                                height: AppSize.appSize64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    Assets.images.response1.path,
                                    width: AppSize.appSize64,
                                    height: AppSize.appSize64,
                                  );
                                },
                              )
                            : Image.asset(
                                Assets.images.response1.path,
                                width: AppSize.appSize64,
                                height: AppSize.appSize64,
                              ),
                      ).paddingOnly(right: AppSize.appSize12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contactOwnerController.ownerName.value.isNotEmpty
                                  ? contactOwnerController.ownerName.value
                                  : AppString.rudraProperties,
                              style: AppStyle.heading4Medium(color: AppColor.textColor),
                            ),
                            Text(
                              AppString.broker,
                              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                            ).paddingOnly(top: AppSize.appSize4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Image.asset(
                      Assets.images.user.path,
                      width: AppSize.appSize20,
                      color: AppColor.primaryColor,
                    ),
                    Text(
                      contactOwnerController.ownerName.value.isNotEmpty
                          ? contactOwnerController.ownerName.value
                          : AppString.lorraineHermann,
                      style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                    ).paddingOnly(left: AppSize.appSize10),
                  ],
                ).paddingOnly(top: AppSize.appSize12),
                Row(
                  children: [
                    Image.asset(
                      Assets.images.call.path,
                      width: AppSize.appSize20,
                      color: AppColor.primaryColor,
                    ),
                    Text(
                      contactOwnerController.ownerPhone.value.isNotEmpty
                          ? contactOwnerController.ownerPhone.value
                          : AppString.lorraineHermannNumber,
                      style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                    ).paddingOnly(left: AppSize.appSize10),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
                Row(
                  children: [
                    Image.asset(
                      Assets.images.email.path,
                      width: AppSize.appSize20,
                      color: AppColor.primaryColor,
                    ),
                    Text(
                      contactOwnerController.ownerEmail.value.isNotEmpty
                          ? contactOwnerController.ownerEmail.value
                          : 'contact@luxuryrealestate.com',
                      style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                    ).paddingOnly(left: AppSize.appSize10),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
              ],
            ),
          )).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Row(
            children: [
              Image.asset(
                Assets.images.checked.path,
                width: AppSize.appSize16,
              ),
              Text(
                AppString.yourRequestHasBeenSharedWithinBroker,
                style: AppStyle.heading5Regular(color: AppColor.primaryColor),
              ).paddingOnly(left: AppSize.appSize6),
            ],
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.similarProperties,
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Obx(() {
            if (contactOwnerController.isLoadingSimilarProperties.value) {
              return Container(
                height: AppSize.appSize372,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ).paddingOnly(top: AppSize.appSize16);
            }

            if (contactOwnerController.similarProperties.isEmpty) {
              return Container(
                height: AppSize.appSize200,
                child: Center(
                  child: Text(
                    'No similar properties found',
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ),
                ),
              ).paddingOnly(top: AppSize.appSize16);
            }

            return SizedBox(
              height: AppSize.appSize372,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(left: AppSize.appSize16),
                itemCount: contactOwnerController.similarProperties.length,
                itemBuilder: (context, index) {
                  final property = contactOwnerController.similarProperties[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to property details
                      if (property.id != null) {
                        Get.toNamed(AppRoutes.propertyDetailsView, arguments: property.id);
                      } else {
                        Get.snackbar(
                          'Error',
                          'Property ID not available. Cannot view details.',
                          backgroundColor: AppColor.negativeColor,
                          colorText: AppColor.whiteColor,
                        );
                      }
                    },
                    child: Container(
                      width: AppSize.appSize300,
                      padding: const EdgeInsets.all(AppSize.appSize10),
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      decoration: BoxDecoration(
                        color: AppColor.secondaryColor,
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: AppSize.appSize200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSize.appSize8),
                                  image: property.propertyPhotos.isNotEmpty
                                      ? (property.propertyPhotos[0].startsWith('http')
                                          ? DecorationImage(
                                              image: NetworkImage(property.propertyPhotos[0]),
                                              fit: BoxFit.cover,
                                            )
                                          : DecorationImage(
                                              image: AssetImage(property.propertyPhotos[0]),
                                              fit: BoxFit.cover,
                                            ))
                                      : DecorationImage(
                                          image: AssetImage(Assets.images.similarProperty1.path),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                right: AppSize.appSize6,
                                top: AppSize.appSize6,
                                child: GestureDetector(
                                  onTap: () {
                                    contactOwnerController.isSimilarPropertyLiked[index] =
                                    !contactOwnerController.isSimilarPropertyLiked[index];
                                  },
                                  child: Container(
                                    width: AppSize.appSize32,
                                    height: AppSize.appSize32,
                                    decoration: BoxDecoration(
                                      color: AppColor.whiteColor.withValues(alpha:AppSize.appSizePoint50),
                                      borderRadius: BorderRadius.circular(AppSize.appSize6),
                                    ),
                                    child: Center(
                                      child: Obx(() => Image.asset(
                                        contactOwnerController.isSimilarPropertyLiked[index]
                                            ? Assets.images.saved.path
                                            : Assets.images.save.path,
                                        width: AppSize.appSize24,
                                      )),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${property.noOfBedrooms} BHK ${property.propertyType}',
                                style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                              ),
                              Text(
                                '${property.locality}, ${property.city}',
                                style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                              ).paddingOnly(top: AppSize.appSize6),
                            ],
                          ).paddingOnly(top: AppSize.appSize8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                property.expectedPrice,
                                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '4.5',
                                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                                  ).paddingOnly(right: AppSize.appSize6),
                                  Image.asset(
                                    Assets.images.star.path,
                                    width: AppSize.appSize18,
                                  ),
                                ],
                              ),
                            ],
                          ).paddingOnly(top: AppSize.appSize6),
                          Divider(
                            color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint3),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSize.appSize6, 
                                  horizontal: AppSize.appSize16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                                  border: Border.all(
                                    color: AppColor.primaryColor,
                                    width: AppSize.appSizePoint50,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      Assets.images.bed.path,
                                      width: AppSize.appSize18,
                                      height: AppSize.appSize18,
                                    ).paddingOnly(right: AppSize.appSize6),
                                    Text(
                                      '${property.noOfBedrooms} BHK',
                                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSize.appSize6, 
                                  horizontal: AppSize.appSize16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                                  border: Border.all(
                                    color: AppColor.primaryColor,
                                    width: AppSize.appSizePoint50,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      Assets.images.bath.path,
                                      width: AppSize.appSize18,
                                      height: AppSize.appSize18,
                                    ).paddingOnly(right: AppSize.appSize6),
                                    Text(
                                      '${property.noOfBathrooms} Bath',
                                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).paddingOnly(top: AppSize.appSize16);
          }),
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () {
        contactOwnerController.launchDialer();
      },
      backgroundColor: AppColor.primaryColor,
      child: Text(
        AppString.callOwnerButton,
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26
    );
  }
}
