import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:antill_estates/configs/app_string.dart';

class TranslationController extends GetxController {

  Map<String, Map<String, String>> translation = {
    'en': {
      'Profile': 'Profile',
      'Francis Zieme': 'Francis Zieme',
      'Edit Profile': 'Edit Profile',
      'View Responses': 'View Responses',
      'Languages': 'Languages',
      'Communication Settings': 'Communication Settings',
      'Share Feedback': 'Share Feedback',
      'Are You Finding us Helpful?': 'Are You Finding us Helpful?',
      'Logout': 'Logout',
      'Delete Account': 'Delete Account',
    },
    'hi': {
      'Profile': 'प्रोफ़ाइल',
      'Francis Zieme': 'फ्रांसिस ज़िएमे',
      'Edit Profile': 'प्रोफ़ाइल संपादित करें',
      'View Responses': 'प्रतिक्रियाएँ देखें',
      'Languages': 'भाषाएँ',
      'Communication Settings': 'संचार सेटिंग्स',
      'Share Feedback': 'प्रतिपुष्टि साझा करें',
      'Are You Finding us Helpful?': 'क्या आपको हमारी मदद उपयोगी लग रही है?',
      'Logout': 'लॉग आउट',
      'Delete Account': 'खाता हटाएं',
    },
    'ar': {
      'Profile': 'الملف الشخصي',
      'Francis Zieme': 'فرانسيس زيمي',
      'Edit Profile': 'تعديل الملف الشخصي',
      'View Responses': 'عرض الردود',
      'Languages': 'اللغات',
      'Communication Settings': 'إعدادات الاتصال',
      'Share Feedback': 'شارك التعليقات',
      'Are You Finding us Helpful?': 'هل تجدنا مفيدين؟',
      'Logout': 'تسجيل الخروج',
      'Delete Account': 'حذف الحساب',
    },
    'zh': {
      'Profile': '个人资料',
      'Francis Zieme': '弗朗西斯·齐姆',
      'Edit Profile': '编辑个人资料',
      'View Responses': '查看回复',
      'Languages': '语言',
      'Communication Settings': '通信设置',
      'Share Feedback': '分享反馈',
      'Are You Finding us Helpful?': '你觉得我们有帮助吗？',
      'Logout': '退出登录',
      'Delete Account': '删除帐户',
    },
    'fr': {
      'Profile': 'Profil',
      'Francis Zieme': 'Francis Zieme',
      'Edit Profile': 'Modifier le profil',
      'View Responses': 'Voir les réponses',
      'Languages': 'Langues',
      'Communication Settings': 'Paramètres de communication',
      'Share Feedback': 'Partager des commentaires',
      'Are You Finding us Helpful?': 'Nous trouvez-vous utiles ?',
      'Logout': 'Se déconnecter',
      'Delete Account': 'Supprimer le compte',
    },
    'de': {
      'Profile': 'Profil',
      'Francis Zieme': 'Francis Zieme',
      'Edit Profile': 'Profil bearbeiten',
      'View Responses': 'Antworten anzeigen',
      'Languages': 'Sprachen',
      'Communication Settings': 'Kommunikationseinstellungen',
      'Share Feedback': 'Feedback teilen',
      'Are You Finding us Helpful?': 'Finden Sie uns hilfreich?',
      'Logout': 'Abmelden',
      'Delete Account': 'Konto löschen',
    },
  };

  RxString selectedLanguage = AppString.en.obs;

  RxList<String> languageList = [
    AppString.en,
    AppString.hi,
    AppString.ar,
    AppString.zh,
    AppString.fr,
    AppString.de,
  ].obs;

  GetStorage storage = GetStorage();

  @override
  void onInit() {
    selectedLanguage.value =
        storage.read(AppString.languages) ?? AppString.en;
    super.onInit();
  }

  String translate(String key) {
    return translation[selectedLanguage.value]?[key] ?? key;
  }

  void changeLanguage(String language) {
    selectedLanguage(language);
    storage.write(AppString.languages, language);
    update();
  }
}
