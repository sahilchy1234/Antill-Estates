import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAboutUs(),
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
        AppString.aboutUs,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAboutUs() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.aboutUsString1,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
          Text(
            AppString.ourMission,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.ourMissionString,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.whatWeOffer,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.whatWeOfferString1,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.whatWeOfferString2,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
          Text(
            AppString.advanceSearch,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.advanceSearchString,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.interactiveMaps,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.interactiveMapsString,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.personalizedRecommendations,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.personalizedRecommendationsString1,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(top: AppSize.appSize20),
          Text(
            AppString.personalizedRecommendationsString2,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
          Text(
            AppString.personalizedRecommendationsString3,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
    );
  }
}
