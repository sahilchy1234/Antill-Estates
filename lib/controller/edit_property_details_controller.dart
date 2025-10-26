import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/services/property_service.dart';

class EditPropertyDetailsController extends GetxController {
  Rx<Property?> property = Rx<Property?>(null);
  RxString currentSection = 'basic'.obs;
  RxBool isLoading = false.obs;
  
  RxInt selectProperty = 0.obs;
  RxBool hasPhoneNumberFocus = true.obs;
  RxBool hasPhoneNumberInput = true.obs;
  FocusNode phoneNumberFocusNode = FocusNode();
  RxInt selectPropertyLooking = 0.obs;
  RxInt selectPropertyType = 0.obs;
  RxInt selectPropertyType2 = 0.obs;

  // Text controllers for form fields
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController subLocalityController = TextEditingController();
  TextEditingController plotAreaController = TextEditingController();
  TextEditingController builtUpAreaController = TextEditingController();
  TextEditingController superBuiltUpAreaController = TextEditingController();
  TextEditingController totalFloorsController = TextEditingController();
  TextEditingController noOfBedroomsController = TextEditingController();
  TextEditingController noOfBathroomsController = TextEditingController();
  TextEditingController noOfBalconiesController = TextEditingController();
  TextEditingController expectedPriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Selected amenities and features
  RxList<String> selectedAmenities = <String>[].obs;
  RxList<String> selectedWaterSource = <String>[].obs;
  RxList<String> selectedOtherFeatures = <String>[].obs;
  RxList<String> selectedLocationAdvantages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    mobileNumberController.addListener(() {
      hasPhoneNumberInput.value = mobileNumberController.text.isNotEmpty;
    });
    
    // Get property data from arguments
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      property.value = args['property'] as Property;
      currentSection.value = args['section'] ?? 'basic';
      _populateFields();
    }
  }

  void _populateFields() {
    if (property.value == null) return;
    
    final prop = property.value!;
    
    // Populate text fields
    mobileNumberController.text = prop.contactPhone;
    cityController.text = prop.city;
    localityController.text = prop.locality;
    subLocalityController.text = prop.subLocality;
    plotAreaController.text = prop.plotArea;
    builtUpAreaController.text = prop.builtUpArea;
    superBuiltUpAreaController.text = prop.superBuiltUpArea;
    totalFloorsController.text = prop.totalFloors;
    noOfBedroomsController.text = prop.noOfBedrooms;
    noOfBathroomsController.text = prop.noOfBathrooms;
    noOfBalconiesController.text = prop.noOfBalconies;
    expectedPriceController.text = prop.expectedPrice;
    descriptionController.text = prop.description;
    
    // Set selected values
    selectPropertyLooking.value = propertyLookingList.indexOf(prop.propertyLooking);
    selectPropertyType.value = propertyTypeList.indexOf(prop.category);
    selectPropertyType2.value = propertyType2List.indexOf(prop.propertyType);
    
    // Set amenities and features
    selectedAmenities.value = List.from(prop.amenities);
    selectedWaterSource.value = List.from(prop.waterSource);
    selectedOtherFeatures.value = List.from(prop.otherFeatures);
    selectedLocationAdvantages.value = List.from(prop.locationAdvantages);
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  void updatePropertyLooking(int index) {
    selectPropertyLooking.value = index;
  }

  void updatePropertyType(int index) {
    selectPropertyType.value = index;
  }

  void updateSelectProperty2(int index) {
    selectPropertyType2.value = index;
  }

  RxList<String> propertyList = [
    AppString.basicDetails,
    AppString.propertyDetails,
    AppString.pricingAndPhotos,
    AppString.amenities,
  ].obs;

  RxList<String> propertyLookingList = [
    AppString.buy,
    AppString.rent,
    AppString.pg,
  ].obs;

  RxList<String> propertyTypeList = [
    AppString.residential,
    AppString.commercial,
  ].obs;

  RxList<String> propertyTypeImageList = [
    Assets.images.flatApartment.path,
    Assets.images.independentHouse.path,
    Assets.images.builderFloor.path,
    Assets.images.builderFloor.path,
    Assets.images.plotLand.path,
    Assets.images.officeSpace.path,
    Assets.images.other.path,
  ].obs;

  RxList<String> propertyType2List = [
    AppString.flatApartment,
    AppString.independentHouse,
    AppString.builderFloor,
    AppString.plotLand,
    AppString.officeSpace,
    AppString.other,
  ].obs;

  // Save property changes
  Future<void> saveProperty() async {
    if (property.value == null) return;
    
    try {
      isLoading.value = true;
      
      // Create updated property object
      final updatedProperty = Property(
        id: property.value!.id,
        userId: property.value!.userId,
        propertyLooking: propertyLookingList[selectPropertyLooking.value],
        category: propertyTypeList[selectPropertyType.value],
        propertyType: propertyType2List[selectPropertyType2.value],
        city: cityController.text.trim(),
        locality: localityController.text.trim(),
        subLocality: subLocalityController.text.trim(),
        plotArea: plotAreaController.text.trim(),
        plotAreaUnit: property.value!.plotAreaUnit,
        builtUpArea: builtUpAreaController.text.trim(),
        superBuiltUpArea: superBuiltUpAreaController.text.trim(),
        otherRooms: property.value!.otherRooms,
        totalFloors: totalFloorsController.text.trim(),
        noOfBedrooms: noOfBedroomsController.text.trim(),
        noOfBathrooms: noOfBathroomsController.text.trim(),
        noOfBalconies: noOfBalconiesController.text.trim(),
        coveredParking: property.value!.coveredParking,
        openParking: property.value!.openParking,
        availabilityStatus: property.value!.availabilityStatus,
        propertyPhotos: property.value!.propertyPhotos,
        ownership: property.value!.ownership,
        expectedPrice: expectedPriceController.text.trim(),
        priceDetails: property.value!.priceDetails,
        description: descriptionController.text.trim(),
        amenities: selectedAmenities,
        waterSource: selectedWaterSource,
        otherFeatures: selectedOtherFeatures,
        locationAdvantages: selectedLocationAdvantages,
        contactName: property.value!.contactName,
        contactPhone: mobileNumberController.text.trim(),
        contactEmail: property.value!.contactEmail,
        contactAvatar: property.value!.contactAvatar,
        createdAt: property.value!.createdAt,
        updatedAt: DateTime.now(),
        isActive: property.value!.isActive,
      );
      
      // Update property in Firebase
      await PropertyService.updateProperty(property.value!.id!, updatedProperty);
      
      // Update local property
      property.value = updatedProperty;
      
      Get.snackbar(
        'Success',
        'Property updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.back();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update property: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    phoneNumberFocusNode.dispose();
    mobileNumberController.dispose();
    cityController.dispose();
    localityController.dispose();
    subLocalityController.dispose();
    plotAreaController.dispose();
    builtUpAreaController.dispose();
    superBuiltUpAreaController.dispose();
    totalFloorsController.dispose();
    noOfBedroomsController.dispose();
    noOfBathroomsController.dispose();
    noOfBalconiesController.dispose();
    expectedPriceController.dispose();
    descriptionController.dispose();
  }
}
