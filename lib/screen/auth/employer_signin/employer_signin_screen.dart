import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/modern_loader.dart';
import 'package:timeless/common/widgets/unified_form_field.dart';
import 'package:timeless/common/widgets/unified_button.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';

import 'package:timeless/screen/auth/employer_signin/employer_signin_controller.dart';
import 'package:timeless/screen/legal/terms_of_service_screen.dart';
import 'package:timeless/screen/legal/privacy_policy_screen.dart';

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
                                    "Create Your PRO Account",
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Join hundreds of companies",
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

                          
                          // Company Name field
                          _buildLabel('Company Name'),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.companyNameController,
                            hintText: 'Ex: ACME Corp',
                            labelText: 'Company Name',
                            isRequired: true,
                            prefixIcon: Icons.business,
                          ),

                          const SizedBox(height: 20),

                          // Address field
                          _buildLabel('Complete Address'),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.addressController,
                            hintText: 'Ex: 15 Rue de la Paix',
                            labelText: 'Complete Address',
                            isRequired: true,
                            prefixIcon: Icons.location_on_outlined,
                          ),

                          const SizedBox(height: 20),

                          // Postal Code and City row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Postal Code'),
                                    const SizedBox(height: 8),
                                    UnifiedFormField(
                                      controller: ctrl.postalCodeController,
                                      hintText: '75001',
                                      labelText: 'Postal Code',
                                      isRequired: true,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      prefixIcon: Icons.markunread_mailbox_outlined,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('City'),
                                    const SizedBox(height: 8),
                                    UnifiedFormField(
                                      controller: ctrl.cityController,
                                      hintText: 'Ex: Paris',
                                      labelText: 'City',
                                      isRequired: true,
                                      prefixIcon: Icons.location_city,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Country field
                          _buildLabel('Country'),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.countryController,
                            hintText: 'France',
                            labelText: 'Country',
                            isRequired: true,
                            prefixIcon: Icons.flag_outlined,
                          ),

                          const SizedBox(height: 20),


                          // SIRET field
                          _buildLabel('SIRET Code'),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.siretController,
                            hintText: '14 digits SIRET number',
                            labelText: 'SIRET Code',
                            isRequired: true,
                            keyboardType: TextInputType.number,
                            maxLength: 14,
                            prefixIcon: Icons.verified_user_outlined,
                          ),

                          const SizedBox(height: 20),

                          // APE field
                          _buildLabel('APE Code'),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.apeController,
                            hintText: 'Ex: 6201Z',
                            labelText: 'APE Code',
                            isRequired: true,
                            prefixIcon: Icons.business_outlined,
                          ),

                          const SizedBox(height: 20),


                          // Email field
                          _buildLabel('Business Email'),
                          const SizedBox(height: 8),
                          UnifiedFormField(
                            controller: ctrl.emailController,
                            hintText: 'contact@your-company.com',
                            labelText: 'Business Email',
                            isRequired: true,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 20),

                          // Password field
                          _buildLabel('Password'),
                          const SizedBox(height: 8),
                          Obx(() => UnifiedFormField(
                            controller: ctrl.passwordController,
                            hintText: 'Minimum 8 characters',
                            labelText: 'Password',
                            isRequired: true,
                            obscureText: ctrl.isPasswordHidden.value,
                            suffixIcon: IconButton(
                              onPressed: ctrl.togglePasswordVisibility,
                              icon: Icon(
                                ctrl.isPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[500],
                              ),
                            ),
                            prefixIcon: Icons.lock_outline,
                          )),

                          const SizedBox(height: 20),

                          // Confirm Password field
                          _buildLabel('Confirm Password'),
                          const SizedBox(height: 8),
                          Obx(() => UnifiedFormField(
                            controller: ctrl.confirmPasswordController,
                            hintText: 'Confirm your password',
                            labelText: 'Confirm Password',
                            isRequired: true,
                            obscureText: ctrl.isConfirmPasswordHidden.value,
                            suffixIcon: IconButton(
                              onPressed: ctrl.toggleConfirmPasswordVisibility,
                              icon: Icon(
                                ctrl.isConfirmPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[500],
                              ),
                            ),
                            prefixIcon: Icons.lock_outline,
                          )),

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

                          // Create account button
                          UnifiedButton(
                            text: 'Create My PRO Account',
                            onPressed: isLoading ? null : _createEmployerAccount,
                            type: UnifiedButtonType.black,
                            isLoading: isLoading,
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

    if (ctrl.cityController.text.trim().isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Required Field",
        message: "City is required",
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