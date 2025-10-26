import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

deleteAccountBottomSheet(BuildContext context) {
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
        height: AppSize.appSize355,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
          bottom: AppSize.appSize20,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppString.deleteAccount,
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
                Text(
                  AppString.deleteAccountString,
                  style: AppStyle.heading4Regular(color: AppColor.textColor),
                ).paddingOnly(top: AppSize.appSize16),
                customRow(AppString.deleteAccountString1),
                customRow(AppString.deleteAccountString2),
                customRow(AppString.deleteAccountString3),
              ],
            ),
            CommonButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.registerView);
              },
              backgroundColor: AppColor.primaryColor,
              child: Text(
                AppString.continueToDeleteButton,
                style: AppStyle.heading5Medium(color: AppColor.whiteColor),
              ),
            ).paddingOnly(bottom: AppSize.appSize10),
          ],
        ),
      );
    },
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
          right: AppSize.appSize12,
          top: AppSize.appSize8,
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
  ).paddingOnly(top: AppSize.appSize16);
}
