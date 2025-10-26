import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class InterestingReadsController extends GetxController {
  RxList<String> interestingReadsImageList = [
    Assets.images.read1.path,
    Assets.images.read2.path,
    Assets.images.read3.path,
    Assets.images.read4.path,
    Assets.images.read5.path,
    Assets.images.read6.path,
    Assets.images.read7.path,
  ].obs;

  RxList<String> interestingReadsTitleList = [
    AppString.readString1,
    AppString.readString2,
    AppString.sarjapurRoad,
    AppString.pivotDoor,
    AppString.ashianaNitara,
    AppString.verdantBy,
    AppString.howToSell,
  ].obs;

  RxList<String> interestingReadsDateList = [
    AppString.november23,
    AppString.october16,
    AppString.may18,
    AppString.may19,
    AppString.feb23,
    AppString.mar29,
    AppString.may03,
  ].obs;
}
