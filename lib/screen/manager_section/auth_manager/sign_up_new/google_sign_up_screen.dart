import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

class SignUpController extends GetxController {
  // Champs
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwdController = TextEditingController();

  // Etats
  final RxBool loading = false.obs;
  bool show = true;
  bool showConfirm = true;

  // Erreurs UI
  String nameError = '';
  String emailError = '';
  String pwdError = '';
  String confirmError = '';

  // Services
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // ========= Validations =========
  void validateName() {
    final text = fullNameController.text.trim();
    nameError = text.isEmpty ? "Please enter name" : '';
    update(["showName"]);
  }

  void validateEmail() {
    final text = emailController.text.trim();
    if (text.isEmpty) {
      emailError = "Please enter email";
    } else if (!RegExp(r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$").hasMatch(text)) {
      emailError = "Invalid email";
    } else {
      emailError = '';
    }
    update(["showEmail"]);
  }

  void validatePassword() {
    final text = passwordController.text.trim();
    if (text.isEmpty) {
      pwdError = "Please enter Password";
    } else if (text.length < 8) {
      pwdError = "At least 8 character";
    } else {
      pwdError = '';
    }
    update(["showPassword"]);
  }

  void validateConfirm() {
    final pwd = passwordController.text.trim();
    final confirm = confirmPwdController.text.trim();
    if (confirm.isEmpty) {
      confirmError = "Please confirm password";
    } else if (confirm != pwd) {
      confirmError = "Password not match";
    } else {
      confirmError = '';
    }
    update(["showConfirm"]);
  }

  bool _isValid() {
    validateName();
    validateEmail();
    validatePassword();
    validateConfirm();
    return nameError.isEmpty && emailError.isEmpty && pwdError.isEmpty && confirmError.isEmpty;
  }

  // ========= UI helpers =========
  void chang() {
    show = !show;
    update(["showPassword"]);
  }

  void changConfirm() {
    showConfirm = !showConfirm;
    update(["showConfirm"]);
  }

  void onChanged(String _) => update(["colorChange"]);

  // ========= Enregistrement email / mot de passe =========
  Future<void> signUpWithEmail() async {
    if (!_isValid()) return;

    loading.value = true;
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        Get.snackbar("Error", "Sign-up failed", colorText: const Color(0xffDA1414));
        return;
      }

      // Ecrit l’utilisateur dans Firestore
      await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .set({
        "Email": emailController.text.trim(),
        "fullName": fullNameController.text.trim(),
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "createdAt": FieldValue.serverTimestamp(),
        "provider": "password",
      }, SetOptions(merge: true));

      // Prefs/navigation
      PrefService.setValue(PrefKeys.rol, "User");
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, emailController.text.trim());
      PrefService.setValue(PrefKeys.fullName, fullNameController.text.trim());

      // Nettoyage champs
      fullNameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPwdController.clear();

      Get.offAll(() => DashBoardScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? e.code, colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Error", "Sign-up failed", colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  // ========= Inscription Google =========
  Future<void> signUpWithGoogle() async {
    loading.value = true;
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return; // cancel

      final authen = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: authen.idToken,
        accessToken: authen.accessToken,
      );

      final UserCredential authResult = await auth.signInWithCredential(credential);
      final User? user = authResult.user;
      if (user == null) {
        Get.snackbar("Google", "Sign-in failed",
            snackPosition: SnackPosition.BOTTOM,
            colorText: const Color(0xffDA1414));
        return;
      }

      // Ecrit/minimise l’utilisateur côté Firestore
      await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .set({
        "Email": user.email ?? account.email,
        "fullName": user.displayName ?? account.displayName ?? "",
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "createdAt": FieldValue.serverTimestamp(),
        "provider": "google",
      }, SetOptions(merge: true));

      // Prefs/nav
      PrefService.setValue(PrefKeys.rol, "User");
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, user.email ?? account.email);
      PrefService.setValue(PrefKeys.fullName, user.displayName ?? account.displayName ?? "");

      Get.offAll(() => DashBoardScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Google", e.message ?? 'Auth error',
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Google", "Sign-in failed",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }
}
