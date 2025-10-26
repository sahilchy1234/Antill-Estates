import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/agent_details_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

class AgentsDetailsView extends StatelessWidget {
  AgentsDetailsView({super.key});

  final AgentDetailsController agentDetailsController = Get.put(AgentDetailsController());

  @override
  Widget build(BuildContext context) {
    agentDetailsController.isSimilarPropertyLiked.value = List<bool>.generate(
        agentDetailsController.searchImageList.length, (index) => false);
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAgentDetails(),
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
        AppString.claudeAnderson,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAgentDetails() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(AppSize.appSize16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColor.backgroundColor,
                      backgroundImage: AssetImage(Assets.images.agents1.path),
                      radius: AppSize.appSize18,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      AppString.claudeAnderson,
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      AppString.leadScore45,
                      style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    ).paddingOnly(right: AppSize.appSize4),
                    Image.asset(
                      Assets.images.star.path,
                      width: AppSize.appSize12,
                    ),
                  ],
                ).paddingOnly(top: AppSize.appSize6),
                Divider(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                  thickness: AppSize.appSizePoint7,
                  height: AppSize.appSize0,
                ).paddingSymmetric(vertical: AppSize.appSize16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          Assets.images.call.path,
                          width: AppSize.appSize18,
                        ).paddingOnly(right: AppSize.appSize6),
                        Text(
                          AppString.claudeAndersonNumber,
                          style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          Assets.images.email.path,
                          width: AppSize.appSize18,
                        ).paddingOnly(right: AppSize.appSize6),
                        Text(
                          AppString.rudraEmail,
                          style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      Assets.images.locationPin.path,
                      width: AppSize.appSize20,
                    ).paddingOnly(right: AppSize.appSize6),
                    Expanded(
                      child: Text(
                        AppString.blancaBranch,
                        style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                      ),
                    ),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
                Divider(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                  thickness: AppSize.appSizePoint7,
                  height: AppSize.appSize0,
                ).paddingSymmetric(vertical: AppSize.appSize16),
                Text(
                  AppString.aboutUs,
                  style: AppStyle.heading6Regular(color: AppColor.textColor),
                ),
                Text(
                  AppString.aboutUsString,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.propertiesListed3,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
              Text(
                AppString.viewAll,
                style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize372,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: agentDetailsController.searchImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  width: AppSize.appSize300,
                  padding: const EdgeInsets.all(AppSize.appSize10),
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            agentDetailsController.searchImageList[index],
                            height: AppSize.appSize200,
                          ),
                          Positioned(
                            right: AppSize.appSize6,
                            top: AppSize.appSize6,
                            child: GestureDetector(
                              onTap: () {
                                agentDetailsController.isSimilarPropertyLiked[index] =
                                !agentDetailsController.isSimilarPropertyLiked[index];
                              },
                              child: Container(
                                width: AppSize.appSize32,
                                height: AppSize.appSize32,
                                decoration: BoxDecoration(
                                  color: AppColor.whiteColor.withValues(alpha:AppSize.appSizePoint50),
                                  borderRadius: BorderRadius.circular(AppSize.appSize6),
                                ),
                                child: Center(
                                  child: Obx(() => Image.asset(
                                    agentDetailsController.isSimilarPropertyLiked[index]
                                        ? Assets.images.saved.path
                                        : Assets.images.save.path,
                                    width: AppSize.appSize24,
                                  )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agentDetailsController.searchTitleList[index],
                            style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                          ),
                          Text(
                            agentDetailsController.searchAddressList[index],
                            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                          ).paddingOnly(top: AppSize.appSize6),
                        ],
                      ).paddingOnly(top: AppSize.appSize8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            agentDetailsController.searchRupeesList[index],
                            style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                          ),
                          Row(
                            children: [
                              Text(
                                agentDetailsController.searchRatingList[index],
                                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                              ).paddingOnly(right: AppSize.appSize6),
                              Image.asset(
                                Assets.images.star.path,
                                width: AppSize.appSize18,
                              ),
                            ],
                          ),
                        ],
                      ).paddingOnly(top: AppSize.appSize6),
                      Divider(
                        color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint3),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(agentDetailsController.searchPropertyImageList.length, (index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSize.appSize6, horizontal: AppSize.appSize16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSize.appSize12),
                              border: Border.all(
                                color: AppColor.primaryColor,
                                width: AppSize.appSizePoint50,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  agentDetailsController.searchPropertyImageList[index],
                                  width: AppSize.appSize18,
                                  height: AppSize.appSize18,
                                ).paddingOnly(right: AppSize.appSize6),
                                Text(
                                  agentDetailsController.searchPropertyTitleList[index],
                                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.reviews,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.addReviewsForBrokerView);
                },
                child: Text(
                  AppString.addReviews,
                  style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: agentDetailsController.reviewRatingImageList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSize.appSize16),
                padding: const EdgeInsets.all(AppSize.appSize16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize16),
                  border: Border.all(
                    color: AppColor.descriptionColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          agentDetailsController.reviewDateList[index],
                          style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                        ),
                        Image.asset(
                          agentDetailsController.reviewRatingImageList[index],
                          width: AppSize.appSize122,
                          height: AppSize.appSize18,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          agentDetailsController.reviewProfileList[index],
                          width: AppSize.appSize36,
                        ),
                        Text(
                          agentDetailsController.reviewProfileNameList[index],
                          style: AppStyle.heading5Medium(color: AppColor.textColor),
                        ).paddingOnly(left: AppSize.appSize6),
                      ],
                    ).paddingOnly(top: AppSize.appSize10),
                    Text(
                      agentDetailsController.reviewTypeList[index],
                      style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
                    ).paddingOnly(top: AppSize.appSize10),
                    Text(
                      agentDetailsController.reviewDescriptionList[index],
                      style: AppStyle.heading5Regular(color: AppColor.textColor),
                    ).paddingOnly(top: AppSize.appSize10),
                  ],
                ),
              );
            },
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CommonButton(
        onPressed: () {
          agentDetailsController.launchDialer();
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          AppString.callOwnerButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ).paddingOnly(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26, top: AppSize.appSize10,
      ),
    );
  }
}
