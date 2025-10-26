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

  // Initialize optimized startup service
  try {
    final startupService = Get.put(AppStartupService(), permanent: true);
    await startupService.initializeCriticalServices();
    
    // Get user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    globalUserId = prefs.getString('userId');
    
    if (globalUserId != null && globalUserId!.isNotEmpty) {
      isOld = true;
      // Initialize user data in background
      startupService.initializeUserData(globalUserId!);
    }
    
    print('✅ App startup completed successfully');
    
  } catch (e, st) {
    print('❌ App startup error: $e');
    print(st);
  }

  runApp(const MyApp());
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppStartupService>(
      builder: (startupService) {
        // Navigate when critical services are ready
        if (startupService.isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToAppropriateScreen();
          });
        }

        return SplashView();
      },
    );
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
