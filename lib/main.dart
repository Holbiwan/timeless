import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

// ===== Screens (User) =====
import 'package:timeless/screen/splashScreen/splash_screen.dart';
// Make sure the SplashScreen class exists in splash_screen.dart and is exported as SplashScreen
import 'package:timeless/screen/first_page/first_screen.dart';
import 'package:timeless/screen/new_home_page/new_home_page_screen.dart';
import 'package:timeless/screen/notification_screen/notification_screen.dart' as UserNotification;
import 'package:timeless/screen/job_detail_screen/job_detail_screen.dart';
import 'package:timeless/screen/job_detail_screen/job_details_success_or_fails/job_details_success_or_faild_screen.dart';
// Ensure this import is correct and the file exists with the correct class name
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_screen.dart';
import 'package:timeless/screen/organization_profile_screen/organization_profile_screen.dart';
import 'package:timeless/screen/see_details/see_details_screen.dart';
import 'package:timeless/screen/dashboard/applications/applications_screen.dart';
import 'package:timeless/screen/update_vacancies_requirements/update_vacancies_requirements_screen.dart';

// ⚠️ Utilise la page de test trouvée : lib/test/upload_cv_test_screen.dart
import 'package:timeless/test/upload_cv_test_screen.dart';

// ===== Manager Section =====
import 'package:timeless/screen/manager_section/Notification/notification_services.dart';
import 'package:timeless/screen/manager_section/auth_manager/first_page/first_screen.dart'
    // ignore: library_prefixes
    as ManagerFirstScreen;
import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart';
import 'package:timeless/screen/manager_section/manager_application_detail_screen/manager_application_detail_screen.dart';
import 'package:timeless/screen/manager_section/resume_screen/resume_screen.dart';
import 'package:timeless/screen/manager_section/applicants_detail_screen/applicants_detail_screen.dart';

// ===== Utils / Services =====
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/pref_keys.dart';

import 'package:timeless/screen/looking_for_screen/looking_for_screen.dart';
import 'package:timeless/missing_classes.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PrefService.init();
  await NotificationService.init();

  // Portrait only
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  // Optional FCM token
  try {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await PrefService.setValue(PrefKeys.deviceToken, fcmToken);
    }
  } catch (e) {
    // ignore: avoid_print
    print("Erreur FCM (ignorable pour la démo): $e");
  }

  // UI chrome
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.red,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

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
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.red,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
      ),

      home: const SplashScreen(),
      // home: FirstScreen(),

      initialRoute: "/",
      getPages: [
        GetPage(
          name: AppRes.notificationScreen,
          // ignore: prefer_const_constructors
          page: () => UserNotification.NotificationScreenU(),
        ),
        GetPage(
          name: AppRes.jobDetailScreen,
          page: () => JobDetailScreen(),
        ),
        // Utilise la page de test présente dans lib/test/
        GetPage(
          name: AppRes.jobDetailUploadCvScreen,
          // ignore: prefer_const_constructors
          page: () => UploadCvTestScreen(),
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
          name: AppRes.managerDashboardScreen,
          page: () => const ManagerDashboardScreen(),
        ),
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
          page: () => ApplicantsDetailScreen(
            isWrong: false, // paramètre requis
          ),
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
        GetPage(
          name: AppRes.firstPageScreenM,
          page: () => const ManagerFirstScreen.FirstPageScreenM(),
        ),
        GetPage(
          name: AppRes.newHomePageUi,
          page: () => const NewHomePageScreen(),
        ),
        GetPage(
          name: AppRes.updateVacanciesRequirementScreen,
          page: () => const UpdateVacanciesRequirementsScreen(),
        ),
        GetPage(
          name: AppRes.lookingForScreen,
          page: () => const LookingForScreen(),
        ),
      ],
    );
  }
}
