// lib/screen/auth/sign_in_screen/sign_in_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

class SignInScreenController extends GetxController {
  // ===== State / Controllers =====
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

  // ===== Prefill RememberMe =====
  void getRememberEmailDataUser() {
    final email = PrefService.getString(PrefKeys.emailRememberUser);
    final pwd = PrefService.getString(PrefKeys.passwordRememberUser);
    if (email.isNotEmpty) {
      emailController.text = email;
      passwordController.text = pwd;
      update(["showEmail", "showPassword"]);
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

  void _gotoDashboard() => Get.offAll(() => DashBoardScreen());

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
      if (user != null) {
        _persistUserPrefs(user, email: email);

        // Récupère quelques champs du profil si présent (facultatif)
        final snap = await fireStore
            .collection("Auth")
            .doc("User")
            .collection("register")
            .doc(user.uid)
            .get();

        final m = snap.data() ?? {};
        PrefService.setValue(
            PrefKeys.fullName, (m["fullName"] ?? "") as String);
        PrefService.setValue(
            PrefKeys.phoneNumber, (m["Phone"] ?? "") as String);
        PrefService.setValue(PrefKeys.city, (m["City"] ?? "") as String);
        PrefService.setValue(PrefKeys.state, (m["State"] ?? "") as String);
        PrefService.setValue(PrefKeys.country, (m["Country"] ?? "") as String);
        PrefService.setValue(
            PrefKeys.occupation, (m["Occupation"] ?? "") as String);

        emailController.clear();
        passwordController.clear();

        _gotoDashboard();
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? e.code,
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Error", "Sign-in failed",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
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

  // ===================================================================
  // GOOGLE SIGN-IN via FirebaseAuth
  // - Android/iOS : signInWithProvider(GoogleAuthProvider())
  // - Web         : signInWithPopup(GoogleAuthProvider())
  // ===================================================================
  Future<void> signWithGoogle() async {
    if (loading.value) return;
    loading.value = true;
    try {
      UserCredential cred;
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile')
        ..setCustomParameters({'prompt': 'select_account'});

      if (kIsWeb) {
        cred = await auth.signInWithPopup(provider);
      } else {
        cred = await auth.signInWithProvider(provider);
      }

      final user = cred.user;
      if (user == null) {
        Get.snackbar("Google", "Sign-in cancelled",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      await _mergeUserDoc(uid: user.uid, data: {
        "Email": user.email ?? "",
        "fullName": user.displayName ?? "",
        "photoURL": user.photoURL ?? "",
        "provider": "google",
        "createdAt": FieldValue.serverTimestamp(),
        "uid": user.uid,
      });

      _persistUserPrefs(user,
          email: user.email ?? "", fullName: user.displayName ?? "");
      _gotoDashboard();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("GoogleAuth error: ${e.code} ${e.message}");
      Get.snackbar("Google", e.message ?? 'Firebase error: ${e.code}',
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print("GoogleAuth error: $e");
      Get.snackbar("Google", "Unexpected error: $e",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  // ===== GitHub (optionnel) =====
  Future<void> signInWithGitHub() async {
    if (loading.value) return;
    loading.value = true;
    try {
      final provider = GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email')
        ..setCustomParameters({'allow_signup': 'false'});

      UserCredential cred;
      if (kIsWeb) {
        cred = await auth.signInWithPopup(provider);
      } else {
        cred = await auth.signInWithProvider(provider);
      }

      final user = cred.user;
      if (user == null) {
        Get.snackbar("GitHub", "Sign-in cancelled",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Récup email si masqué côté GitHub
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
      Get.snackbar("GitHub", e.message ?? 'Firebase error: ${e.code}',
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print("GitHubAuth error: $e");
      Get.snackbar("GitHub", "Unexpected error: $e",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
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

  void button() => update(['colorChange']);

  // ===== Lifecycle =====
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
