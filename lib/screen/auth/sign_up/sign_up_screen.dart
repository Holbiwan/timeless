import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/modern_loader.dart';
import 'package:timeless/common/widgets/unified_form_field.dart';
import 'package:timeless/common/widgets/unified_button.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';

import 'package:timeless/screen/auth/sign_up/sign_up_controller.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_screen.dart';
import 'package:timeless/screen/legal/terms_of_service_screen.dart';
import 'package:timeless/screen/legal/privacy_policy_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController ctrl = Get.put(SignUpController());
  final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

  bool isLoading = false;
  bool acceptTerms = false;

  // Brand colors
  final Color _primaryBlue = const Color(0xFF000647);
  final Color _accentOrange = const Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _primaryBlue,
      body: Stack(
        children: [
          // --- 1. Background Design ---
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  _primaryBlue,
                ],
              ),
            ),
          ),

          // Decorative Blue Circle (Bottom Left)
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1),
                    blurRadius: 50,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),

          // --- 2. Content ---
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Section (Logo & Title)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Header Text & Logo
                        Row(
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              child: const Image(image: AssetImage(AssetRes.logo)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Strings.createAccount,
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Join thousands of talented professionals",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Bottom Section (White Card Form)
                  Container(
                    width: size.width,
                    constraints: BoxConstraints(minHeight: size.height * 0.6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          
                          // First Name field
                          _buildLabel(translationService.getText('first_name')),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.firstNameCtrl,
                            hintText: 'Enter your first name',
                            labelText: translationService.getText('first_name'),
                            isRequired: true,
                            onChanged: ctrl.onChanged,
                            prefixIcon: Icons.person_outline,
                          ),

                          const SizedBox(height: 20),

                          // Last Name field
                          _buildLabel(translationService.getText('last_name')),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.lastNameCtrl,
                            hintText: 'Enter your last name',
                            labelText: translationService.getText('last_name'),
                            isRequired: true,
                            onChanged: ctrl.onChanged,
                            prefixIcon: Icons.person_outline,
                          ),

                          const SizedBox(height: 20),

                          // Email field
                          _buildLabel(translationService.getText('email')),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.emailCtrl,
                            hintText: 'Enter your email address',
                            labelText: translationService.getText('email'),
                            isRequired: true,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => ctrl.emailValidation(),
                            errorText: ctrl.emailError.isNotEmpty ? ctrl.emailError : null,
                            prefixIcon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 20),

                          // Password field
                          _buildLabel(translationService.getText('password')),
                          const SizedBox(height: 8),
                          GetBuilder<SignUpController>(
                            id: "showPassword",
                            builder: (_) => UnifiedFormField(
                              controller: ctrl.passwordCtrl,
                              hintText: 'Minimum 8 characters',
                              labelText: translationService.getText('password'),
                              isRequired: true,
                              obscureText: ctrl.showPassword,
                              onChanged: (_) => ctrl.passwordValidation(),
                              errorText: ctrl.pwdError.isNotEmpty ? ctrl.pwdError : null,
                              suffixIcon: IconButton(
                                onPressed: ctrl.togglePassword,
                                icon: Icon(
                                  ctrl.showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey[500],
                                ),
                              ),
                              prefixIcon: Icons.lock_outline,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Terms and conditions
                          InkWell(
                            onTap: () {
                              setState(() {
                                acceptTerms = !acceptTerms;
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: acceptTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        acceptTerms = value ?? false;
                                      });
                                    },
                                    activeColor: _primaryBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'I accept the ',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Terms of Service',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: _accentOrange,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(() => const TermsOfServiceScreen());
                                            },
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: _accentOrange,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(() => const PrivacyPolicyScreen());
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Sign up button
                          UnifiedButton(
                            text: Strings.signUp,
                            onPressed: isLoading ? null : () {
                              if (acceptTerms) {
                                ctrl.onSignUpTap();
                              } else {
                                AppTheme.showStandardSnackBar(
                                  title: "⚠️ Terms Required",
                                  message: "Please accept the terms of service",
                                  isError: true,
                                );
                              }
                            },
                            type: UnifiedButtonType.black,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 20),

                          // Or continue with divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Or continue with",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // GitHub Sign-up button
                          GetBuilder<SignUpController>(
                            builder: (_) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: UnifiedButton(
                                text: 'Sign up with GitHub',
                                onPressed: isLoading ? null : ctrl.signUpWithGitHub,
                                type: UnifiedButtonType.black,
                                isLoading: isLoading,
                                icon: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const FaIcon(
                                    FontAwesomeIcons.github,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.alreadyHaveAccount,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SigninScreenU()),
                                  ).then((_) {
                                    ctrl.emailCtrl.clear();
                                    ctrl.passwordCtrl.clear();
                                    ctrl.firstNameCtrl.clear();
                                    ctrl.lastNameCtrl.clear();
                                  });
                                },
                                child: Text(
                                  Strings.signIn,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _accentOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Full Screen Loader
          isLoading
              ? Container(
                  height: size.height,
                  width: size.width,
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CommonLoader()),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  // Helper widget to build labels for form fields
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _primaryBlue,
        ),
      ),
    );
  }
}
