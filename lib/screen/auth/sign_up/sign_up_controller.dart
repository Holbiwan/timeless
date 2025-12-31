import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/auth/email_verification/email_verification_screen.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_theme.dart';

class SignUpController extends GetxController {
  // State / Controllers for Sign Up Screen
  final RxBool loading = false.obs;

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool showPassword = true;

  // Erreurs UI
  String emailError = "";
  String pwdError = "";
  String firstError = "";
  String lastError = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  get countryModel => null;


  void emailValidation() {
    final text = emailCtrl.text.trim();
    if (text.isEmpty) {
      emailError = 'Please enter email';
    } else if (RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(text)) {
      emailError = '';
    } else {
      emailError = "Invalid email";
    }
    update(["showEmail"]);
  }

  void passwordValidation() {
    final text = passwordCtrl.text.trim();
    if (text.isEmpty) {
      pwdError = 'Please enter password';
    } else if (text.length >= 8) {
      pwdError = '';
    } else {
      pwdError = "At least 8 characters";
    }
    update(["showPassword"]);
  }

  // stubs preserved (if the UI calls them)))
  void firstNameValidation() {
    firstError = firstNameCtrl.text.trim().isEmpty ? '' : '';
    update(["showFirst"]);
  }

  void lastNameValidation() {
    lastError = lastNameCtrl.text.trim().isEmpty ? '' : '';
    update(["showLast"]);
  }

  bool _basicValidator() {
    emailValidation();
    passwordValidation();
    return emailError.isEmpty && pwdError.isEmpty;
  }

  void togglePassword() {
    showPassword = !showPassword;
    update(["showPassword"]);
  }

  void onChanged(String _) => update(["colorChange"]);

