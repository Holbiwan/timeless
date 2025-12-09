// lib/screen/manager_section/auth_manager/sign_up_new/sign_up_new_controller.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/color_res.dart';

class SignUpControllerM extends GetxController {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController  = TextEditingController();
  final TextEditingController emailController     = TextEditingController();
  final TextEditingController phoneController     = TextEditingController();
  final TextEditingController cityController      = TextEditingController();
  final TextEditingController stateController     = TextEditingController();
  final TextEditingController countryController   = TextEditingController();
  final TextEditingController passwordController  = TextEditingController();

  String firstError = "", lastError = "", emailError = "", phoneError = "",
      cityError = "", stateError = "", countryError = "", pwdError = "";

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
    if (!valid) { await _error('Formulaire incomplet','Merci de corriger les champs en rouge puis réessayer.'); return; }

    loading.value = true; update(['dark']);
    UserCredential cred;

    try {
      cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) { loading.value = false; update(['dark']); await _error('Erreur', _mapAuthError(e)); return; }
    catch (e) { loading.value = false; update(['dark']); await _error('Erreur','Une erreur inattendue s’est produite : $e'); return; }

    // Étapes non-critiques (jamais d’erreur bloquante)
    await _safe(() async {
      final dn = '${firstnameController.text.trim()} ${lastnameController.text.trim()}'.trim();
      if (dn.isNotEmpty) { await cred.user?.updateDisplayName(dn); await cred.user?.reload(); }
    });

    _authCompleted = true;
    _startErrorMuffler(); //  étouffe les snackbars parasites pendant 6s
    loading.value = false; update(['dark']);

    await _success('Succès','Compte créé pour ${cred.user?.email ?? 'votre compte'}.');
    await _safe(() async => Get.offAllNamed(AppRes.managerDashboardScreen));
  }

  Future<void> SignUpWithGoogle() => signUpWithGoogle();
  Future<void> signUpWithGoogle() async {
    if (_authCompleted) return;
    loading.value = true; update(['dark']);
    UserCredential userCred;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) { loading.value = false; update(['dark']); await _error('Annulé','Connexion Google annulée par l’utilisateur.'); return; }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      userCred = await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) { loading.value = false; update(['dark']); await _error('Erreur', _mapAuthError(e)); return; }
    catch (e) { loading.value = false; update(['dark']); await _error('Erreur','Une erreur inattendue s’est produite : $e'); return; }

    _authCompleted = true;
    _startErrorMuffler(); // 
    loading.value = false; update(['dark']);

    await _success('Succès','Bienvenue ${userCred.user?.email ?? ''}');
    await _safe(() async => Get.offAllNamed(AppRes.managerDashboardScreen));
  }

  // --- SECTION: 

  // Validation ---
  bool _validateAll() {
    _validateFirst(); _validateLast(); _validateEmail(); _validatePhone();
    _validateCity();  _validateState(); _validateCountry(); _validatePwd();
    return firstError.isEmpty && lastError.isEmpty && emailError.isEmpty &&
           phoneError.isEmpty && cityError.isEmpty && stateError.isEmpty &&
           countryError.isEmpty && pwdError.isEmpty;
  }
  void _validateFirst(){ firstError = firstnameController.text.trim().isEmpty ? 'Prénom requis.' : ''; }
  void _validateLast() { lastError  = lastnameController.text.trim().isEmpty  ? 'Nom requis.'     : ''; }
  void _validateEmail(){
    final v = emailController.text.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    emailError = v.isEmpty ? 'Email requis.' : (!re.hasMatch(v) ? 'Email invalide.' : '');
  }
  void _validatePhone(){ final d = phoneController.text.replaceAll(RegExp(r'\D'), ''); phoneError = d.isEmpty ? 'Téléphone requis.' : (d.length < 7 ? 'Numéro trop court.' : ''); }
  void _validateCity()   { cityError    = cityController.text.trim().isEmpty    ? 'Ville requise.'      : ''; }
  void _validateState()  { stateError   = stateController.text.trim().isEmpty   ? 'Région/État requis.' : ''; }
  void _validateCountry(){ countryError = countryController.text.trim().isEmpty ? 'Pays requis.'        : ''; }
  void _validatePwd(){ final v = passwordController.text; pwdError = v.isEmpty ? 'Mot de passe requis.' : (v.length < 6 ? '6 caractères minimum.' : ''); }
  void _updateAllFieldIds(){ update(['showFirstname','showLastname','showEmail','showPhoneNumber','showPassword','showCity','showState','showCountry']); }

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
      case 'account-exists-with-different-credential': return 'Un compte existe déjà avec ces informations (autre méthode de connexion).';
      case 'email-already-in-use': return 'Un compte existe déjà avec cet e-mail.';
      case 'invalid-credential': return 'Informations de connexion invalides.';
      case 'operation-not-allowed': return 'Méthode de connexion désactivée dans Firebase.';
      case 'user-disabled': return 'Ce compte a été désactivé.';
      case 'user-not-found': return 'Aucun compte trouvé avec ces informations.';
      case 'wrong-password': return 'Mot de passe incorrect.';
      case 'invalid-verification-code': return 'Code de vérification invalide.';
      case 'invalid-verification-id': return 'ID de vérification invalide.';
      default: return 'Erreur inconnue : ${e.code}';
    }
  }

  Future<void> _safe(Future<void> Function() fn) async { try { await fn(); } catch (e) { if (kDebugMode) print('[SAFE IGNORE] $e'); } }

  @override
  void onClose() {
    firstnameController.dispose(); lastnameController.dispose(); emailController.dispose();
    phoneController.dispose(); cityController.dispose(); stateController.dispose();
    countryController.dispose(); passwordController.dispose();
    super.onClose();
  }
}
