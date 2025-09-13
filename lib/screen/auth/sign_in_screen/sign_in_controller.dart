// lib/screen/auth/sign_in_screen/sign_in_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/service/google_auth_service.dart';
import 'package:timeless/utils/pref_keys.dart';

// ⬇️ pour connaître l'état "succès d'inscription" et étouffer les erreurs tardives
import 'package:timeless/screen/manager_section/auth_manager/sign_up_new/sign_up_new_controller.dart';

class SignInScreenController extends GetxController {
  // ===== State / Controllers =====
  final RxBool loading = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool rememberMe = false;
  bool show = true; // true = caché

  // Erreurs UI
  String emailError = "";
  String pwdError = "";

  // ===== Prefill RememberMe =====
  void getRememberEmailDataUser() {
    final email = PrefService.getString(PrefKeys.emailRememberUser);
    final pwd = PrefService.getString(PrefKeys.passwordRememberUser);
    if (email.isNotEmpty) {
      emailController.text = email;
      passwordController.text = pwd;
    }
  }

  // ===== Validations =====
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

  // ===== Helpers =====

  // ⬇️ Supprime les snacks si un sign-up a déjà réussi (évite le "mauvais" popup après succès)
  bool _suppressAuthErrors() {
    try {
      final c = Get.find<SignUpControllerM>();
      return c.isAuthCompleted; // vrai si succès d'inscription verrouillé
    } catch (_) {
      return false;
    }
  }

  void _snack(
    String title,
    String msg, {
    Color? colorText,
    Color? backgroundColor,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    if (_suppressAuthErrors()) {
      if (kDebugMode) print('[Suppressed Snack] $title: $msg');
      return;
    }
    Get.snackbar(
      title,
      msg,
      snackPosition: snackPosition,
      colorText: colorText,
      backgroundColor: backgroundColor,
    );
  }

  void _persistUserPrefs(User user, {String? email, String? fullName}) {
    PrefService.setValue(PrefKeys.rol, "User");
    PrefService.setValue(PrefKeys.userId, user.uid);
    if (email != null) PrefService.setValue(PrefKeys.email, email);
    if (fullName != null) PrefService.setValue(PrefKeys.fullName, fullName);
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
    Get.offAll(() => DashBoardScreen());
  }

  // ===== Email / Password =====
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (loading.value) return;
    loading.value = true;
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        _snack("Error", "Sign-in failed", colorText: const Color(0xffDA1414));
        return;
      }

      // Profil minimal si absent
      final ref = fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid);

      final snap = await ref.get();
      if (!snap.exists) {
        await ref.set({
          "Email": email,
          "fullName": "",
          "Phone": "",
          "City": "",
          "State": "",
          "Country": "",
          "Occupation": "",
          "createdAt": FieldValue.serverTimestamp(),
          "provider": "password",
          "uid": user.uid,
        });
      }

      _persistUserPrefs(user, email: email);
      _gotoDashboard();
    } on FirebaseAuthException catch (e) {
      _snack("Error", e.message ?? e.code, colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      _snack("Error", "Sign-in failed", colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  Future<void> onLoginBtnTap() async {
    if (rememberMe) {
      await PrefService.setValue(
          PrefKeys.emailRememberUser, emailController.text);
      await PrefService.setValue(
          PrefKeys.passwordRememberUser, passwordController.text);
    }
    if (!validator()) return;

    await signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  // ===== UI helpers =====
  void chang() {
    show = !show;
    update(['showPassword']);
  }

  void onRememberMeChange(bool? value) {
    if (value == null) return;
    rememberMe = value;
    update(['remember_me']);
  }

  void button() => update(['color']);

  // ===============================
  // GOOGLE SIGN-IN (Android/iOS + Web)
  // ===============================
  Future<void> signInWithGoogle() async {
    if (loading.value) return;
    loading.value = true;
    try {
      if (kDebugMode) print('Starting Google Sign-In...');

      // Utiliser le service Google Auth
      final user = await GoogleAuthService.signInWithGoogle();
      if (user == null) {
        if (kDebugMode) print('Google sign-in cancelled or failed');
        _snack("Google", "Connexion annulée",
            snackPosition: SnackPosition.BOTTOM,
            colorText: const Color(0xffDA1414));
        return;
      }

      if (kDebugMode) print('User signed in: ${user.email}');

      // Sauvegarder dans Firestore (non bloquant pour l'UX)
      try {
        await GoogleAuthService.saveUserToFirestore(user);
        if (kDebugMode) print('User data saved to Firestore');
      } catch (firestoreError) {
        if (kDebugMode) print('Firestore error: $firestoreError');
        _snack("Info", "Connexion réussie mais sauvegarde partielle",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade100);
      }

      _persistUserPrefs(user,
          email: user.email ?? "", fullName: user.displayName ?? "");

      _snack("Succès", "Connexion Google réussie !",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800);

      _gotoDashboard();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      }
      String errorMessage = "Erreur de connexion Google";
      switch (e.code) {
        case 'cancelled-popup-request':
        case 'popup-closed-by-user':
          errorMessage = "Connexion annulée";
          break;
        case 'network-request-failed':
          errorMessage = "Erreur réseau - vérifiez votre connexion";
          break;
        case 'popup-blocked':
          errorMessage = "Popup bloqué par le navigateur";
          break;
        case 'account-exists-with-different-credential':
          errorMessage =
              "Ce compte existe déjà avec un autre mode de connexion";
          break;
        case 'user-disabled':
          errorMessage = "Ce compte a été désactivé";
          break;
        default:
          errorMessage = e.message ?? "Erreur Firebase: ${e.code}";
      }
      _snack("Google", errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print('Google sign-in error: $e');
      _snack("Google", "Erreur de connexion: $e",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  // ===== GitHub (non prioritaire démo) =====
  Future<void> signInWithGitHub() async {
    _snack("GitHub", "GitHub Sign-In not configured for mobile yet",
        snackPosition: SnackPosition.BOTTOM,
        colorText: const Color(0xffDA1414));
  }

  // ===== Lifecycle =====
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            