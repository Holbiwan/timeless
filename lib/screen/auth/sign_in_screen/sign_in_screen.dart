// lib/screen/auth/sign_in_screen/sign_in_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/common_text_field.dart';

import 'package:timeless/screen/auth/forgot_password_new/forgot_password_new_screen.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_controller.dart';
import 'package:timeless/screen/auth/sign_up/sign_up_screen.dart';

import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/services/google_auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    controller.loading.value = false;
    controller.getRememberEmailDataUser();
  }

  Future<void> _onSwitchGoogleAccount() async {
    try {
      controller.loading.value = true;
      
      AppTheme.showStandardSnackBar(
        title: "Changement de compte",
        message: "Sélectionnez votre compte Google",
      );
      
      final user = await GoogleAuthService.switchGoogleAccount();

      if (user == null) {
        AppTheme.showStandardSnackBar(
          title: "Google Sign-In",
          message: "Changement de compte annulé",
        );
        return;
      }

      await _handleSuccessfulSignIn(user);

    } catch (e) {
      _handleSignInError(e);
    } finally {
      controller.loading.value = false;
    }
  }

  Future<void> _onGoogleSignInTap() async {
    try {
      controller.loading.value = true;
      final user = await GoogleAuthService.signInWithGoogle();

      if (user == null) {
        AppTheme.showStandardSnackBar(
          title: "Google Sign-In",
          message: "Connexion annulée",
        );
        return;
      }

      await _handleSuccessfulSignIn(user);

    } catch (e) {
      _handleSignInError(e);
    } finally {
      controller.loading.value = false;
    }
  }

  Future<void> _handleSuccessfulSignIn(User user) async {
    // Sauvegarde dans Prefs
    PreferencesService.setValue(PrefKeys.userId, user.uid);
    PreferencesService.setValue(PrefKeys.email, user.email ?? "");
    PreferencesService.setValue(PrefKeys.fullName, user.displayName ?? "");
    PreferencesService.setValue(PrefKeys.rol, "User");

    // Sauvegarder les données utilisateur dans Firestore
    await GoogleAuthService.saveUserToFirestore(user);

    // ⭐ NAVIGATION INTELLIGENTE ⭐
    // Vérifier si c'est la première connexion ou un utilisateur existant
    final creationTime = user.metadata.creationTime;
    final isNewUser = creationTime != null && 
        creationTime.difference(DateTime.now()).inMinutes.abs() < 5;
    
    if (isNewUser) {
      // Nouvel utilisateur (créé il y a moins de 5 minutes)
      AppTheme.showStandardSnackBar(
        title: "Bienvenue !",
        message: "Compte créé avec succès. Complétez votre profil.",
        isSuccess: true,
      );
      // Aller vers l'écran de complétion de profil
      Get.offAll(() => const ProfileCompletionScreen());
    } else {
      // Utilisateur existant
      AppTheme.showStandardSnackBar(
        title: "Bon retour !",
        message: "Connexion réussie.",
        isSuccess: true,
      );
      Get.offAll(() => DashBoardScreen());
    }
  }

  void _handleSignInError(dynamic e) {
    if (e is PlatformException) {
      final msg = e.message ?? '';
      if (e.code == 'sign_in_failed' && msg.contains('ApiException: 10')) {
        AppTheme.showStandardSnackBar(
          title: "Google Sign-In",
          message: "Configuration OAuth Android invalide (code 10).\n"
          "➜ Ajoute le SHA-1/256 de ton build dans Firebase, "
          "télécharge le nouveau google-services.json, désinstalle l'app puis relance.",
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
    return Scaffold(
      backgroundColor: Colors.white,
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

                      // Logo agrandi
                      Center(
                        child: Container(
                          height: 180,
                          width: 180,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          Strings.signInToYourAccount,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
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
                                fontSize: 12,
                                color: ColorRes.textPrimary,
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
                                borderRadius: BorderRadius.circular(10),
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
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorRes.starColor, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorRes.starColor, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: ColorRes.textPrimary,
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: commonTextFormField(
                                onChanged: controller.onChanged,
                                controller: controller.passwordController,
                                obscureText: controller.show,
                                textDecoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 12),
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
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorRes.starColor, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorRes.starColor, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            if (controller.pwdError.isNotEmpty)
                              _errorPill(controller.pwdError),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Remember me
                      GetBuilder<SignInScreenController>(
                        id: "remember_me",
                        builder: (_) => InkWell(
                          onTap: () {
                            controller.rememberMe = !controller.rememberMe;
                            if (controller.rememberMe) {
                              PreferencesService.setValue(
                                PrefKeys.emailRememberUser,
                                controller.emailController.text,
                              );
                              PreferencesService.setValue(
                                PrefKeys.passwordRememberUser,
                                controller.passwordController.text,
                              );
                            } else {
                              PreferencesService.remove(PrefKeys.emailRememberUser);
                              PreferencesService.remove(PrefKeys.passwordRememberUser);
                            }
                            controller.update(["remember_me"]);
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                activeColor: const Color(0xFF000647),
                                checkColor: ColorRes.black,
                                side: const BorderSide(
                                  width: 1.2,
                                  color: Color(0xFF000647),
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
                                  fontSize: 11,
                                  color: ColorRes.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.028),

                      //  Sign in (email/password)
                      GetBuilder<SignInScreenController>(
                        id: "colorChange",
                        builder: (_) => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : controller.onLoginBtnTap,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF000647), width: 2),
                              foregroundColor: Colors.black,
                              textStyle: GoogleFonts.poppins(fontSize: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              Strings.signIn,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
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
                              fontSize: 12,
                              color: ColorRes.darkGold,
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
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: ColorRes.black,
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.028),

                      // ===== Social buttons =====
                      Column(
                        children: [
                          // Google - Connexion normale
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed:
                                  isLoading ? null : _onGoogleSignInTap,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF000647), width: 2),
                                foregroundColor: Colors.black,
                                textStyle: GoogleFonts.poppins(fontSize: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AssetRes.googleLogo,
                                    height: 16,
                                    width: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Continue with Google', style: GoogleFonts.poppins(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Google - Changer de compte
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: TextButton.icon(
                              onPressed: isLoading ? null : _onSwitchGoogleAccount,
                              icon: Icon(Icons.swap_horiz, size: 16, color: ColorRes.darkGold),
                              label: Text(
                                'Use an other Google account',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: ColorRes.darkGold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: ColorRes.darkGold.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // GitHub button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : controller.signInWithGitHub,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF000647), width: 2),
                                foregroundColor: Colors.black,
                                textStyle: GoogleFonts.poppins(fontSize: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.code,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Continue with GitHub', style: GoogleFonts.poppins(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Get.height * 0.025),

                      // ===== Sign up link =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Strings.donTHaveAccount,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
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
                                fontSize: 12,
                                color: ColorRes.darkGold,
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

