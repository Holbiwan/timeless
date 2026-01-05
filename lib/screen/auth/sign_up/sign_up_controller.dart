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
import 'package:timeless/services/email_service.dart';

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
      await EmailService.sendCandidateWelcomeEmail(email: email, fullName: fullName);

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
      final provider = GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email')
        ..setCustomParameters({'allow_signup': 'true'});  // Allow signup

      UserCredential cred;
      
      if (kIsWeb) {
        // Web version uses popup
        cred = await _auth.signInWithPopup(provider);
      } else {
        // Mobile version uses provider
        cred = await _auth.signInWithProvider(provider);
      }

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
      await EmailService.sendCandidateWelcomeEmail(email: email, fullName: fullName);

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
