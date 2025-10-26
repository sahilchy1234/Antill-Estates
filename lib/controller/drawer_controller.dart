import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';

class SlideDrawerController extends GetxController {
  // Loading state
  RxBool isLoading = false.obs;
  
  RxList<String> drawerList = [
    AppString.notification,
    AppString.searchProperty,
  ].obs;

  RxList<String> drawer2List = <String>[].obs;

  RxList<String> searchPropertyNumberList = <String>[].obs;

  RxList<String> drawer3List = [
    AppString.homeScreen,
    // Removed: agentsList, interestingReads
  ].obs;

  RxList<String> drawer4List = [
    AppString.termsOfUse,
    AppString.shareFeedback,
    AppString.rateOurApp,
    AppString.logout,
  ].obs;
}
