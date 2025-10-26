import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antill_estates/services/firebase_auth_service.dart';
import 'package:antill_estates/services/auth_service.dart';
import 'package:antill_estates/services/firebase_storage_service.dart';
import 'package:antill_estates/services/image_cache_service.dart';
import 'package:antill_estates/services/image_optimization_service.dart';
import 'package:antill_estates/services/enhanced_image_service.dart';
import 'package:antill_estates/services/firebase_notification_service.dart';
import 'package:antill_estates/services/user_notification_service.dart';
import 'package:antill_estates/controller/notification_controller.dart';
import 'package:antill_estates/controller/in_app_notification_controller.dart';
import 'package:antill_estates/services/UserDataController.dart';
import 'package:antill_estates/services/app_warmup_service.dart';
import 'package:antill_estates/services/performance_monitor_service.dart';
import 'package:antill_estates/services/instant_cache_service.dart';

/// Optimized app startup service with lazy loading and parallel initialization
class AppStartupService extends GetxController {
  static AppStartupService get instance => Get.find<AppStartupService>();
  
  final RxBool _isInitialized = false.obs;
  final RxString _initializationStatus = 'Starting...'.obs;
  final RxDouble _initializationProgress = 0.0.obs;
  
  // Core services that must be loaded immediately
  final List<String> _criticalServices = [
    'Firebase Core',
    'Firebase Auth',
    'GetStorage',
    'SharedPreferences',
    'AuthService',
  ];
  
  // Non-critical services that can be loaded later
  final List<String> _lazyServices = [
    'Firebase Storage',
    'Image Cache Service',
    'Image Optimization Service',
    'Firebase Notification Service',
    'User Notification Service',
    'Notification Controller',
    'In-App Notification Controller',
  ];
  
  bool get isInitialized => _isInitialized.value;
  String get initializationStatus => _initializationStatus.value;
  double get initializationProgress => _initializationProgress.value;
  
  /// Initialize critical services only (fast startup)
  Future<void> initializeCriticalServices() async {
    // Initialize performance monitor
    Get.put(PerformanceMonitorService(), permanent: true);
    final performanceMonitor = Get.find<PerformanceMonitorService>();
    
    performanceMonitor.startTimer('critical_services_init');
    
    try {
      _initializationStatus.value = 'Initializing core services...';
      _initializationProgress.value = 0.1;
      
      // 1. Initialize Firebase Core (parallel with other critical services)
      await _initializeFirebaseCore();
      _initializationProgress.value = 0.3;
      
      // 2. Initialize storage services in parallel
      await Future.wait([
        GetStorage.init(),
        SharedPreferences.getInstance(),
      ]);
      _initializationProgress.value = 0.5;
      
      // 3. Initialize critical Firebase services in parallel
      await _initializeCriticalFirebaseServices();
      _initializationProgress.value = 0.7;
      
      // 4. Register critical services
      _registerCriticalServices();
      _initializationProgress.value = 0.9;
      
      // 5. Mark as initialized
      _initializationStatus.value = 'Core services ready';
      _initializationProgress.value = 1.0;
      _isInitialized.value = true;
      
      // End performance monitoring
      performanceMonitor.endTimer('critical_services_init');
      
      print('✅ Critical services initialized successfully');
      
      // Start lazy loading non-critical services in background
      _initializeLazyServices();
      
      // Initialize warmup service
      Get.put(AppWarmupService(), permanent: true);
      
    } catch (e) {
      print('❌ Critical services initialization failed: $e');
      _initializationStatus.value = 'Initialization failed';
      rethrow;
    }
  }
  
  /// Initialize Firebase Core services
  Future<void> _initializeFirebaseCore() async {
    try {
      _initializationStatus.value = 'Initializing Firebase...';
      
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Initialize App Check (non-blocking)
      _initializeAppCheck();
      
      // Configure Firestore (optimized settings)
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      print('✅ Firebase Core initialized');
      
    } catch (e) {
      print('❌ Firebase Core initialization failed: $e');
      rethrow;
    }
  }
  
  /// Initialize App Check (non-blocking)
  void _initializeAppCheck() {
    try {
      FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      print('✅ App Check initialized');
    } catch (e) {
      print('⚠️ App Check initialization failed: $e');
      // Don't throw - this is not critical for startup
    }
  }
  
  /// Initialize critical Firebase services
  Future<void> _initializeCriticalFirebaseServices() async {
    try {
      _initializationStatus.value = 'Initializing Firebase Auth...';
      
      // Initialize Firebase Storage with optimized settings
      final storage = FirebaseStorage.instance;
      storage.setMaxUploadRetryTime(const Duration(seconds: 30));
      storage.setMaxDownloadRetryTime(const Duration(seconds: 30));
      
      print('✅ Firebase Auth services initialized');
      
    } catch (e) {
      print('❌ Firebase Auth services initialization failed: $e');
      rethrow;
    }
  }
  
