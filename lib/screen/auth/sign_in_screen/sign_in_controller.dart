// ignore_for_file: unused_element, unused_shown_name

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/auth_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

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
    
    // Debug: Check if userId is saved
    final userId = PreferencesService.getString(PrefKeys.userId);
    print('🔍 UserId in preferences: $userId');
    print('🔍 Current user: ${auth.currentUser?.uid}');
    
    // Force a small delay to ensure preferences are saved, then navigate
    Future.delayed(const Duration(milliseconds: 200), () {
      // Clear any existing DashBoardController to force refresh
      if (Get.isRegistered<DashBoardController>()) {
        Get.delete<DashBoardController>();
      }
      
      Get.offAll(() => DashBoardScreen());
      print('✅ Navigation to DashBoardScreen completed');
    });
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
      // Show user that they can select account
      AppTheme.showStandardSnackBar(
        title: "Google Sign-In",
        message: "Vous pouvez choisir votre compte Google...",
      );
      
      // Use AuthService for consistent Google Sign-in with account selection
      final success = await AuthService.instance.signInWithGoogle();
      
      if (success) {
        print('🎯 Google sign-in successful, navigating to dashboard');
        AppTheme.showStandardSnackBar(
          title: "Connexion réussie",
          message: "Bienvenue !",
          isSuccess: true,
        );
        // Navigate to dashboard directly after successful authentication
        _gotoDashboard();
      } else {
        AppTheme.showStandardSnackBar(
          title: "Google",
          message: "Connexion annulée",
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


  // Show GitHub account selection dialog
  void showGitHubAccountOptions() {
    Get.dialog(
      AlertDialog(
        title: const Text('Connexion GitHub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisissez votre option de connexion :'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _directGitHubSignIn();
                    },
                    child: const Text('Continuer avec le compte actuel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      _showGitHubSwitchInstructions();
                    },
                    child: const Text('Changer de compte'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _directGitHubSignIn() async {
    await _performGitHubSignIn();
  }

  // Open GitHub website for manual sign out
  void _openGitHubWebsite() async {
    try {
      const url = 'https://github.com/logout';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        AppTheme.showStandardSnackBar(
          title: "GitHub",
          message: "Déconnectez-vous, puis revenez dans l'app",
        );
      } else {
        AppTheme.showStandardSnackBar(
          title: "Erreur",
          message: "Impossible d'ouvrir GitHub. Allez manuellement sur github.com",
          isError: true,
        );
      }
    } catch (e) {
      if (kDebugMode) print("Error opening GitHub: $e");
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Allez manuellement sur github.com pour vous déconnecter",
        isError: true,
      );
    }
  }

  void _showGitHubSwitchInstructions() {
    Get.dialog(
      AlertDialog(
        title: const Text('Changer de compte GitHub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pour utiliser un autre compte GitHub :'),
            const SizedBox(height: 12),
            const Text('1. Cliquez "Ouvrir GitHub" ci-dessous'),
            const Text('2. Déconnectez-vous de votre compte actuel'),
            const Text('3. Revenez ici et cliquez "Essayer maintenant"'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _openGitHubWebsite();
                    },
                    child: const Text('Ouvrir GitHub'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _directGitHubSignIn();
                    },
                    child: const Text('Essayer maintenant'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Main GitHub sign-in entry point - shows options first
  Future<void> signInWithGitHub() async {
    // Show account selection options dialog
    showGitHubAccountOptions();
  }

  // Internal method that does the actual GitHub authentication
  Future<void> _performGitHubSignIn() async {
    if (loading.value) return;
    loading.value = true;
    
    try {
      // Inform user about account selection
      AppTheme.showStandardSnackBar(
        title: "GitHub Sign-In",
        message: "Ouverture de GitHub...",
      );
      
      print('🚀 Starting GitHub sign-in...');
      final success = await AuthService.instance.signInWithGitHub();
      
      if (success) {
        print('🎯 GitHub sign-in successful, checking user data...');
        
        AppTheme.showStandardSnackBar(
          title: "GitHub",
          message: "Connexion GitHub réussie !",
          isSuccess: true,
        );
        
        // Wait a moment to ensure preferences are saved by AuthService
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Verify data was saved
        final userId = PreferencesService.getString(PrefKeys.userId);
        final userEmail = PreferencesService.getString(PrefKeys.email);
        print('🔍 Verified - UserId: $userId, Email: $userEmail');
        
        if (userId.isNotEmpty) {
          print('✅ User data confirmed, navigating to dashboard');
          _gotoDashboard();
        } else {
          print('❌ User data not saved properly');
          AppTheme.showStandardSnackBar(
            title: "GitHub Sign-In",
            message: "Données utilisateur non sauvegardées. Veuillez réessayer.",
            isError: true,
          );
        }
      } else {
        AppTheme.showStandardSnackBar(
          title: "GitHub",
          message: "Connexion annulée. Pour changer de compte GitHub, déconnectez-vous sur github.com puis réessayez.",
        );
      }
    } catch (e) {
      if (kDebugMode) print("GitHub sign-in error: $e");
      AppTheme.showStandardSnackBar(
        title: "GitHub Sign-In",
        message: "Erreur lors de la connexion GitHub",
        isError: true,
      );
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
