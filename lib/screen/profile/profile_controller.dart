import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timeless/utils/app_theme.dart';

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
  }

  // Charger le profil depuis Firebase
  Future<void> loadProfileFromFirebase() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      
      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          
          // Charger toutes les données du profil
          fullName.value = data['fullName'] ?? '';
          email.value = data['email'] ?? '';
          phoneNumber.value = data['phoneNumber'] ?? '';
          dateOfBirth.value = data['dateOfBirth'] ?? '';
          city.value = data['city'] ?? '';
          country.value = data['country'] ?? '';
          occupation.value = data['occupation'] ?? '';
          jobPosition.value = data['jobPosition'] ?? '';
          experienceLevel.value = data['experience'] ?? '';
          bio.value = data['bio'] ?? '';
          profileImageUrl.value = data['photoURL'] ?? '';
          
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
          
          // Skills et salary depuis jobPreferences si disponible
          final jobPrefs = data['jobPreferences'] as Map<String, dynamic>?;
          if (jobPrefs != null) {
            skills.value = (jobPrefs['skills'] as List<dynamic>?)?.join(', ') ?? '';
            skillsController.text = skills.value;
            
            final salaryRange = jobPrefs['salaryRange'] as Map<String, dynamic>?;
            if (salaryRange != null) {
              salaryRangeMin.value = salaryRange['min']?.toString() ?? '';
              salaryRangeMax.value = salaryRange['max']?.toString() ?? '';
              salaryMinController.text = salaryRangeMin.value;
              salaryMaxController.text = salaryRangeMax.value;
            }
          }
          
          print('✅ Profil chargé depuis Firebase');
        } else {
          print('❌ Aucun document profil trouvé');
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
        message: "Votre profil a été sauvegardé avec succès !",
        isSuccess: true,
      );
      
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Impossible de sauvegarder le profil",
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
      
      'jobPreferences': {
        'skills': skillsController.text.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        'workType': ['remote', 'hybrid', 'onsite'],
        'contractType': ['fulltime'],
        'salaryRange': {
          'min': salaryMinController.text.trim().isNotEmpty ? int.tryParse(salaryMinController.text.trim()) : null,
          'max': salaryMaxController.text.trim().isNotEmpty ? int.tryParse(salaryMaxController.text.trim()) : null,
          'currency': 'EUR'
        }
      },
    };
    
    if (imageUrl != null) {
      profileData['photoURL'] = imageUrl;
    }
    
    await _firestore.collection('users').doc(user.uid).set(profileData, SetOptions(merge: true));
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

  // Méthode pour vider le profil Firebase
  Future<void> clearProfileData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        
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