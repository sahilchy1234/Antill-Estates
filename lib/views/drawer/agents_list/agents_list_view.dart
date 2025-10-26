import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/agents_list_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

class AgentsListView extends StatelessWidget {
  AgentsListView({super.key});

  final AgentsListController agentsListController = Get.put(AgentsListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAgentsList(),
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
        AppString.agents,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAgentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
      itemCount: agentsListController.agentsProfileList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.agentsDetailsView);
          },
          child: Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            margin: const EdgeInsets.only(bottom: AppSize.appSize16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.border2Color,
                width: AppSize.appSizePoint50,
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColor.whiteColor,
                      backgroundImage: AssetImage(
                        agentsListController.agentsProfileList[index],
                      ),
                      radius: AppSize.appSize22,
                    ).paddingOnly(right: AppSize.appSize10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agentsListController.agentsNameList[index],
                          style: AppStyle.heading5Medium(color: AppColor.textColor),
                        ),
                        Row(
                          children: [
                            Image.asset(
                              Assets.images.call.path,
                              width: AppSize.appSize14,
                            ).paddingOnly(right: AppSize.appSize6),
                            Text(
                              agentsListController.agentsNumberList[index],
                              style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                            ),
                          ],
                        ).paddingOnly(top: AppSize.appSize4),
                      ],
                    ),
                  ],
                ),
                Divider(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                  thickness: AppSize.appSizePoint7,
                  height: AppSize.appSize0,
                ).paddingSymmetric(vertical: AppSize.appSize16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      agentsListController.agentsPropertyList[index],
                      style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    ),
                    Row(
                      children: [
                        Text(
                          agentsListController.agentsRatingList[index],
                          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                        ).paddingOnly(right: AppSize.appSize4),
                        Image.asset(
                          Assets.images.star.path,
                          width: AppSize.appSize12,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
