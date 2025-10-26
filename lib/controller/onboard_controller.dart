import 'package:get/get.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';
import 'package:antill_estates/routes/app_routes.dart';

class OnboardController extends GetxController {
  RxInt currentIndex = 0.obs;

  List<String> images = [
    Assets.images.onboard1.path,
    Assets.images.onboard2.path,
    Assets.images.onboard3.path,
  ];

  List<String> titles = [
    AppString.onboardTitle1,
    AppString.onboardTitle2,
    AppString.onboardTitle3,
  ];

  List<String> subtitles = [
    AppString.onboardSubTitle1,
    AppString.onboardSubTitle2,
    AppString.onboardSubTitle3,
  ];

  void nextPage() {
    if (currentIndex < images.length - AppSize.size1) {
      currentIndex++;
    } else {
      Get.offAllNamed(AppRoutes.loginView);
    }
  }

  String get nextButtonText {
    return currentIndex.value == images.length - AppSize.size1 ? AppString.getStartButton : AppString.nextButton;
  }
}
