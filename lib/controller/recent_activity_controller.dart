import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';

class RecentActivityController extends GetxController {
  RxList<String> todayActivityList = [
    AppString.todayActivity1,
    AppString.todayActivity2,
  ].obs;

  RxList<String> yesterdayActivityList = [
    AppString.yesterdayActivity1,
    AppString.todayActivity2,
    AppString.yesterdayActivity3,
    AppString.yesterdayActivity4,
  ].obs;

  RxList<String> decemberActivityList = [
    AppString.december25Activity1,
    AppString.december25Activity2,
    AppString.yesterdayActivity3,
    AppString.yesterdayActivity4,
    AppString.december25Activity2,
    AppString.december25Activity2,
  ].obs;
}
