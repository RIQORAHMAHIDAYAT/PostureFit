import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'presentation/controllers/theme_controller.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (!kIsWeb && Platform.isAndroid) {
      await Firebase.initializeApp();
      print("Firebase Initialized on Android");
    } else {
      print("Firebase not initialized for this platform (missing options)");
    }
  } catch (e) {
    print("Firebase init error: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  Get.put(ThemeController(), permanent: true);

  runApp(const PostureFitApp());
}

class PostureFitApp extends StatelessWidget {
  const PostureFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    return Obx(() => GetMaterialApp(
          title: 'PostureFit',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeCtrl.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          defaultTransition: Transition.cupertino,
        ));
  }
}
