import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';

class FeedbackController extends GetxController {
  RxBool hasFullNameFocus = false.obs;
  RxBool hasFullNameInput = false.obs;
  RxBool hasPhoneNumberFocus = false.obs;
  RxBool hasPhoneNumberInput = false.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;
  FocusNode focusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController aboutFeedbackController = TextEditingController();
  TextEditingController selectFeedbackController = TextEditingController();

  RxBool isSelectFeedbackExpanded = false.obs;
  RxInt isSelectFeedback = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });
    phoneNumberController.addListener(() {
      hasPhoneNumberInput.value = phoneNumberController.text.isNotEmpty;
    });
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  void toggleSelectFeedbackExpansion() {
    isSelectFeedbackExpanded.value = !isSelectFeedbackExpanded.value;
  }

  void updateSelectFeedback(int index) {
    isSelectFeedback.value = index;
    selectFeedbackController.text = selectFeedbackList[index];
  }

  RxList<String> selectFeedbackList = [
    AppString.iWantReportAProblem,
    AppString.iHaveSuggestions,
    AppString.iWantToComplimentApp,
    AppString.other,
  ].obs;

  @override
  void onClose() {
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    aboutFeedbackController.dispose();
    selectFeedbackController.dispose();
    super.onClose();
  }
}
