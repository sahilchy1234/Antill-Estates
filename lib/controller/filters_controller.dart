import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';

class FiltersController extends GetxController {
  RxBool isSortByExpanded = false.obs;
  RxInt selectSortBy = 0.obs;

  void updateSortBy(int index) {
    selectSortBy.value = index;
  }

  void toggleSortByExpansion() {
    isSortByExpanded.value = !isSortByExpanded.value;
  }

  RxList<String> sortByList = [
    AppString.relevance,
    AppString.newestFirst,
    AppString.priceLowToHigh,
    AppString.priceHighToLow,
  ].obs;

  RxList<String> filtersList = [
    AppString.newBooking,
    AppString.readyToMove,
    AppString.withPhotos,
    AppString.withVideos,
    AppString.budget,
    AppString.bhk,
    AppString.propertyType,
    AppString.noOfBaths,
    AppString.furnished,
  ].obs;
}
