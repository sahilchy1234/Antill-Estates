import 'package:get/get.dart';

class AddAmenitiesController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<bool> selectAmenities = <bool>[].obs;
  RxList<bool> selectWaterSource = <bool>[].obs;
  RxList<bool> selectOtherFeatures = <bool>[].obs;
  RxList<bool> selectLocationAdvantages = <bool>[].obs;

  RxList amenitiesList = [
    "Swimming Pool",
    "Gym",
    "Garden",
    "Security",
    "Parking",
    "Power Backup",
    "Club House",
    "Kids Play Area",
  ].obs;

  RxList waterSourceList = [
    "Municipal Water",
    "Borewell",
    "Both",
  ].obs;

  RxList otherFeaturesList = [
    "Furnished",
    "Semi Furnished",
    "Near School",
    "Near Hospital",
    "Near Market",
  ].obs;

  RxList locationAdvantagesList = [
    "Close to Metro",
    "Close to Bus Stop",
    "Close to Airport",
    "Close to Highway",
    "Close to Mall",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize boolean lists
    selectAmenities.assignAll(List.filled(amenitiesList.length, false));
    selectWaterSource.assignAll(List.filled(waterSourceList.length, false));
    selectOtherFeatures.assignAll(List.filled(otherFeaturesList.length, false));
    selectLocationAdvantages.assignAll(List.filled(locationAdvantagesList.length, false));
  }

  void updateAmenities(int index) {
    selectAmenities[index] = !selectAmenities[index];
  }

  void updateWaterSource(int index) {
    selectWaterSource[index] = !selectWaterSource[index];
  }

  void updateOtherFeatures(int index) {
    selectOtherFeatures[index] = !selectOtherFeatures[index];
  }

  void updateLocationAdvantages(int index) {
    selectLocationAdvantages[index] = !selectLocationAdvantages[index];
  }
}
