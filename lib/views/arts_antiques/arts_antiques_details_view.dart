import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_status_bar.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/arts_antiques_details_controller.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';
import 'package:antill_estates/common/shimmer_loading.dart';
import 'package:antill_estates/configs/app_design.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:antill_estates/utils/price_formatter.dart';

class ArtsAntiquesDetailsView extends StatelessWidget {
  const ArtsAntiquesDetailsView({super.key});

  ArtsAntiquesDetailsController get controller => Get.put(ArtsAntiquesDetailsController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    // Initialize with item ID from arguments
    final itemId = Get.arguments;
    if (itemId != null && itemId is String) {
      if (!controller.isLoading.value && controller.item.value == null) {
        controller.initializeWithItemId(itemId);
      }
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingView();
            }
            
            if (controller.hasError.value) {
              return _buildErrorView();
            }
            
            if (controller.item.value == null) {
              return _buildNotFoundView();
            }
            
            return _buildDetailsView(context);
          }),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  /// Build loading view with shimmer
  Widget _buildLoadingView() {
    return RepaintBoundary(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer
            ShimmerLoading.imageShimmer(
              height: AppSize.appSize300,
              width: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSize.appSize16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading.textShimmer(width: AppSize.appSize200, height: AppSize.appSize24),
                  const SizedBox(height: AppSize.appSize8),
                  ShimmerLoading.textShimmer(width: AppSize.appSize150, height: AppSize.appSize16),
                  const SizedBox(height: AppSize.appSize16),
                  ShimmerLoading.textShimmer(width: AppSize.appSize122, height: AppSize.appSize20),
                  const SizedBox(height: AppSize.appSize24),
                  Row(
                    children: List.generate(3, (index) => 
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 2 ? AppSize.appSize8 : 0),
                          child: ShimmerLoading.simpleShimmer(
                            child: Container(
                              height: AppSize.appSize80,
                              decoration: BoxDecoration(
                                color: AppColor.descriptionColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSize.appSize12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSize.appSize24),
                  ...List.generate(3, (index) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSize.appSize8),
                      child: ShimmerLoading.textShimmer(height: AppSize.appSize16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize50),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColor.negativeColor,
          ),
          const SizedBox(height: AppSize.appSize16),
          Text(
            'Error Loading Item',
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize8),
          Obx(() => Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          )).paddingSymmetric(horizontal: AppSize.appSize32),
          const SizedBox(height: AppSize.appSize24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.appSize32,
                vertical: AppSize.appSize12,
              ),
            ),
            child: Text(
              'Go Back',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Build not found view
  Widget _buildNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.palette_outlined,
            size: 64,
            color: AppColor.descriptionColor,
          ),
          const SizedBox(height: AppSize.appSize16),
          Text(
            'Item Not Found',
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize8),
          Text(
            'The arts & antiques item you\'re looking for\ncould not be found.',
            textAlign: TextAlign.center,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingSymmetric(horizontal: AppSize.appSize32),
          const SizedBox(height: AppSize.appSize24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.appSize32,
                vertical: AppSize.appSize12,
              ),
            ),
            child: Text(
              'Go Back',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Build main details view
  Widget _buildDetailsView(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      cacheExtent: 800,
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(child: _buildImageGallery()),
              RepaintBoundary(child: _buildMainInfo()),
              RepaintBoundary(child: _buildDetailsSection()),
              RepaintBoundary(child: _buildDescriptionSection()),
              _buildActionButtons(context),
              RepaintBoundary(child: _buildReviewsSection()),
              RepaintBoundary(child: _buildSimilarItemsSection()),
              const SizedBox(height: AppSize.appSize80),
            ],
          ),
        ),
      ],
    );
  }

  /// Build app bar
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColor.whiteColor,
      elevation: 0,
      pinned: true,
      leading: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(AppSize.appSize8),
          child: Container(
            margin: const EdgeInsets.all(AppSize.appSize8),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(AppSize.appSize8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: AppSize.appSize8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColor.textColor,
            ),
          ),
        ),
      ),
      actions: [
        Obx(() => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.isSaving.value ? null : controller.toggleSave,
            borderRadius: BorderRadius.circular(AppSize.appSize8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(AppSize.appSize8),
              padding: const EdgeInsets.all(AppSize.appSize8),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(AppSize.appSize8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: AppSize.appSize8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        controller.isSaved.value ? Icons.favorite : Icons.favorite_border,
                        color: controller.isSaved.value ? Colors.red : AppColor.textColor,
                        key: ValueKey(controller.isSaved.value),
                      ),
                    ),
            ),
          ),
        )),
        const SizedBox(width: AppSize.appSize8),
      ],
    );
  }

  /// Build image gallery
  Widget _buildImageGallery() {
    return Obx(() {
      final item = controller.item.value!;
      final images = item.images;

      if (images.isEmpty) {
        return Container(
          height: AppSize.appSize300,
          color: AppColor.backgroundColor,
          child: const Center(
            child: Icon(
              Icons.palette,
              size: 80,
              color: AppColor.descriptionColor,
            ),
          ),
        );
      }

      return Column(
        children: [
          // Main image
          SizedBox(
            height: AppSize.appSize300,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: controller.changeImage,
              itemBuilder: (context, index) {
                return CachedFirebaseImage(
                  imageUrl: images[index],
                  height: AppSize.appSize300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 800, // 2x for better quality on retina displays
                  cacheHeight: 600,
                  showLoadingIndicator: true,
                  errorWidget: Container(
                    color: AppColor.backgroundColor,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: AppColor.descriptionColor,
                    ),
                  ),
                );
              },
            ),
          ),
          // Image indicators
          if (images.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSize.appSize12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Obx(() => Container(
                    width: controller.currentImageIndex.value == index
                        ? AppSize.appSize24
                        : AppSize.appSize8,
                    height: AppSize.appSize8,
                    margin: const EdgeInsets.symmetric(horizontal: AppSize.appSize4),
                    decoration: BoxDecoration(
                      color: controller.currentImageIndex.value == index
                          ? AppColor.primaryColor
                          : AppColor.descriptionColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                  )),
                ),
              ),
            ),
        ],
      );
    });
  }

  /// Build main info section
  Widget _buildMainInfo() {
    return Obx(() {
      final item = controller.item.value!;
      
      return Container(
        padding: const EdgeInsets.all(AppSize.appSize16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.appSize12,
                vertical: AppSize.appSize6,
              ),
              decoration: AppDesign.primaryBadge,
              child: Text(
                item.category,
                style: AppStyle.heading6Medium(color: AppColor.primaryColor),
              ),
            ),
            const SizedBox(height: AppSize.appSize12),
            // Title
            Text(
              item.title,
              style: AppStyle.heading3SemiBold(color: AppColor.textColor),
            ),
            const SizedBox(height: AppSize.appSize8),
            // Artist
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: AppColor.descriptionColor,
                ),
                const SizedBox(width: AppSize.appSize6),
                Text(
                  'By ${item.artist}',
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ),
              ],
            ),
            const SizedBox(height: AppSize.appSize16),
            // Price
            Container(
              padding: AppDesign.mediumPadding,
              decoration: AppDesign.accentContainer,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.getFormattedPrice(),
                    style: AppStyle.heading3SemiBold(color: AppColor.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSize.appSize16),
            // Rating and views
            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 18,
                  color: Colors.amber,
                ),
                const SizedBox(width: AppSize.appSize4),
                Obx(() => Text(
                  controller.averageRating.value > 0
                      ? controller.averageRating.value.toStringAsFixed(1)
                      : 'No rating',
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                )),
                Obx(() => Text(
                  controller.totalReviews.value > 0
                      ? ' (${controller.totalReviews.value} reviews)'
                      : '',
                  style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                )),
                const SizedBox(width: AppSize.appSize16),
                const Icon(
                  Icons.remove_red_eye_outlined,
                  size: 18,
                  color: AppColor.descriptionColor,
                ),
                const SizedBox(width: AppSize.appSize4),
                Text(
                  '${item.views} views',
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Build details section
  Widget _buildDetailsSection() {
    return Obx(() {
      final item = controller.item.value!;
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
        padding: AppDesign.largePadding,
        decoration: AppDesign.subtleContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: AppStyle.heading4SemiBold(color: AppColor.textColor),
            ),
            const SizedBox(height: AppSize.appSize16),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Year',
              value: controller.getYearDisplay(),
            ),
            if (item.dimensions.isNotEmpty) ...[
              const Divider(height: AppSize.appSize24),
              _buildDetailRow(
                icon: Icons.straighten,
                label: 'Dimensions',
                value: item.dimensions,
              ),
            ],
            if (item.materials.isNotEmpty) ...[
              const Divider(height: AppSize.appSize24),
              _buildDetailRow(
                icon: Icons.palette,
                label: 'Materials',
                value: item.materials,
              ),
            ],
            if (item.location.isNotEmpty) ...[
              const Divider(height: AppSize.appSize24),
              _buildDetailRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: item.location,
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Build detail row helper
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColor.primaryColor,
        ),
        const SizedBox(width: AppSize.appSize12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
              const SizedBox(height: AppSize.appSize4),
              Text(
                value,
                style: AppStyle.heading5Medium(color: AppColor.textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build description section
  Widget _buildDescriptionSection() {
    return Obx(() {
      final item = controller.item.value!;
      
      if (item.description.isEmpty) return const SizedBox.shrink();
      
      return Container(
        margin: const EdgeInsets.all(AppSize.appSize16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: AppStyle.heading4SemiBold(color: AppColor.textColor),
            ),
            const SizedBox(height: AppSize.appSize12),
            Text(
              item.description,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
          ],
        ),
      );
    });
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Obx(() {
      final item = controller.item.value!;
      
      return Container(
        padding: const EdgeInsets.all(AppSize.appSize16),
        child: Row(
          children: [
            // Contact Owner button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _showContactDialog(context, item.artist),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: AppSize.appSize14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                ),
                icon: const Icon(Icons.phone, color: AppColor.whiteColor),
                label: Text(
                  'Contact Seller',
                  style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                ),
              ),
            ),
            const SizedBox(width: AppSize.appSize12),
            // Share button
            ElevatedButton(
              onPressed: () {
                // Share functionality can be added here
                Get.snackbar(
                  'Share',
                  'Share functionality coming soon!',
                  backgroundColor: AppColor.primaryColor,
                  colorText: AppColor.whiteColor,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondaryColor,
                padding: const EdgeInsets.all(AppSize.appSize14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  side: const BorderSide(color: AppColor.primaryColor),
                ),
              ),
              child: const Icon(Icons.share, color: AppColor.primaryColor),
            ),
          ],
        ),
      );
    });
  }

  /// Build reviews section
  Widget _buildReviewsSection() {
    return Obx(() {
      if (controller.isLoadingReviews.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSize.appSize24),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.all(AppSize.appSize16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: AppStyle.heading4SemiBold(color: AppColor.textColor),
                ),
                TextButton(
                  onPressed: () => _showAddReviewDialog(),
                  child: Text(
                    'Add Review',
                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSize.appSize12),
            if (controller.reviews.isEmpty)
              Container(
                padding: AppDesign.xLargePadding,
                decoration: AppDesign.subtleContainer,
                child: Center(
                  child: Text(
                    'No reviews yet. Be the first to review!',
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ),
                ),
              )
            else
              ...controller.reviews.take(3).map((review) => _buildReviewCard(review)),
            if (controller.reviews.length > 3)
              Center(
                child: TextButton(
                  onPressed: () {
                    // Show all reviews
                  },
                  child: Text(
                    'View all ${controller.reviews.length} reviews',
                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Build review card
  Widget _buildReviewCard(review) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSize.appSize12),
        padding: AppDesign.mediumPadding,
        decoration: AppDesign.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                  style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                ),
              ),
              const SizedBox(width: AppSize.appSize12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : 'Anonymous',
                      style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: AppSize.appSize6),
                        Text(
                          _formatDate(review.createdAt),
                          style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: AppSize.appSize8),
            Text(
              review.comment,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
          ],
        ],
      ),
    );
  }

  /// Format date helper
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} month${(diff.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Build similar items section
  Widget _buildSimilarItemsSection() {
    return Obx(() {
      if (controller.isLoadingSimilarItems.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSize.appSize24),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.similarItems.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: AppSize.appSize16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
              child: Text(
                'Similar Items',
                style: AppStyle.heading4SemiBold(color: AppColor.textColor),
              ),
            ),
            const SizedBox(height: AppSize.appSize12),
            SizedBox(
              height: AppSize.appSize250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                itemCount: controller.similarItems.length,
                cacheExtent: 500,
                itemBuilder: (context, index) {
                  final item = controller.similarItems[index];
                  return RepaintBoundary(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (item.id != null) {
                            Get.off(() => const ArtsAntiquesDetailsView(), arguments: item.id);
                          }
                        },
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        child: Container(
                          width: AppSize.appSize180,
                          margin: const EdgeInsets.only(right: AppSize.appSize12),
                          decoration: AppDesign.card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(AppSize.appSize12),
                                  topRight: Radius.circular(AppSize.appSize12),
                                ),
                                child: item.images.isNotEmpty
                                    ? CachedFirebaseImage(
                                        imageUrl: item.images.first,
                                        height: AppSize.appSize130,
                                        width: AppSize.appSize180,
                                        fit: BoxFit.cover,
                                        cacheWidth: 360, // 2x for better quality on retina displays
                                        cacheHeight: 260,
                                        showLoadingIndicator: true,
                                        errorWidget: Container(
                                          height: AppSize.appSize130,
                                          color: AppColor.backgroundColor,
                                          child: const Icon(Icons.image_not_supported),
                                        ),
                                      )
                                    : Container(
                                        height: AppSize.appSize130,
                                        color: AppColor.backgroundColor,
                                        child: const Icon(Icons.palette),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSize.appSize10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: AppStyle.heading6Medium(color: AppColor.textColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSize.appSize4),
                                    Text(
                                      item.artist,
                                      style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSize.appSize8),
                                    Text(
                                      _formatPrice(item.price),
                                      style: AppStyle.heading5SemiBold(color: AppColor.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Show contact dialog
  void _showContactDialog(BuildContext context, String artistName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.appSize16),
        ),
        title: Text(
          'Contact Seller',
          style: AppStyle.heading4SemiBold(color: AppColor.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Would you like to contact $artistName about this item?',
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
            const SizedBox(height: AppSize.appSize20),
            // In a real app, you would show actual contact information here
            Container(
              padding: const EdgeInsets.all(AppSize.appSize16),
              decoration: BoxDecoration(
                color: AppColor.secondaryColor,
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColor.primaryColor),
                      const SizedBox(width: AppSize.appSize12),
                      Text(
                        artistName,
                        style: AppStyle.heading5Medium(color: AppColor.textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.appSize12),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: AppColor.primaryColor),
                      const SizedBox(width: AppSize.appSize12),
                      Text(
                        'Contact details available',
                        style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Contact Info',
                'Contact functionality coming soon!',
                backgroundColor: AppColor.primaryColor,
                colorText: AppColor.whiteColor,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
            ),
            child: Text(
              'Contact',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Format price safely using PriceFormatter
  static String _formatPrice(double price) {
    return PriceFormatter.formatNumericPrice(price);
  }

  /// Show add review dialog
  void _showAddReviewDialog() {
    double rating = 5.0;
    final commentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.appSize16),
        ),
        title: Text(
          'Add Review',
          style: AppStyle.heading4SemiBold(color: AppColor.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate this item',
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
            const SizedBox(height: AppSize.appSize12),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 36,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (newRating) {
                rating = newRating;
              },
            ),
            const SizedBox(height: AppSize.appSize20),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your review...',
                hintStyle: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: const BorderSide(color: AppColor.descriptionColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: const BorderSide(color: AppColor.primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.addReview(rating, commentController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
            ),
            child: Text(
              'Submit',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }
}

