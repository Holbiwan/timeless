import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Text fields utilisés par le screen
  final companyNameController = TextEditingController();
  final companyEmailController = TextEditingController();
  final countryController = TextEditingController();
  final dateController = TextEditingController();
  final companyAddressController = TextEditingController();

  // Flags réactifs utilisés dans le screen
  final RxBool isLod = false.obs; // false = prêt, true = loader
  final RxBool isNameValidate = false.obs;
  final RxBool isEmailValidate = false.obs;
  final RxBool isDateController = false.obs; // ton code l’utilise comme bool
  final RxBool isCountryValidate = false.obs;
  final RxBool isAddressValidate = false.obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  // Appelée par les onglets/dashboards
  void init() {
    // Valeurs par défaut pour éviter null/vides
    companyNameController.text = companyNameController.text.isNotEmpty
        ? companyNameController.text
        : 'Timeless Company';
    companyEmailController.text = companyEmailController.text.isNotEmpty
        ? companyEmailController.text
        : 'hello@timeless.dev';
    countryController.text =
        countryController.text.isNotEmpty ? countryController.text : 'France';
    dateController.text =
        dateController.text.isNotEmpty ? dateController.text : '2023-01-01';
    companyAddressController.text = companyAddressController.text.isNotEmpty
        ? companyAddressController.text
        : '10 Rue de la Paix, Paris';
  }

  // Bouton "Edit" dans le screen
  void onTapEdit() {
    Get.snackbar(
      'Edit',
      'Open organization profile editor…',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    // TODO: remplace par ta vraie navigation:
    // Get.to(() => EditProfileScreenM());
  }

  // Helpers de validation (si tu veux les réactiver)
  void validateName() =>
      isNameValidate.value = companyNameController.text.trim().isEmpty;
  void validateEmail() =>
      isEmailValidate.value = companyEmailController.text.trim().isEmpty;
  void validateDate() =>
      isDateController.value = dateController.text.trim().isEmpty;
  void validateCountry() =>
      isCountryValidate.value = countryController.text.trim().isEmpty;
  void validateAddress() =>
      isAddressValidate.value = companyAddressController.text.trim().isEmpty;

  @override
  void onClose() {
    companyNameController.dispose();
    companyEmailController.dispose();
    countryController.dispose();
    dateController.dispose();
    companyAddressController.dispose();
    super.onClose();
  }
}
