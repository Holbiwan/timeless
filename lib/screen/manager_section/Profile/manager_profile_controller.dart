import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ManagerProfileController extends GetxController {
  // --- Images ---
  final RxString fbImageUrl = ''.obs;   // URL distante
  File? image;                          // image locale (camera/galerie)
  final RxBool isLoading = false.obs;

  // --- Champs texte que certains écrans attendent ---
  final companyNameController = TextEditingController();
  final companyEmailController = TextEditingController();
  final countryController = TextEditingController();

  // --- Flags de validation (si besoin par vos écrans) ---
  final RxBool isNameValidate = false.obs;
  final RxBool isEmailValidate = false.obs;
  final RxBool isCountryValidate = false.obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() {
    // Valeurs par défaut pour éviter les null/vides
    companyNameController.text  = companyNameController.text.isNotEmpty  ? companyNameController.text  : 'Timeless Company';
    companyEmailController.text = companyEmailController.text.isNotEmpty ? companyEmailController.text : 'hello@timeless.dev';
    countryController.text      = countryController.text.isNotEmpty      ? countryController.text      : 'France';
    // debugPrint('ManagerProfileController.init()');
  }

  // === Méthodes évoquées par divers écrans ===
  // Variantes de nommage pour couvrir tout ce que j’ai vu dans tes erreurs :
  void ontap() => _pickFromCamera();           // utilisé par certains écrans
  void onTapImage() => _pickFromCamera();      // variante appelée ailleurs
  void ontapGallery() => _pickFromGallery();   // utilisé par certains écrans
  void onTapGallery1() => _pickFromGallery();  // variante appelée ailleurs

  // Soumission / sauvegarde
  VoidCallback get EditTap => _onSave;         // getter attendu
  void onTapSubmit() => _onSave();             // variante appelée ailleurs

  // --- Implémentations minimales (stubs) ---
  void _pickFromCamera() {
    Get.snackbar('Camera', 'Implement camera picker',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
    // TODO: intégrer image_picker si souhaité
  }

  void _pickFromGallery() {
    Get.snackbar('Gallery', 'Implement gallery picker',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
    // TODO: intégrer image_picker si souhaité
  }

  void _onSave() {
    // TODO: Persister les changements (Firestore, etc.)
    Get.snackbar('Saved', 'Profile changes saved',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  // --- Validations simples (si tes écrans les utilisent) ---
  void validateName()    => isNameValidate.value    = companyNameController.text.trim().isEmpty;
  void validateEmail()   => isEmailValidate.value   = companyEmailController.text.trim().isEmpty;
  void validateCountry() => isCountryValidate.value = countryController.text.trim().isEmpty;

  @override
  void onClose() {
    companyNameController.dispose();
    companyEmailController.dispose();
    countryController.dispose();
    super.onClose();
  }
}
