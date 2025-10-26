import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

managePropertyBottomSheet(BuildContext context) {
  showModalBottomSheet(
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
        height: AppSize.appSize315,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppString.manageProperty,
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
              children: [
                Container(
                  width: AppSize.appSize70,
                  height: AppSize.appSize70,
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize6),
                    image: DecorationImage(
                      image: AssetImage(Assets.images.property1.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        AppString.sellFlat,
                        style: AppStyle.heading5SemiBold(
                            color: AppColor.textColor),
                      ),
                      Text(
                        AppString.northBombaySociety,
                        style: AppStyle.heading5Regular(
                            color: AppColor.descriptionColor),
                      ).paddingOnly(top: AppSize.appSize6),
                    ],
                  ),
                ),
              ],
            ).paddingOnly(top: AppSize.appSize26),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.showPropertyDetailsView);
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppString.preview,
                          style: AppStyle.heading4Medium(
                              color: AppColor.textColor),
                        ),
                        Image.asset(
                          Assets.images.arrowRight.path,
                          width: AppSize.appSize20,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint3),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize15, bottom: AppSize.appSize15),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.editPropertyView);
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppString.editDetails,
                          style:
                              AppStyle.heading4Medium(color: AppColor.textColor),
                        ),
                        Image.asset(
                          Assets.images.arrowRight.path,
                          width: AppSize.appSize20,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint3),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize15, bottom: AppSize.appSize15),
                // Disabled: Delete Property functionality
                // GestureDetector(
                //   onTap: () {
                //     Get.back();
                //     Get.toNamed(AppRoutes.deleteListingView);
                //   },
                //   child: Container(
                //     width: double.infinity,
                //     color: Colors.transparent,
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           AppString.deleteProperty,
                //           style:
                //               AppStyle.heading4Medium(color: AppColor.textColor),
                //         ),
                //         Image.asset(
                //           Assets.images.arrowRight.path,
                //           width: AppSize.appSize20,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ).paddingOnly(top: AppSize.appSize26),
          ],
        ),
      ).paddingOnly(bottom: MediaQuery.of(context).viewInsets.bottom);
    },
  );
}
