import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/controller/bottom_bar_controller.dart';
import 'package:antill_estates/views/drawer/drawer_view.dart';
import 'package:antill_estates/views/home/home_view.dart';
import 'package:antill_estates/views/profile/profile_view.dart';
import 'package:antill_estates/views/saved/saved_properties_view.dart';
import 'package:antill_estates/views/arts_antiques/arts_antiques_view.dart';

class BottomBarView extends StatefulWidget {
  final int initialIndex;
  const BottomBarView({super.key, this.initialIndex = 0});

  @override
  State<BottomBarView> createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  late final BottomBarController bottomBarController;

  @override
  void initState() {
    super.initState();
    bottomBarController = Get.put(
      BottomBarController(initialIndex: widget.initialIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      drawer: const DrawerView(),
      body: buildPageView(),
      bottomNavigationBar: buildBottomNavBar(context),
    );
  }

  Widget buildPageView() {
    return PageView(
      physics: const BouncingScrollPhysics(),
      controller: bottomBarController.pageController,
      onPageChanged: (int index) {
        bottomBarController.selectIndex.value = index;
      },
      children: const [
        RepaintBoundary(child: HomeView()),
        RepaintBoundary(child: ArtsAntiquesView()),
        RepaintBoundary(child: SavedPropertiesView()),
        RepaintBoundary(child: ProfileView()),
      ],
    );
  }

  Widget buildBottomNavBar(BuildContext context) {
    return Container(
      height: AppSize.appSize72,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          bottomBarController.bottomBarImageList.length,
          (index) => _buildNavItem(index),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    return Expanded(
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () => bottomBarController.updateIndex(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.transparent,
            child: Obx(() {
              final isSelected = bottomBarController.selectIndex.value == index;
              
              return AnimatedBuilder(
                animation: bottomBarController.iconAnimationControllers[index],
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with background
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.all(isSelected ? AppSize.appSize10 : AppSize.appSize8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColor.primaryColor.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.9,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Image.asset(
                            bottomBarController.bottomBarImageList[index],
                            width: AppSize.appSize22,
                            height: AppSize.appSize22,
                            color: isSelected
                                ? AppColor.whiteColor
                                : AppColor.textColor.withOpacity(0.6),
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSize.appSize4),
                      
                      // Label
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: isSelected ? 11 : 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColor.primaryColor
                              : AppColor.textColor.withOpacity(0.6),
                        ),
                        child: Text(
                          bottomBarController.bottomBarMenuNameList[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
