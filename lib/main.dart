// Main entry point of the Timeless app
// This file initializes Firebase, localization, global services,
// and defines the main application widget using GetX.

// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:timeless/utils/firebase_options.dart';

// Candidate screens
import 'package:timeless/screen/splashScreen/splash_screen.dart';
import 'package:timeless/screen/first_page/first_screen.dart' as candidate_auth;
import 'package:timeless/screen/job_detail_screen/job_detail_screen.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_screen.dart';
import 'package:timeless/screen/jobs/job_application_screen.dart';
import 'package:timeless/screen/dashboard/applications/applications_screen.dart';

// Global services
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/auth_service.dart';
import 'package:timeless/screen/manager_section/Notification/notification_services.dart';

// Recruiter screens
import 'package:timeless/screen/manager_section/auth_manager/first_page/first_screen.dart'
    as manager_auth;

import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart'
    show ManagerDashBoardScreen;

// Employer screens
import 'package:timeless/screen/employer/employer_dashboard_screen.dart';

// App configuration and shared resources
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/color_res.dart';

// App entry point
Future<void> main() async {
  // Required to run async code before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local storage and notifications
  await PreferencesService.init();
  await NotificationService.init();

  // Lock app orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Get and store Firebase Cloud Messaging token
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await PreferencesService.setValue(PrefKeys.deviceToken, fcmToken);
    }
  } catch (e) {
    print('Notification error: $e');
  }

  // Configure system UI (status bar & navigation bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: ColorRes.primaryBlueDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Register global services with GetX
  Get.put(UnifiedTranslationService()); // Centralized translation service
  Get.put(AccessibilityService()); // Accessibility options
  Get.put(AuthService()); // Authentication service

  // Start the app with localization support
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

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityService = Get.find<AccessibilityService>();
    
    return Obx(() => GetMaterialApp(
      title: 'Timeless',
      debugShowCheckedModeBanner: false,

      // Localization configuration
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      fallbackLocale: const Locale('en'),

      // Global accessibility-aware theme
      theme: accessibilityService.globalTheme,

      // Initial screen displayed at launch
      home: const SplashScreen(),

      // App navigation routes
      getPages: [
        // Candidate routes
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
          page: () => candidate_auth.FirstScreen(),
        ),
        GetPage(
          name: AppRes.jobApplicationScreen,
          page: () => JobApplicationScreen(
            job: Get.arguments?['job'],
            docId: Get.arguments?['docId'],
          ),
        ),
        GetPage(
          name: AppRes.applicationsUser,
          page: () => ApplicationsScreen(),
        ),

        // Recruiter login
        GetPage(
          name: AppRes.firstPageScreenM,
          page: () => manager_auth.FirstPageScreenM(),
        ),

        // Recruiter dashboard
        GetPage(
          name: AppRes.managerDashboardScreen,
          page: () => ManagerDashBoardScreen(),
        ),

        // Employer dashboard
        GetPage(
          name: AppRes.employerDashboardScreen,
          page: () => const EmployerDashboardScreen(),
        ),
      ],

      // Fallback route
      unknownRoute: GetPage(
        name: '/404',
        page: () => candidate_auth.FirstScreen(),
      ),
    ));
  }
}
