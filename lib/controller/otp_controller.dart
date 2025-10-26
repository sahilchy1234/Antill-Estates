import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/services/UserDataController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';

class OtpController extends GetxController {
  // Text controller for OTP input
  final TextEditingController pinController = TextEditingController();

  // Observable state variables
  RxString otp = ''.obs;
  RxBool isOTPValid = false.obs;
  RxBool isLoading = false.obs;
  RxInt countdown = 60.obs;
  RxBool canResend = false.obs;
  RxString error = ''.obs;

  // Timer for countdown
  Timer? _countdownTimer;

  // Phone number and verification ID from arguments
  String phoneNumber = '';
  String verificationId = '';

  // Firebase and Storage instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final FirebaseAuthService _firebaseAuthService = Get.find<FirebaseAuthService>();

  @override
  void onInit() {
    super.onInit();

    // Get phone number and verification ID from arguments
    _getArgumentsFromNavigation();

    // Start countdown timer
    startCountdown();

    // Listen to OTP input changes
    pinController.addListener(() {
      validateOTP(pinController.text);
    });

    // Clear any previous errors
    error.value = '';
    print('OtpController initialized with phone: $phoneNumber');
  }

  /// Get arguments from Get.arguments with null safety
  void _getArgumentsFromNavigation() {
    try {
      final args = Get.arguments;
      if (args is Map) {
        phoneNumber = args['phoneNumber']?.toString() ?? '';
        verificationId = args['verificationId']?.toString() ?? '';
      } else if (args is String) {
        // Backward compatibility
        phoneNumber = args;
        verificationId = '';
      } else {
        phoneNumber = '';
        verificationId = '';
      }

      print('Arguments: phoneNumber=$phoneNumber, verificationId=$verificationId');
    } catch (e) {
      print('Error getting navigation arguments: $e');
      phoneNumber = '';
      verificationId = '';
    }
  }

  /// Validate OTP input and update state
  void validateOTP(String value) {
    otp.value = value.trim();

    // Clear error when user starts typing
    if (error.value.isNotEmpty) {
      error.value = '';
    }

    // Check if OTP is valid (6 digits)
    isOTPValid.value = otp.value.length == AppSize.size6 && _isNumeric(otp.value);
    print('OTP validation: ${otp.value}, isValid: ${isOTPValid.value}');
  }

  /// Check if string contains only numeric characters
  bool _isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  /// Verify OTP with Firebase Authentication
  Future<void> verifyOTP() async {
    if (isLoading.value) {
      print('Verification already in progress...');
      return;
    }

    if (!isOTPValid.value) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    if (phoneNumber.isEmpty || verificationId.isEmpty) {
      _showError('Verification details not found. Please restart the process.');
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      print('Starting Firebase OTP verification for: ${otp.value}');

      // Use Firebase Auth Service to verify OTP
      bool success = await _firebaseAuthService.verifyOTP(otp.value);

      if (success) {
        print('OTP verification successful');
        _showSuccess('Phone number verified successfully!');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('phone_num', phoneNumber);

        // Check if user exists in Firebase after successful OTP verification
        await _checkUserExistsInFirebase();
      } else {
        print('OTP verification failed');
        _handleVerificationFailure();
      }
    } catch (e) {
      print('Error during OTP verification: $e');
      _showError('Verification failed. Please check your OTP and try again.');
      _handleVerificationFailure();
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper method to safely convert Map to Map<String, dynamic>
  Map<String, dynamic>? _convertToStringMap(dynamic data) {
    try {
      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is Map) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      print('Error converting map: $e');
      return null;
    }
  }

  Future<void> _checkUserExistsInFirebase() async {
    try {
      print('Checking if user exists in Firebase with phone: $phoneNumber');

      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get()
          .timeout(
        Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Firebase query timeout'),
      );

      if (userQuery.docs.isNotEmpty) {
        // User exists - save user data and navigate to home
        DocumentSnapshot userDoc = userQuery.docs.first;

        final userData = _convertToStringMap(userDoc.data());

        if (userData != null) {
          String userId = userDoc.id;

          print('User found in Firebase: $userId');

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);

          // ✅ Inject UserDataController here (1)
          if (!Get.isRegistered<UserDataController>()) {
            Get.put(UserDataController(userId: userId));
          }

          // Save session
          await _saveUserSession(userId, userData);

          // ✅ Inject UserDataController here again to ensure (2)
          if (!Get.isRegistered<UserDataController>()) {
            Get.put(UserDataController(userId: userId));
          }

          _showSuccess('Welcome back!');
          await Future.delayed(Duration(milliseconds: 500));

          // ✅ Inject UserDataController here just before navigation (3)
          if (!Get.isRegistered<UserDataController>()) {
            Get.put(UserDataController(userId: userId));
          }

          if (Get.currentRoute != '/bottom_bar_view') {
            Get.offAllNamed('/bottom_bar_view');
          }
        } else {
          print('User data conversion failed');
          await _redirectToRegistration();
        }
      } else {
        // User doesn't exist - go to registration
        print('User not found in Firebase. Redirecting to registration...');
        await _redirectToRegistration();
      }
    } catch (e) {
      print('Error checking user in Firebase: $e');
      if (e is TimeoutException || e.toString().contains('UNAVAILABLE')) {
        print('Firebase unavailable, proceeding to registration...');
        await _redirectToRegistration();
      } else {
        _showError('Failed to verify user. Please try again.');
      }
    }
  }

