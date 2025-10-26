import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddReviewForBrokerController extends GetxController {
  TextEditingController writeAReviewController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    writeAReviewController.clear();
  }
}
