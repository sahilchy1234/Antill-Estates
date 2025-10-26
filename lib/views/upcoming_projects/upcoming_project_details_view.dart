import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/common/common_status_bar.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';
import 'package:antill_estates/utils/price_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class UpcomingProjectDetailsView extends StatelessWidget {
  const UpcomingProjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final project = Get.arguments?['project'] as Map<String, dynamic>?;
    
    if (project == null) {
      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        body: Center(
          child: Text(
            'Project details not available',
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: buildProjectDetails(context, project),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  Widget buildProjectDetails(BuildContext context, Map<String, dynamic> project) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Image
          Stack(
            children: [
              // Project Image
              Container(
                height: AppSize.appSize300,
                width: double.infinity,
                child: (project['imageUrl'] ?? project['image']) != null && (project['imageUrl'] ?? project['image']).toString().startsWith('http')
                    ? CachedFirebaseImage(
                        imageUrl: project['imageUrl'] ?? project['image'],
                        width: double.infinity,
                        height: AppSize.appSize300,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.zero,
                        errorWidget: Container(
                          height: AppSize.appSize300,
                          color: AppColor.backgroundColor,
                          child: const Icon(Icons.business, size: 80),
                        ),
                      )
                    : Container(
                        height: AppSize.appSize300,
                        color: AppColor.backgroundColor,
                        child: const Icon(Icons.business, size: 80),
                      ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Back Button
              Positioned(
                top: AppSize.appSize50,
                left: AppSize.appSize16,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: AppSize.appSize40,
                    height: AppSize.appSize40,
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppSize.appSize20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: AppSize.appSize18,
                        color: AppColor.textColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Share Button
              Positioned(
                top: AppSize.appSize50,
                right: AppSize.appSize16,
                child: GestureDetector(
                  onTap: () => _shareProject(project),
                  child: Container(
                    width: AppSize.appSize40,
                    height: AppSize.appSize40,
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppSize.appSize20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.share,
                        size: AppSize.appSize18,
                        color: AppColor.textColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Project Title and Status
              Positioned(
                bottom: AppSize.appSize20,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['title'] ?? 'Project',
                      style: AppStyle.heading3SemiBold(color: AppColor.whiteColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSize.appSize8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize12,
                            vertical: AppSize.appSize6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(project['status']).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSize.appSize16),
                            border: Border.all(
                              color: _getStatusColor(project['status']),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getStatusDisplayText(project['status']),
                            style: AppStyle.heading6Medium(
                              color: _getStatusColor(project['status']),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSize.appSize12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize12,
                            vertical: AppSize.appSize6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSize.appSize16),
                            border: Border.all(
                              color: AppColor.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            PriceFormatter.formatPrice(project['price'] ?? 'Price on Request'),
                            style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Project Details
          Padding(
            padding: const EdgeInsets.all(AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                _buildSectionTitle("Project Information"),
                const SizedBox(height: AppSize.appSize12),
                _buildInfoCard([
                  _buildInfoRow(Icons.location_on, "Address", project['address'] ?? 'Not specified'),
                  _buildInfoRow(Icons.business, "Builder", project['builder'] ?? 'Not specified'),
                  _buildInfoRow(Icons.home, "Flat Sizes", project['flatSize'] ?? 'Not specified'),
                  _buildInfoRow(Icons.calendar_today, "Launch Date", _formatDate(project['launchDate'])),
                  _buildInfoRow(Icons.event, "Completion Date", _formatDate(project['completionDate'])),
                ]),

                const SizedBox(height: AppSize.appSize24),

                // Description
                _buildSectionTitle("Description"),
                const SizedBox(height: AppSize.appSize12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Text(
                    project['description'] ?? 'No description available',
                    style: AppStyle.heading6Regular(color: AppColor.textColor),
                  ),
                ),

                const SizedBox(height: AppSize.appSize24),

                // Amenities
                if (project['amenities'] != null && (project['amenities'] as List).isNotEmpty) ...[
                  _buildSectionTitle("Amenities"),
                  const SizedBox(height: AppSize.appSize12),
                  _buildAmenitiesGrid(project['amenities'] as List),
                  const SizedBox(height: AppSize.appSize24),
                ],

                // Contact Information (only show if contact info exists or provide default)
                _buildSectionTitle("Contact Information"),
                const SizedBox(height: AppSize.appSize12),
                _buildContactCard(project),

                const SizedBox(height: AppSize.appSize24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _callProject(project),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSize.appSize16),
                          decoration: BoxDecoration(
                            color: AppColor.successColor,
                            borderRadius: BorderRadius.circular(AppSize.appSize12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                size: AppSize.appSize18,
                                color: AppColor.whiteColor,
                              ),
                              const SizedBox(width: AppSize.appSize8),
                              Text(
                                "Call",
                                style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.appSize12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _emailProject(project),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSize.appSize16),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(AppSize.appSize12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email,
                                size: AppSize.appSize18,
                                color: AppColor.whiteColor,
                              ),
                              const SizedBox(width: AppSize.appSize8),
                              Text(
                                "Email",
                                style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSize.appSize32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppStyle.heading4SemiBold(color: AppColor.textColor),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        boxShadow: [
          BoxShadow(
            color: AppColor.descriptionColor.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.appSize12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppSize.appSize18,
            color: AppColor.primaryColor,
          ),
          const SizedBox(width: AppSize.appSize12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppStyle.heading6Medium(color: AppColor.descriptionColor),
                ),
                Text(
                  value,
                  style: AppStyle.heading5Regular(color: AppColor.textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid(List amenities) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        boxShadow: [
          BoxShadow(
            color: AppColor.descriptionColor.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: AppSize.appSize8,
        runSpacing: AppSize.appSize8,
        children: amenities.map<Widget>((amenity) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.appSize12,
              vertical: AppSize.appSize6,
            ),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize16),
              border: Border.all(
                color: AppColor.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              amenity.toString(),
              style: AppStyle.heading6Medium(color: AppColor.primaryColor),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> project) {
    final contactInfo = project['contactInfo'] as Map<String, dynamic>?;
    final phone = contactInfo?['phone'] ?? '+1 (555) 123-4567'; // Default phone
    final email = contactInfo?['email'] ?? 'info@antillestates.com'; // Default email

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        boxShadow: [
          BoxShadow(
            color: AppColor.descriptionColor.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone, "Phone", phone),
          _buildInfoRow(Icons.email, "Email", email),
        ],
      ),
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'launched':
        return 'Launched';
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Not specified';
    }
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _shareProject(Map<String, dynamic> project) {
    // Implement sharing functionality
    Get.snackbar(
      'Share',
      'Sharing functionality will be implemented',
      backgroundColor: AppColor.primaryColor,
      colorText: AppColor.whiteColor,
    );
  }

  void _callProject(Map<String, dynamic> project) async {
    final contactInfo = project['contactInfo'] as Map<String, dynamic>?;
    final phone = contactInfo?['phone'] ?? '+1 (555) 123-4567'; // Use default if not available
    
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not make phone call',
        backgroundColor: AppColor.negativeColor,
        colorText: AppColor.whiteColor,
      );
    }
  }

  void _emailProject(Map<String, dynamic> project) async {
    final contactInfo = project['contactInfo'] as Map<String, dynamic>?;
    final email = contactInfo?['email'] ?? 'info@antillestates.com'; // Use default if not available
    
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Inquiry about ${project['title']}',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not open email client',
        backgroundColor: AppColor.negativeColor,
        colorText: AppColor.whiteColor,
      );
    }
  }
}
