import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasFocus;
  final  bool hasInput;
  final String hintText;
  final String labelText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function()? onTapCountryPicker;
  final bool ? readOnly;
  final BoxBorder? border;
  final TextStyle? labelStyle;
  final TextStyle? textfieldStyle;

  CommonTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.hasInput,
    required this.hintText,
    required this.labelText,
    this.keyboardType,
    this.inputFormatters,
    this.onTapCountryPicker,
    this.readOnly,
    this.border,
    this.labelStyle,
    this.textfieldStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: hasFocus || hasInput ? AppSize.appSize6 : AppSize.appSize14,
        bottom: hasFocus || hasInput ? AppSize.appSize8 : AppSize.appSize14,
        left: hasFocus ? AppSize.appSize0 : AppSize.appSize16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: border ?? Border.all(
          color: hasFocus || hasInput ? AppColor.primaryColor : AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasFocus || hasInput)
            Padding(
              padding: EdgeInsets.only(
                left: hasInput ? (hasFocus ? AppSize.appSize16 : AppSize.appSize0) : AppSize.appSize16,
                bottom: hasInput ? AppSize.appSize2 : AppSize.appSize2,
              ),
              child: Text(
                labelText,
                style: labelStyle ?? AppStyle.heading6Regular(color: AppColor.primaryColor),
              ),
            ),
          SizedBox(
            height: AppSize.appSize27,
            child: TextFormField(
              focusNode: focusNode,
              controller: controller,
              cursorColor: AppColor.primaryColor,
              keyboardType: keyboardType,
              style: textfieldStyle ?? AppStyle.heading4Regular(color: AppColor.textColor),
              inputFormatters: inputFormatters,
              readOnly: readOnly ?? false,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: hasFocus ? AppSize.appSize16 : AppSize.appSize0,
                  vertical: AppSize.appSize0,
                ),
                isDense: true,
                hintText: hasFocus ? '' : hintText,
                hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
