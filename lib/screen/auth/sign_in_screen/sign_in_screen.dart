import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:timeless/common/widgets/back_button.dart'; // Keep original backButton for now if needed, but I'll use a custom one.
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/modern_loader.dart';
import 'package:timeless/common/widgets/common_text_field.dart';
import 'package:timeless/common/widgets/unified_form_field.dart';
import 'package:timeless/common/widgets/unified_button.dart';

import 'package:timeless/screen/auth/forgot_password/forgot_password_screen.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_controller.dart';
import 'package:timeless/screen/auth/sign_up/sign_up_screen.dart';

import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/services/auth_service.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/auth/profile_completion/profile_completion_screen.dart';
import 'package:timeless/utils/app_theme.dart';

class SigninScreenU extends StatefulWidget {
  const SigninScreenU({super.key});

  @override
  State<SigninScreenU> createState() => _SigninScreenUState();
}

class _SigninScreenUState extends State<SigninScreenU> {
  final SignInScreenController controller = Get.put(SignInScreenController());

  // Brand colors
  final Color _primaryBlue = const Color(0xFF000647);
  final Color _accentOrange = const Color(0xFFE67E22);

  @override
  void initState() {
    super.initState();
    controller.loading.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getRememberEmailDataUser();
    });
  }

  Future<void> _onSwitchGoogleAccount() async {
    await controller.signWithGoogle();
  }

  Future<void> _onGoogleSignInTap() async {
    await controller.signWithGoogle();
  }

  void _handleSignInError(dynamic e) {
    if (e is PlatformException) {
      final msg = e.message ?? '';
      if (e.code == 'sign_in_failed' && msg.contains('ApiException: 10')) {
        AppTheme.showStandardSnackBar(
          title: "Google Sign-In",
          message: "Invalid Android OAuth config (code 10).\n" 
          "➜ Add SHA-1/256 from your build to Firebase, " 
          "download new google-services.json, uninstall app, then restart.",
          isError: true,
        );
      } else {
        AppTheme.showStandardSnackBar(
          title: "Google Sign-In",
          message: msg.isEmpty ? e.toString() : msg,
          isError: true,
        );
      }
    } else {
      AppTheme.showStandardSnackBar(
        title: "Google Sign-In",
        message: e.toString(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = controller.loading.value;

    return Scaffold(
      backgroundColor: _primaryBlue, // Dark background base
      body: Stack(
        children: [
          // --- 1. Background Design ---
          // Gradient
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black, // Changed to start with Black
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
                        const SizedBox(height: 12),
                        
                        // Header Text & Logo
                        Row(
                          children: [
                            Container(
                              height: 120, // Increased size
                              width: 120,  // Increased size
                              // Removed decoration color, border radius, padding for logo
                              child: const Image(image: AssetImage(AssetRes.logo)),
                            ),
                            const SizedBox(width: 16),
                            Expanded( // Added Expanded to prevent overflow
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Strings.signInToYourAccount,
                                    style: GoogleFonts.inter(
                                      fontSize: 22, // Adjusted font size
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Your career journey starts here",
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
                  
                  const SizedBox(height: 14),

                  // Bottom Section (White Card Form)
                  Container(
                    width: size.width,
                    constraints: BoxConstraints(minHeight: size.height * 0.6), // Ensure it covers enough space
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
                          const SizedBox(height: 7), // Adjust spacing
                          
                          // Email field
                          GetBuilder<SignInScreenController>(
                            id: "showEmail",
                            builder: (_) => UnifiedFormField(
                              controller: controller.emailController,
                              hintText: 'Enter your email address',
                              labelText: Strings.email,
                              isRequired: true,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: controller.onChanged,
                              errorText: controller.emailError.isNotEmpty ? controller.emailError : null,
                              // focusNode: controller.emailFocusNode, // Assuming you have focus nodes in controller
                              prefixIcon: Icons.email_outlined, // Added prefixIcon
                            ),
                          ),

                          const SizedBox(height: 4), // Reduced from Get.height * 0.02

                          // Password field
                          GetBuilder<SignInScreenController>(
                            id: "showPassword",
                            builder: (_) => UnifiedFormField(
                              controller: controller.passwordController,
                              hintText: 'Enter your password',
                              labelText: Strings.password,
                              isRequired: true,
                              obscureText: controller.show,
                              onChanged: controller.onChanged,
                              errorText: controller.pwdError.isNotEmpty ? controller.pwdError : null,
                              suffixIcon: IconButton(
                                onPressed: isLoading ? null : controller.chang,
                                icon: Icon(
                                  controller.show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey[500],
                                ),
                              ),
                              // focusNode: controller.passwordFocusNode, // Assuming you have focus nodes in controller
                              prefixIcon: Icons.lock_outline, // Added prefixIcon
                            ),
                          ),

                          const SizedBox(height: 7),

                          // Remember me
                          GetBuilder<SignInScreenController>(
                            id: "remember_me",
                            builder: (_) => Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: controller.rememberMe,
                                    onChanged: controller.onRememberMeChange,
                                    activeColor: _primaryBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  Strings.rememberMe,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8), // Reduced from Get.height * 0.028

                          // Sign in button
                          UnifiedButton(
                            text: Strings.signIn,
                            onPressed: isLoading ? null : controller.onLoginBtnTap,
                            type: UnifiedButtonType.black,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 4), // Reduced from Get.height * 0.02

                          // Forgot password
                          Center(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                              ),
                              child: Text(
                                Strings.forgotThePassword,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _accentOrange,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8), // Reduced from Get.height * 0.03

                          // Or continue
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  Strings.orContinueWith,
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

                          const SizedBox(height: 8), // Reduced from Get.height * 0.028

                          // Social buttons
                          UnifiedButton(
                            text: 'Continue with Google',
                            onPressed: isLoading ? null : _onGoogleSignInTap,
                            type: UnifiedButtonType.darkPrimary, // Assuming secondary style is appropriate
                            isLoading: isLoading,
                            icon: Image.asset(
                              AssetRes.googleLogo,
                              height: 16,
                              width: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          UnifiedButton(
                            text: 'Use another Google account', // Changed text for clarity
                            onPressed: isLoading ? null : _onSwitchGoogleAccount,
                            type: UnifiedButtonType.tertiary, // Changed to tertiary
                            isLoading: isLoading,
                            icon: Icon(Icons.swap_horiz, size: 16, color: _primaryBlue),
                          ),

                          const SizedBox(height: 4), // Reduced from Get.height * 0.025

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: UnifiedButton(
                              text: 'Continue with GitHub',
                              onPressed: isLoading ? null : controller.signInWithGitHub,
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

                          const SizedBox(height: 8),

                          // Sign up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.donTHaveAccount,
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
                                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                  ).then((_) {
                                    controller.emailController.clear();
                                    controller.passwordController.clear();
                                  });
                                },
                                child: Text(
                                  Strings.signUp,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _accentOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
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

}