// lib/screen/auth/sign_in_screen/sign_in_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

class SignInScreenController extends GetxController {
  // Etat
  final RxBool loading = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool rememberMe = false;
  bool show = true; // afficher/masquer le mot de passe

  // Erreurs UI
  String emailError = "";
  String pwdError = "";

  // Récup pré-remplissage
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
    } else if (RegExp(r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$")
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
      pwdError = "At least 8 character";
    }
    update(["showPassword"]);
  }

  void onChanged(String value) => update(["colorChange"]);

  bool validator() {
    emailValidation();
    passwordValidation();
    return emailError.isEmpty && pwdError.isEmpty;
  }

  // ===== Connexion email/mot de passe =====
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    loading.value = true;
    try {
      // Vérifie si l'email existe déjà dans la collection "Auth/User/register"
      final snap = await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .where("Email", isEqualTo: email)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        Get.snackbar(
            "Error", "Please create account,\n your email is not registered",
            colorText: const Color(0xffDA1414));
        return;
      }

      final credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      final user = credential.user;
      if (user != null) {
        PrefService.setValue(PrefKeys.userId, user.uid);
        PrefService.setValue(PrefKeys.rol, "User");
        PrefService.setValue(PrefKeys.email, email);

        final doc = snap.docs.first;
        PrefService.setValue(PrefKeys.fullName, doc["fullName"] ?? "");
        PrefService.setValue(PrefKeys.phoneNumber, doc["Phone"] ?? "");
        PrefService.setValue(PrefKeys.city, doc["City"] ?? "");
        PrefService.setValue(PrefKeys.state, doc["State"] ?? "");
        PrefService.setValue(PrefKeys.country, doc["Country"] ?? "");
        PrefService.setValue(PrefKeys.occupation, doc["Occupation"] ?? "");

        emailController.clear();
        passwordController.clear();
        Get.off(() => DashBoardScreen());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar("Error", "Wrong user", colorText: const Color(0xffDA1414));
      } else if (e.code == 'wrong-password') {
        Get.snackbar("Error", "Wrong password",
            colorText: const Color(0xffDA1414));
      } else {
        Get.snackbar("Error", e.code, colorText: const Color(0xffDA1414));
      }
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Error", "Sign-in failed",
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  // ===== Bouton Login =====
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

  // ===== Google Sign-In =====
  Future<void> signWithGoogle() async {
    loading.value = true;
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return;

      final authen = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: authen.idToken,
        accessToken: authen.accessToken,
      );

      final UserCredential authResult =
          await auth.signInWithCredential(credential);
      final User? user = authResult.user;
      if (user == null) {
        Get.snackbar("Google", "Sign-in failed",
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
        "Email": user.email ?? account.email,
        "fullName": user.displayName ?? account.displayName ?? "",
        "createdAt": FieldValue.serverTimestamp(),
        "provider": "google",
      }, SetOptions(merge: true));

      PrefService.setValue(PrefKeys.rol, "User");
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, user.email ?? account.email);
      PrefService.setValue(
          PrefKeys.fullName, user.displayName ?? account.displayName ?? "");
      Get.offAll(() => DashBoardScreen());
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Google", "Sign-in failed",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }

  // ===== Facebook Sign-In (stub, compile sans package) =====
  Future<void> faceBookSignIn() async {
    // TODO: implémenter avec `flutter_facebook_auth`.
    // Pour le moment on affiche un message pour ne pas casser la compile.
    Get.snackbar("Facebook", "Facebook Sign-In not implemented yet",
        snackPosition: SnackPosition.BOTTOM,
        colorText: const Color(0xffDA1414));
  }
}
