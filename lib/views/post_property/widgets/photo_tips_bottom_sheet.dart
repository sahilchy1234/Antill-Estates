import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/gen/assets.gen.dart';
photoTipsBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSize.appSize12),
        topRight: Radius.circular(AppSize.appSize12),
      ),
      borderSide: BorderSide.none,
    ),
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: AppSize.appSize250,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppString.photosTips,
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Image.asset(
                    Assets.images.close.path,
                    width: AppSize.appSize24,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSize.appSize5,
                  height: AppSize.appSize5,
                  margin: const EdgeInsets.only(top: AppSize.appSize7),
                  decoration: const BoxDecoration(
                    color: AppColor.descriptionColor,
                    shape: BoxShape.circle,
                  ),
                ).paddingOnly(right: AppSize.appSize10),
                Expanded(
                  child: Text(
                    AppString.photoTips1,
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ),
                ),
              ],
            ).paddingOnly(top: AppSize.appSize16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSize.appSize5,
                  height: AppSize.appSize5,
                  margin: const EdgeInsets.only(top: AppSize.appSize7),
                  decoration: const BoxDecoration(
                    color: AppColor.descriptionColor,
                    shape: BoxShape.circle,
                  ),
                ).paddingOnly(right: AppSize.appSize10),
                Expanded(
                  child: Text(
                    AppString.photoTips2,
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ),
                ),
              ],
            ).paddingOnly(top: AppSize.appSize16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSize.appSize5,
                  height: AppSize.appSize5,
                  margin: const EdgeInsets.only(top: AppSize.appSize7),
                  decoration: const BoxDecoration(
                    color: AppColor.descriptionColor,
                    shape: BoxShape.circle,
                  ),
                ).paddingOnly(right: AppSize.appSize10),
                Expanded(
                  child: Text(
                    AppString.photoTips3,
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ),
                ),
              ],
            ).paddingOnly(top: AppSize.appSize16),
          ],
        ),
      );
    },
  );
}
