
// Main entry point of the Timeless application
// This file initializes Firebase, global services, localization, and sets up the main app widget.
// GetX dependencies are also used for state management and routing.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import 'firebase_options.dart';

// Candidate screens
import 'package:timeless/screen/splashScreen/splash_screen.dart';
import 'package:timeless/screen/first_page/first_screen.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_screen.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_screen.dart';
import 'package:timeless/screen/jobs/job_application_screen.dart';

// Global services
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/theme_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/screen/manager_section/Notification/notification_services.dart';

// Recruiter screens
import 'package:timeless/screen/manager_section/auth_manager/first_page/first_screen.dart'
    as ManagerFirstScreen;
import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart';

// Config and resources
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/pref_keys.dart';

// Entry point of the app
// This function sets up everything needed before launching the app
Future<void> main() async {
  // Needed for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure shared preferences and notification services
  await PreferencesService.init();
  await NotificationService.init();

  // Force the app to remain in portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure push notifications with Firebase
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await PreferencesService.setValue(PrefKeys.deviceToken, fcmToken);
    }
  } catch (e) {
    print('Erreur notifications: $e');
  }

  // Status bar and navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color.fromARGB(255, 110, 8, 3),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize global services using GetX
  Get.put(UnifiedTranslationService()); // Unified translation service (replaces 3 old services)
  Get.put(ThemeService()); // Enhanced theme service
  Get.put(AccessibilityService()); // Accessibility service for all

  // Launch the application with Easy Localization
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

// Widget principal of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Timeless',
      debugShowCheckedModeBanner: false, // Remove debug banner
      
      // Easy Localization setup
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // Theme with Timeless blue colors
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3B82F6)), // Royal blue instead of red
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF000647), // Dark blue for loading indicators
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        // Disable focus outlines completely
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),

      // First screen to show when the app starts
      home: const SplashScreen(),

      // Main routes for navigating the app
      getPages: [
        // Screens for candidates
        GetPage(
          name: AppRes.jobDetailScreen,
          page: () => JobDetailScreen(),
        ),
        GetPage(
          name: AppRes.jobRecommendationScreen,
          page: () => const JobRecommendationScreen(),
        ),
        GetPage(
          name: AppRes.firstScreen,
          page: () => FirstScreen(),
        ),
        GetPage(
          name: AppRes.jobApplicationScreen,
          page: () => JobApplicationScreen(
            job: Get.arguments?['job'], 
            docId: Get.arguments?['docId']
          ),
        ),

        // Login screen for recruiters
        GetPage(
          name: AppRes.firstPageScreenM,
          page: () => const ManagerFirstScreen.FirstPageScreenM(),
        ),
        
        // Dashboard for recruiters
        GetPage(
          name: AppRes.managerDashboardScreen,
          page: () => ManagerDashBoardScreen(),
        ),
      ],

      // Page not found
      unknownRoute: GetPage(
        name: '/404',
        page: () => FirstScreen(),
      ),
    );
  }
}
