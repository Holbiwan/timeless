import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/services/employer_validation_service.dart';

class SignUpControllerM extends GetxController {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController  = TextEditingController();
  final TextEditingController emailController     = TextEditingController();
  final TextEditingController phoneController     = TextEditingController();
  final TextEditingController cityController      = TextEditingController();
  final TextEditingController stateController     = TextEditingController();
  final TextEditingController countryController   = TextEditingController();
  final TextEditingController passwordController  = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController siretController = TextEditingController();

  String firstError = "", lastError = "", emailError = "", phoneError = "",
      cityError = "", stateError = "", countryError = "", pwdError = "",
      companyNameError = "", siretError = "";

  bool isSiretLoading = false;
  bool siretValidated = false;
  Map<String, dynamic>? companyInfo;

  final RxBool loading = false.obs;
  bool rememberMe = false;
  bool show = true;

  bool _authCompleted = false; // succès verrouillé
  bool get isAuthCompleted => _authCompleted;

  final List<String> items1 = const ["France", "Belgium", "Spain", "Germany"];
  String? selectedItem;

  void onChanged(String _) {
    _validateAll();
    _updateAllFieldIds();
    update(['dark']);
    
    // Validation automatique SIRET
    if (siretController.text.length == 14 && !isSiretLoading) {
      _validateSiret();
    }
  }

  void chang() { show = !show; update(['showPassword']); }
  void onRememberMeChange(bool? v) { rememberMe = v ?? false; update(['remember_me']); }
  void changeDropdwon({String? val}) {
    selectedItem = val;
    if (val != null) countryController.text = val;
    _validateCountry();
    update(['dropdown','showCountry']);
  }

  Future<void> onSignUpBtnTap() async {
    if (_authCompleted) return;
    final valid = _validateAll();
    _updateAllFieldIds(); update(['dark']);
    if (!valid) { await _error('Incomplete Form','Please correct the fields in red and try again.'); return; }

    loading.value = true; update(['dark']);
    UserCredential cred;

    try {
      // 1. Créer le compte Firebase Auth
      cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Mettre à jour le profil utilisateur
      final displayName = '${firstnameController.text.trim()} ${lastnameController.text.trim()}'.trim();
      if (displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
        await cred.user?.reload();
      }

      // 3. Sauvegarder les données dans Firestore
      await _saveEmployerToFirestore(cred.user!);

      _authCompleted = true;
      _startErrorMuffler();
      loading.value = false; update(['dark']);

      // 4. Afficher popup de confirmation avec informations détaillées
      await _showSuccessDialog();
      await _safe(() async => Get.offAllNamed(AppRes.managerDashboardScreen));

    } on FirebaseAuthException catch (e) {
      loading.value = false; update(['dark']); 
      await _error('Account Creation Error', _mapAuthError(e)); 
      return;
    } catch (e) {
      loading.value = false; update(['dark']); 
      await _error('Error','An unexpected error occurred: $e'); 
      return;
    }
  }

