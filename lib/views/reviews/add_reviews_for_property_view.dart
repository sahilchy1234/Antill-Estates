import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/add_reviews_for_property_controller.dart';
import 'package:antill_estates/controller/property_details_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class AddReviewsForPropertyView extends StatelessWidget {
  AddReviewsForPropertyView({super.key});

  final AddReviewsForPropertyController addReviewsForPropertyController = Get.put(AddReviewsForPropertyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAddReviewsForPropertyFields(),
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
      title: Obx(() => Text(
        addReviewsForPropertyController.isEditMode.value 
          ? 'Edit Review' 
          : AppString.addReview,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      )),
    );
  }

  Widget buildAddReviewsForPropertyFields() {
    return Obx(() {
      if (addReviewsForPropertyController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final property = addReviewsForPropertyController.propertyId != null 
                ? Get.find<PropertyDetailsController>().currentProperty.value 
                : null;
            
            return Container(
              padding: const EdgeInsets.all(AppSize.appSize16),
              decoration: BoxDecoration(
                color: AppColor.backgroundColor,
                borderRadius: BorderRadius.circular(AppSize.appSize16),
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSize.appSize44,
                    height: AppSize.appSize44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize8),
                      image: property?.propertyPhotos.isNotEmpty == true
                          ? (property!.propertyPhotos.first.startsWith('http')
                              ? DecorationImage(
                                  image: NetworkImage(property.propertyPhotos.first),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: AssetImage(property.propertyPhotos.first),
                                  fit: BoxFit.cover,
                                ))
                          : DecorationImage(
                              image: AssetImage(Assets.images.searchProperty1.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ).paddingOnly(right: AppSize.appSize8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property?.propertyType ?? AppString.semiModernHouse,
                          style: AppStyle.heading4Medium(color: AppColor.textColor),
                        ),
                        Text(
                          property != null 
                              ? '${property.locality}, ${property.city}'
                              : AppString.address6,
                          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                        ).paddingOnly(top: AppSize.appSize4),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          RatingBar(
            initialRating: addReviewsForPropertyController.currentRating.value,
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
              addReviewsForPropertyController.updateRating(rating);
            },
          ).paddingOnly(top: AppSize.appSize26),
          TextFormField(
            controller: addReviewsForPropertyController.writeAReviewController,
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
    });
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main submit/update button
          CommonButton(
            onPressed: addReviewsForPropertyController.isLoading.value 
              ? null 
              : () {
                  addReviewsForPropertyController.submitReview();
                },
            backgroundColor: AppColor.primaryColor,
            child: addReviewsForPropertyController.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  addReviewsForPropertyController.isEditMode.value 
                    ? 'Update Review' 
                    : AppString.submitButton,
                  style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                ),
          ),
          
          // Delete button (only show in edit mode)
          if (addReviewsForPropertyController.isEditMode.value) ...[
            const SizedBox(height: AppSize.appSize12),
            CommonButton(
              onPressed: addReviewsForPropertyController.isLoading.value 
                ? null 
                : () {
                    addReviewsForPropertyController.deleteReview();
                  },
              backgroundColor: Colors.red,
              child: addReviewsForPropertyController.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Delete Review',
                    style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                  ),
            ),
          ],
        ],
      )).paddingOnly(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26, top: AppSize.appSize10,
      ),
    );
  }
}
