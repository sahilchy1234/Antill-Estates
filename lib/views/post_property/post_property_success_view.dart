import 'package:flutter/cupertino.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/gen/assets.gen.dart';

postPropertySuccessDialogue() {
  return buildPostPropertySuccessLoader();
}

Widget buildPostPropertySuccessLoader() {
  return Center(
  child: Image.asset(
    Assets.images.loader.path,
    width: AppSize.appSize150,
  ),
);
}
