import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/UserDataController.dart';
import '../services/firebase_storage_service.dart';
import '../services/image_optimization_service.dart';

class RegisterController extends GetxController {
  // Text controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();


  // Focus nodes
  final FocusNode focusNode = FocusNode();
  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();

  // Observable variables
  RxBool hasFullNameFocus = false.obs;
  RxBool hasFullNameInput = false.obs;
  RxBool hasPhoneNumberFocus = false.obs;
  RxBool hasPhoneNumberInput = false.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;
  RxInt selectOption = 0.obs;
  RxBool isChecked = false.obs;
  RxBool isLoading = false.obs;

  // Image upload variables
  Rx<File?> selectedImage = Rx<File?>(null);
  RxBool isImageUploading = false.obs;
  RxString imageUploadProgress = ''.obs;

  // Options list
  final List<String> optionList = ['No', 'Yes'];

  // Firebase and Storage instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _setupFocusListeners();
    _setupInputListeners();
    _handleNavigationArguments();
  }

  /// Handle navigation arguments if coming from OTP verification
  void _handleNavigationArguments() {
    try {
      final args = Get.arguments;
      if (args is Map && args['phoneNumber'] != null) {
        String phone = args['phoneNumber'].toString();

        // Remove '+91' prefix if present
        if (phone.startsWith('+91')) {
          phone = phone.substring(3); // remove first 3 characters
        }

        phoneNumberController.text = phone;
        hasPhoneNumberInput.value = true;
        print('Pre-filled phone number from OTP: $phone');
      }
    } catch (e) {
      print('Error handling navigation arguments: $e');
    }
  }


  /// Setup focus listeners
  void _setupFocusListeners() {
    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });

    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });

    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
  }

  /// Setup input listeners
  void _setupInputListeners() {
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });

    phoneNumberController.addListener(() {
      hasPhoneNumberInput.value = phoneNumberController.text.isNotEmpty;
    });

    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  /// Update option selection
  void updateOption(int index) {
    selectOption.value = index;
  }

  /// Toggle checkbox
  void toggleCheckbox() {
    isChecked.value = !isChecked.value;
  }

  /// Pick image from gallery or camera
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // Request permissions
      bool hasPermission = await _requestPermissions(source);
      if (!hasPermission) {
        _showError('Permission denied. Please grant camera/gallery access.');
        return;
      }

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        // _showSuccess('Image selected successfully!');
        print('Image selected: ${pickedFile.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showError('Failed to select image. Please try again.');
    }
  }

  /// Request necessary permissions
  Future<bool> _requestPermissions(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        return status == PermissionStatus.granted;
      } else {
        var status = await Permission.photos.request();
        if (status != PermissionStatus.granted) {
          // Try storage permission for older Android versions
          status = await Permission.storage.request();
        }
        return status == PermissionStatus.granted;
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Upload optimized image to Firebase Storage
  Future<String?> _uploadImageToFirebase(File imageFile, String userId) async {
    try {
      isImageUploading.value = true;
      imageUploadProgress.value = 'Preparing upload...';

      // Get the optimized storage service
      final storageService = Get.find<FirebaseStorageService>();
      
      imageUploadProgress.value = 'Optimizing image...';

      // Use optimized upload for profile images
      final downloadURL = await storageService.uploadOptimizedImage(
        imageFile: imageFile,
        userId: userId,
        folder: 'user_profiles',
        useCase: ImageUseCase.profile,
        createThumbnail: true,
      );

      imageUploadProgress.value = 'Upload completed!';
      print('✅ Optimized image uploaded successfully: $downloadURL');

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      imageUploadProgress.value = 'Upload failed';

      // Handle specific Firebase Storage errors
      String errorMessage = 'Failed to upload image. Please try again.';
      
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check Firebase Storage rules.';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage = 'Unauthorized access. Please login again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = 'Storage quota exceeded. Please contact support.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Upload timeout. Please try again.';
      } else if (e.toString().contains('File size too large')) {
        errorMessage = 'File size too large. Maximum size is 10MB.';
      }

      _showError(errorMessage);
      return null;
    } finally {
      isImageUploading.value = false;
    }
  }

  /// Register user with complete profile including image
  Future<void> registerUser() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isLoading.value = true;

      // Format phone number
      String formattedPhoneNumber = _formatPhoneNumber(phoneNumberController.text.trim());

      // Check if user already exists
      bool userExists = await _checkUserExists(formattedPhoneNumber, emailController.text.trim());
      if (userExists) {
        _showError('User with this phone number or email already exists');
        return;
      }

      _showSuccess('Account Creating...');

      // Create user document first to get user ID
      DocumentReference userRef = await _firestore.collection('users').add({
        'fullName': fullNameController.text.trim(),
        'phoneNumber': formattedPhoneNumber,
        'email': emailController.text.trim().toLowerCase(),
        'isRealEstateAgent': selectOption.value == 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileCompleted': false, // Will be updated after image upload
        'lastLoginAt': FieldValue.serverTimestamp(),
        'profileImageUrl': '', // Will be updated if image is uploaded
      });

      String userId = userRef.id;
      String? profileImageUrl;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      Get.put(UserDataController(userId: userId));



      // Upload profile image if selected
      if (selectedImage.value != null) {
        profileImageUrl = await _uploadImageToFirebase(selectedImage.value!, userId);
      }

      // Update user document with profile image URL and completion status
      await userRef.update({
        'profileImageUrl': profileImageUrl ?? '',
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('User registered successfully with ID: $userId');

      // Prepare user data for session
      Map<String, dynamic> userData = {
        'fullName': fullNameController.text.trim(),
        'phoneNumber': formattedPhoneNumber,
        'email': emailController.text.trim().toLowerCase(),
        'isRealEstateAgent': selectOption.value == 1,
        'profileCompleted': true,
        'profileImageUrl': profileImageUrl ?? '',
      };

      // Save user session using AuthService
      final AuthService authService = Get.find<AuthService>();
      await authService.loginUser(userId, formattedPhoneNumber, userData);

      // Show success message
      _showSuccess('Account created successfully! Welcome to Luxury Real Estate!');

      // Clear form
      _clearForm();

      // Navigate to home page after delay
      await Future.delayed(Duration(milliseconds: 1500));
      Get.offAllNamed(AppRoutes.bottomBarView);

    } catch (e) {
      print('Error registering user: $e');

      // Handle specific Firebase errors
      String errorMessage = 'Failed to create account. Please try again.';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please try again later.';
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = 'Storage quota exceeded. Please contact support.';
      }

      _showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user already exists with phone number or email
  Future<bool> _checkUserExists(String phoneNumber, String email) async {
    try {
      // Check by phone number
      QuerySnapshot phoneQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        return true;
      }

      // Check by email
      QuerySnapshot emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      return emailQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false; // Continue with registration if check fails
    }
  }

  /// Format phone number with country code
  String _formatPhoneNumber(String phoneNumber) {
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length == 10 && !phoneNumber.startsWith('+')) {
      return '+91$digitsOnly';
    } else if (digitsOnly.length > 10 && !phoneNumber.startsWith('+')) {
      return '+$digitsOnly';
    } else if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }

    return '+91$digitsOnly'; // Default to India
  }

  /// Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    List<RegExp> patterns = [
      RegExp(r'^\+[1-9]\d{1,14}$'), // International format
      RegExp(r'^[0-9]{10}$'), // 10 digit number
      RegExp(r'^\+91[0-9]{10}$'), // India format
      RegExp(r'^[6-9][0-9]{9}$'), // Indian mobile format
    ];

    return patterns.any((pattern) => pattern.hasMatch(cleanNumber));
  }

  /// Validate form with enhanced validation
  bool _validateForm() {
    // Full name validation
    if (fullNameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }

    if (fullNameController.text.trim().length < 2) {
      _showError('Full name must be at least 2 characters long');
      return false;
    }

    // Phone number validation
    if (phoneNumberController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }

    if (!_isValidPhoneNumber(phoneNumberController.text.trim())) {
      _showError('Please enter a valid phone number');
      return false;
    }

    // Email validation
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return false;
    }

    // Terms and conditions validation
    if (!isChecked.value) {
      _showError('Please accept the terms and conditions');
      return false;
    }

    return true;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  /// Clear form after successful registration
  void _clearForm() {
    fullNameController.clear();
    phoneNumberController.clear();
    emailController.clear();
    selectOption.value = 0;
    isChecked.value = false;
    selectedImage.value = null;

    // Reset focus states
    hasFullNameFocus.value = false;
    hasFullNameInput.value = false;
    hasPhoneNumberFocus.value = false;
    hasPhoneNumberInput.value = false;
    hasEmailFocus.value = false;
    hasEmailInput.value = false;
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Registration Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 4),
      icon: Icon(Icons.error_outline, color: Colors.white, size: 28),
      shouldIconPulse: true,
    );
  }

  /// Show success message
  void _showSuccess(String message) {
    // Registration success - saveData removed as it's handled elsewhere
    Get.snackbar(
      'Registration Successful',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
      shouldIconPulse: true,
    );
  }

  /// Remove selected image
  void removeImage() {
    selectedImage.value = null;
    _showSuccess('Image removed successfully!');
  }

  /// Get image selection options
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  title: 'Camera',
                  onTap: () {
                    Get.back();
                    pickImage(source: ImageSource.camera);
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  title: 'Gallery',
                  onTap: () {
                    Get.back();
                    pickImage(source: ImageSource.gallery);
                  },
                ),
                if (selectedImage.value != null)
                  _buildImageOption(
                    icon: Icons.delete,
                    title: 'Remove',
                    onTap: () {
                      Get.back();
                      removeImage();
                    },
                    color: Colors.red,
                  ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Build image picker option widget
  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (color ?? Colors.blue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color ?? Colors.blue,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    // Dispose controllers and focus nodes
    fullNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    super.onClose();
  }
}
