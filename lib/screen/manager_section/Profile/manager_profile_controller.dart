import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_theme.dart';

class ManagerProfileController extends GetxController {
  // --- SECTION: 

  // Images ---
  final RxString fbImageUrl = ''.obs;   // URL distante
  File? image;                          // image locale (camera/galerie)
  final RxBool isLoading = false.obs;

  // --- SECTION: 

  // Champs texte que certains écrans attendent ---
  final companyNameController = TextEditingController();
  final companyEmailController = TextEditingController();
  final countryController = TextEditingController();
  
  // --- SECTION: 

  // Nouveaux champs pour le profil utilisateur complet ---
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final occupationController = TextEditingController();
  final bioController = TextEditingController();
  
  // --- SECTION: 

  // Champs additionnels pour correspondre à Mon Profil ---
  final dateController = TextEditingController(); // Date de naissance
  final jobPositionController = TextEditingController(); // Poste
  final skillsController = TextEditingController(); // Skills
  final salaryMinController = TextEditingController(); // Salary Min
  final salaryMaxController = TextEditingController(); // Salary Max

  // --- SECTION: 

  // Flags de validation (si besoin par vos écrans) ---
  final RxBool isNameValidate = false.obs;
  final RxBool isEmailValidate = false.obs;
  final RxBool isCountryValidate = false.obs;

  // Getter pour compatibility avec l'EditProfileScreen
  String get profileImageUrl => fbImageUrl.value;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() {
    // Charger le profil depuis Firestore
    _loadProfileFromFirestore();
    // debugPrint('ManagerProfileController.init()');
  }

