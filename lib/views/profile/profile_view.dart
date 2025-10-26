import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/bottom_bar_controller.dart';
import 'package:antill_estates/controller/profile_controller.dart';
import 'package:antill_estates/controller/translation_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/views/profile/widgets/delete_account_bottom_sheet.dart';
import 'package:antill_estates/views/profile/widgets/finding_us_helpful_bottom_sheet.dart';
import 'package:antill_estates/views/profile/widgets/logout_bottom_sheet.dart';
import 'package:antill_estates/common/cached_avatar_image.dart';

import '../../services/UserDataController.dart';


UserDataController controller = Get.find<UserDataController>();


class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  
 ProfileController get profileController => Get.put(ProfileController());
 TranslationController get translationController => Get.put(TranslationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildProfile(),
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
            BottomBarController bottomBarController = Get.find<BottomBarController>();
            bottomBarController.updateIndex(0);
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Obx(() => Text(
        translationController.translate(AppString.profile),
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      )),
    );
  }

  Widget buildProfile() {
    return Obx(() {
      // Add loading state check here if needed
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Obx(() {
                  final imageUrl = controller.profileImagePath.value;

                  return CachedAvatarImage(
                    imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                    radius: AppSize.appSize34,
                    backgroundColor: AppColor.whiteColor,
                    fallbackIcon: const Icon(Icons.person, size: 34),
                  ).paddingOnly(right: AppSize.appSize16);
                }),
                Obx(() => Text(
                  translationController.translate(controller.fullName.value),
                  style: AppStyle.heading3Medium(color: AppColor.textColor),
                )),
              ],
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.editProfileView);
              },
              child: Obx(() => Text(
                translationController.translate(AppString.editProfile),
                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
              )),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: AppSize.appSize36),
          itemCount: profileController.profileOptionImageList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if(index == AppSize.size0) {
                  Get.toNamed(AppRoutes.feedbackView);
                } else if(index == AppSize.size1) {
                  findingUsHelpfulBottomSheet(context);
                } else if(index == AppSize.size2) {
                  logoutBottomSheet(context);
                } else if(index == AppSize.size3) {
                  deleteAccountBottomSheet(context);
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        profileController.profileOptionImageList[index],
                        width: AppSize.appSize20,
                      ).paddingOnly(right: AppSize.appSize12),
                      Obx(() => Text(
                        translationController.translate(profileController.profileOptionTitleList[index]),
                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                      )),
                    ],
                  ),
                  if(index < profileController.profileOptionImageList.length - AppSize.size1)...[
                    Divider(
                      color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                      height: AppSize.appSize0,
                      thickness: AppSize.appSizePoint7,
                    ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize26),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    ).paddingOnly(
      top: AppSize.appSize10,
      left: AppSize.appSize16, right: AppSize.appSize16,
    );
    });
  }
}
