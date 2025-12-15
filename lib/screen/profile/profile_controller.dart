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

class ProfileController extends GetxController {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading state
  final RxBool isLoading = false.obs;

  // Profile data - Observable pour reactivity
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString dateOfBirth = ''.obs;
  final RxString city = ''.obs;
  final RxString country = ''.obs;
  final RxString occupation = ''.obs;
  final RxString jobPosition = ''.obs;
  final RxString experienceLevel = ''.obs;
  final RxString bio = ''.obs;
  final RxString skills = ''.obs;
  final RxString salaryRangeMin = ''.obs;
  final RxString salaryRangeMax = ''.obs;
  final RxString profileImageUrl = ''.obs;

  // Controllers pour l'édition
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final occupationController = TextEditingController();
  final bioController = TextEditingController();
  final dateController = TextEditingController();
  final jobPositionController = TextEditingController();
  final skillsController = TextEditingController();
  final salaryMinController = TextEditingController();
  final salaryMaxController = TextEditingController();

  // Image management
  File? image;

  @override
  void onInit() {
    super.onInit();
    loadProfileFromFirebase();
    _setupRealTimeListeners();
  }
  
  // Configurer les listeners pour la mise à jour en temps réel
  void _setupRealTimeListeners() {
    // Listener pour le nom complet - mise à jour en temps réel de l'affichage
    fullNameController.addListener(() {
      fullName.value = fullNameController.text.trim();
    });
    
    // Listener pour l'email
    emailController.addListener(() {
      email.value = emailController.text.trim();
    });
    
    // Listener pour le téléphone
    phoneController.addListener(() {
      phoneNumber.value = phoneController.text.trim();
    });
    
    // Listener pour la ville
    cityController.addListener(() {
      city.value = cityController.text.trim();
    });
    
    // Listener pour le pays
    countryController.addListener(() {
      country.value = countryController.text.trim();
    });
    
    // Listener pour l'occupation
    occupationController.addListener(() {
      occupation.value = occupationController.text.trim();
    });
    
    // Listener pour la bio
    bioController.addListener(() {
      bio.value = bioController.text.trim();
    });
    
    // Listener pour le poste
    jobPositionController.addListener(() {
      jobPosition.value = jobPositionController.text.trim();
    });
    
    // Listener pour les compétences
    skillsController.addListener(() {
      skills.value = skillsController.text.trim();
    });
    
    // Listener pour les salaires
    salaryMinController.addListener(() {
      salaryRangeMin.value = salaryMinController.text.trim();
    });
    
    salaryMaxController.addListener(() {
      salaryRangeMax.value = salaryMaxController.text.trim();
    });
  }

  // Charger le profil depuis Firebase
  Future<void> loadProfileFromFirebase() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      
      if (user != null) {
        // Charger depuis la collection Auth/User/register (comme utilisé dans sign-in)
        final doc = await _firestore
            .collection('Auth')
            .doc('User')
            .collection('register')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          
          // Charger toutes les données du profil
          fullName.value = data['fullName'] ?? user.displayName ?? '';
          email.value = data['Email'] ?? user.email ?? '';
          phoneNumber.value = data['Phone'] ?? '';
          dateOfBirth.value = data['DateOfBirth'] ?? '';
          city.value = data['City'] ?? '';
          country.value = data['Country'] ?? '';
          occupation.value = data['Occupation'] ?? '';
          jobPosition.value = data['JobPosition'] ?? '';
          experienceLevel.value = data['ExperienceLevel'] ?? '';
          bio.value = data['Bio'] ?? '';
          profileImageUrl.value = data['photoURL'] ?? user.photoURL ?? '';
          skills.value = data['Skills'] ?? '';
          salaryRangeMin.value = data['SalaryRangeMin'] ?? '';
          salaryRangeMax.value = data['SalaryRangeMax'] ?? '';
          
          // Remplir aussi les contrôleurs pour l'édition
          fullNameController.text = fullName.value;
          emailController.text = email.value;
          phoneController.text = phoneNumber.value;
          cityController.text = city.value;
          countryController.text = country.value;
          occupationController.text = occupation.value;
          bioController.text = bio.value;
          dateController.text = dateOfBirth.value;
          jobPositionController.text = jobPosition.value;
          skillsController.text = skills.value;
          salaryMinController.text = salaryRangeMin.value;
          salaryMaxController.text = salaryRangeMax.value;
          
          print('✅ Profil chargé depuis Firebase');
        } else {
          // Si pas de document, utiliser les données de Firebase Auth
          fullName.value = user.displayName ?? '';
          email.value = user.email ?? '';
          profileImageUrl.value = user.photoURL ?? '';
          
          fullNameController.text = fullName.value;
          emailController.text = email.value;
          
          print('❓ Aucun document profil trouvé, utilisation des données Firebase Auth');
        }
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du profil: $e');
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Impossible de charger le profil",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Rafraîchir le profil
  Future<void> refreshProfile() async {
    await loadProfileFromFirebase();
  }

  // Getters pour compatibilité avec l'écran
  String get displayName => fullName.value.isNotEmpty ? fullName.value : 'Votre Nom';
  String get displayOccupation => occupation.value.isNotEmpty ? occupation.value : '';
  String get displayEmail => email.value;
  String get displayPhone => phoneNumber.value;
  String get displayCity => city.value;
  String get displayCountry => country.value;
  String get displayBio => bio.value;
  String get displaySkills => skills.value;
  String get displaySalaryMin => salaryRangeMin.value;
  String get displaySalaryMax => salaryRangeMax.value;
  String get displayExperience => experienceLevel.value;
  String get displayJobPosition => jobPosition.value;
  String get displayDateOfBirth => dateOfBirth.value;

