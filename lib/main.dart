import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

// ===== User =====
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

// ===== Manager =====
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PrefService.init();
  await NotificationService.init();

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await PrefService.setValue(PrefKeys.deviceToken, fcmToken);
    }
  } catch (e) {
    // ignore: avoid_print
    print('Erreur FCM (ok pour la démo): $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.red,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialiser les services
  Get.put(TranslationService());
  Get.put(AccessibilityService());
  Get.put(AutoTranslationService());
  Get.put(AppNotificationService.NotificationService());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Timeless',
      debugShowCheckedModeBanner: false,
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

      // point d’entrée
      home: const SplashScreen(),

      getPages: [
        // === USER ROUTES ===
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

        // === MANAGER ROUTES ===
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
