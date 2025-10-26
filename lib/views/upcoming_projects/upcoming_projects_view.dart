import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_status_bar.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/controller/upcoming_projects_controller.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';
import 'package:antill_estates/utils/price_formatter.dart';
import 'package:antill_estates/services/enhanced_loading_service.dart';

class UpcomingProjectsView extends StatelessWidget {
  const UpcomingProjectsView({super.key});

  UpcomingProjectsController get controller => Get.put(UpcomingProjectsController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshProjects();
            },
            child: buildUpcomingProjects(context),
          ),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  Widget buildUpcomingProjects(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return EnhancedLoadingService.buildHomePageLoading();
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header Section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.appSize20,
                vertical: AppSize.appSize16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withValues(alpha: 0.3),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Row with Back Button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: AppSize.appSize44,
                          height: AppSize.appSize44,
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSize.appSize12),
                            border: Border.all(
                              color: AppColor.whiteColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: AppSize.appSize18,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSize.appSize20),
                  
                  // Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSize.appSize16),
                      border: Border.all(
                        color: AppColor.whiteColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        controller.updateSearchQuery(value);
                      },
                      style: AppStyle.heading5Regular(color: AppColor.whiteColor),
                      decoration: InputDecoration(
                        hintText: "Search projects...",
                        hintStyle: AppStyle.heading5Regular(color: AppColor.whiteColor.withValues(alpha: 0.7)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize16,
                          vertical: AppSize.appSize14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: AppSize.appSize20,
                          color: AppColor.whiteColor.withValues(alpha: 0.7),
                        ),
                        suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  controller.updateSearchQuery('');
                                },
                                child: Icon(
                                  Icons.clear,
                                  size: AppSize.appSize20,
                                  color: AppColor.whiteColor.withValues(alpha: 0.7),
                                ),
                              )
                            : const SizedBox()),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSize.appSize20),
                  
                  // Title and Description
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Projects",
                        style: AppStyle.heading3SemiBold(color: AppColor.whiteColor),
                      ),
                      const SizedBox(height: AppSize.appSize8),
                      Text(
                        "Discover the latest developments and investment opportunities",
                        style: AppStyle.heading5Regular(color: AppColor.whiteColor.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSize.appSize20),
                ],
              ),
            ),



            // Projects List with improved spacing
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
              child: Obx(() {
                if (controller.filteredProjects.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = controller.filteredProjects[index];
                    return _buildProjectCard(project, index);
                  },
                );
              }),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize50, bottom: AppSize.appSize32),
      );
    });
  }




  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.upcomingProjectDetailsView, arguments: {
          'project': project,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSize.appSize20),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(AppSize.appSize20),
          boxShadow: [
            BoxShadow(
              color: AppColor.descriptionColor.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColor.descriptionColor.withValues(alpha: 0.04),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image with Status Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSize.appSize20),
                    topRight: Radius.circular(AppSize.appSize20),
                  ),
                  child: project['imageUrl'] != null && project['imageUrl'].toString().startsWith('http')
                      ? CachedFirebaseImage(
                          imageUrl: project['imageUrl'],
                          width: double.infinity,
                          height: AppSize.appSize200,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.zero,
                          errorWidget: Container(
                            height: AppSize.appSize200,
                            color: AppColor.backgroundColor,
                            child: const Icon(Icons.business, size: 60),
                          ),
                        )
                      : Container(
                          height: AppSize.appSize200,
                          color: AppColor.backgroundColor,
                          child: const Icon(Icons.business, size: 60),
                        ),
                ),
                
                // Status Badge
                Positioned(
                  top: AppSize.appSize16,
                  right: AppSize.appSize16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize12,
                      vertical: AppSize.appSize6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project['status']).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppSize.appSize16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      controller.getStatusDisplayText(project['status'] ?? ''),
                      style: AppStyle.heading6Medium(color: AppColor.whiteColor),
                    ),
                  ),
                ),
                
                // Price Badge
                Positioned(
                  bottom: AppSize.appSize16,
                  left: AppSize.appSize16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize12,
                      vertical: AppSize.appSize8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      PriceFormatter.formatPrice(project['price'] ?? 'Price on Request'),
                      style: AppStyle.heading5SemiBold(color: AppColor.primaryColor),
                    ),
                  ),
                ),
              ],
            ),

            // Project Content
            Padding(
              padding: const EdgeInsets.all(AppSize.appSize20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    project['title'] ?? 'Project',
                    style: AppStyle.heading4SemiBold(color: AppColor.textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSize.appSize12),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: AppSize.appSize16,
                        color: AppColor.descriptionColor,
                      ),
                      const SizedBox(width: AppSize.appSize6),
                      Expanded(
                        child: Text(
                          project['address'] ?? 'Address not available',
                          style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.appSize8),

                  // Builder
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: AppSize.appSize16,
                        color: AppColor.descriptionColor,
                      ),
                      const SizedBox(width: AppSize.appSize6),
                      Expanded(
                        child: Text(
                          project['builder'] ?? 'Builder not specified',
                          style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.appSize8),

                  // Flat Sizes
                  Row(
                    children: [
                      Icon(
                        Icons.home,
                        size: AppSize.appSize16,
                        color: AppColor.descriptionColor,
                      ),
                      const SizedBox(width: AppSize.appSize6),
                      Expanded(
                        child: Text(
                          project['flatSize'] ?? 'Flat sizes not specified',
                          style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.appSize16),

                  // Description
                  Text(
                    project['description'] ?? 'No description available',
                    style: AppStyle.heading6Regular(color: AppColor.textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSize.appSize16),

                  // View Details Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSize.appSize14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.primaryColor,
                          AppColor.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withValues(alpha: 0.3),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "View Details",
                        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSize.appSize32),
      child: Column(
        children: [
          Icon(
            Icons.business_outlined,
            size: AppSize.appSize64,
            color: AppColor.descriptionColor,
          ),
          const SizedBox(height: AppSize.appSize16),
          Text(
            "No Projects Found",
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize8),
          Text(
            "No upcoming projects match your current filters",
            style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.appSize24),
          GestureDetector(
            onTap: () {
              controller.updateStatusFilter('');
              controller.updateSearchQuery('');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.appSize24,
                vertical: AppSize.appSize12,
              ),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
              child: Text(
                "Clear Filters",
                style: AppStyle.heading5Medium(color: AppColor.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppColor.warningColor;
      case 'launched':
        return AppColor.infoColor;
      case 'ongoing':
        return AppColor.successColor;
      case 'completed':
        return AppColor.primaryColor;
      default:
        return AppColor.descriptionColor;
    }
  }



}
