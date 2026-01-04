import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/services/job_service.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'dart:io';

class ApplicationController extends GetxController {
  final JobOfferModel job;

  ApplicationController(this.job);

  // Form key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final coverLetterController = TextEditingController();

  // Observable variables
  final selectedCvFile = Rx<File?>(null);
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    coverLetterController.dispose();
    super.onClose();
  }

  // Load user data from preferences
  void loadUserData() {
    try {
      firstNameController.text = PreferencesService.getString(PrefKeys.firstName);
      lastNameController.text = PreferencesService.getString(PrefKeys.lasttName); // Note: Uses existing typo in PrefKeys
      emailController.text = PreferencesService.getString(PrefKeys.email);
      phoneController.text = PreferencesService.getString(PrefKeys.phone);
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Pick CV file
  Future<void> pickCvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        
        // Check file size (max 5MB)
        if (file.lengthSync() > 5 * 1024 * 1024) {
          Get.snackbar(
            'Fichier trop volumineux',
            'Le CV ne doit pas dépasser 5 MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        selectedCvFile.value = file;
        
        Get.snackbar(
          'CV sélectionné',
          'Fichier ${result.files.single.name} sélectionné',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur de sélection',
        'Impossible de sélectionner le fichier: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Remove CV file
  void removeCvFile() {
    selectedCvFile.value = null;
    Get.snackbar(
      'CV supprimé',
      'Le fichier CV a été retiré',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Get application summary
  String get applicationSummary {
    String summary = '';
    
    if (firstNameController.text.isNotEmpty && lastNameController.text.isNotEmpty) {
      summary += '✓ Nom: ${firstNameController.text} ${lastNameController.text}';
    }
    
    if (emailController.text.isNotEmpty) {
      summary += summary.isNotEmpty ? ' • ' : '';
      summary += '✓ Email confirmé';
    }
    
    if (selectedCvFile.value != null) {
      summary += summary.isNotEmpty ? ' • ' : '';
      summary += '✓ CV joint';
    }
    
    if (coverLetterController.text.isNotEmpty) {
      summary += summary.isNotEmpty ? ' • ' : '';
      summary += '✓ Lettre de motivation';
    }

    return summary.isNotEmpty ? summary : 'Veuillez remplir les informations requises';
  }

  // Validate form
  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Formulaire incomplet',
        'Veuillez corriger les erreurs du formulaire',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedCvFile.value == null) {
      Get.snackbar(
        'CV requis',
        'Veuillez joindre votre CV pour postuler',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Submit application
  Future<void> submitApplication() async {
    if (!_validateForm()) return;

    isSubmitting.value = true;

    try {
      // Get candidate ID
      String candidateId = PreferencesService.getString(PrefKeys.userId);
      if (candidateId.isEmpty) {
        throw Exception('Utilisateur non connecté');
      }

      // Prepare candidate profile data
      Map<String, dynamic> candidateProfile = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      // Submit application
      await JobService.submitApplication(
        jobId: job.id,
        candidateId: candidateId,
        employerId: job.employerId,
        candidateName: '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        candidateEmail: emailController.text.trim(),
        candidatePhone: phoneController.text.trim().isNotEmpty 
            ? phoneController.text.trim() 
            : '',
        cvFile: selectedCvFile.value!,
        coverLetter: coverLetterController.text.trim().isNotEmpty 
            ? coverLetterController.text.trim() 
            : null,
        candidateProfile: candidateProfile,
      );

      // Save user data for future use
      await _saveUserData();

      // Show success message
      Get.snackbar(
        'Candidature envoyée !',
        'Votre candidature a été envoyée avec succès. Vous recevrez une confirmation par email.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // Return to previous screen
      Get.back();
      Get.back(); // Also close job detail screen

      // Navigate to applications list or profile
      // Get.toNamed('/my-applications');

    } catch (e) {
      Get.snackbar(
        'Erreur d\'envoi',
        'Impossible d\'envoyer votre candidature: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Save user data to preferences
  Future<void> _saveUserData() async {
    try {
      PreferencesService.setString(PrefKeys.firstName, firstNameController.text.trim());
      PreferencesService.setString(PrefKeys.lasttName, lastNameController.text.trim()); // Note: Uses existing typo in PrefKeys
      PreferencesService.setString(PrefKeys.email, emailController.text.trim());
      PreferencesService.setString(PrefKeys.phone, phoneController.text.trim());
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Check if required fields are filled
  bool get isFormValid {
    return firstNameController.text.isNotEmpty &&
           lastNameController.text.isNotEmpty &&
           emailController.text.isNotEmpty &&
           GetUtils.isEmail(emailController.text) &&
           selectedCvFile.value != null;
  }

  // Get estimated application time
  String get estimatedTime {
    if (!isFormValid) {
      return 'Complétez le formulaire pour estimer le temps'; // Direct literal string
    }
    
    int timeMinutes = 2; // Base time
    
    if (coverLetterController.text.isEmpty) {
      timeMinutes += 5; // If they need to write cover letter
    }

    return 'Temps estimé: $timeMinutes minutes'; // Direct literal string
  }

  // Auto-fill suggestion
  void suggestAutoFill() {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty || emailController.text.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('Remplissage automatique'),
          content: Text('Voulez-vous utiliser vos informations sauvegardées ?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Non'),
            ), // Changed from deprecated `primary`
            TextButton(
              onPressed: () {
                loadUserData();
                Get.back();
              },
              child: Text('Oui'),
            ),
          ],
        ),
      );
    }
  }
}