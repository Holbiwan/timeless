// lib/screen/auth/sign_up/sign_up_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:country_picker/country_picker.dart';



class SignUpController extends GetxController {
  // ===== State / Controllers =====
  final RxBool loading = false.obs;

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl  = TextEditingController();
  final TextEditingController emailCtrl     = TextEditingController();
  final TextEditingController passwordCtrl  = TextEditingController();

  bool showPassword = true;

  // Erreurs UI
  String emailError = "";
  String pwdError   = "";
  String firstError = "";
  String lastError  = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  get countryModel => null;

  // ===== Validations (minimales pour la démo) =====
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

  // stubs conservés (si l'UI les appelle)
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

  // ===== Core: Register Email/Password =====
  Future<void> onSignUpTap() async {
    if (loading.value) return;
    if (!_basicValidator()) {
      Get.snackbar("Error", "Please check email & password",
          colorText: const Color(0xffDA1414),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    loading.value = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final user = cred.user;
      if (user == null) {
        loading.value = false;
        Get.snackbar("Error", "Unexpected sign up result",
            colorText: const Color(0xffDA1414),
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Prefs locales immédiates (succès coté Auth)
      PrefService.setValue(PrefKeys.rol, "User");
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, emailCtrl.text.trim());
      final full = "${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}".trim();
      PrefService.setValue(PrefKeys.fullName, full);

      // ✅ Message de succès visible tout de suite
      Get.snackbar("Success", "Account created successfully!");

      // ✅ Navigue direct (la démo ne dépend pas de Firestore)
      Get.offAll(() => DashBoardScreen());

      // 🔁 Écriture Firestore en arrière-plan (tolérante)
      final profile = <String, dynamic>{
        "uid": user.uid,
        "Email": emailCtrl.text.trim(),
        "fullName": full,
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "provider": "password",
        "imageUrl": "",
        "deviceTokenU": PrefService.getString(PrefKeys.deviceToken),
        "createdAt": FieldValue.serverTimestamp(),
      };

      try {
        await _db
            .collection("Auth")
            .doc("User")
            .collection("register")
            .doc(user.uid)
            .set(profile, SetOptions(merge: true));
      } catch (e) {
        if (kDebugMode) debugPrint("Firestore profile save failed: $e");
      }

// Valeur par défaut (Canada). Country.from(...) est fourni par country_picker.
// (Removed unused variable 'countryModel')


      // Nettoie les champs (après navigation si besoin)
      firstNameCtrl.clear();
      lastNameCtrl.clear();
      emailCtrl.clear();
      passwordCtrl.clear();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Sign up", e.message ?? 'Firebase error',
          colorText: const Color(0xffDA1414),
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      Get.snackbar("Sign up", "Account creation failed",
          colorText: const Color(0xffDA1414),
          snackPosition: SnackPosition.BOTTOM);
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