  /// Register critical services
  void _registerCriticalServices() {
    try {
      _initializationStatus.value = 'Registering services...';
      
      // Register only critical services
      Get.put(FirebaseAuthService(), permanent: true);
      Get.put(AuthService(), permanent: true);
      
      // Register instant cache service for ultra-fast loading
      Get.put(InstantCacheService(), permanent: true);
      
      print('✅ Critical services registered');
      
    } catch (e) {
      print('❌ Critical services registration failed: $e');
      rethrow;
    }
  }
  
  /// Initialize non-critical services in background
  Future<void> _initializeLazyServices() async {
    try {
      print('🔄 Starting lazy initialization of non-critical services...');
      
      // Initialize services in parallel with priority
      await Future.wait([
        _initializeStorageServices(),
        _initializeImageServices(),
      ]);
      
      // Initialize notification services (lowest priority)
      _initializeNotificationServices();
      
      // Start app warmup in background
      _startAppWarmup();
      
      print('✅ Lazy services initialization completed');
      
    } catch (e) {
      print('❌ Lazy services initialization failed: $e');
      // Don't throw - these are not critical for app functionality
    }
  }
  
  /// Start app warmup in background
  void _startAppWarmup() {
    Future.microtask(() async {
      try {
        if (Get.isRegistered<AppWarmupService>()) {
          final warmupService = Get.find<AppWarmupService>();
          await warmupService.warmupServices();
        }
      } catch (e) {
        print('⚠️ App warmup failed: $e');
      }
    });
  }
  
  /// Initialize storage-related services
  Future<void> _initializeStorageServices() async {
    try {
      Get.put(FirebaseStorageService(), permanent: true);
      print('✅ Storage services initialized');
    } catch (e) {
      print('⚠️ Storage services initialization failed: $e');
    }
  }
  
  /// Initialize image-related services
  Future<void> _initializeImageServices() async {
    try {
      // ImageCacheService is a singleton, already initialized in main.dart
      Get.put(ImageOptimizationService(), permanent: true);
      Get.put(EnhancedImageService(), permanent: true);
      print('✅ Image services initialized');
    } catch (e) {
      print('⚠️ Image services initialization failed: $e');
    }
  }
  
  /// Initialize notification services (lowest priority)
  void _initializeNotificationServices() {
    try {
      // Initialize in background without blocking
      Future.microtask(() async {
        Get.put(NotificationController(), permanent: true);
        
        // Initialize in-app notification controller
        final inAppController = Get.put(InAppNotificationController(), permanent: true);
        
        try {
          await FirebaseNotificationService().initialize();
          final userNotificationService = UserNotificationService();
          await userNotificationService.registerUserForNotifications();
          print('✅ Notification services initialized');
          
          // Check for in-app notifications after a short delay to let user settle
          Future.delayed(const Duration(seconds: 3), () {
            inAppController.checkForNewNotifications();
          });
        } catch (e) {
          print('⚠️ Notification services initialization failed: $e');
        }
      });
      
    } catch (e) {
      print('⚠️ Notification services setup failed: $e');
    }
  }
  
  /// Initialize user data controller (when user is authenticated)
  Future<void> initializeUserData(String userId) async {
    try {
      if (!Get.isRegistered<UserDataController>()) {
        final controller = Get.put(UserDataController(userId: userId));
        // Fetch user data in background without blocking UI
        controller.fetchAndSaveUserData();
        print('✅ User data controller initialized');
      }
    } catch (e) {
      print('❌ User data controller initialization failed: $e');
    }
  }
  
  /// Check if a service is available
  bool isServiceAvailable(String serviceName) {
    switch (serviceName) {
      case 'Firebase Storage':
        return Get.isRegistered<FirebaseStorageService>();
      case 'Image Cache Service':
        return Get.isRegistered<ImageCacheService>();
      case 'Image Optimization Service':
        return Get.isRegistered<ImageOptimizationService>();
      case 'Firebase Notification Service':
        return Get.isRegistered<NotificationController>();
      default:
        return false;
    }
  }
  
  /// Get startup performance metrics
  Map<String, dynamic> getStartupMetrics() {
    return {
      'isInitialized': _isInitialized.value,
      'initializationStatus': _initializationStatus.value,
      'initializationProgress': _initializationProgress.value,
      'criticalServices': _criticalServices,
      'lazyServices': _lazyServices,
      'availableServices': _lazyServices.where((service) => isServiceAvailable(service)).toList(),
    };
  }
  
  /// Force initialize all services (for debugging)
  Future<void> forceInitializeAllServices() async {
    try {
      await _initializeLazyServices();
      print('✅ All services force initialized');
    } catch (e) {
      print('❌ Force initialization failed: $e');
    }
  }
}
