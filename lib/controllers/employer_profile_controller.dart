import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/services/employer_validation_service.dart';

class EmployerProfileController extends GetxController {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading state
  final RxBool isLoading = false.obs;

  // Profile data - Observable pour reactivity
  final RxString companyName = ''.obs;
  final RxString email = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString website = ''.obs;
  final RxString location = ''.obs;
  final RxString address = ''.obs;
  final RxString postalCode = ''.obs;
  final RxString country = ''.obs;
  final RxString contactPerson = ''.obs;
  final RxString siretCode = ''.obs;
  final RxString apeCode = ''.obs;
  final RxString description = ''.obs;
  final RxString sector = ''.obs;
  final RxString employeeCount = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxBool isVerified = false.obs;

  // Controllers pour l'édition
  final companyNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();
  final locationController = TextEditingController();
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();
  final contactPersonController = TextEditingController();
  final siretController = TextEditingController();
  final apeController = TextEditingController();
  final descriptionController = TextEditingController();
  final sectorController = TextEditingController();
  final employeeCountController = TextEditingController();

  // Image management
  File? image;

  @override
  void onInit() {
    super.onInit();
    loadEmployerProfileFromFirebase();
    _setupRealTimeListeners();
  }
  
  // Configurer les listeners pour la mise à jour en temps réel
  void _setupRealTimeListeners() {
    companyNameController.addListener(() {
      companyName.value = companyNameController.text.trim();
    });
    
    emailController.addListener(() {
      email.value = emailController.text.trim();
    });
    
    phoneController.addListener(() {
      phoneNumber.value = phoneController.text.trim();
    });
    
    websiteController.addListener(() {
      website.value = websiteController.text.trim();
    });
    
    locationController.addListener(() {
      location.value = locationController.text.trim();
    });
    
    addressController.addListener(() {
      address.value = addressController.text.trim();
    });
    
    postalCodeController.addListener(() {
      postalCode.value = postalCodeController.text.trim();
    });
    
    countryController.addListener(() {
      country.value = countryController.text.trim();
    });
    
    contactPersonController.addListener(() {
      contactPerson.value = contactPersonController.text.trim();
    });
    
    siretController.addListener(() {
      siretCode.value = siretController.text.trim();
    });
    
    apeController.addListener(() {
      apeCode.value = apeController.text.trim();
    });
    
    descriptionController.addListener(() {
      description.value = descriptionController.text.trim();
    });
    
    sectorController.addListener(() {
      sector.value = sectorController.text.trim();
    });
    
    employeeCountController.addListener(() {
      employeeCount.value = employeeCountController.text.trim();
    });
  }

