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
import 'package:timeless/screen/dashboard/home/tipsforyou_screen.dart';
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

class GuestJobBrowser extends StatelessWidget {
  const GuestJobBrowser({super.key});

  @override
  Widget build(BuildContext context) {
    final UnifiedTranslationService translationService = UnifiedTranslationService.instance;

    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
              translationService.getText('continue_as_guest'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            )),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Logo sans encadrement
            SizedBox(
              width: 300,
              height: 200,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            // Tips for You button
            _buildActionButton(
              context: context,
              title: translationService.getText('tips_for_you'),
              subtitle: translationService.getText('tips_for_you_subtitle'),
              icon: Icons.lightbulb_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TipsForYouScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // See Job Offers button
            _buildActionButton(
              context: context,
              title: translationService.getText('see_job_offers'),
              subtitle: translationService.getText('see_job_offers_subtitle'),
              icon: Icons.work_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuestJobListScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            // Sign up CTA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF000647),
                    const Color(0xFF000647),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Obx(() => Text(
                        translationService.getText('ready_to_apply'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        translationService
                            .getText('ready_to_apply_description'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      )),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF000647),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Obx(() => Text(
                                translationService
                                    .getText('create_account_cta'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              )),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SigninScreenU(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Obx(() => Text(
                                translationService.getText('sign_in_cta'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF000647), width: 2.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF000647).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF000647),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class GuestJobListScreen extends StatelessWidget {
  const GuestJobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UnifiedTranslationService translationService = UnifiedTranslationService.instance;

    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
              translationService.getText('job_offers_title'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            )),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _sampleJobs.length,
        itemBuilder: (context, index) {
          final job = _sampleJobs[index];
          return _buildJobCard(
              context, job, index.toString(), translationService);
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job,
      String docId, UnifiedTranslationService translationService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF000647), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF000647).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.work,
                  color: const Color(0xFF000647),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['Position'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      job['companyName'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            job['requirement'] ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              if (job['salary'] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job['salary'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (job['location'] != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job['location'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              InkWell(
                onTap: () =>
                    _showAuthenticationDialog(context, translationService),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFF000647), width: 2.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    translationService.getText('apply'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAuthenticationDialog(
      BuildContext context, UnifiedTranslationService translationService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.login,
                color: const Color(0xFF000647),
              ),
              const SizedBox(width: 10),
              Obx(() => Text(
                    translationService.getText('login_required'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  )),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Text(
                    translationService.getText('login_required_message'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  )),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SigninScreenU(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF000647),
                        side: const BorderSide(color: Color(0xFF000647)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Obx(() => Text(
                            translationService.getText('sign_in'),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000647),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Obx(() => Text(
                            translationService.getText('sign_up'),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static final List<Map<String, dynamic>> _sampleJobs = [
    {
      'Position': 'Flutter Developer',
      'companyName': 'TechCorp',
      'requirement':
          'Develop cross-platform mobile applications with Flutter. 2+ years of experience required.',
      'salary': '45 000€ - 55 000€',
      'location': 'Paris',
    },
    {
      'Position': 'UI/UX Designer',
      'companyName': 'DesignStudio',
      'requirement':
          'Create modern and intuitive user interfaces. Portfolio required.',
      'salary': '40 000€ - 50 000€',
      'location': 'Lyon',
    },
    {
      'Position': 'Data Scientist',
      'companyName': 'DataFlow',
      'requirement':
          'Analyze complex data and create predictive models. Python/R required.',
      'salary': '50 000€ - 65 000€',
      'location': 'Remote',
    },
    {
      'Position': 'Product Manager',
      'companyName': 'StartupXYZ',
      'requirement':
          'Manage the life cycle of digital products. 3+ years of experience.',
      'salary': '55 000€ - 70 000€',
      'location': 'Marseille',
    },
    {
      'Position': 'DevOps Engineer',
      'companyName': 'CloudTech',
      'requirement':
          'Automate deployments and manage cloud infrastructure. AWS/Azure.',
      'salary': '48 000€ - 62 000€',
      'location': 'Toulouse',
    },
  ];
}
