import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_screen.dart';
import 'package:timeless/screen/auth/sign_up/sign_up_screen.dart';
import 'package:timeless/screen/manager_section/auth_manager/Sign_in/sign_in_screen.dart';
import 'package:timeless/screen/first_page/first_controller.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';
import 'package:timeless/service/translation_service.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstScreen extends StatelessWidget {
  FirstScreen({super.key});

  final FirstScreenController controller = Get.put(FirstScreenController());

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      
      // ignorer avoid_print
      print('size: ${Get.width} x ${Get.height}');
    }

    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorRes.backgroundColor,
              ColorRes.surfaceColor,
            ],
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/logo.png'),
            fit: BoxFit.contain,
            opacity: 0.04, // Encore plus subtil sur cet écran
            alignment: Alignment.center,
            scale: 1.2,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton de traduction
                    Obx(() {
                      final translationService = TranslationService.instance;
                      final isEnglish = translationService.currentLanguage.value == 'en';
                      
                      return InkWell(
                        onTap: () {
                          translationService.toggleLanguage();
                          Get.snackbar(
                            'Language Changed',
                            isEnglish ? 'Switched to French' : 'Switched to English',
                            backgroundColor: ColorRes.primaryAccent,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ColorRes.primaryAccent.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isEnglish ? '🇺🇸' : '🇫🇷',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isEnglish ? 'EN' : 'FR',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: ColorRes.primaryAccent,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.swap_horiz,
                                size: 14,
                                color: ColorRes.primaryAccent.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    // Bouton d'accessibilité
                    InkWell(
                      onTap: () {
                        // Navigator vers AccessibilityPanel
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccessibilityPanel(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: ColorRes.primaryAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ColorRes.primaryAccent,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.accessibility,
                          color: ColorRes.primaryAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Logo principal 2x plus gros
              SizedBox(
                width: 400,
                height: 200,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: Get.height * 0.06),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  Strings.firstScreenSentences,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 21
                    color: ColorRes.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.03),

              /// Bouton Créer un compte
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (con) => const SignUpScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 42,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: ColorRes.primaryAccent,
                  ),
                  child: Text(
                    Strings.createAccount,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: ColorRes.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: Get.height * 0.02),
              Text(
                Strings.alreadyHaveAccount,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: ColorRes.textSecondary,
                ),
              ),
              SizedBox(height: Get.height * 0.02),

              /// Bouton pour se connecter
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ⚠️  SignInScreen dans fichier importé.
                      builder: (con) => const SigninScreenU(),
                    ),
                  );
                },
                child: Container(
                  height: 42,
                  width: 327,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: ColorRes.warningColor, width: 2),
                    color: ColorRes.surfaceColor,
                  ),
                  child: Text(
                    Strings.signIn,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: ColorRes.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.02),

              /// Bouton d'accès direct libre
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuestJobBrowser(),
                    ),
                  );
                },
                child: Container(
                  height: 42,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        ColorRes.appleGreen,
                        ColorRes.appleGreen.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorRes.appleGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Continue as Guest",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Get.height * 0.02),

              /// 🚨 BOUTON DEMO MANAGER ACCESS 🚨
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (con) => const SignInScreenM(),
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.business_center, color: ColorRes.brightYellow, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Employerccess",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.brightYellow
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.02),

              /// CGU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            'By creating an account, you are agreeing ',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: ColorRes.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: Strings.termsOfService,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.infoColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final uri = Uri.parse(
                              'https://www.termsfeed.com/live/588c37bc-3594-490a-be8b-d9409af52df7',
                            );
                            if (!await launchUrl(uri,
                                mode: LaunchMode.externalApplication)) {
                              // ignore: only_throw_errors
                              throw 'Could not launch $uri';
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }
}

class GuestJobBrowser extends StatelessWidget {
  const GuestJobBrowser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Browser'),
        backgroundColor: ColorRes.primaryAccent,
      ),
      body: const Center(
        child: Text('Guest access page'),
      ),
    );
  }
}
