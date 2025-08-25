import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

class SignInScreenController extends GetxController {
  // State
  final RxBool loading = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isUser = false;
  String emailError = "";
  String pwdError = "";
  bool rememberMe = false;
  bool show = true;

  // Prefill remembered credentials
  void getRememberEmailDataUser() {
    final email = PrefService.getString(PrefKeys.emailRememberUser);
    final pwd = PrefService.getString(PrefKeys.passwordRememberUser);
    if (email.isNotEmpty) {
      emailController.text = email;
      passwordController.text = pwd;
    }
  }

  // Validation
  void emailValidation() {
    final text = emailController.text.trim();
    if (text.isEmpty) {
      emailError = 'Please enter email';
    } else if (RegExp(
      r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$",
    ).hasMatch(text)) {
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

  // Email/password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    loading.value = true;
    try {
      final snap = await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .get();

      if (snap.docs.isEmpty) {
        Get.snackbar(
            "Error", "Please create account,\n your email is not registered",
            colorText: const Color(0xffDA1414));
        return;
      }

      isUser = false;
      for (final d in snap.docs) {
        if ((d["Email"] ?? "") == email) {
          isUser = true;
          PrefService.setValue(PrefKeys.rol, "User");
          PrefService.setValue(PrefKeys.userId, d.id);
          PrefService.setValue(PrefKeys.fullName, d["fullName"] ?? "");
          PrefService.setValue(PrefKeys.email, d["Email"] ?? "");
          PrefService.setValue(PrefKeys.phoneNumber, d["Phone"] ?? "");
          PrefService.setValue(PrefKeys.city, d["City"] ?? "");
          PrefService.setValue(PrefKeys.state, d["State"] ?? "");
          PrefService.setValue(PrefKeys.country, d["Country"] ?? "");
          PrefService.setValue(PrefKeys.occupation, d["Occupation"] ?? "");
          break;
        }
      }

      if (!isUser) {
        Get.snackbar(
            "Error", "Please create account,\n your email is not registered",
            colorText: const Color(0xffDA1414));
        return;
      }

      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        PrefService.setValue(PrefKeys.userId, user.uid);
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

  // Login button handler
  Future<void> onLoginBtnTap({String? email, String? password}) async {
    if (rememberMe) {
      await PrefService.setValue(
          PrefKeys.emailRememberUser, emailController.text);
      await PrefService.setValue(
          PrefKeys.passwordRememberUser, passwordController.text);
    }
    if (!validator()) return;

    await signInWithEmailAndPassword(
      email: email!,
      password: password!,
    );
  }

  // UI helpers
  void chang() {
    show = !show;
    update(['showPassword']);
  }

  void onRememberMeChange(bool? value) {
    if (value == null) return;
    rememberMe = value;
    update(['remember_me']);
  }

  void button() {
    final hasText = emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
    update(['color']);
    if (hasText) {
      // no-op placeholder if you colorize outside
    }
  }

  // Google Sign-In
  Future<void> signWithGoogle() async {
    loading.value = true;
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        // User cancelled
        return;
      }

      final GoogleSignInAuthentication authentication =
          await account.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );

      final UserCredential authResult =
          await auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user == null || user.uid.isEmpty) return;

      // Vérifie si email existe déjà dans ta collection "register"
      final regSnap = await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .get();

      isUser = false;
      for (final d in regSnap.docs) {
        if ((d["Email"] ?? "") == user.email && (d["Email"] ?? "").isNotEmpty) {
          isUser = true;
          PrefService.setValue(PrefKeys.rol, "User");
          PrefService.setValue(PrefKeys.accessToken, user.uid);
          PrefService.setValue(PrefKeys.fullName, user.displayName ?? "");
          PrefService.setValue(PrefKeys.userId, user.uid);
          break;
        }
      }

      if (!isUser) {
        Get.snackbar(
            "Error", "Please create account,\n your email is not registered",
            colorText: const Color(0xffDA1414));
        await googleSignIn.signOut();
        return;
      }

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

  // Facebook Sign-In
  Future<void> faceBookSignIn() async {
    loading.value = true;
    try {
      final LoginResult loginResult = await FacebookAuth.instance
          .login(permissions: ["email", "public_profile"]);

      if (loginResult.status != LoginStatus.success ||
          loginResult.accessToken == null) {
        return; // cancelled or failed
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      final UserCredential userCredential =
          await auth.signInWithCredential(facebookAuthCredential);

      final User? user = userCredential.user;
      if (user == null || user.uid.isEmpty) return;

      final regSnap = await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .get();

      isUser = false;
      for (final d in regSnap.docs) {
        if ((d["Email"] ?? "") == (user.email ?? "")) {
          isUser = true;
          PrefService.setValue(PrefKeys.rol, "User");
          PrefService.setValue(PrefKeys.userId, user.uid);
          PrefService.setValue(PrefKeys.fullName, user.displayName ?? "");
          break;
        }
      }

      if (!isUser) {
        Get.snackbar(
            "Error", "Please create account,\n your email is not registered",
            colorText: const Color(0xffDA1414));
        await FacebookAuth.instance.logOut();
        return;
      }

      Get.offAll(() => DashBoardScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Facebook", e.message ?? 'Auth error',
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Facebook", "Sign-in failed",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      loading.value = false;
    }
  }
}
