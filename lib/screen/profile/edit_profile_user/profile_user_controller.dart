// ignore: unused_import
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timeless/services/preferences_service.dart';
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
  final TextEditingController jobPositionController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController experienceLevelController = TextEditingController();
  final TextEditingController salaryMinController = TextEditingController();
  final TextEditingController salaryMaxController = TextEditingController();
  
  // Gestion des images
  XFile? image;
  final ImagePicker _picker = ImagePicker();
  
  // Gestion du CV
  XFile? cvFile;
  final RxString cvFileName = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadExistingProfile();
    loadExistingCV();
  }
  
  // Charger les données du profil existantes
  void loadExistingProfile() {
    fullNameController.text = PreferencesService.getString(PrefKeys.fullName);
    emailController.text = PreferencesService.getString(PrefKeys.email);
    phoneController.text = PreferencesService.getString(PrefKeys.phoneNumber);
    cityController.text = PreferencesService.getString(PrefKeys.city);
    countryController.text = PreferencesService.getString(PrefKeys.country);
    dateOfBirthController.text = PreferencesService.getString(PrefKeys.dateOfBirth);
    addressController.text = PreferencesService.getString(PrefKeys.address);
    occupationController.text = PreferencesService.getString(PrefKeys.occupation);
    jobPositionController.text = PreferencesService.getString(PrefKeys.jobPosition);
    bioController.text = PreferencesService.getString(PrefKeys.bio);
    skillsController.text = PreferencesService.getString(PrefKeys.skillsList);
    experienceLevelController.text = PreferencesService.getString(PrefKeys.experienceLevel);
    salaryMinController.text = PreferencesService.getString(PrefKeys.salaryRangeMin);
    salaryMaxController.text = PreferencesService.getString(PrefKeys.salaryRangeMax);
    
    // Charger l'image de profil si elle existe
    String imagePath = PreferencesService.getString('profile_image_path');
    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      image = XFile(imagePath);
      update(['pic']);
    }
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
    jobPositionController.dispose();
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
  
  // Méthode pour upload du CV
  Future<void> pickCVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        cvFile = XFile(file.path!);
        cvFileName.value = file.name;
        
        // Sauvegarder le chemin du CV
        await PreferencesService.setValue(PrefKeys.cvFilePath, file.path!);
        await PreferencesService.setValue(PrefKeys.cvFileName, file.name);
        
        Get.snackbar(
          'CV Upload', 
          'CV "${file.name}" uploaded successfully!',
          backgroundColor: const Color(0xFF28A745),
          colorText: Colors.white,
        );
        
        update(['cv_section']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking CV file: $e');
      }
      Get.snackbar('Error', 'Failed to upload CV file');
    }
  }
  
  // Méthode pour supprimer le CV
  Future<void> removeCVFile() async {
    try {
      cvFile = null;
      cvFileName.value = '';
      
      await PreferencesService.setValue(PrefKeys.cvFilePath, '');
      await PreferencesService.setValue(PrefKeys.cvFileName, '');
      
      Get.snackbar(
        'CV Removed', 
        'CV file has been removed',
        backgroundColor: const Color(0xFFDC3545),
        colorText: Colors.white,
      );
      
      update(['cv_section']);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing CV file: $e');
      }
    }
  }
  
  // Charger le CV existant au démarrage
  void loadExistingCV() {
    String savedPath = PreferencesService.getString(PrefKeys.cvFilePath);
    String savedName = PreferencesService.getString(PrefKeys.cvFileName);
    
    if (savedPath.isNotEmpty && savedName.isNotEmpty) {
      if (File(savedPath).existsSync()) {
        cvFile = XFile(savedPath);
        cvFileName.value = savedName;
        update(['cv_section']);
      }
    }
  }
  
  // Méthode pour sauvegarder le profil
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      
      // Sauvegarder tous les champs du profil avec les bonnes clés PrefKeys
      await PreferencesService.setValue(PrefKeys.fullName, fullNameController.text);
      await PreferencesService.setValue(PrefKeys.email, emailController.text);
      await PreferencesService.setValue(PrefKeys.phoneNumber, phoneController.text);
      await PreferencesService.setValue(PrefKeys.city, cityController.text);
      await PreferencesService.setValue(PrefKeys.country, countryController.text);
      await PreferencesService.setValue(PrefKeys.dateOfBirth, dateOfBirthController.text);
      await PreferencesService.setValue(PrefKeys.address, addressController.text);
      await PreferencesService.setValue(PrefKeys.occupation, occupationController.text);
      await PreferencesService.setValue(PrefKeys.jobPosition, jobPositionController.text);
      await PreferencesService.setValue(PrefKeys.bio, bioController.text);
      await PreferencesService.setValue(PrefKeys.skillsList, skillsController.text);
      await PreferencesService.setValue(PrefKeys.experienceLevel, experienceLevelController.text);
      await PreferencesService.setValue(PrefKeys.salaryRangeMin, salaryMinController.text);
      await PreferencesService.setValue(PrefKeys.salaryRangeMax, salaryMaxController.text);
      
      // Sauvegarder le chemin de l'image si elle existe
      if (image != null) {
        await PreferencesService.setValue('profile_image_path', image!.path);
      }
      
      Get.snackbar(
        'Profile Saved', 
        'Your profile has been saved successfully!',
        backgroundColor: const Color(0xFF28A745),
        colorText: Colors.white,
      );
      
      isLoading.value = false;
      
      // Fermer l'écran d'édition après sauvegarde réussie
      Get.back();
      
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to save profile');
      if (kDebugMode) {
        print('Error saving profile: $e');
      }
    }
  }
  
  // Méthode pour sauvegarder les modifications dans PreferencesService
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
        await PreferencesService.setValue(PrefKeys.fullName, fullNameController.text);
        await PreferencesService.setValue(PrefKeys.email, emailController.text);
        await PreferencesService.setValue(PrefKeys.phoneNumber, phoneController.text);
        await PreferencesService.setValue(PrefKeys.city, cityController.text);
        await PreferencesService.setValue(PrefKeys.country, countryController.text);
        await PreferencesService.setValue(PrefKeys.dateOfBirth, dateOfBirthController.text);
        await PreferencesService.setValue(PrefKeys.address, addressController.text);
        await PreferencesService.setValue(PrefKeys.occupation, occupationController.text);
        await PreferencesService.setValue(PrefKeys.bio, bioController.text);
        
        // Sauvegarder les données pour le Smart Match
        await PreferencesService.setValue(PrefKeys.experienceLevel, experienceLevelController.text);
        await PreferencesService.setValue(PrefKeys.salaryRangeMin, salaryMinController.text);
        await PreferencesService.setValue(PrefKeys.salaryRangeMax, salaryMaxController.text);
        
        // Traiter les compétences (convertir en JSON array)
        if (skillsController.text.isNotEmpty) {
          final skillsList = skillsController.text
              .split(',')
              .map((skill) => skill.trim())
              .where((skill) => skill.isNotEmpty)
              .toList();
          await PreferencesService.setValue(PrefKeys.skillsList, jsonEncode(skillsList));
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