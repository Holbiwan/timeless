// lib/screen/first_page/first_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_screen.dart';
import 'package:timeless/screen/auth/sign_up/sign_up_screen.dart';
import 'package:timeless/screen/auth/employer_signin/employer_signin_choice_screen.dart';
import 'package:timeless/screen/auth/employer_signin/employer_signin_screen.dart';
import 'package:timeless/screen/first_page/first_controller.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:url_launcher/url_launcher.dart';


class FirstScreen extends StatelessWidget {
  FirstScreen({super.key});

  final FirstScreenController controller = Get.put(FirstScreenController());
  final UnifiedTranslationService translationService = UnifiedTranslationService.instance;

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
                  width: Get.width * 0.95,
                  height: Get.height * 0.32,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: Get.height * 0.02),

                // "L'app pratique pour la recherche d'emploi" text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "The practical app for job searching",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: ColorRes.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: Get.height * 0.03),

                // Bouton pour se connecter
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
                      border: Border.all(
                          color: const Color(0xFF000647), width: 2.0),
                      color: Colors.white,
                    ),
                    child: Text(
                          "Sign in as candidate",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
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
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFF000647), width: 2.0),
                    ),
                    child: Text(
                          "Create candidate account",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                  ),
                ),
                SizedBox(height: Get.height * 0.025),

                // 💼 BOUTON SIGN IN AS PRO - AU DESSUS DU BOUTON CREATE PRO ACCOUNT
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (con) => const EmployerSignInChoiceScreen(),
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
                      color: const Color(0xFF000647),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000647).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                          color: const Color(0xFF000647), width: 2.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Obx(() => Text(
                                translationService.getText('Sign in as'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Get.height * 0.025),

                // Bouton Create pro Account
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployerSignInScreen(),
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
                      color: const Color(0xFF000647),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000647).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                          color: const Color(0xFF000647), width: 2.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Obx(() => Text(
                                translationService.getText('Create pro Account'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: Get.height * 0.035),

                // CGU
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Obx(() => RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  '${translationService.getText('terms_agreement')} ',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: ColorRes.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: translationService
                                  .getText('terms_of_service'),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: ColorRes.infoColor,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final uri = Uri.parse(
                                    'https://www.timeless-app.com/terms',
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
              padding: const EdgeInsets.only(
                  top: 40, left: 18, right: 18, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Boutons à droite
                  Row(
                    children: [
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
                            color: ColorRes.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF000647),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.accessibility,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
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

