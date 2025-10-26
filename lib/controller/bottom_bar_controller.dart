import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/controller/home_controller.dart';

class BottomBarController extends GetxController with GetTickerProviderStateMixin {
  RxInt selectIndex = 0.obs;
  late PageController pageController;
  late List<AnimationController> iconAnimationControllers;
  late List<Animation<double>> iconScaleAnimations;
  
  // Animation for the background pill
  RxDouble pillOffset = 0.0.obs;
  RxDouble pillWidth = 0.0.obs;
  
  // Track last home refresh to prevent excessive loading
  DateTime? _lastHomeRefresh;
  static const _minRefreshInterval = Duration(seconds: 3);

  BottomBarController({int initialIndex = 0}) {
    selectIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
  }

  @override
  void onInit() {
    super.onInit();
    
    // Initialize animation controllers for each tab
    iconAnimationControllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    
    // Create scale animations with spring effect
    iconScaleAnimations = iconAnimationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      );
    }).toList();
    
    // Animate the initial selected tab
    if (selectIndex.value < iconAnimationControllers.length) {
      iconAnimationControllers[selectIndex.value].forward();
    }
  }

  void updateIndex(int index) {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // If already on the same page, add a bounce animation
    if (selectIndex.value == index) {
      _bounceTap(index);
      // Only refresh if it's been a while since last refresh
      if (index == 0 && _shouldRefreshHome()) {
        _refreshHomeData();
      }
      return;
    }
    
    // Animate out the old icon
    if (selectIndex.value < iconAnimationControllers.length) {
      iconAnimationControllers[selectIndex.value].reverse();
    }
    
    // Update the selected index
    selectIndex.value = index;
    
    // Animate in the new icon
    if (index < iconAnimationControllers.length) {
      iconAnimationControllers[index].forward();
    }
    
    // Navigate to the page with smooth animation
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubicEmphasized,
    );

    // Don't auto-refresh on every tab change - only on explicit request
    // This prevents excessive Firebase calls
  }
  
  bool _shouldRefreshHome() {
    if (_lastHomeRefresh == null) return true;
    final timeSinceLastRefresh = DateTime.now().difference(_lastHomeRefresh!);
    return timeSinceLastRefresh > _minRefreshInterval;
  }
  
  void _bounceTap(int index) {
    // Create a bounce effect when tapping the same tab
    if (index < iconAnimationControllers.length) {
      iconAnimationControllers[index].reverse().then((_) {
        iconAnimationControllers[index].forward();
      });
    }
  }

  void _refreshHomeData() {
    // Get the home controller and refresh data
    try {
      final homeController = Get.find<HomeController>();
      _lastHomeRefresh = DateTime.now();
      homeController.refreshHomeData();
      print('🔄 Manual home refresh triggered');
    } catch (e) {
      // Home controller not found, this is normal if we're not on home page
      print('Home controller not found: $e');
    }
  }

  RxList<String> bottomBarImageList = [
    Assets.images.home.path,
    Assets.images.task.path,  // Arts & Antiques tab (using task icon)
    Assets.images.save.path,
    Assets.images.user.path,
  ].obs;

  RxList<String> bottomBarMenuNameList = [
    AppString.home,
    "Arts",  // Arts & Antiques tab
    AppString.saved,
    AppString.profile,
  ].obs;
  
  @override
  void onClose() {
    for (var controller in iconAnimationControllers) {
      controller.dispose();
    }
    pageController.dispose();
    super.onClose();
  }
}
