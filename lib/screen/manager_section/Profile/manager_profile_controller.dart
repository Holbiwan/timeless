import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/color_res.dart';

class ManagerProfileController extends GetxController {
  // --- Images ---
  final RxString fbImageUrl = ''.obs;   // URL distante
  File? image;                          // image locale (camera/galerie)
  final RxBool isLoading = false.obs;

  // --- Champs texte que certains écrans attendent ---
  final companyNameController = TextEditingController();
  final companyEmailController = TextEditingController();
  final countryController = TextEditingController();
  
  // --- Nouveaux champs pour le profil utilisateur complet ---
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final occupationController = TextEditingController();
  final bioController = TextEditingController();

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
    // Charger le profil depuis Firestore
    _loadProfileFromFirestore();
    // debugPrint('ManagerProfileController.init()');
  }

  Future<void> _loadProfileFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          
          // Charger les données du profil
          fullNameController.text = data['fullName'] ?? PrefService.getString(PrefKeys.fullName);
          emailController.text = data['email'] ?? PrefService.getString(PrefKeys.email);
          phoneController.text = data['phone'] ?? PrefService.getString(PrefKeys.phoneNumber);
          cityController.text = data['city'] ?? PrefService.getString(PrefKeys.city);
          countryController.text = data['country'] ?? PrefService.getString(PrefKeys.country);
          occupationController.text = data['occupation'] ?? PrefService.getString(PrefKeys.occupation);
          bioController.text = data['bio'] ?? '';
          
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
    fullNameController.text = PrefService.getString(PrefKeys.fullName).isNotEmpty 
        ? PrefService.getString(PrefKeys.fullName) 
        : 'John Doe';
    emailController.text = PrefService.getString(PrefKeys.email).isNotEmpty 
        ? PrefService.getString(PrefKeys.email) 
        : 'john.doe@example.com';
    phoneController.text = PrefService.getString(PrefKeys.phoneNumber).isNotEmpty 
        ? PrefService.getString(PrefKeys.phoneNumber) 
        : '+33 6 12 34 56 78';
    cityController.text = PrefService.getString(PrefKeys.city).isNotEmpty 
        ? PrefService.getString(PrefKeys.city) 
        : 'Paris';
    occupationController.text = PrefService.getString(PrefKeys.occupation).isNotEmpty 
        ? PrefService.getString(PrefKeys.occupation) 
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

  // --- Implémentations image picker ---
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
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
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
      
      Get.snackbar(
        'Succès',
        'Profil sauvegardé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder le profil: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
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
      'phone': phoneController.text.trim(),
      'city': cityController.text.trim(),
      'country': countryController.text.trim(),
      'occupation': occupationController.text.trim(),
      'bio': bioController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (imageUrl != null) {
      profileData['profileImageUrl'] = imageUrl;
    }
    
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .set(profileData, SetOptions(merge: true));
  }

  void _updateLocalPreferences() {
    PrefService.setValue(PrefKeys.fullName, fullNameController.text.trim());
    PrefService.setValue(PrefKeys.email, emailController.text.trim());
    PrefService.setValue(PrefKeys.phoneNumber, phoneController.text.trim());
    PrefService.setValue(PrefKeys.city, cityController.text.trim());
    PrefService.setValue(PrefKeys.country, countryController.text.trim());
    PrefService.setValue(PrefKeys.occupation, occupationController.text.trim());
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
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    occupationController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
