import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reactive user data
  RxString fullName = ''.obs;
  RxString phoneNumber = ''.obs;
  RxString phoneNumber2 = ''.obs;          // Added for phone number 2
  RxString email = ''.obs;
  RxBool isRealEstateAgent = false.obs;
  RxString profileImagePath = ''.obs; // local path or URL
  RxBool profileCompleted = false.obs;
  RxString aboutMe = ''.obs;                    // Added for About Me
  RxString whatAreYouHere = ''.obs;              // Added for "to buy/sell/broker" choice

  static const String _prefsKey = 'localUserData';
  final String userId; // User's Firestore UID

  UserDataController({required this.userId});

  @override
  void onInit() {
    super.onInit();
    fetchAndSaveUserData();
  }

  /// Fetch from Firestore and save locally
  Future<void> fetchAndSaveUserData() async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() ?? {};

        // Update reactive vars
        fullName.value = data['fullName'] ?? '';
        phoneNumber.value = data['phoneNumber'] ?? '';
        phoneNumber2.value = data['phoneNumber2'] ?? '';
        email.value = data['email'] ?? '';
        isRealEstateAgent.value = data['isRealEstateAgent'] ?? false;
        profileImagePath.value = data['profileImageUrl'] ?? '';
        profileCompleted.value = data['profileCompleted'] ?? false;
        aboutMe.value = data['aboutMe'] ?? '';
        whatAreYouHere.value = data['whatAreYouHere'] ?? '';

        // Save locally
        await _saveLocally(data);
      }
    } catch (e) {
      print('Error fetching user data from Firestore: $e');
    }
  }

  /// Save the whole data locally
  Future<void> _saveLocally(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  /// Load data from local storage
  Future<void> loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_prefsKey)) return;

    try {
      String? jsonData = prefs.getString(_prefsKey);
      if (jsonData == null) return;

      Map<String, dynamic> data = jsonDecode(jsonData);
      fullName.value = data['fullName'] ?? '';
      phoneNumber.value = data['phoneNumber'] ?? '';
      phoneNumber2.value = data['phoneNumber2'] ?? '';
      email.value = data['email'] ?? '';
      isRealEstateAgent.value = data['isRealEstateAgent'] ?? false;
      profileImagePath.value = data['profileImageUrl'] ?? '';
      profileCompleted.value = data['profileCompleted'] ?? false;
      aboutMe.value = data['aboutMe'] ?? '';
      whatAreYouHere.value = data['whatAreYouHere'] ?? '';
    } catch (e) {
      print('Error loading local user data: $e');
    }
  }

  /// Update a single field both locally and in Firestore
  Future<void> updateField(String key, dynamic value) async {
    try {
      // Update Firestore
      await firestore.collection('users').doc(userId).update({key: value});

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      String? jsonData = prefs.getString(_prefsKey);
      Map<String, dynamic> data = {};
      if (jsonData != null) data = jsonDecode(jsonData);

      data[key] = value;
      await prefs.setString(_prefsKey, jsonEncode(data));

      // Update reactive variable
      switch (key) {
        case 'fullName':
          fullName.value = value;
          break;
        case 'phoneNumber':
          phoneNumber.value = value;
          break;
        case 'phoneNumber2':                // Handle phone number 2
          phoneNumber2.value = value;
          break;
        case 'email':
          email.value = value;
          break;
        case 'isRealEstateAgent':
          isRealEstateAgent.value = value;
          break;
        case 'profileImageUrl':
          profileImagePath.value = value;
          break;
        case 'profileCompleted':
          profileCompleted.value = value;
          break;
        case 'aboutMe':                    // Handle About Me
          aboutMe.value = value;
          break;
        case 'whatAreYouHere':             // Handle Buyer/Seller/Broker choice
          whatAreYouHere.value = value;
          break;
      }
    } catch (e) {
      print('Error updating field $key: $e');
    }
  }

  /// Clear all local data
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);

    fullName.value = '';
    phoneNumber.value = '';
    phoneNumber2.value = '';
    email.value = '';
    isRealEstateAgent.value = false;
    profileImagePath.value = '';
    profileCompleted.value = false;
    aboutMe.value = '';
    whatAreYouHere.value = '';
  }
}
