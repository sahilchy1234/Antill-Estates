import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_rich_text.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/drawer_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/text_segment_model.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/services/UserDataController.dart';
import 'package:antill_estates/views/profile/widgets/finding_us_helpful_bottom_sheet.dart';
import 'package:antill_estates/views/profile/widgets/logout_bottom_sheet.dart';
import 'package:antill_estates/common/cached_avatar_image.dart';
import '../../services/enhanced_loading_service.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

 SlideDrawerController get drawerController => Get.put(SlideDrawerController());

  UserDataController get controller => Get.find<UserDataController>();

  @override
  Widget build(BuildContext context) {
    return buildDrawer();
  }

  String getBuyerorSeller(){

    if(controller.isRealEstateAgent.value == false){
      return "buyer";
    }else{
      return "seller";
    }
  }

  Widget buildDrawer() {
    return Obx(() {
      if (drawerController.isLoading.value) {
        return EnhancedLoadingService.buildDrawerLoading();
      }
      
      return Drawer(
    backgroundColor: AppColor.whiteColor,
    width: AppSize.appSize285,
    elevation: AppSize.appSize0,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(AppSize.appSize12),
        bottomRight: Radius.circular(AppSize.appSize12),
      ),
      borderSide: BorderSide.none,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Obx(() {
              final imageUrl = controller.profileImagePath.value;

              return CachedAvatarImage(
                imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                radius: AppSize.appSize22,
                backgroundColor: AppColor.whiteColor,
                fallbackIcon: const Icon(Icons.person, size: 22),
              ).paddingOnly(right: AppSize.appSize14);
            }),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.fullName.value,
                    style: AppStyle.heading3Medium(color: AppColor.textColor),
                  ),
                  CommonRichText(
                    segments: [
                      TextSegment(
                        text: AppString.buyer,
                        style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                      ),
                      TextSegment(
                        text: AppString.lining,
                        style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                      ),
                      TextSegment(
                        text: AppString.manageProfile,
                        style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppRoutes.editProfileView);
                        },
                      ),
                    ],
                  ).paddingOnly(top: AppSize.appSize4),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Image.asset(
                Assets.images.close.path,
                width: AppSize.appSize24,
                height: AppSize.appSize24,
              ),
            )
          ],
        ).paddingOnly(
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),
        Divider(
          color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint3),
          height: AppSize.appSize0,
          thickness: AppSize.appSizePoint7,
        ).paddingOnly(top: AppSize.appSize26),
        Expanded(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(
              top: AppSize.appSize36, bottom: AppSize.appSize10,
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: AppSize.appSize16),
                itemCount: drawerController.drawerList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if(index == AppSize.size0) {
                        Get.back();
                        Get.toNamed(AppRoutes.notificationView);
                      } else if(index == AppSize.size1) {
                        Get.back();
                        Get.toNamed(AppRoutes.searchView);
                      }
                    },
                    child: Text(
                      drawerController.drawerList[index],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ).paddingOnly(bottom: AppSize.appSize26),
                  );
                },
              ),
              // Removed: Your Property Search section (recentActivity, viewedProperties, savedProperties, contactedProperties)
              Divider(
                color: AppColor.primaryColor.withValues(alpha:AppSize.appSizePoint50),
                height: AppSize.appSize0,
                thickness: AppSize.appSizePoint7,
              ).paddingOnly(top: AppSize.appSize10, bottom: AppSize.appSize36),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: AppSize.appSize16),
                itemCount: drawerController.drawer3List.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if(index == AppSize.size0) {
                        Get.back();
                      }
                      // Removed: agentsList and interestingReads functionality
                    },
                    child: Text(
                      drawerController.drawer3List[index],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ).paddingOnly(bottom: AppSize.appSize26),
                  );
                },
              ),
              Text(
                AppString.exploreProperties,
                style: AppStyle.heading6Bold(color: AppColor.primaryColor),
              ).paddingOnly(top: AppSize.appSize10, left: AppSize.appSize16),
              Divider(
                color: AppColor.primaryColor.withValues(alpha:AppSize.appSizePoint50),
                height: AppSize.appSize0,
                thickness: AppSize.appSizePoint7,
              ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.searchView);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSize.appSize16),
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.circular(AppSize.appSize6),
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                Assets.images.residential.path,
                                width: AppSize.appSize20,
                              ),
                            ),
                            Center(
                              child: Text(
                                AppString.residentialProperties,
                                textAlign: TextAlign.center,
                                style: AppStyle.heading5Medium(color: AppColor.textColor),
                              ),
                            ).paddingOnly(top: AppSize.appSize6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.appSize6),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSize.appSize16),
                      decoration: BoxDecoration(
                        color: AppColor.secondaryColor,
                        borderRadius: BorderRadius.circular(AppSize.appSize6),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Image.asset(
                              Assets.images.buildings.path,
                              width: AppSize.appSize20,
                            ),
                          ),
                          Center(
                            child: Text(
                              AppString.commercialProperties,
                              textAlign: TextAlign.center,
                              style: AppStyle.heading5Medium(color: AppColor.textColor),
                            ),
                          ).paddingOnly(top: AppSize.appSize6),
                        ],
                      ),
                    ),
                  ),
                ],
              ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: AppSize.appSize16, top: AppSize.appSize36,
                ),
                itemCount: drawerController.drawer4List.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if(index == AppSize.size0) {
                        Get.back();
                        Get.toNamed(AppRoutes.termsOfUseView);
                      } else if(index == AppSize.size1) {
                        Get.back();
                        Get.toNamed(AppRoutes.feedbackView);
                      } else if(index == AppSize.size2) {
                        Get.back();
                        findingUsHelpfulBottomSheet(context);
                      } else if(index == AppSize.size3) {
                        Get.back();
                        logoutBottomSheet(context);
                      }
                    },
                    child: Text(
                      drawerController.drawer4List[index],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ).paddingOnly(bottom: AppSize.appSize26),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ).paddingOnly(top: AppSize.appSize60),
  );
    });
  }
}
