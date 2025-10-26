import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/gallery_controller.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import '../../services/enhanced_loading_service.dart';

class GalleryView extends StatelessWidget {
  GalleryView({super.key});

  final GalleryController galleryController = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildGallery(),
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
        AppString.gallery,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  SingleChildScrollView buildGallery() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSize.appSize10),
      physics: const ClampingScrollPhysics(),
      child: Obx(() {
        if (galleryController.isLoading.value) {
          return EnhancedLoadingService.buildGalleryLoading();
        }
        
        final propertyPhotos = galleryController.propertyPhotos;
        
        // If we have property photos, show them as a single gallery
        if (propertyPhotos.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property Gallery',
                style: AppStyle.heading3Medium(color: AppColor.textColor),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: propertyPhotos.length,
                itemBuilder: (context, index) {
                  final imageUrl = propertyPhotos[index];
                  return Container(
                    height: AppSize.appSize200,
                    margin: EdgeInsets.only(bottom: AppSize.appSize8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize8),
                      image: DecorationImage(
                        image: imageUrl.startsWith('http') 
                            ? NetworkImage(imageUrl) as ImageProvider
                            : AssetImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ).paddingOnly(top: AppSize.appSize10),
            ],
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16, 
            right: AppSize.appSize16,
          );
        }
        
        // Fallback to hardcoded images if no property photos
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppString.hall,
              style: AppStyle.heading3Medium(color: AppColor.textColor),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: galleryController.hallImageList.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  galleryController.hallImageList[index],
                  height: AppSize.appSize150,
                ).paddingOnly(bottom: AppSize.appSize4);
              },
            ).paddingOnly(top: AppSize.appSize10),
          ],
        ).paddingOnly(
          top: AppSize.appSize10,
          left: AppSize.appSize16, 
          right: AppSize.appSize16,
        );
      }),
    );
  }
}
