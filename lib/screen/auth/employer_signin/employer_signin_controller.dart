import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/models/employer_model.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
// import 'package:timeless/screen/auth/employer_signin/employer_signup_screen.dart';

class EmployerSignInController extends GetxController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final companyNameController = TextEditingController();
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();
  final siretController = TextEditingController();
  final apeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    // Pré-remplir le pays avec France
    countryController.text = 'France';
    // Pré-remplir avec les données de test
    fillTestData();
  }

  // Variable pour choisir quelle société de test utiliser
  final RxInt selectedTestCompany = 0.obs; // 0 = Sainte Thérèse, 1 = X Digital

  // Méthode pour pré-remplir les données de test
  void fillTestData() {
    if (selectedTestCompany.value == 0) {
      // ETABLISSEMENT SAINTE THERESE
      companyNameController.text = 'ETABLISSEMENT SAINTE THERESE';
      addressController.text = '1 rue du test 75001 PARIS';
      postalCodeController.text = '75001';
      countryController.text = 'France';
      siretController.text = '12345678901234'; // SIRET fictif
      apeController.text = '8542Z'; // Code APE pour enseignement
      emailController.text = 'Classe.Sainte-Therese@outlook.com';
      passwordController.text = 'TestPassword123!';
      confirmPasswordController.text = 'TestPassword123!';
    } else {
      // X DIGITAL
      companyNameController.text = 'X DIGITAL';
      addressController.text = '42 Avenue des Champs-Élysées 75008 PARIS';
      postalCodeController.text = '75008';
      countryController.text = 'France';
      siretController.text = '98765432109876'; // SIRET fictif
      apeController.text = '6201Z'; // Code APE pour programmation informatique
      emailController.text = 'holbiwansabrina@gmail.com';
      passwordController.text = 'XDigital2024!';
      confirmPasswordController.text = 'XDigital2024!';
    }
  }

  // Méthode pour changer de société de test
  void switchTestCompany() {
    selectedTestCompany.value = selectedTestCompany.value == 0 ? 1 : 0;
    fillTestData();
  }

  @override
  void onClose() {
    companyNameController.dispose();
    addressController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    siretController.dispose();
    apeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Validation SIRET (basique)
  bool _isValidSiret(String siret) {
    return siret.length == 14 && RegExp(r'^\d+$').hasMatch(siret);
  }

  // Validation APE (basique)
  bool _isValidApe(String ape) {
    return ape.length == 5 && RegExp(r'^\d{4}[A-Z]$').hasMatch(ape.toUpperCase());
  }

  // Connexion employeur
  Future<void> signInEmployer() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // Vérifications des codes
      if (!_isValidSiret(siretController.text.trim())) {
        Get.snackbar(
          'Erreur',
          'Code SIRET invalide (14 chiffres requis)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (!_isValidApe(apeController.text.trim().toUpperCase())) {
        Get.snackbar(
          'Erreur',
          'Code APE invalide (format: 1234A)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Authentification Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Vérifier que c'est bien un employeur dans Firestore
        DocumentSnapshot employerDoc = await _firestore
            .collection('employers')
            .doc(userCredential.user!.uid)
            .get();

        if (!employerDoc.exists) {
          Get.snackbar(
            'Erreur',
            'Compte employeur non trouvé. Veuillez vous inscrire.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          await _auth.signOut();
          return;
        }

        // Récupérer les données employeur
        EmployerModel employer = EmployerModel.fromFirestore(employerDoc);

        // Vérifier les codes SIRET et APE
        if (employer.siretCode != siretController.text.trim() ||
            employer.apeCode.toUpperCase() != apeController.text.trim().toUpperCase()) {
          Get.snackbar(
            'Erreur',
            'Codes SIRET/APE incorrects pour ce compte',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          await _auth.signOut();
          return;
        }

        // Sauvegarder les préférences
        await PreferencesService.setUserType('employer');
        await PreferencesService.setString(PrefKeys.employerId, employer.id);
        await PreferencesService.setString(PrefKeys.companyName, employer.companyName);

        Get.snackbar(
          'Connexion réussie',
          'Bienvenue ${employer.companyName}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Redirection vers le dashboard employeur
        Get.offAllNamed('/employer-dashboard');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);
      Get.snackbar(
        'Erreur de connexion',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur inattendue s\'est produite: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Messages d'erreur Firebase en français
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-email':
        return 'Format d\'email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'network-request-failed':
        return 'Erreur de connexion réseau';
      default:
        return 'Erreur de connexion: $errorCode';
    }
  }

  // Création de compte employeur
  Future<void> createEmployerAccount() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // Vérifications des codes
      if (!_isValidSiret(siretController.text.trim())) {
        Get.snackbar(
          'Erreur',
          'Code SIRET invalide (14 chiffres requis)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Créer le compte Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Sauvegarder les données employeur dans Firestore
        final employerData = {
          'companyName': companyNameController.text.trim(),
          'address': addressController.text.trim(),
          'postalCode': postalCodeController.text.trim(),
          'country': countryController.text.trim(),
          'siretCode': siretController.text.trim(),
          'apeCode': apeController.text.trim(),
          'email': emailController.text.trim(),
          'userType': 'employer',
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('employers')
            .doc(userCredential.user!.uid)
            .set(employerData);

        Get.snackbar(
          '✅ Compte créé !',
          'Votre compte employeur a été créé avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Rediriger vers le dashboard employeur ou écran de bienvenue
        Get.offAllNamed('/employer-dashboard');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Cette adresse email est déjà utilisée';
          break;
        case 'weak-password':
          errorMessage = 'Le mot de passe est trop faible';
          break;
        case 'invalid-email':
          errorMessage = 'Adresse email invalide';
          break;
        default:
          errorMessage = 'Erreur lors de la création du compte: ${e.message}';
      }
      Get.snackbar(
        'Erreur',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur s\'est produite: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Redirection vers connexion employeur (pour plus tard)
  void goToEmployerSignIn() {
    // TODO: Créer un écran de connexion séparé si nécessaire
    Get.snackbar(
      'Info',
      'Fonctionnalité de connexion bientôt disponible',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Validation INSEE des codes (simulation - à connecter à une vraie API)
  Future<bool> validateInseeData(String siret, String ape) async {
    // TODO: Intégrer l'API INSEE pour vérification
    // Pour l'instant, validation de format uniquement
    await Future.delayed(const Duration(seconds: 1)); // Simulation API
    return _isValidSiret(siret) && _isValidApe(ape);
  }
}