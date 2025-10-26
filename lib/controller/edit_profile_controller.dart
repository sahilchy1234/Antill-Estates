import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

import '../services/UserDataController.dart';
import '../services/firebase_storage_service.dart';
import '../services/image_optimization_service.dart';

class EditProfileController extends GetxController {
  RxBool hasFullNameFocus = true.obs;
  RxBool hasFullNameInput = true.obs;
  RxBool hasPhoneNumberFocus = true.obs;
  RxBool hasPhoneNumberInput = true.obs;
  RxBool hasPhoneNumber2Focus = false.obs;
  RxBool hasPhoneNumber2Input = false.obs;
  RxBool hasEmailFocus = true.obs;
  RxBool hasEmailInput = true.obs;
  
  // Loading state
  RxBool isLoading = false.obs;

  FocusNode focusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode phoneNumber2FocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();


  TextEditingController phoneNumber2Controller = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  RxString whatAreYouHereValue = ''.obs;  // Reflects the selected string from whatAreYouHereList

  TextEditingController fullNameController = TextEditingController(text: AppString.francisZieme);
  TextEditingController phoneNumberController = TextEditingController(text: AppString.francisZiemeNumber);
  // TextEditingController phoneNumber2Controller = TextEditingController();
  TextEditingController emailController = TextEditingController(text: AppString.francisZiemeEmail);
  // TextEditingController aboutMeController = TextEditingController();
  TextEditingController whatAreYouHereController = TextEditingController();

  RxBool isWhatAreYouHereExpanded = false.obs;
  RxInt isWhatAreYouHereSelect = 0.obs;
  RxString profileImagePath = ''.obs;
  Rx<Uint8List?> webImage = Rx<Uint8List?>(null);
  RxString profileImage = "".obs;

  // Loading states
  RxBool isUpdating = false.obs;
  RxBool isUploadingImage = false.obs;

  // Get UserDataController instance
  late UserDataController userDataController;