  // Charger le profil employeur depuis Firebase
  Future<void> loadEmployerProfileFromFirebase() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      
      if (user != null) {
        // Charger depuis la collection Auth/Manager/register
        final doc = await _firestore
            .collection('Auth')
            .doc('Manager')
            .collection('register')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          
          // Charger toutes les données du profil employeur
          companyName.value = data['companyName'] ?? '';
          email.value = data['Email'] ?? user.email ?? '';
          phoneNumber.value = data['Phone'] ?? '';
          website.value = data['website'] ?? '';
          location.value = data['location'] ?? '';
          address.value = data['address'] ?? '';
          postalCode.value = data['postalCode'] ?? '';
          country.value = data['country'] ?? '';
          contactPerson.value = data['contactPerson'] ?? '';
          siretCode.value = data['siretCode'] ?? '';
          apeCode.value = data['apeCode'] ?? '';
          description.value = data['description'] ?? '';
          sector.value = data['sector'] ?? '';
          employeeCount.value = data['employeeCount'] ?? '';
          profileImageUrl.value = data['photoURL'] ?? user.photoURL ?? '';
          isVerified.value = data['isVerified'] ?? false;
          
          // Remplir aussi les contrôleurs pour l'édition
          companyNameController.text = companyName.value;
          emailController.text = email.value;
          phoneController.text = phoneNumber.value;
          websiteController.text = website.value;
          locationController.text = location.value;
          addressController.text = address.value;
          postalCodeController.text = postalCode.value;
          countryController.text = country.value;
          contactPersonController.text = contactPerson.value;
          siretController.text = siretCode.value;
          apeController.text = apeCode.value;
          descriptionController.text = description.value;
          sectorController.text = sector.value;
          employeeCountController.text = employeeCount.value;
          
          // Charger aussi les données de l'entreprise si elles existent
          await _loadCompanyData(user.uid);
          
          print('✅ Profil employeur chargé depuis Firebase');
        } else {
          // Si pas de document, utiliser les données de Firebase Auth
          companyName.value = user.displayName ?? '';
          email.value = user.email ?? '';
          profileImageUrl.value = user.photoURL ?? '';
          
          companyNameController.text = companyName.value;
          emailController.text = email.value;
          
          print('❓ Aucun document profil employeur trouvé, utilisation des données Firebase Auth');
        }
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du profil employeur: $e');
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Impossible de charger le profil employeur",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les données spécifiques de l'entreprise
  Future<void> _loadCompanyData(String userId) async {
    try {
      final companyDocs = await _firestore
          .collection("Auth")
          .doc("Manager")
          .collection("register")
          .doc(userId)
          .collection("company")
          .get();

      if (companyDocs.docs.isNotEmpty) {
        final companyData = companyDocs.docs.first.data();
        
        // Mettre à jour les champs spécifiques de l'entreprise
        if (companyData['name'] != null && companyName.value.isEmpty) {
          companyName.value = companyData['name'];
          companyNameController.text = companyName.value;
        }
        
        if (companyData['website'] != null && website.value.isEmpty) {
          website.value = companyData['website'];
          websiteController.text = website.value;
        }
        
        if (companyData['location'] != null && location.value.isEmpty) {
          location.value = companyData['location'];
          locationController.text = location.value;
        }
        
        if (companyData['description'] != null && description.value.isEmpty) {
          description.value = companyData['description'];
          descriptionController.text = description.value;
        }
        
        print('✅ Données entreprise chargées depuis Firebase');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données entreprise: $e');
    }
  }

  // Rafraîchir le profil
  Future<void> refreshProfile() async {
    await loadEmployerProfileFromFirebase();
  }

  // Getters pour compatibilité avec l'écran
  String get displayCompanyName => companyName.value.isNotEmpty ? companyName.value : 'Votre Entreprise';
  String get displayEmail => email.value;
  String get displayPhone => phoneNumber.value;
  String get displayWebsite => website.value;
  String get displayLocation => location.value;
  String get displayAddress => address.value;
  String get displayPostalCode => postalCode.value;
  String get displayCountry => country.value;
  String get displayContactPerson => contactPerson.value;
  String get displaySiretCode => siretCode.value;
  String get displayApeCode => apeCode.value;
  String get displayDescription => description.value;
  String get displaySector => sector.value;
  String get displayEmployeeCount => employeeCount.value;

  // Méthode pour obtenir les initiales de l'entreprise
  String getInitials() {
    if (companyName.value.isEmpty) return 'E';
    
    final words = companyName.value.split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  // Vérifier si une image de profil existe
  bool hasProfileImage() {
    return profileImageUrl.value.isNotEmpty;
  }

  // Méthode pour valider le SIRET
  Future<bool> validateSiretCode() async {
    if (siretCode.value.isEmpty) return false;
    
    try {
      final companyInfo = await EmployerValidationService.validateSiret(siretCode.value);
      if (companyInfo != null) {
        // Mettre à jour automatiquement les informations de l'entreprise
        companyName.value = companyInfo['denomination'] ?? companyName.value;
        apeCode.value = companyInfo['activitePrincipaleUniteLegale'] ?? apeCode.value;
        sector.value = companyInfo['secteur'] ?? sector.value;
        address.value = companyInfo['adresse'] ?? address.value;
        
        // Mettre à jour les contrôleurs
        companyNameController.text = companyName.value;
        apeController.text = apeCode.value;
        sectorController.text = sector.value;
        addressController.text = address.value;
        
        isVerified.value = true;
        
        AppTheme.showStandardSnackBar(
          title: "SIRET validé",
          message: "Les informations de votre entreprise ont été mises à jour automatiquement",
          isSuccess: true,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "SIRET invalide",
        message: "Impossible de valider le SIRET: $e",
        isError: true,
      );
      isVerified.value = false;
      return false;
    }
  }

  // Méthode pour forcer la mise à jour de l'UI
  void forceUpdate() {
    update();
  }

  // Méthodes pour l'édition d'image
  Future<void> onTapImage() async => await _pickFromCamera();
  Future<void> onTapGallery1() async => await _pickFromGallery();

  Future<void> _pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        image = File(pickedFile.path);
        update(['image']);
        AppTheme.showStandardSnackBar(
          title: "Succès",
          message: "Photo capturée avec succès",
          isSuccess: true,
        );
      }
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Problème avec la caméra",
        isError: true,
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        image = File(pickedFile.path);
        update(['image']);
        AppTheme.showStandardSnackBar(
          title: "Succès",
          message: "Photo sélectionnée avec succès",
          isSuccess: true,
        );
      }
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Problème avec la galerie",
        isError: true,
      );
    }
  }

  // Méthode de sauvegarde
  Future<void> onTapSubmit() async {
    try {
      isLoading.value = true;
      update(['save_button']);
      
      // Upload image if needed
      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadImageToFirebase();
        if (imageUrl != null) {
          profileImageUrl.value = imageUrl;
        }
      }
      
      // Save to Firebase
      await _saveToFirebase(imageUrl);
      
      // Update local values
      _updateLocalValues();
      
      AppTheme.showStandardSnackBar(
        title: "Profil mis à jour",
        message: "Votre profil employeur a été sauvegardé avec succès !",
        isSuccess: true,
      );
      
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Impossible de sauvegarder le profil employeur",
        isError: true,
      );
    } finally {
      isLoading.value = false;
      update(['save_button']);
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (image == null) return null;
    
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final String fileName = '${user.uid}_employer_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('employer_profile_images')
          .child(fileName);
      
      final UploadTask uploadTask = ref.putFile(image!);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur upload image: $e');
    }
  }

  Future<void> _saveToFirebase(String? imageUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final Map<String, dynamic> employerData = {
      'uid': user.uid,
      'Email': emailController.text.trim(),
      'companyName': companyNameController.text.trim(),
      'Phone': phoneController.text.trim(),
      'website': websiteController.text.trim(),
      'location': locationController.text.trim(),
      'address': addressController.text.trim(),
      'postalCode': postalCodeController.text.trim(),
      'country': countryController.text.trim(),
      'contactPerson': contactPersonController.text.trim(),
      'siretCode': siretController.text.trim(),
      'apeCode': apeController.text.trim(),
      'description': descriptionController.text.trim(),
      'sector': sectorController.text.trim(),
      'employeeCount': employeeCountController.text.trim(),
      'isVerified': isVerified.value,
      'updatedAt': FieldValue.serverTimestamp(),
      'userType': 'employer',
    };
    
    if (imageUrl != null) {
      employerData['photoURL'] = imageUrl;
    }
    
    // Sauvegarder dans Auth/Manager/register
    await _firestore
        .collection('Auth')
        .doc('Manager')
        .collection('register')
        .doc(user.uid)
        .set(employerData, SetOptions(merge: true));
    
    // Sauvegarder aussi dans la sous-collection company pour compatibilité
    await _saveCompanyData(user.uid);
    
    // Mettre à jour Firebase Auth displayName et photoURL pour synchronisation
    await user.updateDisplayName(companyNameController.text.trim());
    if (imageUrl != null) {
      await user.updatePhotoURL(imageUrl);
    }
    await user.reload();
    
    // Mettre à jour les préférences locales
    await _updateLocalPreferences();
  }

  // Sauvegarder les données de l'entreprise dans la sous-collection
  Future<void> _saveCompanyData(String userId) async {
    final companyData = {
      'name': companyNameController.text.trim(),
      'website': websiteController.text.trim(),
      'location': locationController.text.trim(),
      'description': descriptionController.text.trim(),
      'UpdatedAt': FieldValue.serverTimestamp(),
    };

    final companyRef = _firestore
        .collection("Auth")
        .doc("Manager")
        .collection("register")
        .doc(userId)
        .collection("company");

    final existingDocs = await companyRef.get();
    
    if (existingDocs.docs.isNotEmpty) {
      await companyRef.doc(existingDocs.docs.first.id).update(companyData);
    } else {
      await companyRef.add({
        ...companyData,
        'CreatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _updateLocalValues() {
    companyName.value = companyNameController.text.trim();
    email.value = emailController.text.trim();
    phoneNumber.value = phoneController.text.trim();
    website.value = websiteController.text.trim();
    location.value = locationController.text.trim();
    address.value = addressController.text.trim();
    postalCode.value = postalCodeController.text.trim();
    country.value = countryController.text.trim();
    contactPerson.value = contactPersonController.text.trim();
    siretCode.value = siretController.text.trim();
    apeCode.value = apeController.text.trim();
    description.value = descriptionController.text.trim();
    sector.value = sectorController.text.trim();
    employeeCount.value = employeeCountController.text.trim();
  }
  
  // Mettre à jour les préférences locales
  Future<void> _updateLocalPreferences() async {
    await PreferencesService.setValue(PrefKeys.companyName, companyNameController.text.trim());
    await PreferencesService.setValue(PrefKeys.email, emailController.text.trim());
    await PreferencesService.setValue(PrefKeys.phoneNumber, phoneController.text.trim());
    await PreferencesService.setValue('website', websiteController.text.trim());
    await PreferencesService.setValue('location', locationController.text.trim());
    await PreferencesService.setValue('address', addressController.text.trim());
    await PreferencesService.setValue('postalCode', postalCodeController.text.trim());
    await PreferencesService.setValue('country', countryController.text.trim());
    await PreferencesService.setValue('contactPerson', contactPersonController.text.trim());
    await PreferencesService.setValue('siretCode', siretController.text.trim());
    await PreferencesService.setValue('apeCode', apeController.text.trim());
    await PreferencesService.setValue('description', descriptionController.text.trim());
    await PreferencesService.setValue('sector', sectorController.text.trim());
    await PreferencesService.setValue('employeeCount', employeeCountController.text.trim());
    
    if (profileImageUrl.value.isNotEmpty) {
      await PreferencesService.setValue('employerProfileImageUrl', profileImageUrl.value);
    }
  }

  // Méthode pour vider le profil Firebase
  Future<void> clearEmployerProfileData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Supprimer de la collection Auth/Manager/register
        await _firestore
            .collection('Auth')
            .doc('Manager')
            .collection('register')
            .doc(user.uid)
            .delete();
        
        // Clear all values
        companyName.value = '';
        email.value = '';
        phoneNumber.value = '';
        website.value = '';
        location.value = '';
        address.value = '';
        postalCode.value = '';
        country.value = '';
        contactPerson.value = '';
        siretCode.value = '';
        apeCode.value = '';
        description.value = '';
        sector.value = '';
        employeeCount.value = '';
        profileImageUrl.value = '';
        isVerified.value = false;
        
        // Clear controllers
        companyNameController.clear();
        emailController.clear();
        phoneController.clear();
        websiteController.clear();
        locationController.clear();
        addressController.clear();
        postalCodeController.clear();
        countryController.clear();
        contactPersonController.clear();
        siretController.clear();
        apeController.clear();
        descriptionController.clear();
        sectorController.clear();
        employeeCountController.clear();
        
        print('✅ Profil employeur supprimé de Firebase');
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression du profil employeur: $e');
      throw e;
    }
  }

  @override
  void onClose() {
    companyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    locationController.dispose();
    addressController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    contactPersonController.dispose();
    siretController.dispose();
    apeController.dispose();
    descriptionController.dispose();
    sectorController.dispose();
    employeeCountController.dispose();
    super.onClose();
  }
}