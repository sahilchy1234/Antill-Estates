import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/common/common_rich_text.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/bottom_bar_controller.dart';
import 'package:antill_estates/controller/interesting_reads_details_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/text_segment_model.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';

class InterestingReadsDetailsView extends StatelessWidget {
  InterestingReadsDetailsView({super.key});
  
  final InterestingReadsDetailsController interestingReadsDetailsController = Get.put(InterestingReadsDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildInterestingReadsDetails(context),
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
        AppString.interestingReads,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
      actions: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.searchView);
              },
              child: Image.asset(
                Assets.images.search.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.back();
                Future.delayed(const Duration(milliseconds: AppSize.size400), () {
                  BottomBarController bottomBarController = Get.put(BottomBarController());
                  bottomBarController.pageController.jumpToPage(AppSize.size3);
                },);
              },
              child: Image.asset(
                Assets.images.save.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            GestureDetector(
              onTap: () {
                // Get article title from arguments or default
                final args = Get.arguments;
                final articleTitle = args is Map ? (args['title'] ?? 'Interesting Article') : 'Interesting Article';
                
                final shareText = '''
📰 $articleTitle

Read this insightful article on ${AppString.appName}

📚 Real estate insights
💡 Market trends
🏡 Property tips
📊 Expert analysis

Download ${AppString.appName} for more interesting reads!
''';

                Share.share(
                  shareText,
                  subject: articleTitle,
                );
              },
              child: Image.asset(
                Assets.images.share.path,
                width: AppSize.appSize24,
              ),
            ),
          ],
        ).paddingOnly(right: AppSize.appSize16),
      ],
    );
  }

  SingleChildScrollView buildInterestingReadsDetails(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.nov23,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Text(
            AppString.readString1,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Wrap(
            spacing: AppSize.appSize16,
            runSpacing: AppSize.appSize6,
            children: List.generate(interestingReadsDetailsController.readsHashtagList.length, (index) {
              return Container(
                padding: const EdgeInsets.all(AppSize.appSize6),
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize6),
                ),
                child: Text(
                  interestingReadsDetailsController.readsHashtagList[index],
                  style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                ),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Row(
            children: [
              Text(
                AppString.shareArticle,
                style: AppStyle.heading5Regular(color: AppColor.textColor),
              ),
              Image.asset(
                Assets.images.instagram.path,
                width: AppSize.appSize26,
              ).paddingOnly(left: AppSize.appSize16),
              Image.asset(
                Assets.images.pinterest.path,
                width: AppSize.appSize26,
              ).paddingOnly(left: AppSize.appSize16),
              Image.asset(
                Assets.images.facebook.path,
                width: AppSize.appSize26,
              ).paddingOnly(left: AppSize.appSize16),
              Image.asset(
                Assets.images.whatsapp.path,
                width: AppSize.appSize26,
              ).paddingOnly(left: AppSize.appSize16),
              Image.asset(
                Assets.images.telegram.path,
                width: AppSize.appSize26,
              ).paddingOnly(left: AppSize.appSize16),
            ],
          ).paddingOnly(
            top: AppSize.appSize34,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Divider(
            color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingSymmetric(
            vertical: AppSize.appSize16, horizontal: AppSize.appSize16,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSize.appSize6),
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize6),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      Assets.images.viewers.path,
                      width: AppSize.appSize16,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      AppString.views4252,
                      style: AppStyle.heading5Regular(color: AppColor.textColor),
                    ),
                  ],
                ),
              ).paddingOnly(right: AppSize.appSize20),
              Container(
                padding: const EdgeInsets.all(AppSize.appSize6),
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize6),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      Assets.images.share.path,
                      width: AppSize.appSize16,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      AppString.share165,
                      style: AppStyle.heading5Regular(color: AppColor.textColor),
                    ),
                  ],
                ),
              ).paddingOnly(right: AppSize.appSize20),
              Container(
                padding: const EdgeInsets.all(AppSize.appSize6),
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize6),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      Assets.images.thumbUp.path,
                      width: AppSize.appSize16,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      AppString.likes658,
                      style: AppStyle.heading5Regular(color: AppColor.textColor),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Image.asset(
            Assets.images.read1Image.path,
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.readDetail1,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.readDetail2,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(
            top: AppSize.appSize18,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.understandingKey,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize18,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.understandingKeyDescription,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(
            top: AppSize.appSize18,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSize.appSize5,
                height: AppSize.appSize5,
                margin: const EdgeInsets.only(
                  right: AppSize.appSize12, top: AppSize.appSize8,
                  left: AppSize.appSize12,
                ),
                decoration: const BoxDecoration(
                  color: AppColor.descriptionColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  AppString.understandingKey1,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize18,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSize.appSize5,
                height: AppSize.appSize5,
                margin: const EdgeInsets.only(
                  right: AppSize.appSize12, top: AppSize.appSize8,
                  left: AppSize.appSize12,
                ),
                decoration: const BoxDecoration(
                  color: AppColor.descriptionColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  AppString.understandingKey2,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize18,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSize.appSize5,
                height: AppSize.appSize5,
                margin: const EdgeInsets.only(
                  right: AppSize.appSize12, top: AppSize.appSize8,
                  left: AppSize.appSize12,
                ),
                decoration: const BoxDecoration(
                  color: AppColor.descriptionColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  AppString.understandingKey3,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize18,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.frequentlyAskedQuestions,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          GestureDetector(
            onTap: () {
              interestingReadsDetailsController.toggleAnswer1Expansion();
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppString.question1,
                    style: AppStyle.heading5Regular(color: AppColor.textColor),
                  ),
                ),
                Obx(() => Image.asset(
                  interestingReadsDetailsController.isAnswer1Expanded.value
                      ? Assets.images.dropdownExpand.path
                      : Assets.images.dropdown.path,
                  width: AppSize.appSize20,
                )).paddingOnly(left: AppSize.appSize10),
              ],
            ).paddingOnly(top: AppSize.appSize16),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Divider(
            color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingSymmetric(
            vertical: AppSize.appSize10, horizontal: AppSize.appSize16,
          ),
          Obx(() => AnimatedContainer(
            duration: const Duration(seconds: AppSize.size1),
            curve: Curves.fastEaseInToSlowEaseOut,
            margin: EdgeInsets.only(
              top: interestingReadsDetailsController.isAnswer1Expanded.value
                  ? AppSize.appSize5
                  : AppSize.appSize0,
            ),
            height: interestingReadsDetailsController.isAnswer1Expanded.value
                ? null
                : AppSize.appSize0,
            child: interestingReadsDetailsController.isAnswer1Expanded.value
                ? Text(
              AppString.answer1,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ) : const SizedBox.shrink(),
          )).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          GestureDetector(
            onTap: () {
              interestingReadsDetailsController.toggleAnswer2Expansion();
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppString.question2,
                    style: AppStyle.heading5Regular(color: AppColor.textColor),
                  ),
                ),
                Obx(() => Image.asset(
                  interestingReadsDetailsController.isAnswer2Expanded.value
                      ? Assets.images.dropdownExpand.path
                      : Assets.images.dropdown.path,
                  width: AppSize.appSize20,
                )).paddingOnly(left: AppSize.appSize10),
              ],
            ).paddingOnly(top: AppSize.appSize16),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Divider(
            color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingSymmetric(
            vertical: AppSize.appSize10, horizontal: AppSize.appSize16,
          ),
          Obx(() => AnimatedContainer(
            duration: const Duration(seconds: AppSize.size1),
            curve: Curves.fastEaseInToSlowEaseOut,
            margin: EdgeInsets.only(
              top: interestingReadsDetailsController.isAnswer2Expanded.value
                  ? AppSize.appSize5
                  : AppSize.appSize0,
            ),
            height: interestingReadsDetailsController.isAnswer2Expanded.value
                ? null
                : AppSize.appSize0,
            child: interestingReadsDetailsController.isAnswer2Expanded.value
                ? Text(
              AppString.answer1,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ) : const SizedBox.shrink(),
          )).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          GestureDetector(
            onTap: () {
              interestingReadsDetailsController.toggleAnswer3Expansion();
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppString.question3,
                    style: AppStyle.heading5Regular(color: AppColor.textColor),
                  ),
                ),
                Obx(() => Image.asset(
                  interestingReadsDetailsController.isAnswer3Expanded.value
                      ? Assets.images.dropdownExpand.path
                      : Assets.images.dropdown.path,
                  width: AppSize.appSize20,
                )).paddingOnly(left: AppSize.appSize10),
              ],
            ).paddingOnly(top: AppSize.appSize16),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Divider(
            color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingSymmetric(
            vertical: AppSize.appSize10, horizontal: AppSize.appSize16,
          ),
          Obx(() => AnimatedContainer(
            duration: const Duration(seconds: AppSize.size1),
            curve: Curves.fastEaseInToSlowEaseOut,
            margin: EdgeInsets.only(
              top: interestingReadsDetailsController.isAnswer3Expanded.value
                  ? AppSize.appSize5
                  : AppSize.appSize0,
            ),
            height: interestingReadsDetailsController.isAnswer3Expanded.value
                ? null
                : AppSize.appSize0,
            child: interestingReadsDetailsController.isAnswer3Expanded.value
                ? Text(
              AppString.answer1,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ) : const SizedBox.shrink(),
          )).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          GestureDetector(
            onTap: () {
              interestingReadsDetailsController.toggleAnswer4Expansion();
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppString.question4,
                    style: AppStyle.heading5Regular(color: AppColor.textColor),
                  ),
                ),
                Obx(() => Image.asset(
                  interestingReadsDetailsController.isAnswer4Expanded.value
                      ? Assets.images.dropdownExpand.path
                      : Assets.images.dropdown.path,
                  width: AppSize.appSize20,
                )).paddingOnly(left: AppSize.appSize10),
              ],
            ).paddingOnly(top: AppSize.appSize16),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Divider(
            color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingSymmetric(
            vertical: AppSize.appSize10, horizontal: AppSize.appSize16,
          ),
          Obx(() => AnimatedContainer(
            duration: const Duration(seconds: AppSize.size1),
            curve: Curves.fastEaseInToSlowEaseOut,
            margin: EdgeInsets.only(
              top: interestingReadsDetailsController.isAnswer4Expanded.value
                  ? AppSize.appSize5
                  : AppSize.appSize0,
            ),
            height: interestingReadsDetailsController.isAnswer4Expanded.value
                ? null
                : AppSize.appSize0,
            child: interestingReadsDetailsController.isAnswer4Expanded.value
                ? Text(
              AppString.answer1,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ) : const SizedBox.shrink(),
          )).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(AppSize.appSize16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: interestingReadsDetailsController.commentsController,
                  cursorColor: AppColor.primaryColor,
                  style: AppStyle.heading4Regular(color: AppColor.textColor),
                  maxLines: AppSize.size3,
                  decoration: InputDecoration(
                    hintText: AppString.yourComments,
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
                ),
                TextFormField(
                  controller: interestingReadsDetailsController.nameController,
                  cursorColor: AppColor.primaryColor,
                  style: AppStyle.heading4Regular(color: AppColor.textColor),
                  decoration: InputDecoration(
                    hintText: AppString.name,
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
                ).paddingOnly(top: AppSize.appSize16),
                TextFormField(
                  controller: interestingReadsDetailsController.emailController,
                  cursorColor: AppColor.primaryColor,
                  style: AppStyle.heading4Regular(color: AppColor.textColor),
                  decoration: InputDecoration(
                    hintText: AppString.emailID,
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
                ).paddingOnly(top: AppSize.appSize16),
                CommonButton(
                  onPressed: () {},
                  backgroundColor: AppColor.primaryColor,
                  child: Text(
                    AppString.postACommentButton,
                    style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                  ),
                ).paddingOnly(top: AppSize.appSize16),
              ],
            ),
          ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                width: AppSize.appSizePoint7,
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      Assets.images.jefferyDenesik.path,
                      width: AppSize.appSize48,
                    ).paddingOnly(right: AppSize.appSize12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppString.jefferyDenesik,
                          style: AppStyle.heading4Medium(color: AppColor.textColor),
                        ),
                        Text(
                          AppString.author,
                          style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                        ).paddingOnly(top: AppSize.appSize4),
                      ],
                    ),
                  ],
                ),
                CommonRichText(
                  segments: [
                    TextSegment(
                      text: AppString.authorString,
                      style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    ),
                    TextSegment(
                      text: AppString.readMore,
                      style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                    ),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
              ],
            ),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.otherIntrestingReads,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize116,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: interestingReadsDetailsController.interestingImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  width: AppSize.appSize300,
                  padding: const EdgeInsets.all(AppSize.appSize16),
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        interestingReadsDetailsController.interestingImageList[index],
                      ).paddingOnly(right: AppSize.appSize16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              interestingReadsDetailsController.interestingTitleList[index],
                              maxLines: AppSize.size3,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyle.heading5Medium(color: AppColor.textColor),
                            ),
                            Text(
                              interestingReadsDetailsController.interestingDateList[index],
                              style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                            ).paddingOnly(top: AppSize.appSize6),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }
}
