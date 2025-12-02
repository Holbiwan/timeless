import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import 'firebase_options.dart';

// Principal screens for the candidates
import 'package:timeless/screen/splashScreen/splash_screen.dart';
import 'package:timeless/screen/first_page/first_screen.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_screen.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_screen.dart';
import 'package:timeless/screen/jobs/job_application_screen.dart';

// Sercices for global functionalities
import 'package:timeless/services/translation_service.dart';
import 'package:timeless/services/easy_translation_service.dart';
import 'package:timeless/services/comprehensive_translation_service.dart';
import 'package:timeless/services/theme_service.dart';
import 'package:timeless/services/accessibility_service.dart';
// Import supprimé : auto_translation_service.dart n'existe plus
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/screen/manager_section/Notification/notification_services.dart';

// Screens for the recruiters
import 'package:timeless/screen/manager_section/auth_manager/first_page/first_screen.dart'
    as ManagerFirstScreen;

// Configurations and resources
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/pref_keys.dart';

// Entry point of the application
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
  Get.put(TranslationService()); // Support français/anglais (Legacy)
  Get.put(EasyTranslationService()); // Nouveau service Easy Localization
  Get.put(ComprehensiveTranslationService()); // Service complet avec Google Translate
  Get.put(ThemeService()); // Service de thèmes amélioré
  Get.put(AccessibilityService()); // Accessibilité pour tous
  // AutoTranslationService supprimé - fonctionnalité trop avancée

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
      // Theme with Timeless blue colors - no green focus outlines
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3B82F6)), // Royal blue instead of red
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF000647), // Bleu foncé pour les indicateurs de chargement
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
          page: () => JobApplicationScreen(job: Get.arguments['job'], docId: Get.arguments['docId']),
        ),

        // Login screen for recruiters
        GetPage(
          name: AppRes.firstPageScreenM,
          page: () => const ManagerFirstScreen.FirstPageScreenM(),
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
