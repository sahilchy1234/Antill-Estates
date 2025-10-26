import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/arts_antiques_search_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

class ArtsAntiquesSearchView extends StatelessWidget {
  const ArtsAntiquesSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ArtsAntiquesSearchController>(
      init: ArtsAntiquesSearchController(),
      builder: (controller) {
        // Handle arguments passed from category selection
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final arguments = Get.arguments as Map<String, dynamic>?;
          if (arguments != null) {
            _handleNavigationArguments(arguments, controller);
          }
        });

        return Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: buildAppBar(),
          body: buildSearchFilters(controller, context),
          bottomNavigationBar: buildButton(controller),
        );
      },
    );
  }

  void _handleNavigationArguments(Map<String, dynamic> arguments, ArtsAntiquesSearchController controller) {
    final categoryType = arguments['categoryType'] as String?;
    final selectedCategoryIndex = arguments['selectedCategoryIndex'] as int?;

    if (categoryType != null && selectedCategoryIndex != null) {
      // Map category type to index
      final categoryMap = {
        'paintings': 0,
        'sculptures': 1,
        'antiques': 2,
        'jewelry': 3,
        'collectibles': 4,
        'textiles': 5,
      };

      final categoryIndex = categoryMap[categoryType.toLowerCase()];
      if (categoryIndex != null) {
        controller.selectCategory.value = categoryIndex;
      }
    }
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
        'Search Arts & Antiques',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildSearchFilters(ArtsAntiquesSearchController controller, BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize100),
      children: [
        // Search Text Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            color: AppColor.whiteColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: AppSize.appSizePoint1,
                blurRadius: AppSize.appSize2,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller.searchController,
            cursorColor: AppColor.primaryColor,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
            decoration: InputDecoration(
              hintText: "Search by title, artist, or description",
              hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: AppSize.appSize16, right: AppSize.appSize16,
                ),
                child: Image.asset(
                  Assets.images.search.path,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                maxWidth: AppSize.appSize51,
              ),
            ),
          ),
        ).paddingOnly(
          top: AppSize.appSize26,
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),

        // Category Filter
        Text(
          'Category',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize26,
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: AppSize.appSize16),
          child: Obx(() {
            return Row(
              children: List.generate(controller.categoryList.length, (index) {
                return GestureDetector(
                  onTap: () {
                    controller.updateCategory(index);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: controller.selectCategory.value == index
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                      color: controller.selectCategory.value == index
                          ? AppColor.primaryColor.withOpacity(0.1)
                          : AppColor.whiteColor,
                    ),
                    child: Center(
                      child: Text(
                        controller.categoryList[index],
                        style: AppStyle.heading5Medium(
                          color: controller.selectCategory.value == index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ).paddingOnly(top: AppSize.appSize16),

        // Price Range Filter
        Text(
          'Price Range',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize26,
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),
        Obx(() {
          return Column(
            children: [
              RangeSlider(
                values: controller.values.value,
                onChanged: (RangeValues newValues) {
                  controller.updatePriceRange(newValues);
                },
                min: 0,
                max: 100000,
                divisions: 100,
                activeColor: AppColor.primaryColor,
                inactiveColor: AppColor.descriptionColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹ ${controller.startValueText}',
                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                  Text(
                    '₹ ${controller.endValueText}',
                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                ],
              ).paddingOnly(
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
            ],
          );
        }).paddingOnly(top: AppSize.appSize16),
      ],
    );
  }

  Widget buildButton(ArtsAntiquesSearchController controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26,
      ),
      child: CommonButton(
        onPressed: () async {
          // Show loading indicator
          Get.dialog(
            const Center(
              child: CircularProgressIndicator(),
            ),
            barrierDismissible: false,
          );

          try {
            // Perform search with current filters
            await controller.performSearch();

            // Close loading dialog
            Get.back();

            // Navigate to search results
            Get.toNamed(AppRoutes.artsAntiquesSearchListView);
          } catch (e) {
            // Close loading dialog
            Get.back();

            // Show error message
            Get.snackbar(
              'Search Error',
              'Failed to search items. Please try again.',
              backgroundColor: AppColor.negativeColor,
              colorText: AppColor.whiteColor,
            );
          }
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          'Search Items',
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ),
    );
  }
}

