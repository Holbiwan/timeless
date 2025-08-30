import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpControllerM extends GetxController {
  // Champs saisis
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // États / erreurs UI attendus par l'écran
  String firstError = "";
  String lastError = "";
  String emailError = "";
  String phoneError = "";
  String cityError = "";
  String stateError = "";
  String countryError = "";
  String pwdError = "";

  // Loading pour le bouton (isTrue dans l'écran)
  final RxBool loading = false.obs;

  // Divers (remember + show/hide password)
  bool rememberMe = false;
  bool show = true;

  // Dropdown attendu par l'écran
  final List<String> items1 = const ["France", "Belgium", "Spain", "Germany"];
  String? selectedItem;

  // ==== Méthodes attendues par l'écran ====
  void onChanged(String _) => update(["colorChange"]);

  void chang() {
    show = !show;
    update(["showPassword"]);
  }

  void onRememberMeChange(bool? v) {
    rememberMe = v ?? false;
    update(["remember_me"]);
  }

  /// IMPORTANT : signature avec **paramètre nommé** pour matcher
  /// les appels du type `controller.changeDropdwon(val: ...)`.
  void changeDropdwon({String? val}) {
    selectedItem = val;
    if (val != null) {
      countryController.text = val;
    }
    update(["dropdown"]);
  }

  Future<void> onSignUpBtnTap() async {
    // TODO: implémente ici la vraie logique d’inscription Manager
    Get.snackbar("Manager", "Sign-up not implemented yet");
  }

  // L’écran appelle "SignUpWithGoogle()" (casse identique)
  Future<void> SignUpWithGoogle() async {
    loading.value = true;
    try {
      // TODO: implémente le Google Sign-In manager si besoin
      Get.snackbar("Google", "Google Sign-Up (manager) not implemented yet");
    } finally {
      loading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
