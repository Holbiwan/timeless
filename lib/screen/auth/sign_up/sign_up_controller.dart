// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';
// >>> Import aliasé pour éviter tout conflit et corriger "GoogleSignupScreen not defined"
import 'package:timeless/screen/auth/sign_up/google_signupscreen.dart' as gsu;


class SignUpController extends GetxController {
  // Controllers
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();

  // State
  final RxBool loading = false.obs;

  String emailError = "";
  String pwdError = "";
  String phoneError = "";
  String firstError = "";
  String lastError = "";
  String cityError = "";
  String stateError = "";
  String countryError = "";
  String occupationError = "";

  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  // Dropdown
  String dropDownValue = 'India';
  final List<String> items = const [
    'India',
    'United States',
    'Europe',
    'china',
    'United Kingdom',
    'Cuba',
    'Havana',
    'Cyprus',
    'Nicosia',
    'Czech',
    'Republic',
    'Prague',
  ];

  void changeDropdwon({required String val}) {
    dropDownValue = val;
    countryController.text = dropDownValue;
    update(["dropdown"]);
  }

  // ===== Validations =====
  void emailValidation() {
    final text = emailController.text.trim();
    if (text.isEmpty) {
      emailError = 'Please Enter email';
    } else if (RegExp(r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$")
        .hasMatch(text)) {
      emailError = '';
    } else {
      emailError = "Invalid email";
    }
  }

  void firstNameValidation() {
    firstError =
        firstnameController.text.trim().isEmpty ? 'Please Enter Firstname' : "";
  }

  void lastNameValidation() {
    lastError =
        lastnameController.text.trim().isEmpty ? 'Please Enter Lastname' : "";
  }

  void cityNameValidation() {
    cityError = cityController.text.trim().isEmpty ? 'Please Enter city' : "";
  }

  void stateNameValidation() {
    stateError =
        stateController.text.trim().isEmpty ? 'Please Enter State' : "";
  }

  void countryNameValidation() {
    countryError =
        countryController.text.trim().isEmpty ? 'Please Enter Country' : "";
  }

  void occupationNameValidation() {
    occupationError = occupationController.text.trim().isEmpty
        ? 'Please Enter Occupation'
        : "";
  }

  void phoneValidation() {
    final text = phoneController.text.trim();
    if (text.isEmpty) {
      phoneError = 'Please Enter phoneNumber';
    } else if (text.length == 10) {
      phoneError = "";
    } else {
      phoneError = "Invalid Phone Number";
    }
    update(["showPhoneNumber"]);
  }

  void passwordValidation() {
    final text = passwordController.text.trim();
    if (text.isEmpty) {
      pwdError = 'Please Enter Password';
    } else if (text.length >= 8) {
      pwdError = '';
    } else {
      pwdError = "At Least 8 Character";
    }
  }

  bool validator() {
    emailValidation();
    passwordValidation();
    phoneValidation();
    firstNameValidation();
    lastNameValidation();
    cityNameValidation();
    stateNameValidation();
    countryNameValidation();
    occupationNameValidation();

    return emailError.isEmpty &&
        pwdError.isEmpty &&
        phoneError.isEmpty &&
        firstError.isEmpty &&
        lastError.isEmpty &&
        cityError.isEmpty &&
        stateError.isEmpty &&
        countryError.isEmpty &&
        occupationError.isEmpty;
  }

  void onSignUpBtnTap() {
    if (validator()) {
      singUp(emailController.text.trim(), passwordController.text.trim());
      if (kDebugMode) {
        print("GO TO HOME PAGE");
      }
    }

    update(["showEmail"]);
    update(["showLastname"]);
    update(["showFirstname"]);
    update(["showPhoneNumber"]);
    update(["loginForm"]);
    update(["showPassword"]);
    update(["showOccupation"]);
    update(["showCity"]);
    update(["showState"]);
    update(["showCountry"]);
    update(['dark']);
  }

  void onChanged(String value) => update(["dark"]);

  // ===== Email/Password Sign up =====
  Future<void> singUp(String email, String password) async {
    try {
      loading.value = true;

      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        PrefService.setValue(PrefKeys.userId, uid);
        PrefService.setValue(PrefKeys.rol, "User");

        final fullName =
            "${firstnameController.text.trim()} ${lastnameController.text.trim()}";

        final Map<String, dynamic> map2 = {
          "fullName": fullName,
          "Email": emailController.text.trim(),
          "Phone": phoneController.text.trim(),
          "Occupation": occupationController.text.trim(),
          "City": cityController.text.trim(),
          "State": stateController.text.trim(),
          "Country": countryController.text.trim(),
          "imageUrl": "",
          "deviceTokenU": PrefService.getString(PrefKeys.deviceToken),
        };

        await PrefService.setValue(PrefKeys.email, emailController.text.trim());
        await PrefService.setValue(
            PrefKeys.occupation, occupationController.text.trim());
        await PrefService.setValue(PrefKeys.fullName, fullName);
        await PrefService.setValue(PrefKeys.city, cityController.text.trim());
        await PrefService.setValue(PrefKeys.state, stateController.text.trim());
        await PrefService.setValue(
            PrefKeys.country, countryController.text.trim());
        await PrefService.setValue(
            PrefKeys.phoneNumber, phoneController.text.trim());

        await addDataInFirebase(userUid: uid, map: map2);
      }

      loading.value = false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (kDebugMode) print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar("Error", e.message.toString(),
            colorText: const Color(0xffDA1414));
      }
      loading.value = false;
    } catch (e) {
      if (kDebugMode) print(e);
      loading.value = false;
    }
  }

  Future<void> addDataInFirebase({
    required String userUid,
    required Map<String, dynamic> map,
  }) async {
    try {
      await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(userUid)
          .set(map);
      loading.value = false;

      // Clear fields
      firstnameController.clear();
      lastnameController.clear();
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
      cityController.clear();
      stateController.clear();
      countryController.clear();
      occupationController.clear();

      Get.off(() => DashBoardScreen());
      if (kDebugMode) print("*************************** Success");
    } catch (e) {
      if (kDebugMode) print('...error... $e');
      loading.value = false;
    }
  }

  // ===== UI helpers =====
  bool show = true;
  void chang() {
    show = !show;
    update(['showPassword']);
  }

  bool rememberMe = false;
  void onRememberMeChange(bool? value) {
    if (value != null) {
      rememberMe = value;
      update(['remember_me']);
    }
  }

  bool buttonColor = false;
  void button() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      buttonColor = true;
    } else {
      buttonColor = false;
    }
    update(['color']);
  }

  // ===== Country picker (pour le téléphone) =====
  Country countryModel = Country.from(json: {
    "e164_cc": "1",
    "iso2_cc": "CA",
    "e164_sc": 0,
    "geographic": true,
    "level": 2,
    "name": "Canada",
    "example": "2042345678",
    "display_name": "Canada (CA) [+1]",
    "full_example_with_plus_sign": "+12042345678",
    "display_name_no_e164_cc": "Canada (CA)",
    "e164_key": "1-CA-0"
  });

  void countrySelect(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        countryModel = country;
        update(['phone_filed']);
      },
    );
  }

  void onCountryTap(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        countryModel = country;
        update(['phone_filed']);
      },
    );
  }

  // ===== Google Sign-In (pré-inscription Google) =====
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signWithGoogle() async {
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        // user cancelled
        return;
      }

      loading.value = true;

      final GoogleSignInAuthentication authentication =
          await account.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );

      final UserCredential authResult =
          await auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user?.uid == null || (user?.uid ?? "").isEmpty) {
        loading.value = false;
        return;
      }

      // Vérifie si déjà existant
      bool isUser = false;
      final QuerySnapshot snapshot = await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .get();

      if (snapshot.docs.isEmpty) {
        isUser = false;
        Get.snackbar(
          "Error",
          "Please create account,\n your email is not registered",
          colorText: const Color(0xffDA1414),
        );
      } else {
        for (final d in snapshot.docs) {
          if (kDebugMode) {
            print("${d["Email"]}=||||||++++++++++");
          }
          if ((d["Email"] ?? "") == (user!.email ?? "")) {
            isUser = true;
            Get.snackbar("Error", "This email is already registered",
                colorText: const Color(0xffDA1414));
            break;
          }
        }
      }

      if (!isUser) {
        final display = user!.displayName ?? "";
        final parts = display.trim().split(RegExp(r"\s+"));
        final String firstNm = parts.isNotEmpty ? parts.first : "";
        final String lastNm = parts.length > 1 ? parts.last : "";

        Get.to(() => gsu.GoogleSignupScreen(
              uid: user.uid,
              email: user.email ?? "",
              firstName: firstNm,
              lastName: lastNm,
            ));
      } else {
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      loading.value = false;
    }
  }

  // ===== Facebook Sign-In =====
  Future<void> faceBookSignIn() async {
    try {
      loading.value = true;

      final LoginResult loginResult = await FacebookAuth.instance
          .login(permissions: ["email", "public_profile"]);

      if (loginResult.status != LoginStatus.success ||
          loginResult.accessToken == null) {
        loading.value = false;
        return;
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(
        facebookAuthCredential,
      );

      if (userCredential.user?.uid != null &&
          (userCredential.user?.uid ?? "").isNotEmpty) {
        Get.offAll(() => DashBoardScreen());
      }
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      loading.value = false;
    }
  }
}
