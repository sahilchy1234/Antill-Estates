import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/routes/app_routes.dart';
import 'package:antill_estates/views/splash/splash_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppString.appName,
      defaultTransition: Transition.fadeIn,
      debugShowCheckedModeBanner: false,
      home: SplashView(),
      getPages: AppRoutes.pages,
    );
  }
}
