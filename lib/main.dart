// ==========================================================================
// TIMELESS - Main Application Entry Point / Point d'entrée principal
// ==========================================================================
// EN: Main application file that initializes Firebase, services, and routing
// FR: Fichier principal qui initialise Firebase, les services et le routage
// ==========================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

// =============================================================================
// IMPORTS - User Side / Côté Utilisateur
// =============================================================================
// EN: All screens and services for job seekers
// FR: Tous les écrans et services pour les chercheurs d'emploi
import 'package:timeless/screen/splashScreen/splash_screen.dart';
import 'package:timeless/screen/first_page/first_screen.dart';
import 'package:timeless/screen/new_home_page/new_home_page_screen.dart';
// <- import modifié : suppression du show car la classe n'existe pas
import 'package:timeless/screen/notification_screen/notification_screen.dart'
    as UserNotification;
import 'package:timeless/screen/job_detail_screen/job_detail_screen.dart';
import 'package:timeless/screen/job_detail_screen/job_details_success_or_fails/job_details_success_or_faild_screen.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_screen.dart';
import 'package:timeless/screen/organization_profile_screen/organization_profile_screen.dart';
import 'package:timeless/screen/see_details/see_details_screen.dart';
import 'package:timeless/screen/dashboard/applications/applications_screen.dart';
import 'package:timeless/screen/update_vacancies_requirements/update_vacancies_requirements_screen.dart';
import 'package:timeless/test/upload_cv_test_screen.dart';
import 'package:timeless/service/translation_service.dart';
import 'package:timeless/service/accessibility_service.dart';
import 'package:timeless/service/auto_translation_service.dart';
import 'package:timeless/service/notification_service.dart' as AppNotificationService;

// =============================================================================
// IMPORTS - Manager Side / Côté Gestionnaire
// =============================================================================
// EN: All screens and services for employers and HR managers
// FR: Tous les écrans et services pour les employeurs et gestionnaires RH
import 'package:timeless/screen/manager_section/Notification/notification_services.dart';
import 'package:timeless/screen/manager_section/auth_manager/first_page/first_screen.dart'
    as ManagerFirstScreen;
// import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart' show ManagerDashboardScreen; // <-- à réactiver si le nom est exact
import 'package:timeless/screen/manager_section/manager_application_detail_screen/manager_application_detail_screen.dart';
import 'package:timeless/screen/manager_section/resume_screen/resume_screen.dart';
import 'package:timeless/screen/manager_section/applicants_detail_screen/applicants_detail_screen.dart';

// ===== Utils =====
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/pref_keys.dart';

import 'package:timeless/screen/looking_for_screen/looking_for_screen.dart';

// =============================================================================
// MAIN FUNCTION / FONCTION PRINCIPALE
// =============================================================================
// EN: Application initialization and startup
// FR: Initialisation et démarrage de l'application
// =============================================================================

Future<void> main() async {
  // EN: Ensure Flutter is initialized before any async operations
  // FR: S'assurer que Flutter est initialisé avant toute opération asynchrone
  WidgetsFlutterBinding.ensureInitialized();

  // EN: Initialize Firebase services for authentication and database
  // FR: Initialiser les services Firebase pour l'authentification et la base de données
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // EN: Initialize local storage and notification services
  // FR: Initialiser le stockage local et les services de notifications
  await PrefService.init();
  await NotificationService.init();

  // EN: Lock app orientation to portrait mode for better UX
  // FR: Verrouiller l'orientation en mode portrait pour une meilleure UX
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  // EN: Setup Firebase Cloud Messaging for push notifications
  // FR: Configurer Firebase Cloud Messaging pour les notifications push
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await PrefService.setValue(PrefKeys.deviceToken, fcmToken);
    }
  } catch (e) {
    // EN: FCM errors are non-blocking for demo purposes
    // FR: Les erreurs FCM ne bloquent pas la démo
    print('Erreur FCM (ok pour la démo): $e');
  }

  // EN: Configure status bar and navigation bar styling
  // FR: Configurer le style de la barre de statut et de navigation
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.red,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // EN: Initialize dependency injection for core services
  // FR: Initialiser l'injection de dépendance pour les services principaux
  Get.put(TranslationService());      // Multi-language support / Support multilingue
  Get.put(AccessibilityService());    // Accessibility features / Fonctionnalités d'accessibilité
  Get.put(AutoTranslationService());  // Auto-translation / Traduction automatique
  Get.put(AppNotificationService.NotificationService()); // Push notifications / Notifications push
  
  // EN: Launch the application
  // FR: Lancer l'application
  runApp(const MyApp());
}

