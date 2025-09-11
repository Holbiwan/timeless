// lib/screen/auth/sign_in_screen/sign_in_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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
  bool show = true; // afficher/masquer le mot de passe

  // Erreurs UI (champ texte)
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
      // Vérifie si l'email existe dans ton schéma Firestore (optionnel)
      final snap = await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .where("Email", isEqualTo: email)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        Get.snackbar(
          "Error",
          "Please create account,\n your email is not registered",
          colorText: const Color(0xffDA1414),
        );
        return;
      }

      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        _persistUserPrefs(user, email: email);

        final doc = snap.docs.first.data();
        PrefService.setValue(PrefKeys.fullName, doc["fullName"] ?? "");
        PrefService.setValue(PrefKeys.phoneNumber, doc["Phone"] ?? "");
        PrefService.setValue(PrefKeys.city, doc["City"] ?? "");
        PrefService.setValue(PrefKeys.state, doc["State"] ?? "");
        PrefService.setValue(PrefKeys.country, doc["Country"] ?? "");
        PrefService.setValue(PrefKeys.occupation, doc["Occupation"] ?? "");

        emailController.clear();
        passwordController.clear();

        _gotoDashboard();
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? e.code,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Error", "Sign-in failed",
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

  // ===== Création de compte Email/Password =====
  Future<void> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (loading.value) return;
    loading.value = true;
    try {
      final UserCredential cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = cred.user;
      if (user == null) {
        Get.snackbar("Sign up", "Account creation failed",
            snackPosition: SnackPosition.BOTTOM,
            colorText: const Color(0xffDA1414));
        return;
      }

      await _mergeUserDoc(uid: user.uid, data: {
        "Email": email.trim(),
        "fullName": "$firstName $lastName",
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "createdAt": FieldValue.serverTimestamp(),
        "provider": "password",
        "uid": user.uid,
      });

      _persistUserPrefs(user,
          email: email.trim(), fullName: "$firstName $lastName");
      _gotoDashboard();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Sign up", e.message ?? 'Firebase error',
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      Get.snackbar("Sign up", "Account creation failed",
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

  // (utilisée par sign_up_screen.dart)
  Future<void> registerWithEmailAlt({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (loading.value) return;
    loading.value = true;
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = cred.user;
      if (user == null) {
        Get.snackbar("Sign up", "Account creation failed",
            snackPosition: SnackPosition.BOTTOM,
            colorText: const Color(0xffDA1414));
        return;
      }

      await FirebaseFirestore.instance
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .set({
        "Email": email.trim(),
        "fullName": "$firstName $lastName",
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "createdAt": FieldValue.serverTimestamp(),
        "provider": "password",
        "uid": user.uid,
      }, SetOptions(merge: true));

      PrefService.setValue(PrefKeys.rol, "User");
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, email.trim());
      PrefService.setValue(PrefKeys.fullName, "$firstName $lastName");

      Get.offAll(() => DashBoardScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Sign up", e.message ?? 'Firebase error',
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  void onRememberMeChange(bool? value) {
    if (value == null) return;
    rememberMe = value;
    update(['remember_me']);
  }

  void button() => update(['color']);

   // ===================================================================
  // GOOGLE SIGN-IN via FirebaseAuth
  // ===================================================================
  Future<void> signWithGoogle() async {
    if (loading.value) return;
    loading.value = true;
    try {
      final GoogleAuthProvider provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile')
        ..setCustomParameters({'prompt': 'select_account'});

      // ⭐⭐ CORRECTION : Utilise signInWithPopup pour MOBILE et WEB ⭐⭐
      final UserCredential cred = await auth.signInWithPopup(provider);

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
      if (kDebugMode) print(e);
      Get.snackbar("Google", "Firebase error: ${e.code}",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Google", "Unexpected: $e",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  // ===================================================================
  // GITHUB SIGN-IN via FirebaseAuth
  // ===================================================================
  Future<void> signInWithGitHub() async {
    if (loading.value) return;
    loading.value = true;
    try {
      final GithubAuthProvider provider = GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email')
        ..setCustomParameters({'allow_signup': 'false'});

      // ⭐⭐ CORRECTION : Utilise signInWithPopup pour MOBILE et WEB ⭐⭐
      final UserCredential cred = await auth.signInWithPopup(provider);

      final user = cred.user;
      if (user == null) {
        Get.snackbar("GitHub", "Sign-in cancelled",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // email parfois masqué côté GitHub
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
      if (kDebugMode) print(e);
      Get.snackbar("GitHub", "Firebase error: ${e.code}",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("GitHub", "Unexpected: $e",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  // ===== Facebook (placeholder pour ne pas casser la build) =====
  Future<void> faceBookSignIn() async {
    Get.snackbar("Facebook", "Facebook Sign-In not implemented yet",
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