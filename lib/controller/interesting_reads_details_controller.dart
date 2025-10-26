import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class InterestingReadsDetailsController extends GetxController {
  RxBool isAnswer1Expanded = false.obs;
  RxBool isAnswer2Expanded = false.obs;
  RxBool isAnswer3Expanded = false.obs;
  RxBool isAnswer4Expanded = false.obs;

  TextEditingController commentsController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void toggleAnswer1Expansion() {
    isAnswer1Expanded.value = !isAnswer1Expanded.value;
  }

  void toggleAnswer2Expansion() {
    isAnswer2Expanded.value = !isAnswer2Expanded.value;
  }

  void toggleAnswer3Expansion() {
    isAnswer3Expanded.value = !isAnswer3Expanded.value;
  }

  void toggleAnswer4Expansion() {
    isAnswer4Expanded.value = !isAnswer4Expanded.value;
  }

  RxList<String> readsHashtagList = [
    AppString.landAndPlot,
    AppString.helpPoint,
    AppString.owners,
    AppString.residentials,
  ].obs;

  RxList<String> interestingImageList = [
    Assets.images.read1.path,
    Assets.images.read2.path,
  ].obs;

  RxList<String> interestingTitleList = [
    AppString.readString1,
    AppString.readString2,
  ].obs;

  RxList<String> interestingDateList = [
    AppString.november23,
    AppString.october16,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    commentsController.clear();
    nameController.clear();
    emailController.clear();
  }
}
