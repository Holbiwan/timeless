// lib/screen/auth/sign_in_screen/sign_in_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // Le plugin google_sign_in ne sert que sur mobile.
  final GoogleSignIn googleSignIn = GoogleSignIn();

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

  // ===== Email / Password =====
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
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
        // Prefs
        PrefService.setValue(PrefKeys.userId, user.uid);
        PrefService.setValue(PrefKeys.rol, "User");
        PrefService.setValue(PrefKeys.email, email);

        // Quelques infos du profil Firestore si disponibles
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
        Get.snackbar("Error", "Wrong user",
            colorText: const Color(0xffDA1414));
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

  // ===== Création de compte Email/Password (à appeler depuis ton écran SignUp) =====
Future<void> registerWithEmail({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
}) async {
  loading.value = true;
  try {
    // 1) Crée l’utilisateur Firebase Auth
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

    // 2) Crée/merge la fiche Firestore (même schéma que le reste de l’app)
    await fireStore
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

    // 3) Préférences locales (comme pour Google/GitHub)
    PrefService.setValue(PrefKeys.rol, "User");
    PrefService.setValue(PrefKeys.userId, user.uid);
    PrefService.setValue(PrefKeys.email, email.trim());
    PrefService.setValue(PrefKeys.fullName, "$firstName $lastName");

    // 4) Va au dashboard
    Get.offAll(() => DashBoardScreen());
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

  void onRememberMeChange(bool? value) {
    if (value == null) return;
    rememberMe = value;
    update(['remember_me']);
  }

  void button() => update(['color']);

  // ===== Google Sign-In =====
  // - Mobile: google_sign_in (native)
  // - Web: signInWithPopup(GoogleAuthProvider())
  Future<void> signWithGoogle() async {
    loading.value = true;
    try {
      UserCredential authResult;

      if (kIsWeb) {
        // Web : popup Firebase
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        authResult = await auth.signInWithPopup(googleProvider);
      } else {
        // Mobile : google_sign_in
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        if (account == null) {
          return; // user cancelled
        }
        final authen = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: authen.idToken,
          accessToken: authen.accessToken,
        );
        authResult = await auth.signInWithCredential(credential);
      }

      final User? user = authResult.user;
      if (user == null) {
        Get.snackbar("Google", "Sign-in failed",
            snackPosition: SnackPosition.BOTTOM,
            colorText: const Color(0xffDA1414));
        return;
      }

      // Enregistre/merge profil Firestore
      await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .set({
        "Email": user.email ?? "",
        "fullName": user.displayName ?? "",
        "createdAt": FieldValue.serverTimestamp(),
        "provider": "google",
        "photoURL": user.photoURL ?? "",
        "uid": user.uid,
      }, SetOptions(merge: true));

      // Prefs
      PrefService.setValue(PrefKeys.rol, "User");
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, user.email ?? "");
      PrefService.setValue(PrefKeys.fullName, user.displayName ?? "");

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

  // ===== GitHub Sign-In =====
  // Mobile & Web : signInWithProvider / signInWithPopup selon plate-forme.
  Future<void> signInWithGitHub() async {
    loading.value = true;
    try {
      final provider = GithubAuthProvider();
      provider.addScope('read:user');
      provider.addScope('user:email');
      provider.setCustomParameters({'allow_signup': 'false'});

      UserCredential cred;
      if (kIsWeb) {
        // Sur web, utilise la popup
        cred = await auth.signInWithPopup(provider);
      } else {
        // Sur mobile (Android), ouvre le navigateur (Custom Tabs)
        cred = await auth.signInWithProvider(provider);
      }

      final User? user = cred.user;
      if (user == null) {
        Get.snackbar("GitHub", "Sign-in failed",
            snackPosition: SnackPosition.BOTTOM,
            colorText: const Color(0xffDA1414));
        return;
      }

      // Email : parfois privé côté GitHub → fallback
      String? email = user.email;
      if (email == null || email.isEmpty) {
        for (final p in user.providerData) {
          if ((p.email ?? '').isNotEmpty) {
            email = p.email;
            break;
          }
        }
        if ((email == null || email.isEmpty) &&
            cred.additionalUserInfo?.profile is Map) {
          final map = cred.additionalUserInfo!.profile! as Map;
          final maybe = map['email'];
          if (maybe is String && maybe.isNotEmpty) {
            email = maybe;
          }
        }
        email ??= '${user.uid}@users.noreply.github';
      }

      // Enregistre/merge profil Firestore
      await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .set({
        "Email": email,
        "fullName": user.displayName ?? "",
        "createdAt": FieldValue.serverTimestamp(),
        "provider": "github",
        "photoURL": user.photoURL ?? "",
        "uid": user.uid,
      }, SetOptions(merge: true));

      // Prefs
      PrefService.setValue(PrefKeys.rol, "User");
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, email);
      PrefService.setValue(PrefKeys.fullName, user.displayName ?? "");

      Get.offAll(() => DashBoardScreen());
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("GitHub", e.message ?? 'Firebase error',
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("GitHub", "Sign-in failed",
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
