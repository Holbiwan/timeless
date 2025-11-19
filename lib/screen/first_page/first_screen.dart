import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/common/widgets/language_toggle.dart';
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
  final TranslationService translationService = TranslationService.instance;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      
      // ignorer avoid_print
      print('size: ${Get.width} x ${Get.height}');
    }

    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Stack(
        children: [
          // Arrière-plan avec gradient propre
          Container(
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
            ),
          ),
          // Contenu scrollable
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80), // Espace pour les boutons fixes
              SizedBox(height: Get.height * 0.04),
              // Logo principal TIMELESS
              SizedBox(
                width: Get.width * 0.85,
                height: Get.height * 0.22,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: Get.height * 0.04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => Text(
                  translationService.getText('app_tagline'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: ColorRes.textPrimary,
                  ),
                )),
              ),
              SizedBox(height: Get.height * 0.04),

              // "Already have an account" text
              Obx(() => Text(
                translationService.getText('already_have_account'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: ColorRes.textSecondary,
                ),
              )),
              SizedBox(height: Get.height * 0.03),

              /// Bouton pour se connecter
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      //  SignInScreen dans fichier importé.
                      builder: (con) => const SigninScreenU(),
                    ),
                  );
                },
                child: Container(
                  height: 42,
                  width: Get.width * 0.75,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: ColorRes.warningColor, width: 2),
                    color: ColorRes.surfaceColor,
                  ),
                  child: Obx(() => Text(
                    translationService.getText('sign_in'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: ColorRes.textPrimary,
                    ),
                  )),
                ),
              ),

              SizedBox(height: Get.height * 0.025),

              // Bouton Créer un compte
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
                  width: Get.width * 0.75,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: ColorRes.primaryAccent,
                  ),
                  child: Obx(() => Text(
                    translationService.getText('create_account'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: ColorRes.white,
                    ),
                  )),
                ),
              ),
              SizedBox(height: Get.height * 0.025),

              /// 🚨 BOUTON MANAGER ACCESS 🚨
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
                  height: 44,
                  width: Get.width * 0.75,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_center, color: ColorRes.brightYellow, size: 22),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                        translationService.getText('employer_access'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.brightYellow
                        ),
                      )),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Get.height * 0.025),

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
                  width: Get.width * 0.75,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        ColorRes.brightYellow,
                        ColorRes.orange,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: ColorRes.darkGold),
                    boxShadow: [
                      BoxShadow(
                        color: ColorRes.darkGold.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, color: const Color.fromARGB(255, 3, 14, 31), size: 21),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                        translationService.getText('continue_as_guest'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color.fromARGB(255, 3, 14, 31),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.035),

              /// CGU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Obx(() => RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: '${translationService.getText('terms_agreement')} ',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: ColorRes.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: translationService.getText('terms_of_service'),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.infoColor,
                          decoration: TextDecoration.underline,
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
                )),
              ),
              // Espace supplémentaire pour garantir l'accessibilité des CGU
              SizedBox(height: Get.height * 0.08),
            ],
          ),
        ),
        // Boutons fixes en haut
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 40, left: 18, right: 18, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton de traduction
                const LanguageToggle(),
                
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
        ),
      ],
    ),
    );
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