  // Méthode pour obtenir les initiales
  String getInitials() {
    if (fullName.value.isEmpty) return 'U';
    
    final names = fullName.value.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  // Vérifier si une image de profil existe
  bool hasProfileImage() {
    return profileImageUrl.value.isNotEmpty;
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
          title: "Success",
          message: "Photo captured successfully",
          isSuccess: true,
        );
        // Automatically save the profile with the new photo
        await onTapSubmit();
      }
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Camera problem",
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
          title: "Success",
          message: "Photo selected successfully",
          isSuccess: true,
        );
        // Automatically save the profile with the new photo
        await onTapSubmit();
      }
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Gallery problem",
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
        // Clear the image after successful upload
        image = null;
        update(['image']);
      }
      
      // Save to Firebase
      await _saveToFirebase(imageUrl);
      
      // Update local values
      _updateLocalValues();
      
      AppTheme.showStandardSnackBar(
        title: "Profile Updated",
        message: "Your profile has been saved successfully!",
        isSuccess: true,
      );
      
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Unable to save profile",
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
      
      final String fileName = '${user.uid}_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
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
    
    final Map<String, dynamic> profileData = {
      'uid': user.uid,
      'Email': emailController.text.trim(),
      'fullName': fullNameController.text.trim(),
      'Phone': phoneController.text.trim(),
      'City': cityController.text.trim(),
      'Country': countryController.text.trim(),
      'Occupation': occupationController.text.trim(),
      'Bio': bioController.text.trim(),
      'DateOfBirth': dateController.text.trim(),
      'JobPosition': jobPositionController.text.trim(),
      'Skills': skillsController.text.trim(),
      'SalaryRangeMin': salaryMinController.text.trim(),
      'SalaryRangeMax': salaryMaxController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (imageUrl != null) {
      profileData['photoURL'] = imageUrl;
    }
    
    // Sauvegarder dans Auth/User/register (comme utilisé dans sign-in)
    await _firestore
        .collection('Auth')
        .doc('User')
        .collection('register')
        .doc(user.uid)
        .set(profileData, SetOptions(merge: true));
    
    // Mettre à jour Firebase Auth displayName et photoURL pour synchronisation
    await user.updateDisplayName(fullNameController.text.trim());
    if (imageUrl != null) {
      await user.updatePhotoURL(imageUrl);
    }
    await user.reload(); // Recharger les données utilisateur
    
    // Mettre à jour les préférences locales pour synchronisation avec le reste de l'app
    await _updateLocalPreferences();
  }

  void _updateLocalValues() {
    fullName.value = fullNameController.text.trim();
    email.value = emailController.text.trim();
    phoneNumber.value = phoneController.text.trim();
    city.value = cityController.text.trim();
    country.value = countryController.text.trim();
    occupation.value = occupationController.text.trim();
    bio.value = bioController.text.trim();
    dateOfBirth.value = dateController.text.trim();
    jobPosition.value = jobPositionController.text.trim();
    skills.value = skillsController.text.trim();
    salaryRangeMin.value = salaryMinController.text.trim();
    salaryRangeMax.value = salaryMaxController.text.trim();
  }
  
  // Mettre à jour les préférences locales pour synchronisation
  Future<void> _updateLocalPreferences() async {
    await PreferencesService.setValue(PrefKeys.fullName, fullNameController.text.trim());
    await PreferencesService.setValue(PrefKeys.email, emailController.text.trim());
    await PreferencesService.setValue(PrefKeys.phoneNumber, phoneController.text.trim());
    await PreferencesService.setValue(PrefKeys.city, cityController.text.trim());
    await PreferencesService.setValue(PrefKeys.country, countryController.text.trim());
    await PreferencesService.setValue(PrefKeys.occupation, occupationController.text.trim());
    await PreferencesService.setValue(PrefKeys.bio, bioController.text.trim());
    await PreferencesService.setValue(PrefKeys.dateOfBirth, dateController.text.trim());
    await PreferencesService.setValue(PrefKeys.jobPosition, jobPositionController.text.trim());
    await PreferencesService.setValue(PrefKeys.skills, skillsController.text.trim());
    await PreferencesService.setValue(PrefKeys.salaryMin, salaryMinController.text.trim());
    await PreferencesService.setValue(PrefKeys.salaryMax, salaryMaxController.text.trim());
    
    if (profileImageUrl.value.isNotEmpty) {
      await PreferencesService.setValue(PrefKeys.profileImageUrl, profileImageUrl.value);
    }
  }

  // Méthode pour vider le profil Firebase
  Future<void> clearProfileData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Supprimer de la collection Auth/User/register
        await _firestore
            .collection('Auth')
            .doc('User')
            .collection('register')
            .doc(user.uid)
            .delete();
        
        // Clear all values
        fullName.value = '';
        email.value = '';
        phoneNumber.value = '';
        dateOfBirth.value = '';
        city.value = '';
        country.value = '';
        occupation.value = '';
        jobPosition.value = '';
        experienceLevel.value = '';
        bio.value = '';
        skills.value = '';
        salaryRangeMin.value = '';
        salaryRangeMax.value = '';
        profileImageUrl.value = '';
        
        // Clear controllers
        fullNameController.clear();
        emailController.clear();
        phoneController.clear();
        cityController.clear();
        countryController.clear();
        occupationController.clear();
        bioController.clear();
        dateController.clear();
        jobPositionController.clear();
        skillsController.clear();
        salaryMinController.clear();
        salaryMaxController.clear();
        
        print('✅ Profil supprimé de Firebase');
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression du profil: $e');
      throw e;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    countryController.dispose();
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