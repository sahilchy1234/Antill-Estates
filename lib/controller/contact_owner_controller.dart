import 'package:get/get.dart';
import 'package:antill_estates/model/property_model.dart';
import 'package:antill_estates/services/property_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactOwnerController extends GetxController {
  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;
  
  // Owner contact information
  RxString ownerName = ''.obs;
  RxString ownerPhone = ''.obs;
  RxString ownerEmail = ''.obs;
  RxString ownerAvatar = ''.obs;
  RxString propertyId = ''.obs;

  // Similar properties from Firebase
  RxList<Property> similarProperties = <Property>[].obs;
  RxBool isLoadingSimilarProperties = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get property ID from arguments
    propertyId.value = Get.arguments as String? ?? '';
    
    // Load owner contact information and similar properties
    if (propertyId.value.isNotEmpty) {
      loadOwnerContactInfo();
      loadSimilarProperties();
    }
  }

  Future<void> loadOwnerContactInfo() async {
    try {
      print('🔍 Loading owner contact info for property: ${propertyId.value}');
      
      final ownerContactInfo = await PropertyService.getPropertyOwnerContactInfo(propertyId.value);
      if (ownerContactInfo != null) {
        ownerName.value = ownerContactInfo['ownerName'] ?? '';
        ownerPhone.value = ownerContactInfo['ownerPhone'] ?? '';
        ownerEmail.value = ownerContactInfo['ownerEmail'] ?? '';
        ownerAvatar.value = ownerContactInfo['ownerAvatar'] ?? '';
        
        print('✅ Owner contact info loaded: ${ownerName.value}, ${ownerPhone.value}, ${ownerEmail.value}');
      } else {
        // Set default values if no contact info found
        ownerName.value = 'Property Owner';
        ownerPhone.value = '+91 9995958748';
        ownerEmail.value = 'contact@luxuryrealestate.com';
        ownerAvatar.value = '';
        print('⚠️ Using default owner contact info');
      }
    } catch (e) {
      print('❌ Error loading owner contact info: $e');
      // Set default values on error
      ownerName.value = 'Property Owner';
      ownerPhone.value = '+91 9995958748';
      ownerEmail.value = 'contact@luxuryrealestate.com';
      ownerAvatar.value = '';
    }
  }

  // Load similar properties from Firebase
  Future<void> loadSimilarProperties() async {
    try {
      isLoadingSimilarProperties.value = true;
      print('🔍 Loading similar properties for: ${propertyId.value}');
      
      final similarProps = await PropertyService.getSimilarProperties(propertyId.value, limit: 5);
      similarProperties.value = similarProps;
      isSimilarPropertyLiked.value = List<bool>.generate(similarProps.length, (index) => false);
      
      print('✅ Loaded ${similarProps.length} similar properties');
    } catch (e) {
      print('❌ Error loading similar properties: $e');
      similarProperties.value = [];
      isSimilarPropertyLiked.value = [];
    } finally {
      isLoadingSimilarProperties.value = false;
    }
  }

  void launchDialer() async {
    final phoneNumber = ownerPhone.value.isNotEmpty 
        ? ownerPhone.value.replaceAll(RegExp(r'[^\d+]'), '') // Remove all non-digit and non-plus characters
        : '9995958748';
    
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

}
