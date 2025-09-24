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
      
      // ignore: avoid_print
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
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: ColorRes.brightYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorRes.brightYellow,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '👋',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Logo principal agrandi
              Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorRes.darkBlue,
                      ColorRes.darkBlue.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorRes.brightYellow.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorRes.brightYellow.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: ColorRes.darkBlue.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
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
                    fontSize: 20,
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
                  height: 48,
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
                      fontSize: 18,
                      color: ColorRes.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: Get.height * 0.03),
              Text(
                Strings.alreadyHaveAccount,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: ColorRes.textSecondary,
                ),
              ),
              SizedBox(height: Get.height * 0.0344),

              /// Bouton Se connecter
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
                  height: 48,
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
                      fontSize: 18,
                      color: ColorRes.textPrimary,
                    ),
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
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: ColorRes.warningColor, width: 2),
                    color: ColorRes.cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.business_center, color: ColorRes.warningColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "Employer Access",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.textPrimary
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
                            'By creating an account, you are agreeing\n                to our ',
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
