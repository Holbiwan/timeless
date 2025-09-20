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
      backgroundColor: const Color.fromARGB(255, 234, 239, 164),
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetRes.firstBackScreen),
            fit: BoxFit.cover,
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
                    backButton(),
                  ],
                ),
              ),
              const SizedBox(height: 110),
              Text(
                Strings.logo,
                style: GoogleFonts.poppins(
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Get.height * 0.12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  Strings.firstScreenSentences,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 26,
                    color: ColorRes.black.withOpacity(0.7),
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
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: ColorRes.containerColor,
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
                  color: ColorRes.black.withOpacity(0.6),
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
                  height: 55,
                  width: 327,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: ColorRes.containerColor),
                  ),
                  child: Text(
                    Strings.signIn,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: ColorRes.containerColor,
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
                    border: Border.all(color: Colors.orange, width: 3),
                    gradient: const LinearGradient(colors: [
                      Colors.orange,
                      Colors.deepOrange
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "🚨 DEMO MANAGER ACCESS 🚨",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
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
                          color: ColorRes.textColor,
                        ),
                      ),
                      TextSpan(
                        text: Strings.termsOfService,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.black,
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
