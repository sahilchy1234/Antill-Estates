import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/community_settings_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class CommunitySettingsView extends StatelessWidget {
  CommunitySettingsView({super.key});

  final CommunitySettingsController communitySettingsController = Get.put(CommunitySettingsController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildCommunitySettings(),
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
        AppString.communicationSettings,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildCommunitySettings() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppString.receivePromotional,
                  style: AppStyle.heading5Regular(color: AppColor.textColor),
                ),
              ),
              customSwitch(communitySettingsController.isSwitch1),
            ],
          ),
          Divider(
            color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize26),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppString.receivePushNotification,
                  style: AppStyle.heading5Regular(color: AppColor.textColor),
                ),
              ),
              customSwitch(communitySettingsController.isSwitch2),
            ],
          ),
          Divider(
            color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize26),
        ],
      );
    }).paddingOnly(
      top: AppSize.appSize10,
      left: AppSize.appSize16, right: AppSize.appSize16,
    );
  }

  customSwitch(RxBool switchValue) {
    return GestureDetector(
      onTap: () => switchValue.toggle(),
      child: Stack(
        alignment:
        switchValue.value ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          Container(
            alignment: Alignment.center,
            height: AppSize.appSize14Point78,
            width: AppSize.appSize35Point98,
            decoration: BoxDecoration(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                borderRadius: BorderRadius.circular(AppSize.appSize10)),
          ),
          Container(
            alignment: Alignment.center,
            height: AppSize.appSize21Point11,
            width: AppSize.appSize21Point11,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: switchValue.value
                    ? AppColor.primaryColor
                    : AppColor.descriptionColor),
          )
        ],
      ),
    ).paddingOnly(left: AppSize.appSize10);
  }
}
