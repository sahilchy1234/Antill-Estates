import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';

class ExploreCityController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxInt selectPropertyLooking = 0.obs;
  RxInt selectCategories = 0.obs;
  RxInt selectProperties = 0.obs;

  void updatePropertyLooking(int index) {
    selectPropertyLooking.value = index;
  }

  void updateCategories(int index) {
    selectCategories.value = index;
  }

  void updateProperties(int index) {
    selectProperties.value = index;
  }

  RxList<String> propertyLookingList = [
    AppString.buy,
    AppString.rentPg,
    AppString.room,
  ].obs;

  RxList<String> categoriesList = [
    AppString.residential,
    AppString.commercialUse,
  ].obs;

  RxList<String> propertyTypeList = [
    AppString.residentialApartment,
    AppString.independentVilla,
    AppString.plotLandAdd,
  ].obs;
}
