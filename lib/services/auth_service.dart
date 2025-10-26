import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends GetxService {
  final GetStorage _storage = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoggedIn = false.obs;
  RxString userId = ''.obs;
  RxString phoneNumber = ''.obs;
  Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  RxBool isFirebaseReady = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeAuth();

    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((User? user) {
      print('Firebase Auth state changed: ${user?.uid ?? 'No user'}');
      isFirebaseReady.value = user != null;

      if (user != null && user.isAnonymous) {
        print('Anonymous user authenticated: ${user.uid}');
      } else if (user != null) {
        print('Registered user authenticated: ${user.uid}');
      }
    });
  }

  /// Initialize authentication with immediate anonymous sign-in
  Future<void> _initializeAuth() async {
    try {
      // First check if there's already a Firebase user
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        // Sign in anonymously immediately to enable Firebase services
        print('No Firebase user found, signing in anonymously...');
        UserCredential result = await _auth.signInAnonymously();
        print('Anonymous authentication successful: ${result.user?.uid}');
        isFirebaseReady.value = true;
      } else {
        print('Existing Firebase user found: ${currentUser.uid}');
        isFirebaseReady.value = true;
      }

      // Check for existing user session
      await _checkExistingSession();

    } catch (e) {
      print('Error initializing auth: $e');
      // Try to continue without Firebase auth if it fails
      isFirebaseReady.value = false;
    }
  }

  /// Check for existing user session in local storage
  Future<void> _checkExistingSession() async {
    try {
      bool? storedLoginState = _storage.read('isLoggedIn');
      String? storedUserId = _storage.read('userId');
      String? storedPhoneNumber = _storage.read('phoneNumber');
      Map<String, dynamic>? storedUserData = _storage.read('userData');

      if (storedLoginState == true && storedUserId != null) {
        // Verify user still exists in Firestore
        bool userExists = await _verifyUserInFirestore(storedUserId);

        if (userExists && isSessionValid()) {
          // Restore session
          isLoggedIn.value = true;
          userId.value = storedUserId;
          phoneNumber.value = storedPhoneNumber ?? '';
          userData.value = Map<String, dynamic>.from(storedUserData ?? {});

          print('User session restored for: $storedUserId');
          return;
        }
      }

      // Clear invalid session
      await _clearLocalSession();
      print('No valid user session found');
    } catch (e) {
      print('Error checking existing session: $e');
      await _clearLocalSession();
    }
  }

  /// Ensure Firebase authentication is ready
  Future<void> ensureFirebaseAuth() async {
    try {
      if (_auth.currentUser == null) {
        print('Creating anonymous Firebase user for services...');
        UserCredential result = await _auth.signInAnonymously();
        print('Anonymous authentication created: ${result.user?.uid}');
        isFirebaseReady.value = true;
      } else {
        isFirebaseReady.value = true;
      }
    } catch (e) {
      print('Error ensuring Firebase auth: $e');
      isFirebaseReady.value = false;
    }
  }

  /// Login user with phone verification
  Future<void> loginUser(String firestoreUserId, String userPhoneNumber, Map<String, dynamic> userInfo) async {
    try {
      // Ensure Firebase Auth is ready
      await ensureFirebaseAuth();

      // Update user's last login in Firestore
      await _firestore.collection('users').doc(firestoreUserId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'firebaseUserId': _auth.currentUser?.uid,
      });

      // Store session locally
      await _storage.write('isLoggedIn', true);
      await _storage.write('userId', firestoreUserId);
      await _storage.write('phoneNumber', userPhoneNumber);
      await _storage.write('userData', userInfo);
      await _storage.write('loginTimestamp', DateTime.now().millisecondsSinceEpoch);

      // Update reactive variables
      isLoggedIn.value = true;
      userId.value = firestoreUserId;
      phoneNumber.value = userPhoneNumber;
      userData.value = Map<String, dynamic>.from(userInfo);

      print('User logged in successfully: $firestoreUserId');
    } catch (e) {
      print('Error logging in user: $e');
      throw Exception('Failed to login user: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Update Firestore if user exists
      if (userId.value.isNotEmpty) {
        try {
          await _firestore.collection('users').doc(userId.value).update({
            'lastLogoutAt': FieldValue.serverTimestamp(),
            'isActive': false,
          });
        } catch (e) {
          print('Error updating logout in Firestore: $e');
        }
      }

      // Clear local session
      await _clearLocalSession();

      // Keep anonymous Firebase user for app functionality
      // Don't sign out from Firebase Auth to maintain Storage access
      print('User logged out successfully');

      // Navigate to onboard
      // Get.offAllNamed(AppRoutes.onboardView);

    } catch (e) {
      print('Error during logout: $e');
    }
  }

  /// Clear local session data
  Future<void> _clearLocalSession() async {
    try {
      await _storage.erase();

      isLoggedIn.value = false;
      userId.value = '';
      phoneNumber.value = '';
      userData.value = {};

    } catch (e) {
      print('Error clearing local session: $e');
    }
  }

  /// Verify user exists in Firestore
  Future<bool> _verifyUserInFirestore(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error verifying user in Firestore: $e');
      return false;
    }
  }

  /// Check if session is still valid (7 days)
  bool isSessionValid() {
    try {
      int? loginTimestamp = _storage.read('loginTimestamp');
      if (loginTimestamp == null) return false;

      DateTime loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(loginTime);

      // Session valid for 7 days
      return difference.inDays < 7;
    } catch (e) {
      print('Error checking session validity: $e');
      return false;
    }
  }

  /// Update user data
  Future<void> updateUserData(Map<String, dynamic> newData) async {
    try {
      if (userId.value.isNotEmpty) {
        // Update Firestore
        await _firestore.collection('users').doc(userId.value).update({
          ...newData,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local storage
        Map<String, dynamic> updatedData = Map<String, dynamic>.from(userData.value);
        updatedData.addAll(newData);

        await _storage.write('userData', updatedData);
        userData.value = updatedData;

        print('User data updated successfully');
      }
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  /// Get current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Check if Firebase is ready for operations
  bool get isFirebaseAuthReady => isFirebaseReady.value && _auth.currentUser != null;
}
