import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/firebase_auth_service.dart';

class LoginController extends GetxController {
  // Observable variables
  RxBool hasFocus = false.obs;
  RxBool hasInput = false.obs;
  RxBool isLoading = false.obs;

  // Controllers and focus nodes
  late FocusNode focusNode;
  late TextEditingController mobileController;

  // Firebase Auth Service
  final FirebaseAuthService _firebaseAuthService = Get.find<FirebaseAuthService>();

  // Listeners for proper cleanup
  late VoidCallback _focusListener;
  late VoidCallback _textListener;

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers
    focusNode = FocusNode();
    mobileController = TextEditingController();

    // Create listeners
    _focusListener = () {
      hasFocus.value = focusNode.hasFocus;
    };

    _textListener = () {
      hasInput.value = mobileController.text.isNotEmpty;
    };

    // Add listeners
    focusNode.addListener(_focusListener);
    mobileController.addListener(_textListener);
  }

  // Improved phone number validation
  bool _validatePhoneNumber() {
    String phone = mobileController.text.trim();

    // Check if empty
    if (phone.isEmpty) {
      _showErrorSnackbar('Please enter a phone number');
      return false;
    }

    // Check exact length (should be exactly 10 digits for Indian numbers)
    if (phone.length != 10) {
      _showErrorSnackbar('Please enter a valid 10-digit phone number');
      return false;
    }

    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showErrorSnackbar('Phone number should contain only digits');
      return false;
    }

    // Check if starts with valid Indian mobile prefixes
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
      _showErrorSnackbar('Please enter a valid Indian mobile number');
      return false;
    }

    return true;
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 3),
    );
  }

  // Show success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 3),
    );
  }

  // Send OTP using Firebase Authentication
  Future<void> sendOTP() async {
    if (isLoading.value) {
      print('Already processing OTP request, please wait...');
      return;
    }

    if (!_validatePhoneNumber()) {
      return;
    }

    try {
      isLoading.value = true;
      String phoneNumber = '+91${mobileController.text.trim()}';
      print('Starting Firebase OTP process for: $phoneNumber');

      // Use Firebase Auth Service with callback pattern
      await _firebaseAuthService.sendOTPWithCallback(
        phoneNumber,
        onCodeSent: (String verificationId) {
          print('Firebase OTP sent successfully');
          _showSuccessSnackbar('OTP sent successfully to ${mobileController.text}');

          // Navigate to OTP verification screen
          Future.delayed(Duration(milliseconds: 500), () {
            Get.toNamed(AppRoutes.otpView, arguments: {
              'phoneNumber': phoneNumber,
              'verificationId': verificationId,
            });
          });
        },
        onVerificationFailed: (String error) {
          print('Firebase OTP failed: $error');
          _showErrorSnackbar(error);
        },
        onVerificationCompleted: () {
          print('Auto verification completed');
          _showSuccessSnackbar('Phone number verified automatically');

          // Navigate directly to main app or user check
          Future.delayed(Duration(milliseconds: 500), () {
            // You can implement user existence check here
            Get.offAllNamed('/bottom_bar_view');
          });
        },
      );

    } catch (e) {
      print('Error sending OTP: $e');
      _showErrorSnackbar('Failed to send OTP. Please try again.');
    } finally {
      // isLoading.value = false;
    }
  }

  // Clear form data
  void clearForm() {
    mobileController.clear();
    hasFocus.value = false;
    hasInput.value = false;
  }

  // Check if form is valid (exactly 10 digits)
  bool get isFormValid {
    String phone = mobileController.text.trim();
    return phone.length == 10 && RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone);
  }

  @override
  void onClose() {
    // Remove listeners before disposing
    focusNode.removeListener(_focusListener);
    mobileController.removeListener(_textListener);

    // Dispose resources
    focusNode.dispose();
    mobileController.dispose();
    super.onClose();
  }
}
