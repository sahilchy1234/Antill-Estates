import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/filters_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

filterBottomSheet(BuildContext context) {
  FiltersController filtersController = Get.put(FiltersController());
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
        // height: AppSize.appSize630,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppString.filters,
                    style: AppStyle.heading4Medium(color: AppColor.textColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Image.asset(
                      Assets.images.close.path,
                      width: AppSize.appSize24,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  filtersController.toggleSortByExpansion();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppString.sortBy,
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                    Obx(() => Image.asset(
                      filtersController.isSortByExpanded.value
                          ? Assets.images.dropdownExpand.path
                          : Assets.images.dropdown.path,
                      width: AppSize.appSize17,
                    )),
                  ],
                ).paddingOnly(top: AppSize.appSize26),
              ),
              Obx(() => AnimatedContainer(
                duration: const Duration(seconds: AppSize.size1),
                curve: Curves.fastEaseInToSlowEaseOut,
                margin: EdgeInsets.only(
                  top: filtersController.isSortByExpanded.value
                      ? AppSize.appSize16
                      : AppSize.appSize0,
                ),
                height: filtersController.isSortByExpanded.value
                    ? null
                    : AppSize.appSize0,
                child: filtersController.isSortByExpanded.value
                    ? Column(
                  children: List.generate(filtersController.sortByList.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSize.appSize14),
                      child: GestureDetector(
                        onTap: () {
                          filtersController.updateSortBy(index);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              filtersController.sortByList[index],
                              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                            ),
                            Container(
                              width: AppSize.appSize20,
                              height: AppSize.appSize20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.textColor,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: filtersController.selectSortBy.value == index ? Center(
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
                          ],
                        ),
                      ),
                    );
                  }),
                ) : const SizedBox.shrink(),
              )),
              Obx(() => Divider(
                color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint4),
                thickness: AppSize.appSizePoint7,
                height: AppSize.appSize0,
              ).paddingOnly(
                top: filtersController.isSortByExpanded.value
                    ? AppSize.appSize4
                    : AppSize.appSize16,
                bottom: AppSize.appSize16,
              )),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtersController.filtersList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            filtersController.filtersList[index],
                            style: AppStyle.heading5Medium(color: AppColor.textColor),
                          ),
                          Image.asset(
                            Assets.images.dropdown.path,
                            width: AppSize.appSize17,
                          ),
                        ],
                      ),
                      if(index < filtersController.filtersList.length - AppSize.size1)...[
                        Divider(
                          color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint4),
                          thickness: AppSize.appSizePoint7,
                          height: AppSize.appSize0,
                        ).paddingOnly(
                          top: AppSize.appSize16,
                          bottom: AppSize.appSize16,
                        ),
                      ],
                    ],
                  );
                },
              ),
              SizedBox(
                height: AppSize.appSize10,
              )
            ],
          ),
        ),
      ).paddingOnly(bottom: MediaQuery.of(context).viewInsets.bottom);
    },
  );
}
