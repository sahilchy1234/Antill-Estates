import 'dart:io';
import 'package:flutter/material.dart';
import 'package:antill_estates/configs/app_color.dart';

class CachedAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Widget? fallbackIcon;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const CachedAvatarImage({
    super.key,
    this.imageUrl,
    this.radius = 22.0,
    this.backgroundColor,
    this.fallbackIcon,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getCachedImagePath(),
      builder: (context, snapshot) {
        Widget avatarWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show network image while loading cache
          avatarWidget = _buildNetworkAvatar();
        } else if (snapshot.hasData && snapshot.data != null) {
          // Use cached image
          avatarWidget = _buildCachedAvatar(snapshot.data!);
        } else {
          // Fallback to network image or default
          avatarWidget = _buildNetworkAvatar();
        }

        // Add border if requested
        if (showBorder) {
          avatarWidget = Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? AppColor.primaryColor,
                width: borderWidth,
              ),
            ),
            child: avatarWidget,
          );
        }

        return avatarWidget;
      },
    );
  }

  Future<String?> _getCachedImagePath() async {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return null;
    }

    // Use network image with built-in caching for now
    // Future: Implement advanced avatar caching
    return null;
  }

  Widget _buildCachedAvatar(String cachedPath) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColor.whiteColor,
      backgroundImage: FileImage(File(cachedPath)),
      onBackgroundImageError: (exception, stackTrace) {
        print('Error loading cached avatar: $exception');
      },
    );
  }

  Widget _buildNetworkAvatar() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildDefaultAvatar();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColor.whiteColor,
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        print('Error loading network avatar: $exception');
      },
      child: null,
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColor.whiteColor,
      child: fallbackIcon ?? Icon(
        Icons.person,
        size: radius,
        color: AppColor.descriptionColor,
      ),
    );
  }
}
