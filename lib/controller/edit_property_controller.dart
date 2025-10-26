import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/model/property_model.dart';

class EditPropertyController extends GetxController {
  Rx<Property?> property = Rx<Property?>(null);
  RxBool isLoading = false.obs;

  RxList<String> editPropertyTitleList = [
    AppString.basicDetails,
    AppString.propertyDetails,
    AppString.priceDetails,
    AppString.amenities,
  ].obs;

  RxList<String> editPropertySubtitleList = [
    AppString.basicDetailsString,
    AppString.propertyDetailsString,
    AppString.priceDetailsString,
    AppString.amenitiesString,
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Get property data from arguments
    if (Get.arguments != null) {
      property.value = Get.arguments as Property;
    }
  }

  void updateProperty(Property updatedProperty) {
    property.value = updatedProperty;
  }
}
