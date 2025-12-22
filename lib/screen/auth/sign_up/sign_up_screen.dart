import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';

import 'package:timeless/screen/auth/sign_up/sign_up_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController ctrl = Get.put(SignUpController());
  final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: accessibilityService.textColor,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF000647), width: 1.0),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
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
                    // Logo avec accessibilité - agrandi et statique
                    accessibilityService.buildAccessibleWidget(
                      semanticLabel: 'Timeless app logo',
                      child: Center(
                        child: Container(
                          height: 240,
                          width: Get.width * 0.9,
                          alignment: Alignment.center,
                          child: RepaintBoundary(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: Get.width * 0.85,
                              height: 220,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              gaplessPlayback: false,
                              isAntiAlias: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        translationService.getText('create_account'),
                        style: accessibilityService.getAccessibleTextStyle(
                          fontSize: AppTheme.fontSizeXLarge,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // First name field
                    _buildLabel(translationService.getText('first_name')),
                    GetBuilder<SignUpController>(
                      id: "showFirst",
                      builder: (_) => _buildInputField(
                        child: TextFormField(
                          controller: ctrl.firstNameCtrl,
                          onChanged: ctrl.onChanged,
                          decoration: AppTheme.getInputDecoration(
                            hint: translationService.getText('first_name'),
                          ),
                          style: accessibilityService.getAccessibleTextStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Last name field
                    _buildLabel(translationService.getText('last_name')),
                    GetBuilder<SignUpController>(
                      id: "showLast",
                      builder: (_) => _buildInputField(
                        child: TextFormField(
                          controller: ctrl.lastNameCtrl,
                          onChanged: ctrl.onChanged,
                          decoration: AppTheme.getInputDecoration(
                            hint: translationService.getText('last_name'),
                          ),
                          style: accessibilityService.getAccessibleTextStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email field
                    _buildLabel('${translationService.getText('email')} *'),
                    GetBuilder<SignUpController>(
                      id: "showEmail",
                      builder: (_) => Column(
                        children: [
                          _buildInputField(
                            child: TextFormField(
                              controller: ctrl.emailCtrl,
                              onChanged: (_) => ctrl.emailValidation(),
                              keyboardType: TextInputType.emailAddress,
                              decoration: AppTheme.getInputDecoration(
                                hint: translationService.getText('email'),
                                suffixIcon: IconButton(
                                  tooltip: 'Copy email',
                                  onPressed: () async {
                                    accessibilityService.triggerHapticFeedback();
                                    await Clipboard.setData(
                                      ClipboardData(text: ctrl.emailCtrl.text),
                                    );
                                    Get.snackbar(
                                      'Copied', 
                                      'Email copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: accessibilityService.primaryColor,
                                      colorText: AppTheme.white,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.copy,
                                    color: accessibilityService.secondaryTextColor,
                                  ),
                                ),
                              ),
                              style: accessibilityService.getAccessibleTextStyle(),
                            ),
                          ),
                          if (ctrl.emailError.isNotEmpty)
                            AppTheme.errorMessage(ctrl.emailError),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Password field
                    _buildLabel('${translationService.getText('password')} *'),
                    GetBuilder<SignUpController>(
                      id: "showPassword",
                      builder: (_) => Column(
                        children: [
                          _buildInputField(
                            child: TextFormField(
                              controller: ctrl.passwordCtrl,
                              obscureText: ctrl.showPassword,
                              onChanged: (_) => ctrl.passwordValidation(),
                              decoration: AppTheme.getInputDecoration(
                                hint: translationService.getText('password_hint'),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Copy password',
                                      onPressed: () async {
                                        accessibilityService.triggerHapticFeedback();
                                        await Clipboard.setData(
                                          ClipboardData(
                                              text: ctrl.passwordCtrl.text),
                                        );
                                        Get.snackbar('Copied',
                                            'Password copied to clipboard',
                                            snackPosition:
                                                SnackPosition.BOTTOM,
                                            backgroundColor: accessibilityService.primaryColor,
                                            colorText: AppTheme.white);
                                      },
                                      icon: Icon(
                                        Icons.copy,
                                        color: accessibilityService.secondaryTextColor,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: ctrl.showPassword ? 'Show' : 'Hide',
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              accessibilityService.triggerHapticFeedback();
                                              ctrl.togglePassword();
                                            },
                                      icon: Icon(
                                        ctrl.showPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: accessibilityService.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              style: accessibilityService.getAccessibleTextStyle(),
                            ),
                          ),
                          if (ctrl.pwdError.isNotEmpty)
                            AppTheme.errorMessage(ctrl.pwdError),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Go button
                    GetBuilder<SignUpController>(
                      id: "colorChange",
                      builder: (_) => accessibilityService.buildAccessibleWidget(
                        semanticLabel: 'Go',
                        onTap: isLoading ? null : () {
                          accessibilityService.triggerHapticFeedback();
                          ctrl.onSignUpTap();
                        },
                        child: SizedBox(
                          width: 80,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF000647), width: 1.0),
                            ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : ctrl.onSignUpTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000647)),
                                    ),
                                  )
                                : const Text(
                                    'Go',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Terms and conditions
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: accessibilityService.getAccessibleTextStyle(
                          fontSize: AppTheme.fontSizeSmall,
                          color: accessibilityService.secondaryTextColor,
                        ),
                        children: [
                          TextSpan(text: '${translationService.getText('terms_agreement')} '),
                          TextSpan(
                            text: translationService.getText('terms_of_service'),
                            style: accessibilityService.getAccessibleTextStyle(
                              fontSize: AppTheme.fontSizeSmall,
                              color: accessibilityService.primaryColor,
                              fontWeight: FontWeight.w600,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                accessibilityService.triggerHapticFeedback();
                                final uri = Uri.parse('https://www.timeless-app.com/terms');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  Get.snackbar(
                                    translationService.getText('error'),
                                    'Could not open Terms of Service',
                                    backgroundColor: accessibilityService.errorColor,
                                    colorText: AppTheme.white,
                                  );
                                }
                              },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: accessibilityService.getAccessibleTextStyle(
                              fontSize: AppTheme.fontSizeSmall,
                              color: accessibilityService.primaryColor,
                              fontWeight: FontWeight.w600,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                accessibilityService.triggerHapticFeedback();
                                final uri = Uri.parse('https://www.privacypolicygenerator.info/live.php?token=VQQZx8YfJz2gQh7y3jKb9Rm6XsEr4vNJ');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  Get.snackbar(
                                    translationService.getText('error'),
                                    'Could not open Privacy Policy',
                                    backgroundColor: accessibilityService.errorColor,
                                    colorText: AppTheme.white,
                                  );
                                }
                              },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Loader
              isLoading ? const CommonLoader() : const SizedBox(),
            ],
          );
        }),
      ),
    ));
  }

  // ---------- SECTION: UI HELPERS ----------
  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(
          text,
          style: accessibilityService.getAccessibleTextStyle(
            fontSize: AppTheme.fontSizeRegular,
            fontWeight: FontWeight.w500,
            color: accessibilityService.secondaryTextColor,
          ),
        ),
      );

  Widget _buildInputField({required Widget child}) => Container(
        decoration: AppTheme.containerDecoration.copyWith(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF000647),
            width: 1.0,
          ),
        ),
        child: child,
      );
}
