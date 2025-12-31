import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/auth/email_verification/email_verification_screen.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/auth_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_theme.dart';

class SignInScreenController extends GetxController {
  // State and controllers
  final RxBool loading = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool rememberMe = false;
  bool show = true; // affiche/masque le mot de passe

  // Erreurs UI
  String emailError = "";
  String pwdError = "";

  // // --- SECTION: 


  // Prefill RememberMe // --- SECTION: 



  void getRememberEmailDataUser() {
    final email = PreferencesService.getString(PrefKeys.emailRememberUser);
    final pwd = PreferencesService.getString(PrefKeys.passwordRememberUser);
    
    if (email.isNotEmpty && pwd.isNotEmpty) {
      rememberMe = true;
      emailController.text = email;
      passwordController.text = pwd;
      update(["showEmail", "showPassword", "remember_me"]);
    } else {
      rememberMe = false;
      emailController.clear();
      passwordController.clear();
      update(["showEmail", "showPassword", "remember_me"]);
    }
  }

  // // --- SECTION: 


  // Validations // --- SECTION: 



  void emailValidation() {
    final text = emailController.text.trim();
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
    final text = passwordController.text.trim();
    if (text.isEmpty) {
      pwdError = 'Please enter Password';
    } else if (text.length >= 8) {
      pwdError = '';
    } else {
      pwdError = "At least 8 characters";
    }
    update(["showPassword"]);
  }

  void onChanged(String _) => update(["colorChange"]);

  bool validator() {
    emailValidation();
    passwordValidation();
    return emailError.isEmpty && pwdError.isEmpty;
  }

  // // --- SECTION: 


  // Helpers // --- SECTION: 



  void _persistUserPrefs(User user, {String? email, String? fullName}) {
    PreferencesService.setValue(PrefKeys.rol, "User");
    PreferencesService.setValue(PrefKeys.userId, user.uid);
    if (email != null) PreferencesService.setValue(PrefKeys.email, email);
    if (fullName != null) PreferencesService.setValue(PrefKeys.fullName, fullName);
  }

  Future<void> _mergeUserDoc({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return fireStore
        .collection("Auth")
        .doc("User")
        .collection("register")
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  void _gotoDashboard() {
    print('🚀 Navigating to DashBoardScreen...');
    Get.offAll(() => DashBoardScreen());
    print('✅ Navigation to DashBoardScreen completed');
  }

  // // --- SECTION: 


  // Email / Password // --- SECTION: 



  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (loading.value) return;
    loading.value = true;
    
    try {
      print('📧 Starting email authentication for: $email');
      // Use AuthService for consistent authentication
      final success = await AuthService.instance.signInWithEmail(email, password);
      print('📧 Email authentication result: $success');
      
      if (success) {
        print('🎯 Email sign-in successful, navigating to dashboard');
        // Save remember me preferences if selected
        if (rememberMe) {
          await PreferencesService.setValue(PrefKeys.emailRememberUser, email);
          await PreferencesService.setValue(PrefKeys.passwordRememberUser, password);
        } else {
          await PreferencesService.setValue(PrefKeys.emailRememberUser, "");
          await PreferencesService.setValue(PrefKeys.passwordRememberUser, "");
        }
        
        // Clear form and navigate to dashboard
        emailController.clear();
        passwordController.clear();
        print('🏠 Calling _gotoDashboard()');
        _gotoDashboard();
        
      } else {
        // Authentication failed
        AppTheme.showStandardSnackBar(
          title: "Error",
          message: "Invalid email or password",
          isError: true,
        );
      }
    } catch (e) {
      if (kDebugMode) print("Sign in error: $e");
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "An error occurred during sign in",
        isError: true,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> onLoginBtnTap() async {
    if (!validator()) return;

    await signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  // // --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// ==
  // GOOGLE SIGN-IN via FirebaseAuth
  // - Android/iOS : signInWithProvider(GoogleAuthProvider())
  // - Web         : signInWithPopup(GoogleAuthProvider())
  // // --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// --- SECTION: 


// ==
  Future<void> signWithGoogle() async {
    if (loading.value) return;
    loading.value = true;
    
    try {
      // Use AuthService for consistent Google Sign-in
      final success = await AuthService.instance.signInWithGoogle();
      
      if (success) {
        print('🎯 Google sign-in successful, navigating to dashboard');
        // Navigate to dashboard directly after successful authentication
        _gotoDashboard();
      } else {
        AppTheme.showStandardSnackBar(
          title: "Google",
          message: "Sign-in cancelled",
        );
      }
    } catch (e) {
      if (kDebugMode) print("GoogleAuth error: $e");
      AppTheme.showStandardSnackBar(
        title: "Google", 
        message: "Erreur lors de la connexion Google",
        isError: true,
      );
    } finally {
      loading.value = false;
    }
  }


  // // --- SECTION: 


  // GitHub (optionnel) // --- SECTION: 



  Future<void> signInWithGitHub() async {
    if (loading.value) return;
    loading.value = true;
    try {
      // On Android, GitHub has issues with Custom Tabs
      if (!kIsWeb) {
        AppTheme.showStandardSnackBar(
          title: "GitHub Sign-In",
          message: "GitHub is not supported on Android for this version.\n"
          "Please use Google Sign-In or Email/Password.",
        );
        return;
      }

      final provider = GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email')
        ..setCustomParameters({'allow_signup': 'false'});

      UserCredential cred = await auth.signInWithPopup(provider);

      final user = cred.user;
      if (user == null) {
        AppTheme.showStandardSnackBar(
            title: "GitHub",
            message: "Sign-in cancelled");
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
        if (email.isEmpty) email = '${user.uid}@users.noreply.github';
      }

      await _mergeUserDoc(uid: user.uid, data: {
        "Email": email,
        "fullName": user.displayName ?? "",
        "photoURL": user.photoURL ?? "",
        "provider": "github",
        "createdAt": FieldValue.serverTimestamp(),
        "uid": user.uid,
      });

      _persistUserPrefs(user, email: email, fullName: user.displayName ?? "");
      _gotoDashboard();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("GitHubAuth error: ${e.code} ${e.message}");
      AppTheme.showStandardSnackBar(
          title: "GitHub",
          message: e.message ?? 'Firebase error: ${e.code}',
          isError: true);
    } catch (e) {
      if (kDebugMode) print("GitHubAuth error: $e");
      AppTheme.showStandardSnackBar(
          title: "GitHub",
          message: "Unexpected error: $e",
          isError: true);
    } finally {
      loading.value = false;
    }
  }

  // // --- SECTION: 


  // UI helpers // --- SECTION: 



  void chang() {
    show = !show;
    update(['showPassword']);
  }

  void onRememberMeChange(bool? value) {
    if (value == null) return;
    rememberMe = value;
    update(['remember_me']);
  }

  void button() => update(['colorChange']);

  // // --- SECTION: 


  // Lifecycle // --- SECTION: 



  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
