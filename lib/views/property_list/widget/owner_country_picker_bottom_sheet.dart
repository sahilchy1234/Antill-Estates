import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/owner_country_picker_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

ownerCountryPickerBottomSheet(BuildContext context) {
  OwnerCountryPickerController ownerCountryPickerController =
      Get.put(OwnerCountryPickerController());
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSize.appSize12),
        topRight: Radius.circular(AppSize.appSize12),
      ),
      borderSide: BorderSide.none,
    ),
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: AppSize.appSize437,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ownerCountryPickerController.searchController,
                    cursorColor: AppColor.primaryColor,
                    style:
                        AppStyle.heading4Regular(color: AppColor.primaryColor),
                    decoration: InputDecoration(
                      hintText: AppString.searchCountry,
                      hintStyle: AppStyle.heading4Regular(
                          color: AppColor.descriptionColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: const BorderSide(
                          color: AppColor.descriptionColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: const BorderSide(
                          color: AppColor.descriptionColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        borderSide: const BorderSide(
                          color: AppColor.descriptionColor,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Image.asset(
                    Assets.images.close.path,
                    width: AppSize.appSize24,
                  ).paddingOnly(left: AppSize.appSize16),
                ),
              ],
            ).paddingOnly(bottom: AppSize.appSize16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: ownerCountryPickerController.flagsImageList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      ownerCountryPickerController.selectCountry(index);
                      Get.back();
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            height: AppSize.appSize60,
                            width: AppSize.appSize60,
                            margin:
                                const EdgeInsets.only(right: AppSize.appSize15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(ownerCountryPickerController
                                    .flagsImageList[index]),
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${ownerCountryPickerController.countries[index][AppString.namePicker]}",
                                style: AppStyle.heading4Regular(
                                    color: AppColor.textColor),
                              ),
                              Text(
                                "${ownerCountryPickerController.countries[index][AppString.codeText]}",
                                style: AppStyle.heading5Regular(
                                    color: AppColor.descriptionColor),
                              ).paddingOnly(top: AppSize.appSize5),
                            ],
                          ),
                        ],
                      ).paddingOnly(bottom: AppSize.appSize30),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ).paddingOnly(bottom: MediaQuery.of(context).viewInsets.bottom);
    },
  );
}
