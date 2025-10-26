import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class LeadDetailsView extends StatelessWidget {
  const LeadDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildLeadsDetails(context),
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
        AppString.leadDetails,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildLeadsDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSize.appSize16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize16),
            border: Border.all(
              color: AppColor.descriptionColor,
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
                        Assets.images.response2.path,
                        width: AppSize.appSize30,
                      ).paddingOnly(right: AppSize.appSize6),
                      Text(
                        AppString.claudeAnderson,
                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                      ),
                    ],
                  ),
                  Text(
                    AppString.today,
                    style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset(
                    Assets.images.call.path,
                    width: AppSize.appSize20,
                  ).paddingOnly(right: AppSize.appSize6),
                  Text(
                    AppString.number1,
                    style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                  ),
                ],
              ).paddingOnly(top: AppSize.appSize16),
              Row(
                children: [
                  Image.asset(
                    Assets.images.email.path,
                    width: AppSize.appSize20,
                  ).paddingOnly(right: AppSize.appSize6),
                  Text(
                    AppString.rudraEmail,
                    style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                  ),
                ],
              ).paddingOnly(top: AppSize.appSize10),
              Divider(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                height: AppSize.appSize0,
                thickness: AppSize.appSizePoint7,
              ).paddingSymmetric(vertical: AppSize.appSize16),
              Row(
                children: [
                  Text(
                    AppString.leadScore4Point5,
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ).paddingOnly(right: AppSize.appSize6),
                  Image.asset(
                    Assets.images.star.path,
                    width: AppSize.appSize12,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(AppSize.appSize16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize16),
            color: AppColor.backgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppString.focusedOn,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Text(
                AppString.semiModernHouse,
                style: AppStyle.heading5SemiBold(color: AppColor.textColor),
              ).paddingOnly(top: AppSize.appSize16),
              Row(
                children: [
                  Image.asset(
                    Assets.images.locationPin.path,
                    width: AppSize.appSize18,
                  ).paddingOnly(right: AppSize.appSize6),
                  Expanded(
                    child: Text(
                      AppString.templeSquare,
                      style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    ),
                  ),
                ],
              ).paddingOnly(top: AppSize.appSize10),
              Divider(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                height: AppSize.appSize0,
                thickness: AppSize.appSizePoint7,
              ).paddingSymmetric(vertical: AppSize.appSize16),
              Text(
                AppString.rupee50Lakh,
                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
              ),
            ],
          ),
        ).paddingOnly(top: AppSize.appSize26),
        Text(
          AppString.activityDetails,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(top: AppSize.appSize26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppString.numberOfInterestSent,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
            Text(
              AppString.na,
              style: AppStyle.heading5Medium(color: AppColor.textColor),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppString.numberOfViews,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
            Text(
              AppString.views252,
              style: AppStyle.heading5Medium(color: AppColor.textColor),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize16),
        Divider(
          color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
          height: AppSize.appSize0,
          thickness: AppSize.appSizePoint7,
        ).paddingSymmetric(vertical: AppSize.appSize16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppString.planningToBuyWithin,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
            Text(
              AppString.na,
              style: AppStyle.heading5Medium(color: AppColor.textColor),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppString.interestedInSiteVisit,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
            Text(
              AppString.na,
              style: AppStyle.heading5Medium(color: AppColor.textColor),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize16),
      ],
    ).paddingOnly(
      top: AppSize.appSize10,
      left: AppSize.appSize16, right: AppSize.appSize16,
    );
  }
}