  Future<void> SignUpWithGoogle() => signUpWithGoogle();
  Future<void> signUpWithGoogle() async {
    if (_authCompleted) return;
    loading.value = true; update(['dark']);
    UserCredential userCred;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) { loading.value = false; update(['dark']); await _error('Cancelled','Google sign-in cancelled by user.'); return; }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      userCred = await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) { loading.value = false; update(['dark']); await _error('Error', _mapAuthError(e)); return; }
    catch (e) { loading.value = false; update(['dark']); await _error('Error','An unexpected error occurred: $e'); return; }

    _authCompleted = true;
    _startErrorMuffler(); // 
    loading.value = false; update(['dark']);

    await _success('Success','Welcome ${userCred.user?.email ?? ''}');
    await _safe(() async => Get.offAllNamed(AppRes.managerDashboardScreen));
  }

  // --- SECTION: Validation SIRET/APE ---
  
  Future<void> _validateSiret() async {
    final siret = siretController.text.trim().replaceAll(' ', '');
    if (siret.length != 14) {
      siretError = "Le SIRET doit contenir 14 chiffres";
      siretValidated = false;
      companyInfo = null;
      update(['showSiret', 'showAPE']);
      return;
    }

    isSiretLoading = true;
    siretError = "";
    update(['showSiret']);

    try {
      // Utiliser le nouveau service de validation
      companyInfo = await EmployerValidationService.validateSiret(siret);
      
      if (companyInfo != null) {
        // Remplir automatiquement le nom de l'entreprise si pas déjà fait
        if (companyNameController.text.isEmpty && companyInfo!['denomination'] != null) {
          companyNameController.text = companyInfo!['denomination'];
        }
        
        siretValidated = true;
        siretError = "";
        
        if (kDebugMode) {
          print('✅ SIRET validé: ${companyInfo!['denomination']} - ${companyInfo!['activitePrincipaleLibelle']}');
        }
      }
    } catch (e) {
      siretError = e.toString().replaceFirst('Exception: ', '');
      siretValidated = false;
      companyInfo = null;
      
      if (kDebugMode) {
        print('❌ Erreur validation SIRET: $e');
      }
    }

    isSiretLoading = false;
    update(['showSiret', 'showAPE', 'showCompanyName']);
  }

  // --- SECTION: Firestore Integration ---
  
  Future<void> _saveEmployerToFirestore(User user) async {
    try {
      final employerData = {
        'uid': user.uid,
        'email': user.email,
        'firstName': firstnameController.text.trim(),
        'lastName': lastnameController.text.trim(),
        'displayName': user.displayName,
        'phone': phoneController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'country': countryController.text.trim(),
        'companyName': companyNameController.text.trim(),
        'siretCode': siretController.text.trim().replaceAll(' ', ''),
        'apeCode': companyInfo?['activitePrincipaleUniteLegale'] ?? '',
        'companyInfo': companyInfo,
        'accountType': 'employer',
        'isVerified': true, // SIRET validé
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'rememberMe': rememberMe,
      };

      // Sauvegarder dans la collection employers
      await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid)
          .set(employerData);

      if (kDebugMode) {
        print('✅ Données employeur sauvegardées dans Firestore');
        print('📄 Document ID: ${user.uid}');
        print('🏢 Entreprise: ${companyNameController.text.trim()}');
        print('🔍 SIRET: ${siretController.text.trim()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur sauvegarde Firestore: $e');
      }
      throw Exception('Erreur lors de la sauvegarde des données: $e');
    }
  }

  Future<void> _showSuccessDialog() async {
    _clearSnackbars();
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.check_circle, color: Colors.green[700], size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '🎉 Account created successfully!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📧 Email: ${emailController.text.trim()}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🏢 Company: ${companyNameController.text.trim()}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🔍 SIRET: ${siretController.text.trim()}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    if (companyInfo != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '📋 Code APE: ${companyInfo!['activitePrincipaleUniteLegale']}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🏭 Secteur: ${companyInfo!['activitePrincipaleLibelle']}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Your information has been saved and your company has been verified.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You will be redirected to your employer dashboard.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Continuer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      ),
      barrierDismissible: false,
    );
  }

  // --- SECTION: Validation ---
  bool _validateAll() {
    _validateFirst(); _validateLast(); _validateEmail(); _validatePhone();
    _validateCity();  _validateState(); _validateCountry(); _validatePwd();
    _validateCompanyName(); _validateSiretLocal();
    return firstError.isEmpty && lastError.isEmpty && emailError.isEmpty &&
           phoneError.isEmpty && cityError.isEmpty && stateError.isEmpty &&
           countryError.isEmpty && pwdError.isEmpty && companyNameError.isEmpty &&
           siretError.isEmpty;
  }
  void _validateFirst(){ firstError = firstnameController.text.trim().isEmpty ? 'First name required.' : ''; }
  void _validateLast() { lastError  = lastnameController.text.trim().isEmpty  ? 'Last name required.'     : ''; }
  void _validateEmail(){
    final v = emailController.text.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    emailError = v.isEmpty ? 'Email required.' : (!re.hasMatch(v) ? 'Invalid email.' : '');
  }
  void _validatePhone(){ final d = phoneController.text.replaceAll(RegExp(r'\D'), ''); phoneError = d.isEmpty ? 'Phone required.' : (d.length < 7 ? 'Number too short.' : ''); }
  void _validateCity()   { cityError    = cityController.text.trim().isEmpty    ? 'City required.'      : ''; }
  void _validateState()  { stateError   = stateController.text.trim().isEmpty   ? 'State/Region required.' : ''; }
  void _validateCountry(){ countryError = countryController.text.trim().isEmpty ? 'Country required.'        : ''; }
  void _validatePwd(){ final v = passwordController.text; pwdError = v.isEmpty ? 'Password required.' : (v.length < 6 ? '6 characters minimum.' : ''); }
  void _validateCompanyName(){ companyNameError = companyNameController.text.trim().isEmpty ? 'Company name required.' : ''; }
  void _validateSiretLocal(){ 
    final siret = siretController.text.trim().replaceAll(' ', '');
    if (siret.isEmpty) {
      siretError = 'SIRET required.';
    } else if (siret.length != 14) {
      siretError = 'SIRET must contain 14 digits.';
    } else if (!siretValidated) {
      siretError = 'SIRET not validated.';
    } else {
      siretError = '';
    }
  }
  void _updateAllFieldIds(){ update(['showFirstname','showLastname','showEmail','showPhoneNumber','showPassword','showCity','showState','showCountry','showCompanyName','showSiret']); }

  // --- SECTION: 

  // Popups & garde-fous ---
  void _startErrorMuffler() {
    // Pendant 6 secondes, ferme tout snackbar parasite (les erreurs d'autres contrôleurs)
    int ticks = 0;
    Timer.periodic(const Duration(milliseconds: 200), (t) {
      Get.closeAllSnackbars();
      ticks++;
      if (ticks >= 30) t.cancel(); // ~6s
    });
  }

  Future<void> _success(String title, String message) async {
    _clearSnackbars();
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        backgroundColor: Colors.green[50],
        actions: [ TextButton(onPressed: () => Get.back(), child: const Text('OK')) ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _error(String title, String message) async {
    // Si succès déjà validé → on ignore toute erreur tardive
    if (_authCompleted) { if (kDebugMode) print('[IGNORED AFTER SUCCESS] $title: $message'); return; }
    _clearSnackbars();
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        backgroundColor: ColorRes.royalBlue.withOpacity(0.1),
        actions: [ TextButton(onPressed: () => Get.back(), child: const Text('OK')) ],
      ),
      barrierDismissible: false,
    );
  }

  void _clearSnackbars() {
    Get.closeAllSnackbars();
    final ctx = Get.context;
    if (ctx != null) { ScaffoldMessenger.of(ctx).clearSnackBars(); }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential': return 'An account already exists with this information (different sign-in method).';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'invalid-credential': return 'Invalid credentials.';
      case 'operation-not-allowed': return 'Sign-in method disabled in Firebase.';
      case 'user-disabled': return 'This account has been disabled.';
      case 'user-not-found': return 'No account found with these credentials.';
      case 'wrong-password': return 'Incorrect password.';
      case 'invalid-verification-code': return 'Invalid verification code.';
      case 'invalid-verification-id': return 'Invalid verification ID.';
      default: return 'Unknown error: ${e.code}';
    }
  }

  Future<void> _safe(Future<void> Function() fn) async { try { await fn(); } catch (e) { if (kDebugMode) print('[SAFE IGNORE] $e'); } }

  @override
  void onClose() {
    firstnameController.dispose(); lastnameController.dispose(); emailController.dispose();
    phoneController.dispose(); cityController.dispose(); stateController.dispose();
    countryController.dispose(); passwordController.dispose();
    companyNameController.dispose(); siretController.dispose();
    super.onClose();
  }
}
