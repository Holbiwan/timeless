// ignore: unused_import
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

class ProfileUserController extends GetxController {
  // Variables observables
  final RxString fbImageUrl = ''.obs;
  final RxBool isNameValidate = false.obs;
  final RxBool isEmailValidate = false.obs;
  final RxBool isAddressValidate = false.obs;
  final RxBool isOccupationValidate = false.obs;
  final RxBool isLoading = false.obs;
  
  // Contrôleurs de texte - TOUS VIDES par défaut pour l'expérience utilisateur
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController experienceLevelController = TextEditingController();
  final TextEditingController salaryMinController = TextEditingController();
  final TextEditingController salaryMaxController = TextEditingController();
  
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
    phoneController.dispose();
    cityController.dispose();
    countryController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    occupationController.dispose();
    bioController.dispose();
    skillsController.dispose();
    experienceLevelController.dispose();
    salaryMinController.dispose();
    salaryMaxController.dispose();
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
  
  // Méthode pour sauvegarder les modifications dans PrefService
  // ignore: non_constant_identifier_names
  Future<void> EditTap() async {
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
      
      isLoading.value = true;
      
      try {
        // Sauvegarder les données de base
        await PrefService.setValue(PrefKeys.fullName, fullNameController.text);
        await PrefService.setValue(PrefKeys.email, emailController.text);
        await PrefService.setValue(PrefKeys.phoneNumber, phoneController.text);
        await PrefService.setValue(PrefKeys.city, cityController.text);
        await PrefService.setValue(PrefKeys.country, countryController.text);
        await PrefService.setValue(PrefKeys.dateOfBirth, dateOfBirthController.text);
        await PrefService.setValue(PrefKeys.address, addressController.text);
        await PrefService.setValue(PrefKeys.occupation, occupationController.text);
        await PrefService.setValue(PrefKeys.bio, bioController.text);
        
        // Sauvegarder les données pour le Smart Match
        await PrefService.setValue(PrefKeys.experienceLevel, experienceLevelController.text);
        await PrefService.setValue(PrefKeys.salaryRangeMin, salaryMinController.text);
        await PrefService.setValue(PrefKeys.salaryRangeMax, salaryMaxController.text);
        
        // Traiter les compétences (convertir en JSON array)
        if (skillsController.text.isNotEmpty) {
          final skillsList = skillsController.text
              .split(',')
              .map((skill) => skill.trim())
              .where((skill) => skill.isNotEmpty)
              .toList();
          await PrefService.setValue(PrefKeys.skillsList, jsonEncode(skillsList));
        }
        
        isLoading.value = false;
        Get.back();
        Get.snackbar(
          'Success', 
          'Profile updated successfully! Smart Match will now use your data.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
      } catch (e) {
        isLoading.value = false;
        if (kDebugMode) print('Error saving profile: $e');
        Get.snackbar('Error', 'Failed to save profile. Please try again.');
      }
      
    } else {
      Get.snackbar('Error', 'Please fill all required fields correctly');
    }
    
    update(['Organization']);
  }
  
  // Méthode pour réinitialiser - garde tout vide par défaut
  void reset() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    cityController.clear();
    countryController.clear();
    dateOfBirthController.clear();
    addressController.clear();
    occupationController.clear();
    bioController.clear();
    skillsController.clear();
    experienceLevelController.clear();
    salaryMinController.clear();
    salaryMaxController.clear();
    image = null;
    fbImageUrl.value = '';
    
    isNameValidate.value = false;
    isEmailValidate.value = false;
    isAddressValidate.value = false;
    isOccupationValidate.value = false;
    isLoading.value = false;
  }
  
  showDatePicker({required context, required DateTime initialDate, required DateTime firstDate, required DateTime lastDate}) {}
}