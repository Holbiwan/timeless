// ignore: unused_import
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileUserController extends GetxController {
  // Variables observables
  final RxString fbImageUrl = ''.obs;
  final RxBool isNameValidate = false.obs;
  final RxBool isEmailValidate = false.obs;
  final RxBool isAddressValidate = false.obs;
  final RxBool isOccupationValidate = false.obs;
  
  // Contrôleurs de texte
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  
  // Gestion des images
  XFile? image;
  final ImagePicker _picker = ImagePicker();
  
  @override
  // ignore: unnecessary_overrides
  void onInit() {
    super.onInit();
    // Initialisez les contrôleurs avec les valeurs existantes si nécessaire
  }
  
  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    occupationController.dispose();
    super.onClose();
  }
  
  // Méthode pour prendre une photo
  Future<void> ontap() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      
      if (pickedFile != null) {
        image = pickedFile;
        update(['pic']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error taking photo: $e');
      }
      Get.snackbar('Error', 'Failed to take photo');
    }
  }
  
  // Méthode pour choisir depuis la galerie
  Future<void> ontapGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      
      if (pickedFile != null) {
        image = pickedFile;
        update(['pic']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      Get.snackbar('Error', 'Failed to pick image');
    }
  }
  
  // Méthode pour le date picker
  void onDatePickerTap(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      dateOfBirthController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }
  
  // Méthode pour les changements de texte
  void onChanged(String value) {
    // Implémentez la validation si nécessaire
  }
  
  // Méthode pour sauvegarder les modifications
  // ignore: non_constant_identifier_names
  void EditTap() {
    // Implémentez la logique de sauvegarde ici
    if (kDebugMode) {
      print('Saving profile changes...');
    }
    
    // Validation basique
    isNameValidate.value = fullNameController.text.isEmpty;
    isEmailValidate.value = emailController.text.isEmpty || !emailController.text.contains('@');
    isAddressValidate.value = addressController.text.isEmpty;
    isOccupationValidate.value = occupationController.text.isEmpty;
    
    if (!isNameValidate.value && 
        !isEmailValidate.value && 
        !isAddressValidate.value && 
        !isOccupationValidate.value) {
      // Sauvegardez les données
      Get.back();
      Get.snackbar('Success', 'Profile updated successfully');
    } else {
      Get.snackbar('Error', 'Please fill all required fields correctly');
    }
    
    update(['Organization']);
  }
  
  // Méthode pour réinitialiser
  void reset() {
    fullNameController.clear();
    emailController.clear();
    dateOfBirthController.clear();
    addressController.clear();
    occupationController.clear();
    image = null;
    fbImageUrl.value = '';
    
    isNameValidate.value = false;
    isEmailValidate.value = false;
    isAddressValidate.value = false;
    isOccupationValidate.value = false;
  }
  
  showDatePicker({required context, required DateTime initialDate, required DateTime firstDate, required DateTime lastDate}) {}
}

class TextEditingController {
  String _text = '';

  String get text => _text;
  set text(String value) => _text = value;

  void clear() {
    _text = '';
  }
  
  void dispose() {}
}