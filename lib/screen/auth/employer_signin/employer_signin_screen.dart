// lib/screen/auth/employer_signin/employer_signup_screen_new.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';

import 'package:timeless/screen/auth/employer_signin/employer_signin_controller.dart';

class EmployerSignInScreen extends StatefulWidget {
  const EmployerSignInScreen({super.key});

  @override
  State<EmployerSignInScreen> createState() => _EmployerSignInScreenState();
}

class _EmployerSignInScreenState extends State<EmployerSignInScreen> {
  final EmployerSignInController ctrl = Get.put(EmployerSignInController());
  final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

  bool isLoading = false;
  bool acceptTerms = false;

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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo avec accessibilité
                  accessibilityService.buildAccessibleWidget(
                    semanticLabel: 'Timeless app logo',
                    child: Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accessibilityService.isHighContrastMode.value 
                              ? AppTheme.secondaryGold 
                              : AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          boxShadow: AppTheme.shadowRegular,
                        ),
                        child: const Image(image: AssetImage(AssetRes.logo)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      'Create PRO Account',
                      style: accessibilityService.getAccessibleTextStyle(
                        fontSize: AppTheme.fontSizeXLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),


                  // --- SECTION: 


                  // Nom de la société --- SECTION: 



                  _buildLabel('Company Name *'),
                  _buildInputField(
                    child: TextFormField(
                      controller: ctrl.companyNameController,
                      decoration: AppTheme.getInputDecoration(
                        hint: 'Ex: ACME Corp',
                      ),
                      style: accessibilityService.getAccessibleTextStyle(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- SECTION: 


                  // Adresse --- SECTION: 



                  _buildLabel('Complete Address *'),
                  _buildInputField(
                    child: TextFormField(
                      controller: ctrl.addressController,
                      decoration: AppTheme.getInputDecoration(
                        hint: 'Ex: 15 Rue de la Paix',
                      ),
                      style: accessibilityService.getAccessibleTextStyle(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- SECTION: 


                  // Code postal --- SECTION: 



                  _buildLabel('Postal Code *'),
                  _buildInputField(
                    child: TextFormField(
                      controller: ctrl.postalCodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      decoration: AppTheme.getInputDecoration(
                        hint: 'Ex: 75001',
                      ),
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      style: accessibilityService.getAccessibleTextStyle(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- SECTION: 


                  // Pays --- SECTION: 



                  _buildLabel('Country *'),
                  _buildInputField(
                    child: TextFormField(
                      controller: ctrl.countryController,
                      decoration: AppTheme.getInputDecoration(
                        hint: 'France',
                      ),
                      style: accessibilityService.getAccessibleTextStyle(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- SECTION: 


                  // Code SIRET --- SECTION: 



                  _buildLabel('SIRET Code *'),
                  _buildInputField(
                    child: TextFormField(
                      controller: ctrl.siretController,
                      keyboardType: TextInputType.number,
                      maxLength: 14,
                      decoration: AppTheme.getInputDecoration(
                        hint: '14 digits',
                        suffixIcon: IconButton(
                          tooltip: 'Copy SIRET',
                          onPressed: () async {
                            accessibilityService.triggerHapticFeedback();
                            await Clipboard.setData(
                              ClipboardData(text: ctrl.siretController.text),
                            );
                            Get.snackbar(
                              'Copied', 
                              'SIRET copied to clipboard',
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
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      style: accessibilityService.getAccessibleTextStyle(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- SECTION: 


                  // Code APE --- SECTION: 



                  _buildLabel('APE Code *'),
                  _buildInputField(
                    child: TextFormField(
                      controller: ctrl.apeController,
                      decoration: AppTheme.getInputDecoration(
                        hint: 'Ex: 6201Z',
                        suffixIcon: IconButton(
                          tooltip: 'Copy APE',
                          onPressed: () async {
                            accessibilityService.triggerHapticFeedback();
                            await Clipboard.setData(
                              ClipboardData(text: ctrl.apeController.text),
                            );
                            Get.snackbar(
                              'Copied', 
                              'APE code copied to clipboard',
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
                  const SizedBox(height: 12),

                  // --- SECTION: 


                  // Email --- SECTION: 



                  _buildLabel('Business Email *'),
                  _buildInputField(
                    child: TextFormField(
                      controller: ctrl.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: AppTheme.getInputDecoration(
                        hint: 'contact@your-company.com',
                        suffixIcon: IconButton(
                          tooltip: 'Copy email',
                          onPressed: () async {
                            accessibilityService.triggerHapticFeedback();
                            await Clipboard.setData(
                              ClipboardData(text: ctrl.emailController.text),
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

                  const SizedBox(height: 12),

                  // --- SECTION: PASSWORD ---


                  // Password --- SECTION: 



                  _buildLabel('Password *'),
                  Obx(() => _buildInputField(
                    child: TextFormField(
                      controller: ctrl.passwordController,
                      obscureText: ctrl.isPasswordHidden.value,
                      decoration: AppTheme.getInputDecoration(
                        hint: 'Minimum 8 characters',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Copy password',
                              onPressed: () async {
                                accessibilityService.triggerHapticFeedback();
                                await Clipboard.setData(
                                  ClipboardData(text: ctrl.passwordController.text),
                                );
                                Get.snackbar(
                                  'Copied', 
                                  'Password copied to clipboard',
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
                            IconButton(
                              tooltip: ctrl.isPasswordHidden.value 
                                  ? 'Show password' 
                                  : 'Hide password',
                              onPressed: () {
                                accessibilityService.triggerHapticFeedback();
                                ctrl.togglePasswordVisibility();
                              },
                              icon: Icon(
                                ctrl.isPasswordHidden.value 
                                    ? Icons.visibility 
                                    : Icons.visibility_off,
                                color: accessibilityService.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      style: accessibilityService.getAccessibleTextStyle(),
                    ),
                  )),

                  const SizedBox(height: 12),

                  // --- SECTION: 


                  // Confirmation Password --- SECTION: 



                  _buildLabel('Confirm Password *'),
                  Obx(() => _buildInputField(
                    child: TextFormField(
                      controller: ctrl.confirmPasswordController,
                      obscureText: ctrl.isConfirmPasswordHidden.value,
                      decoration: AppTheme.getInputDecoration(
                        hint: 'Confirm your password',
                        suffixIcon: IconButton(
                          tooltip: ctrl.isConfirmPasswordHidden.value 
                              ? 'Show password' 
                              : 'Hide password',
                          onPressed: () {
                            accessibilityService.triggerHapticFeedback();
                            ctrl.toggleConfirmPasswordVisibility();
                          },
                          icon: Icon(
                            ctrl.isConfirmPasswordHidden.value 
                                ? Icons.visibility 
                                : Icons.visibility_off,
                            color: accessibilityService.secondaryTextColor,
                          ),
                        ),
                      ),
                      style: accessibilityService.getAccessibleTextStyle(),
                    ),
                  )),

                  const SizedBox(height: 20),

                  // Bouton de création de compte
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _createEmployerAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000647),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Create My PRO Account',
                          style: accessibilityService.getAccessibleTextStyle(
                            fontSize: AppTheme.fontSizeRegular,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Remember me checkbox
                  GetBuilder<EmployerSignInController>(
                    id: "remember_me",
                    builder: (_) {
                      return Row(
                        children: [
                          Checkbox(
                            activeColor: const Color(0xFF000647),
                            checkColor: Colors.white,
                            side: const BorderSide(
                              width: 1.2,
                              color: Color(0xFF000647),
                            ),
                            value: ctrl.rememberMe,
                            onChanged: ctrl.onRememberMeChange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Remember me',
                              style: accessibilityService.getAccessibleTextStyle(
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Checkbox pour les termes et conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            acceptTerms = value ?? false;
                          });
                        },
                        activeColor: accessibilityService.primaryColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text.rich(
                            TextSpan(
                              text: 'By creating an account, I accept the ',
                              style: accessibilityService.getAccessibleTextStyle(
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
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
                                      final uri = Uri.parse('https://example.com/terms');
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                ),
                                const TextSpan(text: ' and the '),
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
                                      final uri = Uri.parse('https://example.com/privacy');
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Info légale entreprise
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accessibilityService.isHighContrastMode.value 
                          ? AppTheme.white 
                          : ColorRes.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                      border: Border.all(
                        color: accessibilityService.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '⚖️ Your SIRET and APE codes will be automatically verified against the INSEE database to validate your company\'s legality.',
                      style: accessibilityService.getAccessibleTextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        color: accessibilityService.secondaryTextColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Loader
            if (isLoading) const CommonLoader(),
          ],
        ),
      ),
    ));
  }

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

  Future<void> _createEmployerAccount() async {
    if (!acceptTerms) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Terms Required",
        message: "Please accept the terms of service",
        isError: true,
      );
      return;
    }

    // Validation des champs
    if (_validateFields()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Créer le compte Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: ctrl.emailController.text.trim(),
          password: ctrl.passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          // Sauvegarder les données employeur dans Firestore
          final employerData = {
            'companyName': ctrl.companyNameController.text.trim(),
            'address': ctrl.addressController.text.trim(),
            'postalCode': ctrl.postalCodeController.text.trim(),
            'country': ctrl.countryController.text.trim(),
            'siretCode': ctrl.siretController.text.trim(),
            'apeCode': ctrl.apeController.text.trim(),
            'email': ctrl.emailController.text.trim(),
            'userType': 'employer',
            'isVerified': false,
            'createdAt': FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance
              .collection('employers')
              .doc(userCredential.user!.uid)
              .set(employerData);

          AppTheme.showStandardSnackBar(
            title: "✅ Account Created!",
            message: "Your employer account has been created successfully",
            isError: false,
          );

          // Redirection ou action suivante
          Get.offAllNamed('/employer-dashboard');
        }
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'This email address is already in use';
            break;
          case 'weak-password':
            message = 'The password is too weak';
            break;
          case 'invalid-email':
            message = 'Invalid email address';
            break;
          default:
            message = 'Error creating account: ${e.message}';
        }
        AppTheme.showStandardSnackBar(
          title: "❌ Error",
          message: message,
          isError: true,
        );
      } catch (e) {
        AppTheme.showStandardSnackBar(
          title: "❌ Error",
          message: "An error occurred: $e",
          isError: true,
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _validateFields() {
    if (ctrl.companyNameController.text.trim().isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Required Field",
        message: "Company name is required",
        isError: true,
      );
      return false;
    }

    if (ctrl.addressController.text.trim().isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Required Field",
        message: "Address is required",
        isError: true,
      );
      return false;
    }

    if (ctrl.postalCodeController.text.trim().length != 5) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Invalid Postal Code",
        message: "Postal code must contain 5 digits",
        isError: true,
      );
      return false;
    }

    if (ctrl.siretController.text.trim().length != 14) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Invalid SIRET",
        message: "SIRET code must contain 14 digits",
        isError: true,
      );
      return false;
    }

    if (ctrl.apeController.text.trim().isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Required Field",
        message: "APE code is required",
        isError: true,
      );
      return false;
    }

    if (!GetUtils.isEmail(ctrl.emailController.text.trim())) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Invalid Email",
        message: "Please enter a valid email",
        isError: true,
      );
      return false;
    }

    if (ctrl.passwordController.text.length < 8) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Password Too Short",
        message: "Password must contain at least 8 characters",
        isError: true,
      );
      return false;
    }

    if (ctrl.passwordController.text != ctrl.confirmPasswordController.text) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Passwords Don't Match",
        message: "Passwords do not match",
        isError: true,
      );
      return false;
    }

    return true;
  }
}