// =============================================================================
// APP CLASS / CLASSE PRINCIPALE DE L'APPLICATION
// =============================================================================
// EN: Main widget that defines app theme, routing, and entry point
// FR: Widget principal qui définit le thème, le routage et le point d'entrée
// =============================================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Timeless',
      debugShowCheckedModeBanner: false,
      
      // EN: App theme with red branding colors
      // FR: Thème de l'application avec les couleurs de marque rouge
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.red,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
      ),

      // EN: Entry point - Splash screen for smooth app startup
      // FR: Point d'entrée - Écran de démarrage pour un lancement fluide
      home: const SplashScreen(),

      // EN: Application routing system with GetX
      // FR: Système de routage de l'application avec GetX
      getPages: [
        // =================================================================
        // USER ROUTES / ROUTES UTILISATEUR
        // =================================================================
        // EN: All navigation routes for job seekers
        // FR: Toutes les routes de navigation pour les chercheurs d'emploi
        GetPage(
          name: AppRes.notificationScreen,
          page: () => const UserNotification.NotificationScreenU(),
        ),
        GetPage(
          name: AppRes.jobDetailScreen,
          page: () => JobDetailScreen(),
        ),
        GetPage(
          name: AppRes.jobDetailUploadCvScreen,
          page: () => const UploadCvTestScreen(),
        ),
        GetPage(
          name: AppRes.jobDetailSuccessOrFailed,
          page: () => JobDetailsSuccessOrFailedScreen(),
        ),
        GetPage(
          name: AppRes.jobRecommendationScreen,
          page: () => const JobRecommendationScreen(),
        ),
        GetPage(
          name: AppRes.organizationProfileScreen,
          page: () => const OrganizationProfileScreen(),
        ),
        GetPage(
          name: AppRes.seeDetailsScreen,
          page: () => const SeeDetailsScreen(),
        ),
        GetPage(
          name: AppRes.applicationsUser,
          page: () => ApplicationsScreen(),
        ),
        GetPage(
          name: AppRes.firstScreen,
          page: () => FirstScreen(),
        ),
        // NOTE: on ne met cette page que si la classe existe vraiment
        // GetPage(
        //   name: AppRes.newHomePageUi,
        //   page: () => const NewHomePageUi(), // <- vérifie que la classe s’appelle bien NewHomePageUi
        // ),
        GetPage(
          name: AppRes.updateVacanciesRequirementScreen,
          page: () => const UpdateVacanciesRequirementsScreen(),
        ),
        GetPage(
          name: AppRes.lookingForScreen,
          page: () => const LookingForScreen(),
        ),

        // =================================================================
        // MANAGER ROUTES / ROUTES GESTIONNAIRE
        // =================================================================
        // EN: All navigation routes for employers and HR managers
        // FR: Toutes les routes pour les employeurs et gestionnaires RH
        // GetPage(
        //   name: AppRes.managerDashboardScreen,
        //   page: () => const ManagerDashboardScreen(), // <- réactive si ce nom est correct
        // ),
        GetPage(
          name: AppRes.managerApplicationDetailScreen,
          page: () => ManagerApplicationDetailScreen(),
        ),
        GetPage(
          name: AppRes.resumeScreen,
          page: () => const ResumeScreen(),
        ),
        GetPage(
          name: AppRes.applicantsDetails,
          page: () => ApplicantsDetailScreen(isWrong: false),
        ),
        GetPage(
          name: AppRes.firstPageScreenM,
          page: () => const ManagerFirstScreen.FirstPageScreenM(),
        ),
      ],

      unknownRoute: GetPage(
        name: '/404',
        page: () => FirstScreen(),
      ),
    );
  }
}