  Future<void> _loadProfileFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          
          // Charger les données du profil
          fullNameController.text = data['fullName'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phoneNumber'] ?? '';
          cityController.text = data['city'] ?? '';
          countryController.text = data['country'] ?? '';
          occupationController.text = data['occupation'] ?? '';
          bioController.text = data['bio'] ?? '';
          dateController.text = data['dateOfBirth'] ?? '';
          jobPositionController.text = data['jobPosition'] ?? '';
          
          // jobPreferences removed - skills and salary managed separately if needed
          
          // Charger l'image de profil
          if (data['profileImageUrl'] != null) {
            fbImageUrl.value = data['profileImageUrl'];
          }
          
          return;
        }
      }
    } catch (e) {
      // En cas d'erreur, utiliser les valeurs par défaut
      print('Erreur chargement profil: $e');
    }
    
    // Valeurs par défaut si pas de profil Firestore
    _setDefaultValues();
  }

  void _setDefaultValues() {
    // Valeurs par défaut pour éviter les null/vides
    companyNameController.text = companyNameController.text.isNotEmpty ? companyNameController.text : 'Timeless Company';
    companyEmailController.text = companyEmailController.text.isNotEmpty ? companyEmailController.text : 'hello@timeless.dev';
    countryController.text = countryController.text.isNotEmpty ? countryController.text : 'France';
    
    // Valeurs depuis les préférences ou par défaut
    fullNameController.text = PreferencesService.getString(PrefKeys.fullName).isNotEmpty 
        ? PreferencesService.getString(PrefKeys.fullName) 
        : 'John Doe';
    emailController.text = PreferencesService.getString(PrefKeys.email).isNotEmpty 
        ? PreferencesService.getString(PrefKeys.email) 
        : 'john.doe@example.com';
    phoneController.text = PreferencesService.getString(PrefKeys.phoneNumber).isNotEmpty 
        ? PreferencesService.getString(PrefKeys.phoneNumber) 
        : '+33 6 12 34 56 78';
    cityController.text = PreferencesService.getString(PrefKeys.city).isNotEmpty 
        ? PreferencesService.getString(PrefKeys.city) 
        : 'Paris';
    occupationController.text = PreferencesService.getString(PrefKeys.occupation).isNotEmpty 
        ? PreferencesService.getString(PrefKeys.occupation) 
        : 'Developer';
    bioController.text = bioController.text.isNotEmpty ? bioController.text : 'Passionate about technology and innovation';
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

  // --- SECTION: 

  // Implémentations image picker ---
  Future<void> _pickFromCamera() async {
    try {
      isLoading.value = true;
      
      // Simplifier : essayer directement l'image picker qui gère les permissions automatiquement
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false, // Évite les problèmes de permissions
      );
      
      if (pickedFile != null) {
        image = File(pickedFile.path);
        fbImageUrl.value = ''; // Clear network image when local image is selected
        update(['image']); // Update the image widget
        Get.snackbar('Succès', 'Photo capturée avec succès',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Info', 'Aucune photo sélectionnée',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      // Gestion plus douce des erreurs
      if (e.toString().contains('permission')) {
        Get.snackbar(
          'Permission requise', 
          'Autorisez l\'accès à la caméra dans les paramètres de l\'application',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorRes.appleGreen,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar('Erreur', 'Problème avec la caméra: ${e.toString().split(':').last}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ColorRes.royalBlue,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      isLoading.value = true;
      
      // Simplifier : essayer directement l'image picker
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false, // Évite les problèmes de permissions
      );
      
      if (pickedFile != null) {
        image = File(pickedFile.path);
        fbImageUrl.value = ''; // Clear network image when local image is selected
        update(['image']); // Update the image widget
        Get.snackbar('Succès', 'Photo sélectionnée avec succès',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Info', 'Aucune photo sélectionnée',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      // Gestion plus douce des erreurs
      if (e.toString().contains('permission')) {
        Get.snackbar(
          'Permission requise', 
          'Autorisez l\'accès aux photos dans les paramètres de l\'application',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorRes.appleGreen,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar('Erreur', 'Problème avec la galerie: ${e.toString().split(':').last}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ColorRes.royalBlue,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _onSave() async {
    try {
      isLoading.value = true;
      update(['save_button']); // Update button state
      
      // Upload de l'image si une nouvelle image a été sélectionnée
      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadImageToFirebase();
        if (imageUrl != null) {
          fbImageUrl.value = imageUrl;
        }
      }
      
      // Sauvegarder le profil dans Firestore
      await _saveProfileToFirestore(imageUrl);
      
      // Mettre à jour les préférences locales
      _updateLocalPreferences();
      
      // Afficher popup de confirmation avec AppTheme
      AppTheme.showStandardSnackBar(
        title: "Profil mis à jour",
        message: "Votre profil a été sauvegardé avec succès !",
        isSuccess: true,
      );
      
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du profil: $e');
      
      // Afficher popup d'erreur avec AppTheme
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Impossible de sauvegarder le profil: $e",
        isError: true,
      );
    } finally {
      isLoading.value = false;
      update(['save_button']); // Update button state
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (image == null) return null;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      final String fileName = '${user.uid}_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);
      
      final UploadTask uploadTask = ref.putFile(image!);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur upload image: $e');
    }
  }

  Future<void> _saveProfileToFirestore(String? imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final Map<String, dynamic> profileData = {
      'uid': user.uid,
      'email': emailController.text.trim(),
      'fullName': fullNameController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
      'city': cityController.text.trim(),
      'country': countryController.text.trim(),
      'occupation': occupationController.text.trim(),
      'bio': bioController.text.trim(),
      'dateOfBirth': dateController.text.trim(),
      'jobPosition': jobPositionController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      
      // jobPreferences removed
    };
    
    if (imageUrl != null) {
      profileData['profileImageUrl'] = imageUrl;
    }
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(profileData, SetOptions(merge: true));
  }

  void _updateLocalPreferences() {
    PreferencesService.setValue(PrefKeys.fullName, fullNameController.text.trim());
    PreferencesService.setValue(PrefKeys.email, emailController.text.trim());
    PreferencesService.setValue(PrefKeys.phoneNumber, phoneController.text.trim());
    PreferencesService.setValue(PrefKeys.city, cityController.text.trim());
    PreferencesService.setValue(PrefKeys.country, countryController.text.trim());
    PreferencesService.setValue(PrefKeys.occupation, occupationController.text.trim());
  }

  // --- SECTION: 

  // Validations simples (si tes écrans les utilisent) ---
  void validateName()    => isNameValidate.value    = companyNameController.text.trim().isEmpty;
  void validateEmail()   => isEmailValidate.value   = companyEmailController.text.trim().isEmpty;
  void validateCountry() => isCountryValidate.value = countryController.text.trim().isEmpty;

  @override
  void onClose() {
    companyNameController.dispose();
    companyEmailController.dispose();
    countryController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    occupationController.dispose();
    bioController.dispose();
    dateController.dispose();
    jobPositionController.dispose();
    skillsController.dispose();
    salaryMinController.dispose();
    salaryMaxController.dispose();
    super.onClose();
  }
}
