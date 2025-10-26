import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/furnishing_details_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class FurnishingDetailsView extends StatelessWidget {
  FurnishingDetailsView({super.key});

 final FurnishingDetailsController furnishingDetailsController = Get.put(FurnishingDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildFurnishingDetails(),
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
        AppString.furnishingDetails,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildFurnishingDetails() {
    return Column(
      children: [
        Row(
          children: [
            _reusableContainer(Assets.images.fan.path, AppString.fan),
            const SizedBox(width: AppSize.appSize16),
            _reusableContainer(Assets.images.lights.path, AppString.lights),
            const SizedBox(width: AppSize.appSize16),
            _reusableContainer(Assets.images.bedSheet.path, AppString.sofa),
          ],
        ),
        Row(
          children: [
            _reusableContainer(Assets.images.solarPanel.path, AppString.internetWifiConnectivity),
            const SizedBox(width: AppSize.appSize16),
            Container(
              padding: const EdgeInsets.all(AppSize.appSize14),
              decoration: BoxDecoration(
                color: AppColor.backgroundColor,
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.images.stove.path,
                    width: AppSize.appSize18,
                  ).paddingOnly(right: AppSize.appSize6),
                  Text(
                    AppString.stove,
                    style: AppStyle.heading6Regular(color: AppColor.textColor),
                  ),
                ],
              ),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize16),
        Row(
          children: [
            _reusableContainer(Assets.images.wardrobe.path, AppString.wardrobe),
            const SizedBox(width: AppSize.appSize16),
            _reusableContainer(Assets.images.waterPurifier.path, AppString.waterPurifier),
          ],
        ).paddingOnly(top: AppSize.appSize16),
        Row(
          children: [
            _reusableContainer(Assets.images.solarPanel.path, AppString.solarPanel),
            const SizedBox(width: AppSize.appSize16),
            _reusableContainer(Assets.images.solarPanel.path, AppString.geyser2),
          ],
        ).paddingOnly(top: AppSize.appSize16),
      ],
    ).paddingOnly(
      top: AppSize.appSize10,
      left: AppSize.appSize16, right: AppSize.appSize16,
    );
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () {
        furnishingDetailsController.launchDialer();
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

  _reusableContainer(String image, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSize.appSize14),
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(AppSize.appSize12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: AppSize.appSize18,
            ).paddingOnly(right: AppSize.appSize6),
            Text(
              text,
              style: AppStyle.heading6Regular(color: AppColor.textColor),
            ),
          ],
        ),
      ),
    );
  }
}
