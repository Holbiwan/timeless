// Employer profile controller
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
  // Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading flag
  final RxBool isLoading = false.obs;

  // Profile fields (reactive)
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

  // Text controllers
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

  // Selected image
  File? image;

  @override
  void onInit() {
    super.onInit();
    loadEmployerProfileFromFirebase();
    _setupRealTimeListeners();
  }

  // Sync text fields with reactive values
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

  // Load employer profile from Firebase
  Future<void> loadEmployerProfileFromFirebase() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        final doc = await _firestore
            .collection('Auth')
            .doc('Manager')
            .collection('register')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;

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

          // Fill form fields
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

          await _loadCompanyData(user.uid);
        } else {
          companyName.value = user.displayName ?? '';
          email.value = user.email ?? '';
          profileImageUrl.value = user.photoURL ?? '';

          companyNameController.text = companyName.value;
          emailController.text = email.value;
        }
      }
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Failed to load employer profile",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load extra company data
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
      }
    } catch (_) {}
  }

  // Refresh profile
  Future<void> refreshProfile() async {
    await loadEmployerProfileFromFirebase();
  }

  // Get company initials
  String getInitials() {
    if (companyName.value.isEmpty) return 'E';
    final words = companyName.value.split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  // Check profile image
  bool hasProfileImage() {
    return profileImageUrl.value.isNotEmpty;
  }

  // Validate SIRET and auto-fill company data
  Future<bool> validateSiretCode() async {
    if (siretCode.value.isEmpty) return false;

    try {
      final companyInfo =
          await EmployerValidationService.validateSiret(siretCode.value);

      if (companyInfo != null) {
        companyName.value =
            companyInfo['denomination'] ?? companyName.value;
        apeCode.value =
            companyInfo['activitePrincipaleUniteLegale'] ?? apeCode.value;
        sector.value = companyInfo['secteur'] ?? sector.value;
        address.value = companyInfo['adresse'] ?? address.value;

        companyNameController.text = companyName.value;
        apeController.text = apeCode.value;
        sectorController.text = sector.value;
        addressController.text = address.value;

        isVerified.value = true;

        AppTheme.showStandardSnackBar(
          title: "SIRET verified",
          message: "Company data updated automatically",
          isSuccess: true,
        );
        return true;
      }
      return false;
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Invalid SIRET",
        message: "SIRET validation failed",
        isError: true,
      );
      isVerified.value = false;
      return false;
    }
  }

  // Pick image from camera
  Future<void> onTapImage() async => await _pickFromCamera();

  // Pick image from gallery
  Future<void> onTapGallery1() async => await _pickFromGallery();

  // Save profile
  Future<void> onTapSubmit() async {
    try {
      isLoading.value = true;
      update(['save_button']);

      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadImageToFirebase();
        if (imageUrl != null) {
          profileImageUrl.value = imageUrl;
        }
      }

      await _saveToFirebase(imageUrl);
      _updateLocalValues();

      AppTheme.showStandardSnackBar(
        title: "Profile updated",
        message: "Employer profile saved successfully",
        isSuccess: true,
      );
    } catch (_) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Failed to save employer profile",
        isError: true,
      );
    } finally {
      isLoading.value = false;
      update(['save_button']);
    }
  }

  // Clear employer profile data
  Future<void> clearEmployerProfileData() async {
    try {
      // Clear reactive values
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

      // Clear text controllers
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

      // Clear selected image
      image = null;
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Failed to clear profile data",
        isError: true,
      );
    }
  }

  // Pick image from camera
  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        image = File(pickedFile.path);
        update(['image_picker']);
      }
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Failed to pick image from camera",
        isError: true,
      );
    }
  }

  // Pick image from gallery
  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        image = File(pickedFile.path);
        update(['image_picker']);
      }
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Failed to pick image from gallery",
        isError: true,
      );
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImageToFirebase() async {
    try {
      if (image == null) return null;
      
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final fileName = 'employer_profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('employer_profiles')
          .child(fileName);
      
      final uploadTask = storageRef.putFile(image!);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Failed to upload image",
        isError: true,
      );
      return null;
    }
  }

  // Save profile data to Firebase
  Future<void> _saveToFirebase(String? imageUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final profileData = {
        'companyName': companyName.value,
        'Email': email.value,
        'Phone': phoneNumber.value,
        'website': website.value,
        'location': location.value,
        'address': address.value,
        'postalCode': postalCode.value,
        'country': country.value,
        'contactPerson': contactPerson.value,
        'siretCode': siretCode.value,
        'apeCode': apeCode.value,
        'description': description.value,
        'sector': sector.value,
        'employeeCount': employeeCount.value,
        'isVerified': isVerified.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (imageUrl != null) {
        profileData['photoURL'] = imageUrl;
      }
      
      await _firestore
          .collection('Auth')
          .doc('Manager')
          .collection('register')
          .doc(user.uid)
          .update(profileData);
    } catch (e) {
      rethrow;
    }
  }

  // Update local values after save
  void _updateLocalValues() {
    // Save to local preferences
    PreferencesService.setString(
      PrefKeys.companyName,
      companyName.value,
    );
    PreferencesService.setString(
      PrefKeys.email,
      email.value,
    );
    PreferencesService.setString(
      PrefKeys.phone,
      phoneNumber.value,
    );
    
    // Update reactive values to ensure UI consistency
    update();
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
