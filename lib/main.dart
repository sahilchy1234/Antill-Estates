import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/configs/performance_config.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/views/splash/splash_view.dart';
import 'package:antill_estates/services/auth_service.dart';
import 'package:antill_estates/services/app_startup_service.dart';
import 'package:antill_estates/services/performance_monitor_service.dart';
import 'package:antill_estates/services/cache_service.dart';
import 'package:antill_estates/services/image_cache_service.dart';
import 'package:antill_estates/services/cache_manager.dart';

bool isOld = false;
String? globalUserId;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize performance optimizations
  PerformanceConfig.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Start performance monitoring
  final performanceMonitor = Get.put(PerformanceMonitorService(), permanent: true);
  performanceMonitor.startTimer('app_startup_total');

  // Initialize comprehensive cache services for super fast loading
  try {
    // Initialize base cache service
    await Get.putAsync(() => initCacheService(), permanent: true);
    
    // Initialize image cache service
    await ImageCacheService.instance.init();
    
    // Initialize cache manager
    Get.put(CacheManager(), permanent: true);
    
    print('✅ All cache services initialized successfully');
  } catch (e) {
    print('❌ Cache initialization error: $e');
  }

  // Initialize startup service (but don't await - let it run while splash shows)
  final startupService = Get.put(AppStartupService(), permanent: true);
  
  // Get user ID from SharedPreferences quickly
  try {
    final prefs = await SharedPreferences.getInstance();
    globalUserId = prefs.getString('userId');
    
    if (globalUserId != null && globalUserId!.isNotEmpty) {
      isOld = true;
    }
  } catch (e) {
    print('❌ SharedPreferences error: $e');
  }

  runApp(const MyApp());
  
  // Start initialization AFTER a small delay to ensure splash screen renders
  Future.delayed(const Duration(milliseconds: 100), () {
    startupService.initializeCriticalServices().then((_) {
      // Initialize user data in background if needed
      if (globalUserId != null && globalUserId!.isNotEmpty) {
        startupService.initializeUserData(globalUserId!);
      }
      print('✅ App startup completed successfully');
    }).catchError((e, st) {
      print('❌ App startup error: $e');
      print(st);
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppString.appName,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      home: const AuthWrapper(),
      getPages: AppRoutes.pages,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
      ),
      theme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasNavigated = false;
  final DateTime _startTime = DateTime.now();
  static const int _minSplashDuration = 2000; // Minimum 2 seconds

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppStartupService>(
      init: Get.find<AppStartupService>(),
      builder: (startupService) {
        // Navigate when critical services are ready AND minimum time has passed
        if (startupService.isInitialized && !_hasNavigated) {
          _navigateAfterMinimumDuration();
        }

        return const SplashView();
      },
    );
  }

  void _navigateAfterMinimumDuration() async {
    // Calculate how long splash has been showing
    final elapsedTime = DateTime.now().difference(_startTime).inMilliseconds;
    final remainingTime = _minSplashDuration - elapsedTime;

    // Wait for remaining time if needed
    if (remainingTime > 0) {
      await Future.delayed(Duration(milliseconds: remainingTime));
    }

    // Check if still mounted and haven't navigated yet
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToAppropriateScreen();
      });
    }
  }

  void _navigateToAppropriateScreen() {
    try {
      // End performance monitoring
      if (Get.isRegistered<PerformanceMonitorService>()) {
        final performanceMonitor = Get.find<PerformanceMonitorService>();
        performanceMonitor.endTimer('app_startup_total');
        performanceMonitor.logMetrics();
        
        // Log startup summary
        final summary = performanceMonitor.getStartupSummary();
        print('📊 Startup Summary: $summary');
        
        // Log recommendations
        final recommendations = performanceMonitor.getPerformanceRecommendations();
        recommendations.forEach((recommendation) {
          print('💡 $recommendation');
        });
      }
      
      // Check if user is authenticated
      if (isOld && globalUserId != null && globalUserId!.isNotEmpty) {
        // User is logged in - go to main app
        if (Get.currentRoute != AppRoutes.bottomBarView) {
          Get.offAllNamed(AppRoutes.bottomBarView);
        }
      } else {
        // Check AuthService for session
        final authService = Get.find<AuthService>();
        if (authService.isLoggedIn.value && authService.isSessionValid()) {
          if (Get.currentRoute != AppRoutes.bottomBarView) {
            Get.offAllNamed(AppRoutes.bottomBarView);
          }
        } else {
          // Check if user has phone number saved
          final prefs = SharedPreferences.getInstance();
          prefs.then((prefs) {
            if (prefs.containsKey('phone_num')) {
              if (Get.currentRoute != AppRoutes.registerView) {
                Get.offAllNamed(AppRoutes.registerView);
              }
            } else {
              if (Get.currentRoute != AppRoutes.onboardView) {
                Get.offAllNamed(AppRoutes.onboardView);
              }
            }
          });
        }
      }
    } catch (e) {
      print('❌ Navigation error: $e');
      // Fallback to onboard screen
      if (Get.currentRoute != AppRoutes.onboardView) {
        Get.offAllNamed(AppRoutes.onboardView);
      }
    }
  }
}