  // Email Verification System
  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
      if (kDebugMode) print('✅ Email verification sent to ${user.email}');
    } catch (e) {
      if (kDebugMode) print('❌ Error sending verification email: $e');
      rethrow;
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        if (kDebugMode) print('✅ Email verified for ${user.email}');
        return;
      }
      throw Exception('Email not verified');
    } catch (e) {
      if (kDebugMode) print('❌ Email verification check failed: $e');
      rethrow;
    }
  }


  Future<void> _sendWelcomeEmailWithVerification(
      String email, String fullName) async {
    try {
      if (kDebugMode) {
        print(" Sending welcome email with verification to $email");
      }

      // Generate professional welcome email with verification instructions
      final emailHTML =
          await _generateVerificationWelcomeEmail(email, fullName);

      // Send via Firebase Extensions (mail collection)
      final mailDoc = await _db.collection("mail").add({
        "to": [email],
        "message": {
          "subject": " Welcome to Timeless - Please verify your email",
          "html": emailHTML,
          "text":
              "Welcome to Timeless, $fullName! Please verify your email to complete your registration."
        }
      });

      // Log email sending attempt
      await _db.collection("emailQueue").add({
        "to": email,
        "template": "welcome_verification",
        "templateData": {
          "fullName": fullName,
          "email": email,
          "verificationRequired": true,
          "appName": "Timeless"
        },
        "subject": " Welcome to Timeless - Please verify your email",
        "priority": "high",
        "createdAt": FieldValue.serverTimestamp(),
        "status": "sent",
        "mailDocId": mailDoc.id
      });

      if (kDebugMode) {
        print("✅ Welcome email with verification sent successfully to $email");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error sending welcome email: $e");
      }
      // Don't fail account creation for email issues
    }
  }


  Future<String> _generateVerificationWelcomeEmail(
      String email, String fullName) async {
    return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Timeless - Verify Your Email</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; padding: 40px 20px; }
        .header h1 { margin: 0; font-size: 28px; font-weight: 700; }
        .header p { margin: 10px 0 0 0; opacity: 0.9; font-size: 16px; }
        .content { padding: 40px 30px; }
        .content h2 { color: #333; margin-top: 0; font-size: 24px; }
        .verification-box { background: #f8f9fa; padding: 25px; border-radius: 10px; margin: 25px 0; border-left: 4px solid #667eea; text-align: center; }
        .verification-notice { background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .feature { display: flex; align-items: center; margin: 15px 0; padding: 10px; }
        .feature-icon { color: #667eea; margin-right: 15px; font-size: 20px; }
        .feature-text { color: #555; font-size: 16px; }
        .footer { background-color: #f8f9fa; text-align: center; padding: 30px 20px; border-top: 1px solid #eee; }
        .footer h3 { color: #333; margin: 0 0 10px 0; }
        .footer p { color: #666; margin: 5px 0; }
        .small-text { font-size: 12px; color: #999; margin-top: 20px; }
        .highlight { color: #667eea; font-weight: 600; }
        @media (max-width: 600px) {
            .content { padding: 30px 20px; }
            .header { padding: 30px 20px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1> Welcome to Timeless!</h1>
            <p>Your professional journey starts here</p>
        </div>
        
        <div class="content">
            <h2>Hello $fullName,</h2>
            
            <p>Welcome to Timeless! We're excited to have you join our community of professionals. Your account has been created successfully, and we just need to verify your email address to get started.</p>
            
            <div class="verification-box">
                <h3 style="margin-top: 0; color: #333;"> Email Verification Required</h3>
                <p><strong>We've sent a verification link to:</strong></p>
                <p class="highlight" style="font-size: 16px;">$email</p>
                <p style="margin-bottom: 0; color: #666;">Please check your inbox and click the verification link to activate your account.</p>
            </div>
            
            <div class="verification-notice">
                <p style="margin: 0; color: #856404;"><strong>⚠️ Important:</strong> You'll need to verify your email before you can access all features of your Timeless account.</p>
            </div>
            
            <h3 style="color: #333;"> What you can do once verified:</h3>
            
            <div class="feature">
                <span class="feature-icon">✨</span>
                <span class="feature-text">Browse thousands of quality job listings</span>
            </div>
            <div class="feature">
                <span class="feature-icon">⚡</span>
                <span class="feature-text">Apply to jobs with one-click using your profile</span>
            </div>
            <div class="feature">
                <span class="feature-icon"></span>
                <span class="feature-text">Track your applications in real-time</span>
            </div>
            <div class="feature">
                <span class="feature-icon"></span>
                <span class="feature-text">Receive personalized job recommendations</span>
            </div>
            <div class="feature">
                <span class="feature-icon"></span>
                <span class="feature-text">Connect directly with employers</span>
            </div>
            <div class="feature">
                <span class="feature-icon"></span>
                <span class="feature-text">Get notified about application updates</span>
            </div>
            
            <p style="margin-top: 30px; color: #666;">If you don't see the verification email in your inbox, please check your spam folder. If you need assistance, our support team is available 24/7.</p>
        </div>
        
        <div class="footer">
            <h3>The Timeless Team </h3>
            <p>Your professional success is our priority</p>
            <p> support@timeless.app |  www.timeless.app</p>
            
            <div class="small-text">
                <p>This email was sent automatically after account creation.</p>
                <p>If you didn't create this account, you can safely ignore this email.</p>
            </div>
        </div>
    </div>
</body>
</html>
    """;
  }

// Register Email/Password with Email Verification
  Future<void> onSignUpTap() async {
    if (loading.value) return;
    if (!_basicValidator()) {
      AppTheme.showStandardSnackBar(
          title: "Validation Error",
          message: "Please check email & password requirements",
          isError: true);
      return;
    }

    loading.value = true;
    try {
      // Create user account
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final user = cred.user;
      if (user == null) {
        throw Exception("Account creation failed - no user returned");
      }

      // Clear any existing profile data first
      await _clearAllProfileData();

      // Create user profile data
      final fullName =
          "${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}".trim();
      final email = emailCtrl.text.trim();

      // Save to Firestore
      final profile = <String, dynamic>{
        "uid": user.uid,
        "Email": email,
        "fullName": fullName,
        "firstName": firstNameCtrl.text.trim(),
        "lastName": lastNameCtrl.text.trim(),
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "provider": "email",
        "imageUrl": "",
        "emailVerified": false,
        "accountStatus": "pending_verification",
        "deviceTokenU": PreferencesService.getString(PrefKeys.deviceToken),
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _db
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .set(profile);

      // Send Firebase verification email
      await sendEmailVerification(user);

      // Also send custom welcome email for better UX
      await _sendWelcomeEmailWithVerification(email, fullName);

      // Show instruction for checking Firebase verification email
      AppTheme.showStandardSnackBar(
        title: " Check Your Email",
        message:
            "Firebase has sent a verification link to $email. Click the link to verify your account.",
      );

      // Show success message
      AppTheme.showStandardSnackBar(
        title: "✅ Account Created Successfully!",
        message:
            " Verification email sent to $email\nPlease check your inbox and click the verification link to activate your account.",
        isSuccess: true,
      );

      // Navigate to email verification screen instead of dashboard
      Get.offAll(() => EmailVerificationScreen(
            email: email,
            userFullName: fullName,
          ));

      // Clear form fields
      firstNameCtrl.clear();
      lastNameCtrl.clear();
      emailCtrl.clear();
      passwordCtrl.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Account creation failed";

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              "This email is already registered. Please sign in instead.";
          break;
        case 'weak-password':
          errorMessage =
              "Password is too weak. Please use a stronger password.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address format.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled.";
          break;
        default:
          errorMessage = e.message ?? "Unknown error occurred";
      }

      AppTheme.showStandardSnackBar(
        title: "Account Creation Failed",
        message: errorMessage,
        isError: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint("Sign up error: $e");
      AppTheme.showStandardSnackBar(
        title: "Account Creation Failed",
        message: "An unexpected error occurred. Please try again.",
        isError: true,
      );
    } finally {
      loading.value = false;
    }
  }

  // Clear all profile data to ensure new user starts fresh
  Future<void> _clearAllProfileData() async {
    try {
      await Future.wait([
        // Clear personal info (keep only what we just set)
        PreferencesService.setValue(PrefKeys.phoneNumber, ''),
        PreferencesService.setValue(PrefKeys.dateOfBirth, ''),
        PreferencesService.setValue(PrefKeys.city, ''),
        PreferencesService.setValue(PrefKeys.state, ''),
        PreferencesService.setValue(PrefKeys.country, ''),
        PreferencesService.setValue(PrefKeys.occupation, ''),
        PreferencesService.setValue(PrefKeys.jobPosition, ''),
        PreferencesService.setValue(PrefKeys.bio, ''),
        PreferencesService.setValue(PrefKeys.address, ''),
        PreferencesService.setValue(PrefKeys.profileImageUrl, ''),
        PreferencesService.setValue(PrefKeys.profilePhoto, ''),

        // Clear job matching preferences
        PreferencesService.setValue(PrefKeys.experienceLevel, ''),
        PreferencesService.setValue(PrefKeys.skillsList, ''),
        PreferencesService.setValue(PrefKeys.salaryRangeMin, ''),
        PreferencesService.setValue(PrefKeys.salaryRangeMax, ''),
        PreferencesService.setValue(PrefKeys.jobTypes, ''),
        PreferencesService.setValue(PrefKeys.industryPreferences, ''),
        PreferencesService.setValue(PrefKeys.companyTypes, ''),
        PreferencesService.setValue(PrefKeys.maxCommuteDistance, ''),
        PreferencesService.setValue(PrefKeys.workLocationPreference, ''),
      ]);

      if (kDebugMode) {
        print('✅ Profile data cleared for new user');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error clearing profile data: $e');
      }
    }
  }

  // GitHub Sign-Up
  Future<void> signUpWithGitHub() async {
    if (loading.value) return;
    loading.value = true;
    
    try {
      // On Android, GitHub has issues with Custom Tabs
      if (!kIsWeb) {
        AppTheme.showStandardSnackBar(
          title: "GitHub Sign-Up",
          message: "GitHub is not supported on Android for this version.\n"
              "Please use Email/Password registration.",
        );
        return;
      }

      final provider = GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email')
        ..setCustomParameters({'allow_signup': 'true'});  // Allow signup

      UserCredential cred = await _auth.signInWithPopup(provider);

      final user = cred.user;
      if (user == null) {
        AppTheme.showStandardSnackBar(
            title: "GitHub",
            message: "Sign-up cancelled");
        return;
      }

      // Get email if hidden by GitHub
      String email = user.email ?? '';
      if (email.isEmpty) {
        for (final p in user.providerData) {
          if ((p.email ?? '').isNotEmpty) {
            email = p.email!;
            break;
          }
        }
        if (email.isEmpty && cred.additionalUserInfo?.profile is Map) {
          final map = cred.additionalUserInfo!.profile! as Map;
          final maybe = map['email'];
          if (maybe is String && maybe.isNotEmpty) email = maybe;
        }
        if (email.isEmpty) email = '\${user.uid}@users.noreply.github.com';
      }

      // Clear any existing profile data first
      await _clearAllProfileData();

      // Extract name from GitHub profile
      String firstName = '';
      String lastName = '';
      final fullName = user.displayName ?? '';
      
      if (fullName.isNotEmpty) {
        final nameParts = fullName.split(' ');
        firstName = nameParts.first;
        if (nameParts.length > 1) {
          lastName = nameParts.sublist(1).join(' ');
        }
      }

      // Create user profile data
      final profile = <String, dynamic>{
        "uid": user.uid,
        "Email": email,
        "fullName": fullName,
        "firstName": firstName,
        "lastName": lastName,
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "provider": "github",
        "imageUrl": user.photoURL ?? "",
        "photoURL": user.photoURL ?? "",
        "emailVerified": user.emailVerified,
        "accountStatus": user.emailVerified ? "active" : "pending_verification",
        "deviceTokenU": PreferencesService.getString(PrefKeys.deviceToken),
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _db
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .set(profile);

      // Save user preferences
      await PreferencesService.setValue(PrefKeys.rol, "User");
      await PreferencesService.setValue(PrefKeys.userId, user.uid);
      await PreferencesService.setValue(PrefKeys.email, email);
      await PreferencesService.setValue(PrefKeys.fullName, fullName);

      // Send welcome email
      await _sendWelcomeEmailWithVerification(email, fullName);

      AppTheme.showStandardSnackBar(
        title: "✅ Account Created Successfully!",
        message: "Welcome to Timeless! Your GitHub account has been linked successfully.",
        isSuccess: true,
      );

      // Navigate to email verification if needed, otherwise dashboard
      if (user.emailVerified) {
        // Navigate to dashboard directly
        Get.offAll(() => DashBoardScreen());
      } else {
        Get.offAll(() => EmailVerificationScreen(
              email: email,
              userFullName: fullName,
            ));
      }

      // Clear form fields
      firstNameCtrl.clear();
      lastNameCtrl.clear();
      emailCtrl.clear();
      passwordCtrl.clear();
      
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("GitHub Sign-up error: \${e.code} \${e.message}");
      AppTheme.showStandardSnackBar(
          title: "GitHub Sign-up",
          message: e.message ?? 'Firebase error: \${e.code}',
          isError: true);
    } catch (e) {
      if (kDebugMode) print("GitHub Sign-up error: \$e");
      AppTheme.showStandardSnackBar(
          title: "GitHub Sign-up",
          message: "Unexpected error: \$e",
          isError: true);
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  Widget onCountryTap(BuildContext context) {
    // TODO: Implement country picker logic or remove this stub if unused.
    throw UnimplementedError('onCountryTap is not implemented.');
  }
}
