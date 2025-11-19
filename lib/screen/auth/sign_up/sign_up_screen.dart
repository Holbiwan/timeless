// lib/screen/auth/sign_up/sign_up_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/common_text_field.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

import 'package:timeless/screen/auth/sign_up/sign_up_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController ctrl = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.white,
      appBar: AppBar(
        title: Text('Create account', style: GoogleFonts.poppins()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Obx(() {
          final isLoading = ctrl.loading.value;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo agrandi
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorRes.logoColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Image(image: AssetImage(AssetRes.logo)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Create your account',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ===== First name =====
                    _label('First name'),
                    GetBuilder<SignUpController>(
                      id: "showFirst",
                      builder: (_) => _box(
                        child: commonTextFormField(
                          controller: ctrl.firstNameCtrl,
                          onChanged: ctrl.onChanged,
                          textDecoration: _decoration(hint: 'First name'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ===== Last name =====
                    _label('Last name'),
                    GetBuilder<SignUpController>(
                      id: "showLast",
                      builder: (_) => _box(
                        child: commonTextFormField(
                          controller: ctrl.lastNameCtrl,
                          onChanged: ctrl.onChanged,
                          textDecoration: _decoration(hint: 'Last name'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ===== Email =====
                    _label('${Strings.email} *'),
                    GetBuilder<SignUpController>(
                      id: "showEmail",
                      builder: (_) => Column(
                        children: [
                          _box(
                            child: commonTextFormField(
                              controller: ctrl.emailCtrl,
                              onChanged: (_) => ctrl.emailValidation(),
                              textDecoration: _decoration(
                                hint: 'Email',
                                suffix: IconButton(
                                  tooltip: 'Copy email',
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: ctrl.emailCtrl.text),
                                    );
                                    Get.snackbar(
                                        'Copied', 'Email copied to clipboard',
                                        snackPosition: SnackPosition.BOTTOM);
                                  },
                                  icon: Icon(Icons.copy,
                                      color: Colors.black.withOpacity(0.25)),
                                ),
                              ),
                            ),
                          ),
                          if (ctrl.emailError.isNotEmpty)
                            _errorPill(ctrl.emailError),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ===== Password =====
                    _label('${Strings.password} *'),
                    GetBuilder<SignUpController>(
                      id: "showPassword",
                      builder: (_) => Column(
                        children: [
                          _box(
                            child: commonTextFormField(
                              controller: ctrl.passwordCtrl,
                              obscureText: ctrl.showPassword,
                              onChanged: (_) => ctrl.passwordValidation(),
                              textDecoration: _decoration(
                                hint: 'Password (min 8 chars)',
                                suffix: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Copy password',
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                              text: ctrl.passwordCtrl.text),
                                        );
                                        Get.snackbar('Copied',
                                            'Password copied to clipboard',
                                            snackPosition:
                                                SnackPosition.BOTTOM);
                                      },
                                      icon: Icon(Icons.copy,
                                          color:
                                              Colors.black.withOpacity(0.25)),
                                    ),
                                    IconButton(
                                      tooltip:
                                          ctrl.showPassword ? 'Show' : 'Hide',
                                      onPressed: isLoading
                                          ? null
                                          : ctrl.togglePassword,
                                      icon: Icon(
                                        ctrl.showPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.black.withOpacity(0.25),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (ctrl.pwdError.isNotEmpty)
                            _errorPill(ctrl.pwdError),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== Create account button =====
                    GetBuilder<SignUpController>(
                      id: "colorChange",
                      builder: (_) => InkWell(
                        onTap: isLoading ? null : ctrl.onSignUpTap,
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                ColorRes.orange,
                                ColorRes.brightYellow
                              ],
                            ),
                          ),
                          child: Text(
                            'Create account',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ColorRes.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Terms and conditions
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        children: [
                          const TextSpan(text: 'By creating an account, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: GoogleFonts.poppins(
                              color: ColorRes.darkGold,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final uri = Uri.parse('https://www.termsfeed.com/live/588c37bc-3594-490a-be8b-d9409af52df7');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Could not open Terms of Service',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.poppins(
                              color: ColorRes.darkGold,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final uri = Uri.parse('https://www.privacypolicygenerator.info/live.php?token=VQQZx8YfJz2gQh7y3jKb9Rm6XsEr4vNJ');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Could not open Privacy Policy',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Loader
              isLoading ? const CommonLoader() : const SizedBox(),
            ],
          );
        }),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      );

  BoxDecoration _shadowBox() => BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            color: const Color(0xFF8C8C8C).withOpacity(0.15),
            spreadRadius: -8,
            blurRadius: 20,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      );

  Widget _box({required Widget child}) => Container(
        decoration: _shadowBox(),
        child: child,
      );

  InputDecoration _decoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      hintText: hint,
      filled: true,
      fillColor: Colors.transparent,
      suffixIcon: suffix,
      hintStyle: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black.withOpacity(0.15),
      ),
      border: _enableBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorRes.brightYellow, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: _enableBorder(),
      disabledBorder: _enableBorder(),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _errorBorder(),
    );
  }

  OutlineInputBorder _enableBorder() => OutlineInputBorder(
        borderSide: const BorderSide(color: ColorRes.orange),
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
        color: const Color(0xFFFFE6E6), // ColorRes.invalidColor si dispo
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: Color(0xFFDA1414)),
          const SizedBox(width: 10),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 9,
              color: const Color(0xFFDA1414),
            ),
          ),
        ],
      ),
    );
  }
}
