import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class PopularBuildersController extends GetxController {
  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;

  RxList<String> searchImageList = [
    Assets.images.searchProperty1.path,
    Assets.images.property4.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.harmonyHomes,
    AppString.elysianEstates,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.harmonyHomesAddress,
    AppString.elysianEstatesAddress,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.priceOnRequest,
  ].obs;

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point2,
    AppString.sq456,
  ].obs;

  RxList<String> upcomingProjectImageList = [
    Assets.images.upcoming1.path,
    Assets.images.upcomingProject1.path,
  ].obs;

  RxList<String> upcomingProjectTitleList = [
    AppString.metropolisMansion,
    AppString.luxuryVilla,
  ].obs;

  RxList<String> upcomingProjectAddressList = [
    AppString.metropolisMansionAddress,
    AppString.address8,
  ].obs;

  RxList<String> upcomingProjectFlatSizeList = [
    AppString.bhk4Apartments,
    AppString.bhk3Apartment,
  ].obs;

  RxList<String> upcomingProjectPriceList = [
    AppString.rupee90Lakh,
    AppString.lakh45,
  ].obs;
}
