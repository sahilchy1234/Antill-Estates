import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/add_review_for_broker_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class AddReviewsForBrokerView extends StatelessWidget {
  AddReviewsForBrokerView({super.key});

  final AddReviewForBrokerController addReviewForBrokerController = Get.put(AddReviewForBrokerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAddReviewsForBrokerFields(),
      bottomNavigationBar: buildButton(context),
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
        AppString.addReview,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAddReviewsForBrokerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSize.appSize16),
          decoration: BoxDecoration(
            color: AppColor.backgroundColor,
            borderRadius: BorderRadius.circular(AppSize.appSize16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColor.backgroundColor,
                backgroundImage: AssetImage(Assets.images.agents1.path),
                radius: AppSize.appSize22,
              ).paddingOnly(right: AppSize.appSize8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.claudeAnderson,
                    style: AppStyle.heading4Medium(color: AppColor.textColor),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Text(
                          AppString.buyer,
                          style: AppStyle.heading5Regular(
                              color: AppColor.descriptionColor),
                        ),
                        VerticalDivider(
                          color: AppColor.descriptionColor
                              .withValues(alpha:AppSize.appSizePoint4),
                          thickness: AppSize.appSizePoint7,
                          indent: AppSize.appSize2,
                          endIndent: AppSize.appSize2,
                        ),
                        Image.asset(
                          Assets.images.call.path,
                          width: AppSize.appSize14,
                          color: AppColor.descriptionColor,
                        ).paddingOnly(right: AppSize.appSize6),
                        Text(
                          AppString.claudeAndersonNumber,
                          style: AppStyle.heading5Regular(
                              color: AppColor.descriptionColor),
                        ),
                      ],
                    ),
                  ).paddingOnly(top: AppSize.appSize4),
                ],
              ),
            ],
          ),
        ),
        RatingBar(
          initialRating: AppSize.appSize3,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: AppSize.size5,
          ratingWidget: RatingWidget(
            full: Image.asset(Assets.images.ratingStar.path),
            half: Image.asset(Assets.images.ratingStar.path),
            empty: Image.asset(Assets.images.emptyRatingStar.path),
          ),
          glow: false,
          itemSize: AppSize.appSize30,
          itemPadding: const EdgeInsets.only(right: AppSize.appSize16),
          onRatingUpdate: (rating) {

          },
        ).paddingOnly(top: AppSize.appSize26),
        TextFormField(
          controller: addReviewForBrokerController.writeAReviewController,
          cursorColor: AppColor.primaryColor,
          style: AppStyle.heading4Regular(color: AppColor.textColor),
          maxLines: AppSize.size3,
          decoration: InputDecoration(
            hintText: AppString.writeAReviews,
            hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: const BorderSide(
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ).paddingOnly(top: AppSize.appSize26),
      ],
    ).paddingOnly(
      top: AppSize.appSize10,
      left: AppSize.appSize16,
      right: AppSize.appSize16,
    );
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CommonButton(
        onPressed: () {
          Get.back();
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          AppString.submitButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ).paddingOnly(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26, top: AppSize.appSize10,
      ),
    );
  }
}
