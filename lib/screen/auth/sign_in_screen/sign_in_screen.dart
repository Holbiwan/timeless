// lib/screen/auth/sign_in_screen/sign_in_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/common_text_field.dart';

import 'package:timeless/screen/auth/forgot_password_new/forgot_password_new_screen.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_controller.dart';
import 'package:timeless/screen/auth/sign_up/sign_up_screen.dart';

import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/service/google_auth_service.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';

class SigninScreenU extends StatefulWidget {
  const SigninScreenU({super.key});

  @override
  State<SigninScreenU> createState() => _SigninScreenUState();
}

class _SigninScreenUState extends State<SigninScreenU> {
  final SignInScreenController controller = Get.put(SignInScreenController());

  @override
  void initState() {
    super.initState();
    controller.loading.value = false;
    controller.getRememberEmailDataUser();
  }

  Future<void> _onGoogleSignInTap() async {
    try {
      controller.loading.value = true;
      final cred = await GoogleAuthService.signInWithGoogle();
      final user = cred?.user;

      if (user == null) {
        Get.snackbar("Google Sign-In", "Cancelled",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Sauvegarde dans Prefs
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, user.email ?? "");
      PrefService.setValue(PrefKeys.fullName, user.displayName ?? "");
      PrefService.setValue(PrefKeys.rol, "User");

      // Navigation vers le Dashboard
      Get.offAll(() => DashBoardScreen());
    } catch (e) {
      Get.snackbar("Google Sign-In", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      controller.loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Obx(() {
            final isLoading = controller.loading.value;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      backButton(),
                      const SizedBox(height: 16),

                      // Logo
                      Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorRes.logoColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Image(image: AssetImage(AssetRes.logo)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          Strings.signInToYourAccount,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ColorRes.black,
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.04),

                      // ===== Email =====
                      Padding(
                        padding: EdgeInsets.only(
                            left: 4, bottom: Get.height * 0.008),
                        child: Row(
                          children: [
                            Text(
                              Strings.email,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: ColorRes.black.withOpacity(0.6),
                              ),
                            ),
                            const Text(' *',
                                style: TextStyle(
                                    fontSize: 15, color: ColorRes.starColor)),
                          ],
                        ),
                      ),
                      GetBuilder<SignInScreenController>(
                        id: "showEmail",
                        builder: (_) => Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 0),
                                    color: ColorRes.containerColor
                                        .withOpacity(0.15),
                                    spreadRadius: -8,
                                    blurRadius: 20,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: commonTextFormField(
                                onChanged: controller.onChanged,
                                controller: controller.emailController,
                                textDecoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 12),
                                  hintText: 'Email',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: ColorRes.black.withOpacity(0.15),
                                  ),
                                  border: _inputBorderFor(
                                      controller.emailController.text,
                                      controller.emailError),
                                  focusedBorder: _inputBorderFor(
                                      controller.emailController.text,
                                      controller.emailError),
                                  enabledBorder: _inputBorderFor(
                                      controller.emailController.text,
                                      controller.emailError),
                                  disabledBorder: _inputBorderFor(
                                      controller.emailController.text,
                                      controller.emailError),
                                  errorBorder: _inputBorderFor(
                                      controller.emailController.text,
                                      controller.emailError),
                                  focusedErrorBorder: _inputBorderFor(
                                      controller.emailController.text,
                                      controller.emailError),
                                ),
                              ),
                            ),
                            if (controller.emailError.isNotEmpty)
                              _errorPill(controller.emailError),
                          ],
                        ),
                      ),

                      SizedBox(height: Get.height * 0.02),

                      // ===== Password =====
                      Padding(
                        padding: EdgeInsets.only(
                            left: 4, bottom: Get.height * 0.008),
                        child: Row(
                          children: [
                            Text(
                              Strings.password,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorRes.black.withOpacity(0.6),
                              ),
                            ),
                            const Text(' *',
                                style: TextStyle(
                                    fontSize: 15, color: ColorRes.starColor)),
                          ],
                        ),
                      ),
                      GetBuilder<SignInScreenController>(
                        id: "showPassword",
                        builder: (_) => Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 0),
                                    color: ColorRes.containerColor
                                        .withOpacity(0.15),
                                    spreadRadius: -8,
                                    blurRadius: 20,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: commonTextFormField(
                                onChanged: controller.onChanged,
                                controller: controller.passwordController,
                                obscureText: controller.show,
                                textDecoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 12),
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  suffixIcon: IconButton(
                                    onPressed: isLoading
                                        ? null
                                        : controller.chang,
                                    icon: Icon(
                                      controller.show
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: ColorRes.black.withOpacity(0.25),
                                    ),
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: ColorRes.black.withOpacity(0.15),
                                  ),
                                  border: _inputBorderFor(
                                      controller.passwordController.text,
                                      controller.pwdError),
                                  focusedBorder: _inputBorderFor(
                                      controller.passwordController.text,
                                      controller.pwdError),
                                  enabledBorder: _inputBorderFor(
                                      controller.passwordController.text,
                                      controller.pwdError),
                                  disabledBorder: _inputBorderFor(
                                      controller.passwordController.text,
                                      controller.pwdError),
                                  errorBorder: _inputBorderFor(
                                      controller.passwordController.text,
                                      controller.pwdError),
                                  focusedErrorBorder: _inputBorderFor(
                                      controller.passwordController.text,
                                      controller.pwdError),
                                ),
                              ),
                            ),
                            if (controller.pwdError.isNotEmpty)
                              _errorPill(controller.pwdError),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ===== Remember me =====
                      GetBuilder<SignInScreenController>(
                        id: "remember_me",
                        builder: (_) => InkWell(
                          onTap: () {
                            controller.rememberMe = !controller.rememberMe;
                            if (controller.rememberMe) {
                              PrefService.setValue(
                                PrefKeys.emailRememberUser,
                                controller.emailController.text,
                              );
                              PrefService.setValue(
                                PrefKeys.passwordRememberUser,
                                controller.passwordController.text,
                              );
                            } else {
                              PrefService.remove(PrefKeys.emailRememberUser);
                              PrefService.remove(PrefKeys.passwordRememberUser);
                            }
                            controller.update(["remember_me"]);
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                activeColor: ColorRes.containerColor,
                                checkColor: ColorRes.white,
                                side: const BorderSide(
                                  width: 1.2,
                                  color: ColorRes.containerColor,
                                ),
                                value: controller.rememberMe,
                                onChanged: controller.onRememberMeChange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Text(
                                Strings.rememberMe,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: ColorRes.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.028),

                      // ===== Sign in (email/password) =====
                      GetBuilder<SignInScreenController>(
                        id: "colorChange",
                        builder: (_) => InkWell(
                          onTap:
                              isLoading ? null : controller.onLoginBtnTap,
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [
                                  ColorRes.gradientColor,
                                  ColorRes.containerColor,
                                ],
                              ),
                            ),
                            child: Text(
                              Strings.signIn,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: ColorRes.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.02),

                      // ===== Forgot password =====
                      Center(
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreenU()),
                          ),
                          child: Text(
                            Strings.forgotThePassword,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: ColorRes.containerColor,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.03),

                      // ===== Or continue =====
                      Center(
                        child: Text(
                          Strings.orContinueWith,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: ColorRes.black,
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.028),

                      // ===== Social buttons =====
                      Column(
                        children: [
                          // Google
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed:
                                  isLoading ? null : _onGoogleSignInTap,
                              icon: const Icon(Icons.login),
                              label:
                                  const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(width: 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // GitHub (optionnel, non modifié)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : controller.signInWithGitHub,
                              icon: const Icon(Icons.code),
                              label:
                                  const Text('Continue with GitHub'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Get.height * 0.03),

                      // ===== Sign up link =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Strings.donTHaveAccount,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: ColorRes.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SignUpScreen()),
                              ).then((_) {
                                controller.emailController.clear();
                                controller.passwordController.clear();
                              });
                            },
                            child: Text(
                              Strings.signUp,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: ColorRes.containerColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Loader
                isLoading ? const CommonLoader() : const SizedBox(),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Helpers
  InputBorder _inputBorderFor(String text, String error) {
    if (text.trim().isEmpty) return InputBorder.none;
    return error.isNotEmpty ? _errorBorder() : _enableBorder();
  }

  OutlineInputBorder _enableBorder() => OutlineInputBorder(
        borderSide: const BorderSide(color: ColorRes.containerColor),
        borderRadius: BorderRadius.circular(12),
      );

  OutlineInputBorder _errorBorder() => OutlineInputBorder(
        borderSide: const BorderSide(color: ColorRes.starColor),
        borderRadius: BorderRadius.circular(12),
      );

  Widget _errorPill(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: ColorRes.invalidColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Image(image: AssetImage(AssetRes.invalid), height: 14),
          const SizedBox(width: 10),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 9,
              color: ColorRes.starColor,
            ),
          ),
        ],
      ),
    );
  }
}

extension on User? {
   get user => null;
}
