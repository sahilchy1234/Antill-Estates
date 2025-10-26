import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPropertyController extends GetxController {
  RxInt selectSavedProperty = 0.obs;

  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;

  void updateSavedProperty(int index) {
    selectSavedProperty.value = index;
  }

  void launchDialer() async {
    final Uri phoneNumber = Uri(scheme: 'tel', path: '9995958748');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  RxList<String> savedPropertyList = [
    AppString.properties3,
    AppString.project,
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.contactProperty1.path,
    Assets.images.contactProperty2.path,
    Assets.images.contactProperty3.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.silverstone,
    AppString.vijayVRX,
    AppString.yashasviSiddhi,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.thorstenBusse,
    AppString.kohinoorChowk,
    AppString.puranaPaltan,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupee63Lakh,
    AppString.rupees58Lakh,
    AppString.rupee65Lakh,
  ].obs;

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point2,
    AppString.bhk2,
  ].obs;
}
