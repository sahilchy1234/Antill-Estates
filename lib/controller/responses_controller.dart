import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class ResponsesController extends GetxController {
  RxList<String> responseImageList = [
    Assets.images.response2.path,
    Assets.images.reponse6.path,
    Assets.images.response5.path,
  ].obs;

  RxList<String> responseNameList = [
    AppString.claudeAnderson,
    AppString.hattieKoch,
    AppString.vincentMarks,
  ].obs;

  RxList<String> responseTimingList = [
    AppString.today,
    AppString.yesterday,
    AppString.yesterday,
  ].obs;

  RxList<String> responseLeadingScoreList = [
    AppString.leadScore4Point5,
    AppString.leadScore3Point5,
    AppString.leadScore2Point5,
  ].obs;

  RxList<String> responseAddressList = [
    AppString.semiModernHouse,
    AppString.sellIndependentHouse,
    AppString.sellIndependentHouse,
  ].obs;

  RxList<String> responseAddress2List = [
    AppString.northBombaySociety,
    AppString.northBombaySociety,
    AppString.roslynWalks,
  ].obs;

  RxList<String> responseRupeesList = [
    AppString.rupee50Lakh,
    AppString.rupee50Lakh,
    AppString.rupees2Crore,
  ].obs;
}
