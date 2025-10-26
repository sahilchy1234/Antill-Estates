// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';

class CommonStatusBar extends StatelessWidget {
  const CommonStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppSize.appSize0,
      left: AppSize.appSize0,
      right: AppSize.appSize0,
      child: Container(
        height: MediaQuery.of(context).padding.top,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
        ),
      ),
    );
  }
}