  /// Redirect to registration with proper error handling
  Future<void> _redirectToRegistration() async {
    try {
      _showSuccess('Please complete your registration');
      await Future.delayed(Duration(milliseconds: 500));

      // ✅ Also inject UserDataController here if userId is available (4)
      if (phoneNumber.isNotEmpty && !Get.isRegistered<UserDataController>()) {
        Get.put(UserDataController(userId: phoneNumber));
      }

      // Navigate to register view using your route constant
      if (Get.currentRoute != '/register_view') {
        Get.offAllNamed('/register_view', arguments: {
          'phoneNumber': phoneNumber,
          'isFromOTP': true,
        });
      }
    } catch (e) {
      print('Error during registration redirect: $e');
      _showError('Navigation error. Please restart the app.');
    }
  }

  /// Save user session data to local storage with null safety
  Future<void> _saveUserSession(String userId, Map<String, dynamic> userData) async {
    try {
      await _storage.write('isLoggedIn', true);
      await _storage.write('userId', userId);
      await _storage.write('phoneNumber', phoneNumber);
      await _storage.write('userData', userData);
      await _storage.write('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
      print('User session saved successfully');
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  /// Handle verification failure
  void _handleVerificationFailure() {
    // Reset form state
    isOTPValid.value = false;
    pinController.clear();
    otp.value = '';
  }

  /// Resend OTP using Firebase Authentication
  Future<void> resendOTP() async {
    if (!canResend.value || isLoading.value) {
      print('Resend not allowed: canResend=${canResend.value}, isLoading=${isLoading.value}');
      return;
    }

    if (phoneNumber.isEmpty) {
      _showError('Phone number not found. Please restart the process.');
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      print('Attempting to resend OTP to: $phoneNumber');

      // Use Firebase Auth Service to resend OTP
      bool success = await _firebaseAuthService.resendOTP();

      if (success) {
        print('OTP resent successfully');
        _resetFormState();
        startCountdown();
        _showSuccess('OTP resent successfully to ${_maskPhoneNumber(phoneNumber)}');
      } else {
        _showError('Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      print('Error during OTP resend: $e');
      _showError('Network error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset form state for resend
  void _resetFormState() {
    pinController.clear();
    otp.value = '';
    isOTPValid.value = false;
    error.value = '';
  }

  /// Start countdown timer for resend button
  void startCountdown() {
    // Cancel any existing timer
    _countdownTimer?.cancel();

    // Reset countdown and resend state
    countdown.value = 60;
    canResend.value = false;
    print('Starting countdown timer: ${countdown.value} seconds');

    // Start new timer
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        // Enable resend when countdown reaches zero
        canResend.value = true;
        timer.cancel();
        print('Countdown completed, resend enabled');
      }
    });
  }

  /// Format countdown for display (MM:SS)
  String get formattedCountdown {
    final minutes = countdown.value ~/ 60;
    final seconds = countdown.value % 60;
    return '${_formatTimeComponent(minutes)}:${_formatTimeComponent(seconds)}';
  }

  /// Format time component with leading zero
  String _formatTimeComponent(int time) {
    return time < 10 ? '0$time' : '$time';
  }

  /// Mask phone number for display
  String _maskPhoneNumber(String phone) {
    if (phone.length > 5) {
      return '${phone.substring(0, 3)}****${phone.substring(phone.length - 2)}';
    }
    return phone;
  }

  /// Show error message
  void _showError(String message) {
    try {
      error.value = message;
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.error_outline, color: Colors.white),
      );
    } catch (e) {
      print('Error showing snackbar: $e');
    }
  }

  /// Show success message
  void _showSuccess(String message) {
    try {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 2),
        icon: Icon(Icons.check_circle_outline, color: Colors.white),
      );
    } catch (e) {
      print('Error showing snackbar: $e');
    }
  }

  /// Handle auto-complete from Pinput widget
  void onCompleted(String value) {
    otp.value = value;
    validateOTP(value);

    // Auto-verify when OTP is complete and valid
    if (isOTPValid.value && !isLoading.value) {
      print('Auto-verifying completed OTP: $value');
      Future.delayed(Duration(milliseconds: 300), () {
        verifyOTP();
      });
    }
  }

  /// Clear OTP and reset form
  void clearOTP() {
    pinController.clear();
    otp.value = '';
    isOTPValid.value = false;
    error.value = '';
  }

  /// Check if we can navigate back
  bool get canGoBack => !isLoading.value;

  /// Handle back navigation
  void goBack() {
    if (canGoBack) {
      Get.back();
    }
  }

  @override
  void onClose() {
    print('OtpController closing - cleaning up resources');

    // Cancel timer to prevent memory leaks
    _countdownTimer?.cancel();

    // Dispose text controller
    pinController.dispose();

    super.onClose();
  }
}
