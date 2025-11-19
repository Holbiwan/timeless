import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCompletionController extends GetxController {
  // Loading state
  var loading = false.obs;

  // User info from Google
  var firstName = ''.obs;
  var lastName = ''.obs;
  var email = ''.obs;
  var userPhotoUrl = ''.obs;
  
  // Controllers for form fields
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final titleController = TextEditingController();
  final cityController = TextEditingController();
  final bioController = TextEditingController();
  
  // Selected values
  var selectedExperience = 'junior'.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    initializeWithGoogleData();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    titleController.dispose();
    cityController.dispose();
    bioController.dispose();
    super.onClose();
  }

  void initializeWithGoogleData() {
    final user = _auth.currentUser;
    if (user != null) {
      email.value = user.email ?? '';
      userPhotoUrl.value = user.photoURL ?? '';
      
      // Séparer le nom complet en prénom et nom
      final fullName = user.displayName ?? '';
      final nameParts = fullName.split(' ');
      
      if (nameParts.isNotEmpty) {
        firstName.value = nameParts.first;
        firstNameController.text = nameParts.first;
        
        if (nameParts.length > 1) {
          lastName.value = nameParts.skip(1).join(' ');
          lastNameController.text = nameParts.skip(1).join(' ');
        }
      }
    }
  }

  String getExperienceLabel(String value) {
    switch (value) {
      case 'internship':
        return 'Stage / Alternance';
      case 'junior':
        return 'Junior (0-2 ans)';
      case 'mid':
        return 'Confirmé (3-5 ans)';
      case 'senior':
        return 'Senior (5-10 ans)';
      case 'expert':
        return 'Expert (10+ ans)';
      default:
        return value;
    }
  }

  Future<void> saveProfileData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      final userData = {
        // Informations de base
        'uid': user.uid,
        'email': user.email,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'fullName': '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        'phoneNumber': phoneController.text.trim(),
        'photoURL': user.photoURL,
        
        // Informations professionnelles
        'title': titleController.text.trim(),
        'bio': bioController.text.trim(),
        'experience': selectedExperience.value,
        'city': cityController.text.trim(),
        
        // Métadonnées
        'provider': 'google',
        'profileCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        
        // Préférences par défaut
        'jobPreferences': {
          'categories': [],
          'workType': ['remote', 'hybrid', 'onsite'],
          'contractType': ['fulltime'],
          'salaryRange': {
            'min': null,
            'max': null,
            'currency': 'EUR'
          }
        },
        
        // Activité
        'savedJobs': [],
        'appliedJobs': [],
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'user',
      };

      // Sauvegarder dans la collection users
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      print('✅ Profil utilisateur sauvegardé avec succès');

    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du profil: $e');
      rethrow;
    }
  }

  Future<bool> isProfileCompleted() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['profileCompleted'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Erreur lors de la vérification du profil: $e');
      return false;
    }
  }

  // Validation methods
  bool isFormValid() {
    return firstNameController.text.trim().isNotEmpty &&
           lastNameController.text.trim().isNotEmpty;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    // Simple validation pour numéro de téléphone
    final phoneRegex = RegExp(r'^[\+]?[1-9][\d]{0,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }
}