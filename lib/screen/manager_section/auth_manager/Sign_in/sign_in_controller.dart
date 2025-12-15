import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart';
import 'package:timeless/screen/organization_profile_screen/organization_profile_screen.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/color_res.dart';

class SignInScreenControllerM extends GetxController {
  RxBool loading = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  bool isManager = false;
  String emailError = "";
  String pwdError = "";
  

  getRememberEmailDataManger() {
    if (PreferencesService.getString(PrefKeys.emailRememberManager) != "") {
      emailController.text = PreferencesService.getString(PrefKeys.emailRememberManager);
      passwordController.text = PreferencesService.getString(PrefKeys.passwordRememberManager);
    }
  }

  void signInWithEmailAndPassword({required String email, required String password}) async {
    loading.value = true;

    await fireStore
        .collection("Auth")
        .doc("Manager")
        .collection("register")
        .get()
        .then((value) async {
      if (value.docs.length.isEqual(0)) {
        loading.value = false;
        Get.snackbar("Error", "Please create account,\n your email is not registered",
            colorText: const Color(0xffDA1414));
      } else {
        for (int i = 0; i < value.docs.length; i++) {
          if (kDebugMode) {
            print("${value.docs[i]["Email"]}=||||||++++++++++");
          }

          if (value.docs[i]["Email"] == email && value.docs[i]["Email"] != "") {
            isManager = true;
            PreferencesService.setValue(PrefKeys.rol, "Manager");
            PreferencesService.setValue(PrefKeys.totalPost, value.docs[i]["TotalPost"]);
            PreferencesService.setValue(PrefKeys.company, value.docs[i]["company"]);
            PreferencesService.setValue(PrefKeys.userId, value.docs[i].id);

            await fireStore
                .collection("Auth")
                .doc("Manager")
                .collection("register")
                .doc(value.docs[i].id)
                .collection("company")
                .get()
                .then((value2) {
              for (int j = 0; j < value2.docs.length; j++) {
                PreferencesService.setValue(PrefKeys.companyName, value2.docs[j]['name']);
              }
            });

            if (kDebugMode) {
              print("$isManager====]]]]]");
            }

            break;
          } else {
            isManager = false;

            if (kDebugMode) {
              print("$isManager====]]]]]");
            }
          }
        }

        if (isManager == true) {
          try {
            loading.value = true;
            UserCredential credential = await auth.signInWithEmailAndPassword(
                email: email, password: password);

            if (kDebugMode) {
              print(credential);
            }

            if (credential.user!.email.toString() == email) {
              PreferencesService.setValue(PrefKeys.userId, credential.user!.uid.toString());
              Get.off(() => PreferencesService.getBool(PrefKeys.company)
                  ? ManagerDashBoardScreen()
                  : const OrganizationProfileScreen());

              emailController.text = "";
              passwordController.text = "";
              update(["loginForm", "showEmail", "pwdError"]);
            }
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              Get.snackbar("Error", "Wrong user", colorText: const Color(0xffDA1414));
              loading.value = false;

              if (kDebugMode) {
                print('No user found for that email.');
              }
            } else if (e.code == 'wrong-password') {
              Get.snackbar("Error", "Wrong password", colorText: const Color(0xffDA1414));
              loading.value = false;

              if (kDebugMode) {
                print('Wrong password provided for that user.');
              }
            }

            if (kDebugMode) {
              print(e.code);
            }
            Get.snackbar("Error", e.code, colorText: const Color(0xffDA1414));
            loading.value = false;
          }
        } else {
          Get.snackbar("Error", "Please create account,\n your email is not registered",
              colorText: const Color(0xffDA1414));
          loading.value = false;
        }
        loading.value = false;
      }

      if (kDebugMode) {
        print("${value.isBlank}=|=|=|");
      }

      if (kDebugMode) {
        print("${value.docs.length}=|=|=|");
      }
    });
  }

  void onChanged(String value) {
    update(["colorChange"]);
  }

  emailValidation() {
    if (emailController.text.trim() == "") {
      emailError = 'Please enter email';
    } else {
      if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailController.text)) {
        emailError = '';
      } else {
        emailError = "Invalid email";
      }
    }
  }

  passwordValidation() {
    if (passwordController.text.trim() == "") {
      pwdError = 'Please enter password';
    } else {
      if (passwordController.text.trim().length >= 8) {
        pwdError = '';
      } else {
        pwdError = "At least 8 character";
      }
    }
  }

  bool validator() {
    emailValidation();
    passwordValidation();
    if (emailError == "" && pwdError == "") {
      return true;
    } else {
      return false;
    }
  }

  onLoginBtnTap() async {
    if (rememberMe == true) {
      await PreferencesService.setValue(PrefKeys.emailRememberManager, emailController.text);
      await PreferencesService.setValue(PrefKeys.passwordRememberManager, passwordController.text);
    }
    if (validator()) {
      signInWithEmailAndPassword(
          password: passwordController.text.trim(),
          email: emailController.text.trim());

      if (kDebugMode) {
        print("GO TO HOME PAGE");
      }
    }
    update(["loginForm", "showEmail", "pwdError"]);
  }

  bool show = true;

  chang() {
    debugPrint("SHOW $show");
    show = !show;
    update(['showPassword']);
  }

  bool rememberMe = false;

  Future<void> onRememberMeChange(bool? value) async {
    if (value != null) {
      rememberMe = value;
      update(['remember_me']);
    }
  }

  bool buttonColor = false;

  button() {
    if (emailController.text != '' && passwordController.text != '') {
      buttonColor = true;
      update(['color']);
    } else {
      buttonColor = false;
      update(['color']);
    }
    update();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  // SOLUTION DEMO - Connexion anonyme + données démo dans Firestore
  void demoLogin() async {
    loading.value = true;
    
    try {
      // Connexion anonyme Firebase (pas besoin de compte)
      UserCredential credential = await auth.signInAnonymously();
      
      if (credential.user != null) {
        // Créer un profil démo temporaire
        await _createDemoProfile(credential.user!.uid);
        
        Get.off(() => ManagerDashBoardScreen());
        
        Get.snackbar(
          "Demo Mode", 
          "✅ Connected in secure demo mode!", 
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Si l'anonyme échoue, connexion locale
      debugPrint('Firebase Demo Error: $e');
      await _localDemoLogin();
    }
    
    loading.value = false;
  }

  Future<void> _localDemoLogin() async {
    // Mode démo local si Firebase échoue
    final demoUserId = "demo-${DateTime.now().millisecondsSinceEpoch}";
    
    // Définir les préférences locales
    await PreferencesService.setValue(PrefKeys.rol, "Manager");
    await PreferencesService.setValue(PrefKeys.totalPost, 0);
    await PreferencesService.setValue(PrefKeys.company, true);
    await PreferencesService.setValue(PrefKeys.userId, demoUserId);
    await PreferencesService.setValue(PrefKeys.companyName, "Timeless Demo Corp");
    
    Get.off(() => ManagerDashBoardScreen());
    
    Get.snackbar(
      "Demo Mode Local", 
      "✅ Local demo mode activated!", 
      backgroundColor: ColorRes.appleGreen,
      colorText: Colors.white,
    );
  }

  Future<void> _createDemoProfile(String userId) async {
    try {
      // Créer le profil manager dans Firestore
      await fireStore
          .collection("Auth")
          .doc("Manager")
          .collection("register")
          .doc(userId)
          .set({
        "Email": "demo@timeless.app",
        "CompanyName": "Timeless Demo Corp",
        "TotalPost": 0,
        "company": true,
        "CreatedAt": FieldValue.serverTimestamp(),
        "DemoAccount": true,
        "Anonymous": true,
      });

      // Créer les infos de l'entreprise
      await fireStore
          .collection("Auth")
          .doc("Manager")
          .collection("register")
          .doc(userId)
          .collection("company")
          .add({
        "name": "Timeless Demo Corp",
        "website": "https://demo.timeless.app",
        "location": "Paris, France",
        "description": "Demonstration company for Timeless - Temporary session",
        "CreatedAt": FieldValue.serverTimestamp(),
      });

      // Définir les préférences
      await PreferencesService.setValue(PrefKeys.rol, "Manager");
      await PreferencesService.setValue(PrefKeys.totalPost, 0);
      await PreferencesService.setValue(PrefKeys.company, true);
      await PreferencesService.setValue(PrefKeys.userId, userId);
      await PreferencesService.setValue(PrefKeys.companyName, "Timeless Demo Corp");
    } catch (e) {
      debugPrint('Demo profile creation error: $e');
      // Continue anyway with local data
    }
  }

  void signWithGoogle() async {
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (await googleSignIn.isSignedIn()) {
      loading.value = true;
    }
    final GoogleSignInAuthentication authentication = await account!.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
      accessToken: authentication.accessToken,
    );

    final UserCredential authResult = await auth.signInWithCredential(credential);
    final User? user = authResult.user;

    if (kDebugMode) {
      print(user!.email);
    }

    if (user?.uid != null && user?.uid != "") {
      loading.value = true;
      await fireStore
          .collection("Auth")
          .doc("Manager")
          .collection("register")
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {
          loading.value = false;
          Get.snackbar("Error", "Please create account,\n your email is not registered",
              colorText: const Color(0xffDA1414));
        } else {
          for (int i = 0; i < value.docs.length; i++) {
            if (value.docs[i]["Email"] == user!.email && value.docs[i]["Email"] != "") {
              isManager = true;
              PreferencesService.setValue(PrefKeys.rol, "Manager");
              PreferencesService.setValue(PrefKeys.totalPost, value.docs[i]["TotalPost"]);
              PreferencesService.setValue(PrefKeys.company, value.docs[i]["company"]);
              PreferencesService.setValue(PrefKeys.userId, user.uid);
              Get.off(() => PreferencesService.getBool(PrefKeys.company)
                  ? ManagerDashBoardScreen()
                  : const OrganizationProfileScreen());
              break;
            } else {
              isManager = false;
            }
          }
          
          if (!isManager) {
            Get.snackbar("Error", "Please create account,\n your email is not registered",
                colorText: const Color(0xffDA1414));
            if (await googleSignIn.isSignedIn()) {
              await googleSignIn.signOut();
            }
          }
          
          loading.value = false;
        }
      });

      PreferencesService.setValue(PrefKeys.userId, user?.uid.toString());
      loading.value = false;
    } else {
      loading.value = false;
    }
  }
}