  @override
  void onInit() {
    super.onInit();

    userDataController = Get.find<UserDataController>();

    // Get UserDataController instance

    // Load existing user data
    loadUserData();

    // Focus listeners
    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    phoneNumber2FocusNode.addListener(() {
      hasPhoneNumber2Focus.value = phoneNumber2FocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });

    // Input listeners
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });
    phoneNumberController.addListener(() {
      hasPhoneNumberInput.value = phoneNumberController.text.isNotEmpty;
    });
    phoneNumber2Controller.addListener(() {
      hasPhoneNumber2Input.value = phoneNumber2Controller.text.isNotEmpty;
    });
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  /// Load existing user data into controllers
  void loadUserData() {
    fullNameController.text = userDataController.fullName.value;
    phoneNumberController.text = userDataController.phoneNumber.value;
    phoneNumber2Controller.text = userDataController.phoneNumber2.value;  // new
    emailController.text = userDataController.email.value;
    aboutMeController.text = userDataController.aboutMe.value;             // new
    whatAreYouHereValue.value = userDataController.whatAreYouHere.value;   // new
    whatAreYouHereController.text = whatAreYouHereValue.value;             // new

    // Update input states
    hasFullNameInput.value = fullNameController.text.isNotEmpty;
    hasPhoneNumberInput.value = phoneNumberController.text.isNotEmpty;
    hasPhoneNumber2Input.value = phoneNumber2Controller.text.isNotEmpty;   // new
    hasEmailInput.value = emailController.text.isNotEmpty;
  }

  void toggleWhatAreYouHereExpansion() {
    isWhatAreYouHereExpanded.value = !isWhatAreYouHereExpanded.value;
  }

  void updateWhatAreYouHere(int index) {
    isWhatAreYouHereSelect.value = index;
    whatAreYouHereController.text = whatAreYouHereList[index];
    whatAreYouHereValue.value = whatAreYouHereList[index]; // new

    bool isAgent = index == 2; // "I Am A Broker"
    updateRealEstateAgentStatus(isAgent);
  }


  /// Update full name
  Future<void> updateFullName() async {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Full name cannot be empty');
      return;
    }

    isUpdating.value = true;
    try {
      await userDataController.updateField('fullName', fullNameController.text.trim());
      Get.snackbar('Success', 'Full name updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update full name: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Update phone number
  Future<void> updatePhoneNumber() async {
    if (phoneNumberController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Phone number cannot be empty');
      return;
    }

    isUpdating.value = true;
    try {
      await userDataController.updateField('phoneNumber', phoneNumberController.text.trim());
      Get.snackbar('Success', 'Phone number updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update phone number: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Update email
  Future<void> updateEmail() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email cannot be empty');
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email');
      return;
    }

    isUpdating.value = true;
    try {
      await userDataController.updateField('email', emailController.text.trim());
      Get.snackbar('Success', 'Email updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update email: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Update real estate agent status
  Future<void> updateRealEstateAgentStatus(bool isAgent) async {
    isUpdating.value = true;
    try {
      await userDataController.updateField('isRealEstateAgent', isAgent);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update agent status: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Upload optimized image to Firebase Storage and update profile
  Future<String?> uploadImageToFirebase(dynamic imageData, String userId) async {
    try {
      // Get the optimized storage service
      final storageService = Get.find<FirebaseStorageService>();
      
      if (kIsWeb) {
        // For web, we need to handle Uint8List differently
        // Convert to File-like structure for optimization service
        final tempFile = await _createTempFileFromBytes(imageData as Uint8List, userId);
        final result = await storageService.uploadOptimizedImage(
          imageFile: tempFile,
          userId: userId,
          folder: 'profile_images',
          useCase: ImageUseCase.profile,
          createThumbnail: true,
        );
        // Clean up temp file
        await tempFile.delete();
        return result;
      } else {
        // Mobile upload with optimization
        final result = await storageService.uploadOptimizedImage(
          imageFile: File(imageData as String),
          userId: userId,
          folder: 'profile_images',
          useCase: ImageUseCase.profile,
          createThumbnail: true,
        );
        return result;
      }
    } catch (e) {
      print('❌ Error uploading optimized image: $e');
      return null;
    }
  }

  /// Create temporary file from bytes for web uploads
  Future<File> _createTempFileFromBytes(Uint8List bytes, String userId) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_profile_$userId.jpg');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  /// Update profile image
  Future<void> updateProfileImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    isUploadingImage.value = true;
    try {
      String? imageUrl;

      if (kIsWeb) {
        webImage.value = await image.readAsBytes();
        imageUrl = await uploadImageToFirebase(webImage.value, userDataController.userId);
      } else {
        profileImage.value = image.path;
        imageUrl = await uploadImageToFirebase(image.path, userDataController.userId);
      }

      if (imageUrl != null) {
        await userDataController.updateField('profileImageUrl', imageUrl);
        profileImagePath.value = imageUrl;
        Get.snackbar('Success', 'Profile image updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to upload image');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile image: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Update all profile data at once
  Future<void> updateAllProfileData() async {
    if (fullNameController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email');
      return;
    }

    isUpdating.value = true;
    try {
      // Update all fields
      await Future.wait([
        userDataController.updateField('fullName', fullNameController.text.trim()),
        userDataController.updateField('phoneNumber', phoneNumberController.text.trim()),
        userDataController.updateField('phoneNumber2', phoneNumber2Controller.text.trim()),   // new
        userDataController.updateField('email', emailController.text.trim()),
        userDataController.updateField('aboutMe', aboutMeController.text.trim()),               // new
        userDataController.updateField('whatAreYouHere', whatAreYouHereValue.value),           // new
        userDataController.updateField('isRealEstateAgent', isWhatAreYouHereSelect.value == 2),
      ]);


      // Mark profile as completed
      await userDataController.updateField('profileCompleted', true);

      Get.snackbar('Success', 'Profile updated successfully');
      Get.back(); // Navigate back after successful update
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  /// Validate phone number (basic validation)
  bool isValidPhoneNumber(String phone) {
    return phone.trim().length >= 10;
  }

  /// Check if all required fields are filled
  bool get isFormValid {
    return fullNameController.text.trim().isNotEmpty &&
        phoneNumberController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        isValidEmail(emailController.text.trim()) &&
        isValidPhoneNumber(phoneNumberController.text.trim());
  }

  RxList<String> whatAreYouHereList = [
    AppString.toBuyProperty,
    AppString.toSellProperty,
    AppString.iAmABroker,
  ].obs;

  @override
  void onClose() {
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    phoneNumber2FocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    phoneNumber2Controller.dispose();
    emailController.dispose();
    aboutMeController.dispose();
    whatAreYouHereController.dispose();
    super.onClose();
  }
}
