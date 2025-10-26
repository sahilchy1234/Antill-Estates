import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/activity_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

listingStatesBottomSheet(BuildContext context) {
  ActivityController activityController = Get.put(ActivityController());
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
        height: AppSize.appSize315,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26, bottom: AppSize.appSize26,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppString.listingStates,
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
                ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: AppSize.appSize26),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activityController.listingStatesList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        activityController.updateListing(index);
                        activityController.selectListing.value = index;
                      },
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Obx(() => Container(
                              width: AppSize.appSize20,
                              height: AppSize.appSize20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.textColor,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: activityController.selectListing.value == index ? Center(
                                child: Container(
                                  width: AppSize.appSize12,
                                  height: AppSize.appSize12,
                                  decoration: const BoxDecoration(
                                    color: AppColor.textColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ) : const SizedBox.shrink(),
                            )).paddingOnly(right: AppSize.appSize10),
                            Text(
                              activityController.listingStatesList[index],
                              style: AppStyle.heading5Regular(color: AppColor.textColor),
                            ),
                            if(index == AppSize.size0)...[
                              Text(
                                AppString.defaultText,
                                style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                              ),
                            ],
                          ],
                        ).paddingOnly(bottom: AppSize.appSize16),
                      ),
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if(activityController.selectListing.value == AppSize.size2) {
                        activityController.deleteShowing.value = true;
                      }
                      Get.back();
                    },
                    child: Container(
                      height: AppSize.appSize49,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                      ),
                      child: Center(
                        child: Text(
                          AppString.seePropertyButton,
                          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.appSize26),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: AppSize.appSize49,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColor.primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                      ),
                      child: Center(
                        child: Text(
                          AppString.cancelButton,
                          style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
