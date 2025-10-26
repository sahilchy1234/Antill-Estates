import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/delete_listing_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class DeleteListingView extends StatelessWidget {
  DeleteListingView({super.key});

  final DeleteListingController deleteListingController = Get.put(DeleteListingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildDeleteListingList(),
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
        AppString.deleteListing,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildDeleteListingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AppSize.appSize12,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
      itemCount: deleteListingController.listingList.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                deleteListingController.updateListing(index);
              },
              child: Obx(() {
                return SizedBox(
                  child: Row(
                    children: [
                      Container(
                        width: AppSize.appSize20,
                        height: AppSize.appSize20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.textColor,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: deleteListingController.selectListing.value == index ? Center(
                          child: Container(
                            width: AppSize.appSize12,
                            height: AppSize.appSize12,
                            decoration: const BoxDecoration(
                              color: AppColor.textColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ) : const SizedBox.shrink(),
                      ),
                      Text(
                        deleteListingController.listingList[index],
                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                      ).paddingOnly(left: AppSize.appSize10),
                    ],
                  ),
                );
              }),
            ),
            if(index < deleteListingController.listingList.length - AppSize.size1)...[
              Divider(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                thickness: AppSize.appSizePoint7,
                height: AppSize.appSize0,
              ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize26),
            ],
          ],
        );
      },
    );
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () {
        Get.back();
      },
      backgroundColor: AppColor.primaryColor,
      child: Text(
        AppString.deleteButton,
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
      left: AppSize.appSize16, right: AppSize.appSize16,
      bottom: AppSize.appSize26, top: AppSize.appSize10,
    );
  }
}
