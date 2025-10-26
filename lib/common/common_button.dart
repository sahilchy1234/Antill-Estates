import 'package:flutter/material.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';

class CommonButton extends StatelessWidget {
  const CommonButton(
      {super.key,
        this.onPressed,
        this.child,
        this.width,
        this.height,
        this.backgroundColor,
        this.elevation});

  /// Callback function triggered when the button is pressed.
  final void Function()? onPressed;

  /// The content of the button.
  final Widget? child;

  /// The width of the button. If not specified, it takes the intrinsic width.
  final double? width;

  /// The height of the button. If not specified, it takes the intrinsic height.
  final double? height;

  /// The background color of the button.
  final Color? backgroundColor;

  ///Button elevation add on button style
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height ?? AppSize.appSize52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: WidgetStatePropertyAll(elevation),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12))),
          backgroundColor: WidgetStatePropertyAll(
              backgroundColor ?? AppColor.primaryColor),
        ),
        child: child,
      ),
    );
  }
}
