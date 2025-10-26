import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';

class AddPropertyDetailsController extends GetxController {
  // Text Controllers
  TextEditingController cityController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController subLocalityController = TextEditingController();
  TextEditingController plotAreaController = TextEditingController();
  TextEditingController builtUpAreaController = TextEditingController();
  TextEditingController superBuiltUpAreaController = TextEditingController();
  TextEditingController totalFloorsController = TextEditingController();

  // Selection Indices
  RxInt selectRoom1 = 0.obs;
  RxInt selectRoom2 = 0.obs;
  RxInt selectBedRoom = 0.obs;
  RxInt selectBathRoom = 0.obs;
  RxInt selectBalconies = 0.obs;
  RxInt selectStatus = 0.obs;
  RxInt selectOwnership = 0.obs; // Added for ownership selection

  // Parking Counters
  RxInt count = 0.obs; // Covered parking count
  RxInt countOpen = 0.obs; // Open parking count

  // Button States
  RxString selectedButton = ''.obs;
  RxString selectedOpenButton = ''.obs;
  RxBool isCityFilled = false.obs;

  // Getters for easy access to selected values
  int? get selectedBedrooms => selectBedRoom.value < bedRoomList.length ?
  (bedRoomList[selectBedRoom.value] == AppString.more ? null : int.tryParse(bedRoomList[selectBedRoom.value])) : null;

  int? get selectedBathrooms => selectBathRoom.value < bathRoomsList.length ?
  (bathRoomsList[selectBathRoom.value] == AppString.more ? null : int.tryParse(bathRoomsList[selectBathRoom.value])) : null;

  int? get selectedBalconies => selectBalconies.value < balconiesList.length ?
  (balconiesList[selectBalconies.value] == AppString.more ? null : int.tryParse(balconiesList[selectBalconies.value])) : null;

  String get selectedAvailability => selectStatus.value < availabilityStatusList.length ?
  availabilityStatusList[selectStatus.value] : '';

  String get selectedOwnership => selectOwnership.value < ownershipList.length ?
  ownershipList[selectOwnership.value] : '';

  int get coveredParking => count.value;
  int get openParking => countOpen.value;

  // Get selected other rooms
  List<String> get selectedOtherRooms {
    List<String> selected = [];
    if (selectRoom1.value > 0) {
      selected.add(otherRoomList1[selectRoom1.value - 1]);
    }
    if (selectRoom2.value > 0) {
      selected.add(otherRoomList2[selectRoom2.value - 1]);
    }
    return selected;
  }

  // Validation
  bool get isCityValid => cityController.text.trim().isNotEmpty;
  bool get isLocalityValid => localityController.text.trim().isNotEmpty;
  bool get isPlotAreaValid => plotAreaController.text.trim().isNotEmpty;
  bool get isTotalFloorsValid => totalFloorsController.text.trim().isNotEmpty;

  bool get isFormValid => isCityValid && isLocalityValid && isPlotAreaValid && isTotalFloorsValid;

  @override
  void onInit() {
    super.onInit();

    // Add listeners for real-time validation
    cityController.addListener(() {
      onCityChanged(cityController.text);
    });
  }

  void onCityChanged(String value) {
    isCityFilled.value = value.isNotEmpty;
  }

  void updateRoom1(int index) {
    selectRoom1.value = index;
  }

  void updateRoom2(int index) {
    selectRoom2.value = index;
  }

  void updateBedRoom(int index) {
    selectBedRoom.value = index;
  }

  void updateBathRoom(int index) {
    selectBathRoom.value = index;
  }

  void updateBalconies(int index) {
    selectBalconies.value = index;
  }

  void updateStatus(int index) {
    selectStatus.value = index;
  }

  void updateOwnership(int index) {
    selectOwnership.value = index;
  }

  // Covered Parking Methods
  void increment() {
    count++;
    selectedButton.value = AppString.plusText;
  }

  void decrement() {
    if (count > 0) {
      count--;
      selectedButton.value = AppString.minusText;
    }
  }

  // Open Parking Methods
  void incrementOpen() {
    countOpen++;
    selectedOpenButton.value = AppString.plusText;
  }

  void decrementOpen() {
    if (countOpen > 0) {
      countOpen--;
      selectedOpenButton.value = AppString.minusText;
    }
  }

  // Reset counters
  void resetCoveredParking() {
    count.value = 0;
    selectedButton.value = '';
  }

  void resetOpenParking() {
    countOpen.value = 0;
    selectedOpenButton.value = '';
  }

  // Clear all form data
  void clearAllData() {
    // Clear text controllers
    cityController.clear();
    localityController.clear();
    subLocalityController.clear();
    plotAreaController.clear();
    builtUpAreaController.clear();
    superBuiltUpAreaController.clear();
    totalFloorsController.clear();

    // Reset selections
    selectRoom1.value = 0;
    selectRoom2.value = 0;
    selectBedRoom.value = 0;
    selectBathRoom.value = 0;
    selectBalconies.value = 0;
    selectStatus.value = 0;
    selectOwnership.value = 0;

    // Reset counters
    resetCoveredParking();
    resetOpenParking();

    // Reset validation state
    isCityFilled.value = false;
  }

  // Data Lists
  RxList<String> otherRoomList1 = [
    AppString.addPoojaRooms,
    AppString.addStudyRooms,
  ].obs;

  RxList<String> otherRoomList2 = [
    AppString.addServantRooms,
    AppString.addOthers,
  ].obs;

  RxList<String> bedRoomList = [
    AppString.numeric1,
    AppString.numeric2,
    AppString.numeric3,
    AppString.numeric4,
    AppString.numeric5,
    AppString.numeric6,
    AppString.more,
  ].obs;

  RxList<String> bathRoomsList = [
    AppString.numeric1,
    AppString.numeric2,
    AppString.numeric3,
    AppString.numeric4,
    AppString.more,
  ].obs;

  RxList<String> balconiesList = [
    AppString.numeric0,
    AppString.numeric1,
    AppString.numeric2,
    AppString.numeric3,
    AppString.numeric4,
    AppString.more,
  ].obs;

  RxList<String> availabilityStatusList = [
    AppString.readyToMove,
    AppString.underConstruction,
  ].obs;

  RxList<String> ownershipList = [
    AppString.freehold,
    AppString.coOperativeSociety,
    AppString.powerOfAttorney,
    AppString.leasehold,
  ].obs;

  // Area unit options
  RxList<String> areaUnitList = [
    'sq ft',
    'sq meter',
    'sq yard',
    'acre',
  ].obs;

  @override
  void dispose() {
    cityController.dispose();
    localityController.dispose();
    subLocalityController.dispose();
    plotAreaController.dispose();
    builtUpAreaController.dispose();
    superBuiltUpAreaController.dispose();
    totalFloorsController.dispose();
    super.dispose();
  }
}
