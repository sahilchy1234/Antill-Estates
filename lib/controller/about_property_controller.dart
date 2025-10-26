import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPropertyController extends GetxController {
  void launchDialer() async {
    final Uri phoneNumber = Uri(scheme: 'tel', path: '9995958748');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
}
