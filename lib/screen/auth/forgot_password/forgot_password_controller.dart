import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  GlobalKey<FormState> forgotFormKey = GlobalKey();

  TextEditingController forgotEmailController = TextEditingController();
  String emailError = "";
  emailValidation() {
    if (forgotEmailController.text.trim() == "") {
      emailError = 'Please Enter email';
    } else {
      if (RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(forgotEmailController.text)) {
        // return 'Enter  valid Email';
        emailError = '';
      } else {
        emailError = "Invalid email";
      }
    }
  }

  bool validator() {
    emailValidation();

    if (emailError == "") {
      return true;
    } else {
      return false;
    }
  }

  onLoginBtnTap() {
    if (validator()) {
        if (kDebugMode) {
          print("Email validation passed, attempting to send reset email...");
        }
        resetPassword();
      /*Get.to(OtpScreenM());*/
    } else {
        if (kDebugMode) {
          print("Email validation failed: $emailError");
        }
    }
    update(["showEmail"]);
  }

  Future resetPassword() async{
    try {
      if (kDebugMode) {
        print("Attempting to send password reset email to: ${forgotEmailController.text.trim()}");
      }
      
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: forgotEmailController.text.trim()
      );
      
      if (kDebugMode) {
        print("Password reset email sent successfully");
      }
      
      Get.snackbar(
        "Reset Password", 
        "Un lien de réinitialisation a été envoyé à votre email", 
        backgroundColor: const Color(0xFF000647),
        colorText: Colors.white,
        duration: const Duration(seconds: 4)
      );
      
      // Délai avant de revenir en arrière pour éviter le conflit avec le snackbar
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
      
    } catch (error) {
      if (kDebugMode) {
        print("Error sending password reset email: $error");
      }
      
      String errorMessage = "Une erreur s'est produite";
      if (error.toString().contains("user-not-found")) {
        errorMessage = "Aucun compte trouvé avec cette adresse email";
      } else if (error.toString().contains("invalid-email")) {
        errorMessage = "Adresse email invalide";
      } else if (error.toString().contains("network-request-failed")) {
        errorMessage = "Problème de connexion réseau";
      }
      
      Get.snackbar(
        "Erreur", 
        errorMessage, 
        backgroundColor: const Color(0xffDA1414),
        colorText: Colors.white,
        duration: const Duration(seconds: 4)
      );
    }
  }

  RxBool isEmailValidate = false.obs;
}
