// 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/models/employer_model.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/screen/auth/email_verification/employer_email_verification_screen.dart';
import 'package:timeless/utils/app_res.dart';
// import 'package:timeless/screen/auth/employer_signin/employer_signup_screen.dart';

class EmployerSignInController extends GetxController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final companyNameController = TextEditingController();
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final siretController = TextEditingController();
  final apeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Remember me functionality
  bool rememberMe = false;

  @override
  void onInit() {
    super.onInit();
    // Pré-remplir le pays avec France uniquement
    countryController.text = 'France';
    // Charger les données mémorisées si Remember me était activé
    getRememberEmployerData();
  }

  // Load saved employer data if Remember me was enabled
  void getRememberEmployerData() {
    final email = PreferencesService.getString(PrefKeys.emailRememberManager);
    final password = PreferencesService.getString(PrefKeys.passwordRememberManager);
    
    // Only pre-fill if we have saved data AND Remember me was enabled
    if (email.isNotEmpty && password.isNotEmpty) {
      rememberMe = true;
      emailController.text = email;
      passwordController.text = password;
      confirmPasswordController.text = password;
    } else {
      // Ensure fields are empty if nothing is saved
      rememberMe = false;
      // Only keep France as default country
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      companyNameController.clear();
      addressController.clear();
      postalCodeController.clear();
      cityController.clear();
      siretController.clear();
      apeController.clear();
    }
  }

  // Toggle Remember me
  void onRememberMeChange(bool? value) {
    rememberMe = value ?? false;
    
    // If disabling Remember Me, remove saved data
    if (!rememberMe) {
      PreferencesService.remove(PrefKeys.emailRememberManager);
      PreferencesService.remove(PrefKeys.passwordRememberManager);
    }
    update(['remember_me']);
  }

  @override
  void onClose() {
    companyNameController.dispose();
    addressController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    countryController.dispose();
    siretController.dispose();
    apeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Email Verification System
  Future<void> sendEmailVerification(User user) async {
    try {
      debugPrint('🔄 Attempting to send email verification to ${user.email}');
      debugPrint('🔍 User emailVerified status: ${user.emailVerified}');
      debugPrint('🔍 User uid: ${user.uid}');
      
      await user.sendEmailVerification();
      debugPrint('✅ Email verification sent successfully to ${user.email}');
      
      // Show success message to user
      Get.snackbar(
        '📧 Email Sent',
        'Verification email sent to ${user.email}. Please check your inbox and spam folder.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('❌ Error sending verification email: $e');
      debugPrint('❌ Error details: ${e.toString()}');
      
      // Show error to user
      Get.snackbar(
        '❌ Email Error',
        'Failed to send verification email: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      rethrow;
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        debugPrint('✅ Email verified for ${user.email}');
        return;
      }
      throw Exception('Email not verified');
    } catch (e) {
      debugPrint('❌ Email verification check failed: $e');
      rethrow;
    }
  }

  // Welcome email for employers
  Future<void> _sendWelcomeEmailWithVerification(String email, String companyName) async {
    try {
      debugPrint("📧 Sending welcome email to employer: $email");

      await _generateEmployerWelcomeEmail(email, companyName);

      // Here you would integrate with your email service
      // For now, we'll show a placeholder
      debugPrint("✅ Welcome email generated for $companyName");
      
      // TODO: Integrate with actual email service (SendGrid, AWS SES, etc.)
      
    } catch (e) {
      debugPrint('❌ Error sending welcome email: $e');
      rethrow;
    }
  }

  // Generate professional welcome email for employers
  Future<String> _generateEmployerWelcomeEmail(String email, String companyName) async {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Welcome to Timeless - PRO Account Created</title>
        <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f4f4f4; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
            .header { text-align: center; margin-bottom: 30px; padding: 20px; background: linear-gradient(135deg, #000647, #1e3c72); color: white; border-radius: 8px; }
            .logo { font-size: 28px; font-weight: bold; margin-bottom: 10px; }
            .subtitle { font-size: 16px; opacity: 0.9; }
            .content { margin-bottom: 30px; }
            h2 { color: #000647; margin-bottom: 20px; }
            h3 { color: #333; margin-top: 25px; margin-bottom: 15px; }
            .verification-box { background-color: #e3f2fd; padding: 20px; border-radius: 8px; border-left: 4px solid #2196f3; margin: 20px 0; }
            .verification-notice { background-color: #fff3cd; padding: 15px; border-radius: 8px; border-left: 4px solid #ffc107; margin: 20px 0; }
            .feature { display: flex; align-items: center; margin: 10px 0; padding: 10px; background-color: #f8f9fa; border-radius: 5px; }
            .feature-icon { margin-right: 12px; font-size: 20px; }
            .feature-text { font-size: 14px; }
            .highlight { background-color: #ffeb3b; padding: 3px 6px; border-radius: 3px; font-weight: bold; }
            .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #666; font-size: 14px; }
            .cta-button { display: inline-block; background-color: #000647; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="logo">🚀 Timeless PRO</div>
                <div class="subtitle">Your recruitment platform starts here</div>
            </div>
            
            <div class="content">
                <h2>Welcome $companyName!</h2>
                
                <p>Congratulations! Your Timeless PRO account has been created successfully. We're excited to have your company join our professional recruitment platform.</p>
                
                <div class="verification-box">
                    <h3 style="margin-top: 0; color: #333;">📧 Email Verification Required</h3>
                    <p><strong>We've sent a verification link to:</strong></p>
                    <p class="highlight" style="font-size: 16px;">$email</p>
                    <p style="margin-bottom: 0; color: #666;">Please check your inbox and click the verification link to activate your PRO account.</p>
                </div>
                
                <div class="verification-notice">
                    <p style="margin: 0; color: #856404;"><strong>⚠️ Important:</strong> You'll need to verify your email before you can access all PRO features and start posting jobs.</p>
                </div>
                
                <h3 style="color: #333;">🎯 What you can do once verified:</h3>
                
                <div class="feature">
                    <span class="feature-icon">📝</span>
                    <span class="feature-text">Post unlimited job offers and manage applications</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">👥</span>
                    <span class="feature-text">Access a pool of qualified candidates</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">⚡</span>
                    <span class="feature-text">Manage applications with our advanced filtering system</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">📊</span>
                    <span class="feature-text">Track recruitment analytics and performance</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">💬</span>
                    <span class="feature-text">Communicate directly with candidates</span>
                </div>
                <div class="feature">
                    <span class="feature-icon">🔔</span>
                    <span class="feature-text">Receive notifications for new applications</span>
                </div>
                
                <p style="margin-top: 30px; color: #666;">If you don't see the verification email in your inbox, please check your spam folder. If you need assistance, our PRO support team is available 24/7.</p>
                
                <p style="margin-top: 20px;"><strong>Next steps:</strong></p>
                <ol>
                    <li>Click the verification link in the email we sent you</li>
                    <li>Complete your company profile</li>
                    <li>Start posting your first job offer!</li>
                </ol>
            </div>
            
            <div class="footer">
                <p><strong>Timeless PRO Team</strong></p>
                <p>Connecting talent with opportunity</p>
                <p style="font-size: 12px; margin-top: 20px;">© 2024 Timeless. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Validation SIRET (basique)
  bool _isValidSiret(String siret) {
    return siret.length == 14 && RegExp(r'^\d+$').hasMatch(siret);
  }

  // Validation APE (basique)
  bool _isValidApe(String ape) {
    return ape.length == 5 && RegExp(r'^\d{4}[A-Z]$').hasMatch(ape.toUpperCase());
  }

  // Connexion employeur
  Future<void> signInEmployer() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // Vérifications des codes
      if (!_isValidSiret(siretController.text.trim())) {
        Get.snackbar(
          'Error',
          'Invalid SIRET code (14 digits required)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (!_isValidApe(apeController.text.trim().toUpperCase())) {
        Get.snackbar(
          'Error',
          'Invalid APE code (format: 1234A)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Authentification Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Vérifier que c'est bien un employeur dans Firestore
        DocumentSnapshot employerDoc = await _firestore
            .collection('employers')
            .doc(userCredential.user!.uid)
            .get();

        if (!employerDoc.exists) {
          Get.snackbar(
            'Error',
            'Employer account not found. Please sign up first.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          await _auth.signOut();
          return;
        }

        // Récupérer les données employeur
        EmployerModel employer = EmployerModel.fromFirestore(employerDoc);

        // Vérifier les codes SIRET et APE
        if (employer.siretCode != siretController.text.trim() ||
            employer.apeCode.toUpperCase() != apeController.text.trim().toUpperCase()) {
          Get.snackbar(
            'Error',
            'Incorrect SIRET/APE codes for this account',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          await _auth.signOut();
          return;
        }

        // Check if email is verified
        if (!userCredential.user!.emailVerified) {
          Get.snackbar(
            '⚠️ Email Not Verified',
            'Please verify your email before accessing the PRO dashboard.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          
          // Redirect to email verification screen
          Get.offAll(() => EmployerEmailVerificationScreen(
            email: employer.email,
            companyName: employer.companyName,
          ));
          return;
        }

        // Sauvegarder les préférences
        await PreferencesService.setUserType('employer');
        await PreferencesService.setString(PrefKeys.employerId, employer.id);
        await PreferencesService.setString(PrefKeys.companyName, employer.companyName);
        await PreferencesService.setValue(PrefKeys.isLogin, true);

        Get.snackbar(
          'Login Successful',
          'Connection successful...Welcome to your employer space ${employer.companyName}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Redirection vers le dashboard employeur
        Get.offAllNamed(AppRes.employerDashboardScreen);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);
      Get.snackbar(
        'Login Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Firebase error messages in English
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'Network connection error';
      default:
        return 'Login error: $errorCode';
    }
  }

  // Create employer account
  Future<void> createEmployerAccount() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // Vérifications des codes
      if (!_isValidSiret(siretController.text.trim())) {
        Get.snackbar(
          'Error',
          'Invalid SIRET code (14 digits required)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Créer le compte Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Sauvegarder les données employeur dans Firestore
        final employerData = {
          'companyName': companyNameController.text.trim(),
          'address': addressController.text.trim(),
          'postalCode': postalCodeController.text.trim(),
          'city': cityController.text.trim(),
          'country': countryController.text.trim(),
          'siretCode': siretController.text.trim(),
          'apeCode': apeController.text.trim(),
          'email': emailController.text.trim(),
          'userType': 'employer',
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('employers')
            .doc(userCredential.user!.uid)
            .set(employerData);

        // Send Firebase verification email
        await sendEmailVerification(userCredential.user!);

        // Send custom welcome email for better UX
        await _sendWelcomeEmailWithVerification(
          emailController.text.trim(),
          companyNameController.text.trim(),
        );

        // Save credentials if Remember me is enabled and account creation succeeded
        if (rememberMe) {
          await PreferencesService.setValue(PrefKeys.emailRememberManager, emailController.text.trim());
          await PreferencesService.setValue(PrefKeys.passwordRememberManager, passwordController.text.trim());
        } else {
          // If Remember me is not enabled, ensure no data is saved
          PreferencesService.remove(PrefKeys.emailRememberManager);
          PreferencesService.remove(PrefKeys.passwordRememberManager);
        }

        // Show instruction for checking Firebase verification email
        Get.snackbar(
          '📧 Check Your Email',
          'Firebase has sent a verification link to ${emailController.text}. Click the link to verify your account.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // Show success message with verification instructions
        Get.snackbar(
          '✅ PRO Account Created!',
          'Verification email sent to ${emailController.text}\nPlease check your inbox and click the verification link to activate your PRO account.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        // Navigate to employer email verification screen
        Get.offAll(() => EmployerEmailVerificationScreen(
          email: emailController.text.trim(),
          companyName: companyNameController.text.trim(),
        ));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email address is already in use';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = 'Error creating account: ${e.message}';
      }
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Redirection vers connexion employeur (pour plus tard)
  void goToEmployerSignIn() {
    // TODO: Créer un écran de connexion séparé si nécessaire
    Get.snackbar(
      'Info',
      'Fonctionnalité de connexion bientôt disponible',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Validation INSEE des codes (simulation - à connecter à une vraie API)
  Future<bool> validateInseeData(String siret, String ape) async {
    // TODO: Intégrer l'API INSEE pour vérification
    // Pour l'instant, validation de format uniquement
    await Future.delayed(const Duration(seconds: 1)); // Simulation API
    return _isValidSiret(siret) && _isValidApe(ape);
  }
}