import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:antill_estates/configs/app_string.dart';

class AddPhotoAndPricingController extends GetxController {
  TextEditingController expectedPriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController(); // Alternative name used in AddAmenitiesView

  RxInt selectOwnership = 0.obs;
  RxInt selectPriceDetails = 0.obs;
  RxList<XFile> images = <XFile>[].obs;
  RxList<File> selectedImages = <File>[].obs; // For Firebase upload
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Sync the two controllers
    expectedPriceController.addListener(() {
      priceController.text = expectedPriceController.text;
    });
    priceController.addListener(() {
      expectedPriceController.text = priceController.text;
    });
  }

  Future<void> pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      // Limit to 5 images maximum
      final availableSlots = 5 - images.length;
      final imagesToAdd = picked.take(availableSlots).toList();

      images.addAll(imagesToAdd);

      // Convert XFile to File for Firebase
      for (XFile xFile in imagesToAdd) {
        selectedImages.add(File(xFile.path));
      }
    }
  }

  Future<void> pickSingleImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && images.length < 5) {
      images.add(picked);
      selectedImages.add(File(picked.path));
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null && images.length < 5) {
      images.add(picked);
      selectedImages.add(File(picked.path));
    }
  }

  void removeImage(int index) {
    if (index < images.length) {
      images.removeAt(index);
      selectedImages.removeAt(index);
    }
  }

  void updateOwnership(int index) {
    selectOwnership.value = index;
  }

  void updatePriceDetails(int index) {
    selectPriceDetails.value = index;
  }

  String get selectedOwnership => ownershipList[selectOwnership.value];

  String get selectedPriceDetail => priceDetailsList[selectPriceDetails.value];

  RxList<String> ownershipList = [
    AppString.freehold,
    AppString.coOperativeSociety,
    AppString.powerOfAttorney,
    AppString.leasehold,
  ].obs;

  RxList<String> priceDetailsList = [
    AppString.allInclusivePrice,
    AppString.priceNegotiable,
    AppString.taxAndGovtCharges,
  ].obs;

  // Validation methods
  bool get hasImages => images.isNotEmpty;

  bool get isPriceValid => expectedPriceController.text.trim().isNotEmpty;

  bool get isDescriptionValid => descriptionController.text.trim().isNotEmpty;

  bool get isFormValid => isPriceValid && isDescriptionValid;

  // Clear all data
  void clearData() {
    expectedPriceController.clear();
    descriptionController.clear();
    priceController.clear();
    images.clear();
    selectedImages.clear();
    selectOwnership.value = 0;
    selectPriceDetails.value = 0;
  }

  @override
  void dispose() {
    expectedPriceController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
