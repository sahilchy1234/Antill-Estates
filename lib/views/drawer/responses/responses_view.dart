import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/responses_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

class ResponsesView extends StatelessWidget {
  ResponsesView({super.key});

 final ResponsesController responsesController = Get.put(ResponsesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildResponsesList(),
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
        AppString.responses,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildResponsesList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
      itemCount: responsesController.responseImageList.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(AppSize.appSize16),
          decoration: BoxDecoration(
            color: AppColor.backgroundColor,
            borderRadius: BorderRadius.circular(AppSize.appSize16),
            border: Border.all(
              color: AppColor.border2Color,
              width: AppSize.appSizePoint7,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        responsesController.responseImageList[index],
                        width: AppSize.appSize30,
                      ).paddingOnly(right: AppSize.appSize6),
                      Text(
                        responsesController.responseNameList[index],
                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                      ),
                    ],
                  ),
                  Text(
                    responsesController.responseTimingList[index],
                    style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    responsesController.responseLeadingScoreList[index],
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ).paddingOnly(right: AppSize.appSize6),
                  Image.asset(
                    Assets.images.star.path,
                    width: AppSize.appSize12,
                  ),
                ],
              ).paddingOnly(top: AppSize.appSize6),
              Divider(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                height: AppSize.appSize0,
                thickness: AppSize.appSizePoint7,
              ).paddingSymmetric(vertical: AppSize.appSize16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        responsesController.responseAddressList[index],
                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize6),
                      Text(
                        responsesController.responseAddress2List[index],
                        style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                      ),
                    ],
                  ),
                  Text(
                    responsesController.responseRupeesList[index],
                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                ],
              ),
              Divider(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                height: AppSize.appSize0,
                thickness: AppSize.appSizePoint7,
              ).paddingSymmetric(vertical: AppSize.appSize16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.leadDetailsView);
                  },
                  child: Text(
                    AppString.viewLeadDetails,
                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ).paddingOnly(bottom: AppSize.appSize26);
      },
    );
  }
}
