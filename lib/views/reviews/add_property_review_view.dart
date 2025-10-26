import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_button.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/show_property_details_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class AddPropertyReviewView extends StatelessWidget {
  AddPropertyReviewView({super.key});

  final ShowPropertyDetailsController showPropertyDetailsController = Get.find<ShowPropertyDetailsController>();
  final TextEditingController reviewController = TextEditingController();
  final RxDouble selectedRating = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildReviewForm(),
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
        'Add Review',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildReviewForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property info
          Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Row(
              children: [
                Container(
                  width: AppSize.appSize60,
                  height: AppSize.appSize60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                    image: showPropertyDetailsController.getPropertyImages().isNotEmpty
                        ? (showPropertyDetailsController.getPropertyImages()[0].startsWith('http')
                            ? DecorationImage(
                                image: NetworkImage(showPropertyDetailsController.getPropertyImages()[0]),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: AssetImage(showPropertyDetailsController.getPropertyImages()[0]),
                                fit: BoxFit.cover,
                              ))
                        : DecorationImage(
                            image: AssetImage(Assets.images.property3.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(width: AppSize.appSize12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showPropertyDetailsController.getPropertyTitle(),
                        style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                      ),
                      SizedBox(height: AppSize.appSize4),
                      Text(
                        showPropertyDetailsController.getPropertyAddress(),
                        style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSize.appSize24),

          // Rating section
          Text(
            'Rate this property',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize16),
          Center(
            child: Obx(() => RatingBar.builder(
              initialRating: selectedRating.value,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: AppSize.appSize40,
              itemPadding: const EdgeInsets.symmetric(horizontal: AppSize.appSize4),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: AppColor.primaryColor,
              ),
              onRatingUpdate: (rating) {
                selectedRating.value = rating;
              },
            )),
          ),
          SizedBox(height: AppSize.appSize8),
          Center(
            child: Obx(() => Text(
              selectedRating.value > 0 
                  ? '${selectedRating.value.toStringAsFixed(1)} stars'
                  : 'Tap to rate',
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            )),
          ),

          SizedBox(height: AppSize.appSize24),

          // Review text
          Text(
            'Write your review',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint50),
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: TextField(
              controller: reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your experience with this property...',
                hintStyle: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSize.appSize16),
              ),
              style: AppStyle.heading5Regular(color: AppColor.textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: AppSize.appSize10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => CommonButton(
        onPressed: selectedRating.value > 0 && reviewController.text.trim().isNotEmpty
            ? () => _submitReview()
            : null,
        backgroundColor: selectedRating.value > 0 && reviewController.text.trim().isNotEmpty
            ? AppColor.primaryColor
            : AppColor.descriptionColor,
        child: Text(
          'Submit Review',
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      )),
    );
  }

  void _submitReview() async {
    if (selectedRating.value == 0 || reviewController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please provide both rating and review text',
        backgroundColor: Colors.red,
        colorText: AppColor.whiteColor,
      );
      return;
    }

    try {
      await showPropertyDetailsController.addReview(
        selectedRating.value,
        reviewController.text.trim(),
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit review: $e',
        backgroundColor: Colors.red,
        colorText: AppColor.whiteColor,
      );
    }
  }
}
