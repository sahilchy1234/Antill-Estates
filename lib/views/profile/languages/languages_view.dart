import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/languages_controller.dart';
import 'package:antill_estates/controller/translation_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class LanguagesView extends StatelessWidget {
  LanguagesView({super.key});

  final LanguagesController languagesController = Get.put(LanguagesController());
  final TranslationController translationController = Get.put(TranslationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildLanguagesList(),
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
        AppString.languages,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildLanguagesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AppSize.appSize12,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
      itemCount: languagesController.languagesList.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                languagesController.updateLanguage(index);
                Future.delayed(Duration.zero, () {
                  translationController
                      .changeLanguage(translationController.languageList[index]);
                });
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
                        child: languagesController.selectLanguage.value == index ? Center(
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
                        languagesController.languagesList[index],
                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                      ).paddingOnly(left: AppSize.appSize10),
                    ],
                  ),
                );
              }),
            ),
            if(index < languagesController.languagesList.length - AppSize.size1)...[
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
        AppString.setLanguagesButton,
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
      left: AppSize.appSize16, right: AppSize.appSize16,
      bottom: AppSize.appSize26, top: AppSize.appSize10,
    );
  }
}
