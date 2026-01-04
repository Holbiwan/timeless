import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_screen.dart';
import 'package:timeless/screen/auth/sign_up/sign_up_screen.dart';
import 'package:timeless/screen/auth/employer_signin/employer_signin_choice_screen.dart';
import 'package:timeless/screen/auth/employer_signin/employer_signin_screen.dart';
import 'package:timeless/screen/first_page/first_controller.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/widgets/simple_language_switch.dart';

class FirstScreen extends StatelessWidget {
  FirstScreen({super.key});

  final FirstScreenController controller = Get.put(FirstScreenController());
  final UnifiedTranslationService translationService =
      UnifiedTranslationService.instance;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      // ignorer avoid_print
      print('size: ${Get.width} x ${Get.height}');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black.withOpacity(0.9),
              const Color(0xFF000647).withOpacity(0.3),
              Colors.black,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Language selector at top left
              Container(
                width: Get.width,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16, top: 1), // Reverted padding
                child: SimpleLanguageSwitch(),
              ),

              const SizedBox(height: 20), // Reverted SizedBox height

              // Welcome message with gradient effect
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          const Color(0xFFFF8C00),
                          Colors.white,
                          const Color(0xFFFF8C00),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        "TIMELESS",
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFF8C00).withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          const Color(0xFFFF8C00),
                          Colors.white,
                          const Color(0xFFFF8C00),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        "Job App",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Because opportunities don't wait",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 0), // Keeping this tight

              Container(
                width: Get.width * 0.85,
                height: Get.height * 0.20, // Keeping this tighter
                alignment: Alignment.center,
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: 0.95,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: Get.width * 0.85,
                      height: Get.height * 0.18, // Keeping this tighter
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      gaplessPlayback: false,
                      isAntiAlias: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.01),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (con) => const SigninScreenU(),
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
                      border: Border.all(
                          color: const Color(0xFF000647), width: 2.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: const Color(0xFF000647),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr("candidateconnexion"),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: Get.height * 0.01),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (con) => const SignUpScreen(),
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
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFF000647), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          color: const Color(0xFF000647),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr("create_candidate_account"),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: Get.height * 0.01),

              // 💼 BOUTON SIGN IN AS PRO
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (con) => const EmployerSignInChoiceScreen(),
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
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFF000647), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_center_outlined,
                          color: const Color(0xFF000647),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            context.tr("employerconnexion"),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000647),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF000647).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: Get.height * 0.01),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployerSignInScreen(),
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
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFF000647), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_business_outlined,
                          color: const Color(0xFF000647),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            context.tr('create_employer_account'),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000647),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF000647).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 10),

              // Section des réseaux sociaux
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          const Color(0xFFFF8C00),
                          Colors.white,
                          const Color(0xFFFF8C00),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        "Connect with us",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(
                          'https://linkedin.com/in/sabrina-papeau',
                          FontAwesomeIcons.linkedin,
                          const Color(0xFF0077B5), // LinkedIn blue
                        ),
                        const SizedBox(width: 15),
                        _buildSocialIcon(
                          'https://x.com/Holbiwan_Place',
                          FontAwesomeIcons.xTwitter,
                          Colors.white, // Changed to white for visibility on dark background
                        ),
                        const SizedBox(width: 15),
                        _buildSocialIcon(
                          'https://www.instagram.com/timelessflowapp/',
                          FontAwesomeIcons.instagram,
                          const Color(0xFFE1306C), // Instagram pink
                        ),
                        const SizedBox(width: 15),
                        _buildSocialIcon(
                          'https://facebook.com/TimelessFlowApp',
                          FontAwesomeIcons.facebook,
                          const Color(0xFF1877F2), // Facebook blue
                        ),
                        const SizedBox(width: 15),
                        _buildSocialIcon(
                          'https://www.youtube.com/@BriaDev_Paris',
                          FontAwesomeIcons.youtube,
                          const Color(0xFFFF0000), // YouTube red
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String url, IconData icon, Color color) {
    return InkWell(
      onTap: () async {
        try {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Erreur lors de l\'ouverture du lien: $e');
          }
        }
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color, // Keep original brand color
          size: 16,
        ),
      ),
    );
  }
}
