import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildPrivacyPolicy(),
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
        AppString.privacyPolicy,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildPrivacyPolicy() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.privacyPolicyString1,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
          Text(
            AppString.privacyPolicyString2,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
          Text(
            AppString.privacyPolicyString3,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
          Text(
            AppString.informationYouProvide,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize20, bottom: AppSize.appSize20),
          customRow(AppString.informationYouProvideString1),
          customRow(AppString.informationYouProvideString2),
          customRow(AppString.informationYouProvideString3),
          Text(
            AppString.informationCollected,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize20, bottom: AppSize.appSize20),
          customRow(AppString.informationCollectedString1),
          customRow(AppString.informationCollectedString2),
          customRow(AppString.informationCollectedString3),
          Text(
            AppString.howUseInformation,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize20, bottom: AppSize.appSize20),
          Text(
            AppString.howUseInformationString,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(bottom: AppSize.appSize20),
          customRow(AppString.howUseInformationString1),
          customRow(AppString.howUseInformationString2),
          customRow(AppString.howUseInformationString3),
          customRow(AppString.howUseInformationString4),
          customRow(AppString.howUseInformationString5),
          customRow(AppString.howUseInformationString6),
          customRow(AppString.howUseInformationString7),
          customRow(AppString.howUseInformationString8),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
    );
  }

  customRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSize.appSize5,
          height: AppSize.appSize5,
          margin: const EdgeInsets.only(
            right: AppSize.appSize12, top: AppSize.appSize8,
            left: AppSize.appSize12,
          ),
          decoration: const BoxDecoration(
            color: AppColor.descriptionColor,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
        ),
      ],
    );
  }
}
