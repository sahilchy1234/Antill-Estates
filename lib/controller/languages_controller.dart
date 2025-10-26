import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:antill_estates/configs/app_string.dart';

class LanguagesController extends GetxController {
  RxInt selectLanguage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    selectLanguage.value = GetStorage().read(AppString.selectedLanguage) ?? 0;
  }

  void updateLanguage(int index) {
    selectLanguage.value = index;
    GetStorage().write(AppString.selectedLanguage, index);
  }

  RxList<String> languagesList = [
    AppString.english,
    AppString.hindi,
    AppString.arabic,
    AppString.chinese,
    AppString.french,
    AppString.german,
  ].obs;
}
