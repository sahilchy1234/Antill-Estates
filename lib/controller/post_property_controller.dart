import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';

import 'package:antill_estates/services/property_service.dart';

import '../model/property_model.dart';

class PostPropertyController extends GetxController {
  RxBool hasFocus = false.obs;
  RxBool hasInput = false.obs;
  RxInt selectPropertyLooking = 0.obs;
  RxInt selectCategories = 0.obs;
  RxInt selectPropertyType = 0.obs;
  RxBool isLoading = false.obs;

  FocusNode focusNode = FocusNode();
  TextEditingController mobileController = TextEditingController();

  // Property data controllers (add these from your other controllers)
  TextEditingController cityController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController subLocalityController = TextEditingController();
  TextEditingController plotAreaController = TextEditingController();
  TextEditingController expectedPriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Observable lists for selections
  RxList<String> selectedAmenities = <String>[].obs;
  RxList<String> selectedWaterSource = <String>[].obs;
  RxList<String> selectedOtherFeatures = <String>[].obs;
  RxList<String> selectedLocationAdvantages = <String>[].obs;
  RxList<File> selectedImages = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      hasFocus.value = focusNode.hasFocus;
    });
    mobileController.addListener(() {
      hasInput.value = mobileController.text.isNotEmpty;
    });
  }

  void updatePropertyLooking(int index) {
    selectPropertyLooking.value = index;
  }

  void updateCategories(int index) {
    selectCategories.value = index;
  }

  void updateSelectProperty(int index) {
    selectPropertyType.value = index;
  }

  // Post property to Firebase
  Future<void> postProperty() async {
    try {
      isLoading.value = true;

      // Upload images first
      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        imageUrls = await PropertyService.uploadPropertyImages(selectedImages);
      }

      // Create property object
      final property = Property(
        propertyLooking: propertyLookingList[selectPropertyLooking.value],
        category: categoriesList[selectCategories.value],
        propertyType: propertyTypeList[selectPropertyType.value],
        city: cityController.text.trim(),
        locality: localityController.text.trim(),
        subLocality: subLocalityController.text.trim(),
        plotArea: plotAreaController.text.trim(),
        plotAreaUnit: 'sq ft', // Default unit
        totalFloors: '1', // You can get this from your form
        noOfBedrooms: '1', // From your bedroom selection
        noOfBathrooms: '1', // From your bathroom selection
        noOfBalconies: '0', // From your balcony selection
        availabilityStatus: 'Ready to Move', // From availability selection
        propertyPhotos: imageUrls,
        ownership: 'Individual', // From ownership selection
        expectedPrice: expectedPriceController.text.trim(),
        description: descriptionController.text.trim(),
        amenities: selectedAmenities,
        waterSource: selectedWaterSource,
        otherFeatures: selectedOtherFeatures,
        locationAdvantages: selectedLocationAdvantages,
        contactName: '', // Will be populated by PropertyService from user data
        contactPhone: mobileController.text.trim(), // Use phone number from mobile controller
        contactAvatar: '', // Will be populated by PropertyService from user data
      );

      // Post to Firebase
      final propertyId = await PropertyService.postProperty(property);

      // Show success message
      Get.snackbar(
        'Success',
        'Property posted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to success page
      Get.offAllNamed('/property-success', arguments: propertyId);

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to post property: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  RxList propertyLookingList = [
    AppString.buy,
    AppString.rent,
    AppString.pg,
  ].obs;

  RxList categoriesList = [
    AppString.residential,
    AppString.commercial,
  ].obs;

  RxList propertyTypeList = [
    AppString.flatApartment,
    AppString.independentHouse,
    AppString.builderFloor,
    AppString.residentialPlot,
    AppString.plotLand,
    AppString.officeSpace,
    AppString.other,
  ].obs;

  RxList propertyTypeImageList = [
    Assets.images.flatApartment.path,
    Assets.images.independentHouse.path,
    Assets.images.builderFloor.path,
    Assets.images.builderFloor.path,
    Assets.images.plotLand.path,
    Assets.images.officeSpace.path,
    Assets.images.other.path,
  ].obs;

  @override
  void onClose() {
    focusNode.dispose();
    mobileController.dispose();
    cityController.dispose();
    localityController.dispose();
    subLocalityController.dispose();
    plotAreaController.dispose();
    expectedPriceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
