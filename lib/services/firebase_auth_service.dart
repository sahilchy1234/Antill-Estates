import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Core state variables
  String? verificationId;
  bool isOTPsent = false;
  int? resendToken;

  // Reactive variables for better state management
  RxBool isLoading = false.obs;
  RxString currentPhoneNumber = ''.obs;

  /// Main method with callback pattern for real-time feedback
  Future<bool> sendOTPWithCallback(
      String phoneNumber, {
        required Function(String) onCodeSent,
        required Function(String) onVerificationFailed,
        Function()? onVerificationCompleted,
      }) async {
    try {
      print('FirebaseAuthService: Starting OTP verification for $phoneNumber');

      // Reset state
      isOTPsent = false;
      verificationId = null;
      isLoading.value = true;
      currentPhoneNumber.value = phoneNumber;

      // Set up completion tracking to prevent duplicate callbacks
      bool isCompleted = false;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 120), // Extended timeout for better reliability

         forceResendingToken: resendToken,
          // forceRecaptchaFlow: true, // ✅ THIS FORCES RECAPTCHA V2

        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Auto verification completed for $phoneNumber');
          if (!isCompleted) {
            isCompleted = true;
            isLoading.value = false;

            try {
              UserCredential result = await _auth.signInWithCredential(credential);
              if (result.user != null) {
                isOTPsent = true;
                print('User auto-signed in: ${result.user?.phoneNumber}');

                // Show success message for auto verification
                _showSuccessSnackbar('Phone number verified automatically');

                // Call completion callback if provided
                if (onVerificationCompleted != null) {
                  onVerificationCompleted();
                } else {
                  // Fallback to codeSent callback for auto verification
                  onCodeSent('auto-verified');
                }
              }
            } catch (e) {
              print('Auto sign-in failed: $e');
              onVerificationFailed('Auto verification failed: ${e.toString()}');
            }
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.code} - ${e.message}');
          if (!isCompleted) {
            isCompleted = true;
            isOTPsent = false;
            isLoading.value = false;

            String errorMessage = _getErrorMessage(e);
            _showErrorSnackbar(errorMessage);
            onVerificationFailed(errorMessage);
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          print('OTP code sent successfully');
          print('Verification ID: $verificationId');

          if (!isCompleted) {
            isCompleted = true;

            // Update state variables
            this.verificationId = verificationId;
            this.resendToken = resendToken;
            isOTPsent = true;
            isLoading.value = false;

            // Show success message with masked phone number
            String maskedNumber = _maskPhoneNumber(phoneNumber);
            _showSuccessSnackbar('OTP sent to $maskedNumber');

            print('OTP sent successfully, isOTPsent: $isOTPsent');

            // Trigger the callback immediately when code is sent
            onCodeSent(verificationId);
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout for: $verificationId');
          // Store verification ID but don't mark as completed
          // This is just a timeout notification, not a failure
          if (this.verificationId == null) {
            this.verificationId = verificationId;
          }
        },
      );

      return true;

    } catch (e) {
      print('Error in sendOTPWithCallback: $e');
      isLoading.value = false;
      isOTPsent = false;

      String errorMessage = 'Failed to send OTP: ${e.toString()}';
      _showErrorSnackbar(errorMessage);
      onVerificationFailed(errorMessage);
      return false;
    }
  }

  /// Legacy method for backward compatibility
  Future<bool> sendOTP(String phoneNumber) async {
    bool success = false;

    await sendOTPWithCallback(
      phoneNumber,
      onCodeSent: (String verificationId) {
        success = true;
      },
      onVerificationFailed: (String error) {
        success = false;
      },
    );

    // Wait for callbacks to be processed
    await Future.delayed(Duration(seconds: 3));

    return success && isOTPsent;
  }

  /// Resend OTP with proper token handling
  Future<bool> resendOTP() async {
    if (currentPhoneNumber.value.isEmpty) {
      _showErrorSnackbar('No phone number found. Please start the process again.');
      return false;
    }

    try {
      print('Resending OTP to: ${currentPhoneNumber.value}');
      isLoading.value = true;
      bool operationCompleted = false;
      bool success = false;

      await _auth.verifyPhoneNumber(
        phoneNumber: currentPhoneNumber.value,
        forceResendingToken: resendToken, // Use stored resend token
        timeout: Duration(seconds: 120),

        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Auto verification completed on resend');
          if (!operationCompleted) {
            operationCompleted = true;
            isLoading.value = false;

            try {
              await _auth.signInWithCredential(credential);
              isOTPsent = true;
              success = true;
              _showSuccessSnackbar('Phone number verified automatically');
            } catch (e) {
              print('Auto sign-in failed on resend: $e');
              _showErrorSnackbar('Auto verification failed');
            }
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          print('Resend verification failed: ${e.message}');
          if (!operationCompleted) {
            operationCompleted = true;
            isLoading.value = false;
            String errorMessage = _getErrorMessage(e);
            _showErrorSnackbar(errorMessage);
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          print('OTP resent successfully');
          if (!operationCompleted) {
            operationCompleted = true;

            // Update state
            this.verificationId = verificationId;
            this.resendToken = resendToken;
            isOTPsent = true;
            success = true;
            isLoading.value = false;

            _showSuccessSnackbar('OTP resent successfully');
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout on resend: $verificationId');
          if (this.verificationId == null) {
            this.verificationId = verificationId;
          }
        },
      );

      // Wait for callbacks with timeout
      int waitTime = 0;
      while (!operationCompleted && waitTime < 10000) {
        await Future.delayed(Duration(milliseconds: 100));
        waitTime += 100;
      }

      if (!operationCompleted) {
        isLoading.value = false;
        _showErrorSnackbar('Resend request timed out. Please try again.');
        return false;
      }

      return success;

    } catch (e) {
      isLoading.value = false;
      print('Error in resendOTP: $e');
      _showErrorSnackbar('Failed to resend OTP: ${e.toString()}');
      return false;
    }
  }

  /// Verify OTP code with enhanced error handling
  Future<bool> verifyOTP(String otpCode) async {
    if (verificationId == null || verificationId!.isEmpty) {
      _showErrorSnackbar('Verification ID not found. Please request OTP again.');
      return false;
    }

    if (otpCode.trim().isEmpty || otpCode.trim().length != 6) {
      _showErrorSnackbar('Please enter a valid 6-digit OTP code.');
      return false;
    }

    try {
      isLoading.value = true;

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpCode.trim(),
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        isLoading.value = false;
        _showSuccessSnackbar('Phone number verified successfully');
        print('User verified and signed in: ${userCredential.user?.phoneNumber}');
        return true;
      }

      isLoading.value = false;
      _showErrorSnackbar('Verification failed. Please try again.');
      return false;

    } catch (e) {
      isLoading.value = false;
      print('OTP verification failed: $e');

      String errorMessage = 'Invalid OTP code';
      if (e is FirebaseAuthException) {
        errorMessage = _getErrorMessage(e);
      }

      _showErrorSnackbar(errorMessage);
      return false;
    }
  }

  /// Get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number format is invalid';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'app-not-authorized':
        return 'App not authorized for Firebase Auth';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please check and try again';
      case 'session-expired':
        return 'Verification session has expired. Please request a new OTP';
      case 'credential-already-in-use':
        return 'This phone number is already associated with another account';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return e.message ?? 'Verification failed. Please try again';
    }
  }

  /// Mask phone number for display purposes
  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length > 5) {
      return '${phoneNumber.substring(0, 3)}****${phoneNumber.substring(phoneNumber.length - 2)}';
    }
    return phoneNumber;
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 4),
      icon: Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// Show success snackbar
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
      icon: Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  /// Sign out user and reset all state
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Reset all state variables
      isOTPsent = false;
      verificationId = null;
      resendToken = null;
      isLoading.value = false;
      currentPhoneNumber.value = '';

      print('User signed out successfully');
      _showSuccessSnackbar('Signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      _showErrorSnackbar('Failed to sign out: ${e.toString()}');
    }
  }

  /// Clear current session data
  void clearSession() {
    isOTPsent = false;
    verificationId = null;
    resendToken = null;
    isLoading.value = false;
    currentPhoneNumber.value = '';
    print('Session data cleared');
  }

  // Getters for accessing user information
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String? get userPhoneNumber => currentUser?.phoneNumber;
  bool get isPhoneVerified => currentUser != null && currentUser!.phoneNumber != null;

  // Getters for current session state
  bool get hasVerificationId => verificationId != null && verificationId!.isNotEmpty;
  bool get canResend => resendToken != null && currentPhoneNumber.value.isNotEmpty;
  String get sessionPhoneNumber => currentPhoneNumber.value;
}
