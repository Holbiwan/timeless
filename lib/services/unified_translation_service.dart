// lib/services/unified_translation_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/google_translation_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_theme.dart';

/// Unified Translation Service
/// This service replaces TranslationService, EasyTranslationService, and ComprehensiveTranslationService
/// It combines static translations, Easy Localization support, and dynamic Google Translate
class UnifiedTranslationService extends GetxController {
  static UnifiedTranslationService get instance => Get.find();

  // Current language observable
  var currentLanguage = 'en'.obs;
  
  // Dynamic translation features
  var isAutoTranslateEnabled = false.obs;
  var isTranslating = false.obs;

  // Supported languages with their codes and names
  final Map<String, String> supportedLanguages = {
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'ar': 'العربية',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
  };

  // Emoji flags for each language
  final Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'fr': '🇫🇷', 
    'es': '🇪🇸',
    'ar': '🇸🇦',
    'de': '🇩🇪',
    'it': '🇮🇹',
    'pt': '🇵🇹',
    'zh': '🇨🇳',
    'ja': '🇯🇵',
    'ko': '🇰🇷',
  };

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  // Load user preferences
  void _loadPreferences() {
    try {
      // Temporarily force language to English for presentation
      currentLanguage.value = 'en';
      _setLocaleWithoutNotification('en');
      // Original logic commented out for easy revert:
      // final savedLang = PreferencesService.getString(PrefKeys.currentLanguage);
      // if (savedLang.isNotEmpty && supportedLanguages.containsKey(savedLang)) {
      //   currentLanguage.value = savedLang;
      //   _setLocaleWithoutNotification(savedLang);
      // } else {
      //   final systemLocale = Get.deviceLocale?.languageCode ?? 'en';
      //   currentLanguage.value = supportedLanguages.containsKey(systemLocale) ? systemLocale : 'en';
      //   _setLocaleWithoutNotification(currentLanguage.value);
      // }

      // Load auto-translate preference
      isAutoTranslateEnabled.value = PreferencesService.getBool('auto_translate_enabled');
    } catch (e) {
      if (kDebugMode) print('Error loading translation preferences: $e');
      // Default values
      currentLanguage.value = 'en';
      isAutoTranslateEnabled.value = false;
    }
  }

  // Set locale without showing notification (for initialization)
  void _setLocaleWithoutNotification(String langCode) {
    if (supportedLanguages.containsKey(langCode)) {
      try {
        Get.context?.setLocale(Locale(langCode));
      } catch (e) {
        if (kDebugMode) print('Error setting locale: $e');
      }
    }
  }

  // Change app language with notification
  void setLanguage(String langCode) {
    if (!supportedLanguages.containsKey(langCode)) return;

    final oldLanguage = currentLanguage.value;
    currentLanguage.value = langCode;

    try {
      // Set locale for Easy Localization
      Get.context?.setLocale(Locale(langCode));

      // Save preference
      PreferencesService.setValue(PrefKeys.currentLanguage, langCode);

      // Show success notification
      AppTheme.showStandardSnackBar(
        title: getText('language_switched'),
        message: '${getText('switched_to')} ${supportedLanguages[langCode]}',
        isSuccess: true,
      );
    } catch (e) {
      if (kDebugMode) print('Error setting language: $e');
      // Rollback on error
      currentLanguage.value = oldLanguage;
    }
  }

  // Toggle auto-translate feature
  void toggleAutoTranslate() {
    isAutoTranslateEnabled.value = !isAutoTranslateEnabled.value;
    
    try {
      PreferencesService.setValue('auto_translate_enabled', isAutoTranslateEnabled.value);
      
      AppTheme.showStandardSnackBar(
        title: "Auto Translation",
        message: isAutoTranslateEnabled.value ? "Enabled" : "Disabled",
        isSuccess: true,
      );
    } catch (e) {
      if (kDebugMode) print('Error saving auto-translate preference: $e');
    }
  }

  // Get text from static translations
  String getText(String key) {
    return staticTranslations[currentLanguage.value]?[key] ?? key;
  }

  // Translate dynamic text using Google Translate
  Future<String> translateDynamicText(String text, {String? targetLang}) async {
    if (text.trim().isEmpty) return text;

    final target = targetLang ?? currentLanguage.value;
    
    // Skip translation if already in target language
    if (target == 'en' && await _isEnglishText(text)) {
      return text;
    }

    try {
      isTranslating.value = true;
      
      final translatedText = await GoogleUnifiedTranslationService.translateText(
        text: text,
        targetLanguage: target,
      );

      return translatedText ?? text;
    } catch (e) {
      if (kDebugMode) print('Translation error: $e');
      _showTranslationError('Translation failed. Check your internet connection.');
      return text;
    } finally {
      isTranslating.value = false;
    }
  }

  // Auto-translate text if enabled
  Future<String> autoTranslateIfEnabled(String text, {String? targetLang}) async {
    if (isAutoTranslateEnabled.value) {
      return await translateDynamicText(text, targetLang: targetLang);
    }
    return text;
  }

  // Detect language of text
  Future<String?> detectTextLanguage(String text) async {
    if (text.trim().isEmpty) return null;

    try {
      return await GoogleUnifiedTranslationService.detectLanguage(text);
    } catch (e) {
      if (kDebugMode) print('Language detection error: $e');
      return null;
    }
  }

  // Check if translation service is available
  Future<bool> isTranslationServiceAvailable() async {
    try {
      final testResult = await GoogleUnifiedTranslationService.translateText(
        text: 'test',
        targetLanguage: 'fr',
      );
      return testResult != null;
    } catch (e) {
      if (kDebugMode) print('Translation service unavailable: $e');
      return false;
    }
  }

  // Show translation error to user
  void _showTranslationError(String message) {
    try {
      AppTheme.showStandardSnackBar(
        title: getText('error'),
        message: message,
        isError: true,
      );
    } catch (e) {
      if (kDebugMode) print('Cannot show error: $e');
    }
  }

  // Simple English text detection heuristic
  Future<bool> _isEnglishText(String text) async {
    final commonEnglishWords = ['the', 'and', 'is', 'in', 'to', 'of', 'a', 'that', 'it', 'with'];
    final cleanText = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ');
    final words = cleanText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    
    if (words.isEmpty) return false;
    
    final englishWordsFound = words.where((word) => commonEnglishWords.contains(word)).length;
    return englishWordsFound > words.length * 0.2;
  }

  // Reset to default settings
  void resetToDefaults() {
    try {
      currentLanguage.value = 'en';
      isAutoTranslateEnabled.value = false;
      isTranslating.value = false;

      PreferencesService.setValue(PrefKeys.currentLanguage, 'en');
      PreferencesService.setValue('auto_translate_enabled', false);
      
      Get.context?.setLocale(const Locale('en'));

      AppTheme.showStandardSnackBar(
        title: "Settings Reset",
        message: "Translation settings reset to defaults",
        isSuccess: true,
      );
    } catch (e) {
      if (kDebugMode) print('Reset error: $e');
    }
  }

  // Convenience methods for quick language switching
  void setEnglish() => setLanguage('en');
  void setFrench() => setLanguage('fr');
  void setSpanish() => setLanguage('es');
  void setArabic() => setLanguage('ar');
  void setGerman() => setLanguage('de');
  void setItalian() => setLanguage('it');
  void setPortuguese() => setLanguage('pt');
  void setChinese() => setLanguage('zh');
  void setJapanese() => setLanguage('ja');
  void setKorean() => setLanguage('ko');

  // Toggle between main languages (EN -> FR -> ES -> EN)
  void toggleLanguage() {
    switch (currentLanguage.value) {
      case 'en':
        setFrench();
        break;
      case 'fr':
        setSpanish();
        break;
      case 'es':
        setEnglish();
        break;
      default:
        setEnglish();
    }
  }

  // Getters for UI
  String get currentLanguageName => supportedLanguages[currentLanguage.value] ?? 'English';
  String get currentFlag => languageFlags[currentLanguage.value] ?? '🇺🇸';
  List<String> get availableLanguageCodes => supportedLanguages.keys.toList();
  String getLanguageName(String code) => supportedLanguages[code] ?? 'Unknown';
  String getLanguageFlag(String code) => languageFlags[code] ?? '🏳️';

  // Static translations (merged from the original UnifiedTranslationService)
  static const Map<String, Map<String, String>> staticTranslations = {
    'en': {
      // Navigation & General
      'dashboard': 'Dashboard',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'back': 'Back',
      'next': 'Next',
      'continue': 'Continue',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'create': 'Create',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'cancel': 'Cancel',
      'close': 'Close',

      // Language switching
      'language_switched': 'Language Changed',
      'switched_to': 'Switched to',
      'switched_to_french': 'Switched to French',
      'switched_to_english': 'Switched to English',

      // Smart Matching
      'smart_matching': 'Smart Job Matching',
      'intelligent_matching_system': 'Intelligent Matching System',
      'algorithm_description': 'Our algorithm analyzes your profile and skills to find the best matching jobs',
      'find_matches': 'Find My Matches',
      'analyzing_profile': 'Analyzing Profile...',
      'processing_skills': 'Processing skills and preferences',
      'calculated_matches': 'Your Calculated Matches',
      'apply': 'Apply',
      'saved': 'Saved',
      'bookmark_added': 'Job added to bookmarks',
      'match_percentage': '% Match',
      'why_great_match': 'Why this is a great match:',
      'skills_match': 'skills match',
      'location_match': 'Location',
      'contract_type': 'Contract type',
      'category': 'Category',

      // Auth Screens
      'first_name': 'First name',
      'last_name': 'Last name',
      'password': 'Password',
      'password_hint': 'Password (min 8 chars)',
      'create_user_email': 'Create User + Email',
      'user_created_success': '✅ USER CREATED SUCCESSFULLY!',
      'create_account': 'Create Your Account',
      'already_have_account': 'Already have an account?',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'create_account_as_pro': 'Create account as',

      // Profile
      'my_profile': 'My Profile',
      'personal_information': 'Personal Information',
      'professional_information': 'Professional Information',
      'full_name': 'Full Name',
      'email': 'Email',
      'phone': 'Phone',
      'date_of_birth': 'Date of Birth',
      'city': 'City',
      'country': 'Country',
      'current_occupation': 'Current Occupation',
      'job_position': 'Job Position',
      'bio': 'Bio',
      'edit_profile': 'Edit Profile',
      // 'job_preferences': 'Job Preferences', // Removed

      // Job Related
      'position': 'Position',
      'company': 'Company',
      'salary': 'Salary',
      'requirements': 'Requirements',
      'description': 'Description',
      'apply_now': 'Apply Now',
      'job_offers': 'Job Offers',
      'job recommendation': 'Job Recommendation',
      'no_results_found_filters': 'No results found with these filters',
      'no_job_offers_available': 'No job offers available',
      'reset_filters': 'Reset Filters',
      'loading_jobs': 'Loading jobs...',
      'not_specified': 'Not specified',
      'company_name_default': 'Company',
      'description_not_available': 'Description not available',
      'apply_for': 'Apply for',
      'this_position': 'this position',
      'you_are_applying_for': 'You are applying for the position of',
      'at': 'at',
      'this_company': 'this company',
      'error_loading_user_info': 'Error loading user info',
      'file_selection_error': 'Failed to select file',
      'has_been_sent_successfully': 'has been sent successfully!',
      'confirmation_email_sent_to': 'A confirmation email has been sent to',
      'perfect': 'Perfect!',
      'application_send_error': 'Failed to send application',
      'position_default': 'Position',
      'position_not_specified': 'Position not specified',
      'company_not_specified': 'Company not specified',
      'location_not_specified': 'Location not specified',
      'salary_not_specified': 'Salary not specified',
      'personal_information_title': 'Personal Information',
      'full_name_label': 'Full Name *',
      'name_required': 'Name is required',
      'email_label': 'Email *',
      'email_required_validation': 'Email is required',
      'invalid_email_validation': 'Invalid email',
      'phone_number_label': 'Phone Number *',
      'phone_number_required': 'Phone number is required',
      'curriculum_vitae_title': 'Curriculum Vitae',
      'cv_selected_message': 'CV selected',
      'select_your_cv_label': 'Select your CV *',
      'accepted_formats_label': 'PDF, DOC, DOCX accepted',
      'cover_letter_title': 'Cover Letter (optional)',
      'cover_letter_hint': 'Explain why you are the ideal candidate for this position...',
      'send_my_application': 'Send my application',

      // Error Messages
      'connection_error': 'Connection error',
      'please_try_again': 'Please try again',
      'invalid_email': 'Invalid email',
      'password_too_short': 'Password too short',
      'please_enter_password': 'Please enter password',

      // Terms & Accessibility
      'terms_agreement': 'By creating an account, you are agreeing to our',
      'terms_of_service': 'Terms of Service',
      'accessibility': 'Accessibility',
      'help': 'Help',
      'welcome': 'Welcome',
      'app_tagline': 'Bridging the gap with timeless talent',

      // Theme & Appearance
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'theme_switched': 'Theme switched',
      'theme_switched_dark': 'Switched to dark mode',
      'theme_switched_light': 'Switched to light mode',

      // Application process
      'apply_screen_title': 'Apply',
      'upload_cv': 'Upload your CV *',
      'click_select_cv': 'Click to select your CV',
      'accepted_formats': 'Accepted formats: PDF, DOC, DOCX',
      'cv_selected': '✅ CV Selected',
      'contact_info': 'Contact Information',
      'cover_letter': 'Cover Letter (optional)',
      'cover_letter_placeholder': 'Explain why you are interested in this position...',
      'submit_application': 'Submit my application',
      'application_sent': 'Application Sent!',
      'application_success': 'Your application for {title} has been successfully submitted',
      'cv_required': '⚠️ CV Required',
      'please_select_cv': 'Please select your CV',
      'email_required': '⚠️ Email Required',
      'application_sent_message': 'Your application has been sent successfully',
      'confirmation_email_info': 'A confirmation email has been sent to your inbox',
      'apply_button': 'Apply',
      'cancel_button': 'Cancel',
      'confirm_application': 'Confirm Application',
      'confirm_application_message': 'Are you sure you want to apply for this position?',
    },
    'fr': {
      // Navigation & Général
      'dashboard': 'Tableau de Bord',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'logout': 'Déconnexion',
      'back': 'Retour',
      'next': 'Suivant',
      'continue': 'Continuer',
      'save': 'Sauvegarder',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'create': 'Créer',
      'search': 'Rechercher',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'cancel': 'Annuler',
      'close': 'Fermer',

      // Changement de langue
      'language_switched': 'Langue modifiée',
      'switched_to': 'Basculé vers',
      'switched_to_french': 'Basculé vers le français',
      'switched_to_english': 'Basculé vers l\'anglais',

      // Smart Matching
      'smart_matching': 'Smart Job Matching',
      'intelligent_matching_system': 'Système de Matching Intelligent',
      'algorithm_description': 'Notre algorithme analyse votre profil et compétences pour trouver les meilleurs emplois correspondants',
      'find_matches': 'Trouver mes correspondances',
      'analyzing_profile': 'Analyse en cours...',
      'processing_skills': 'Traitement des compétences et préférences',
      'calculated_matches': 'Vos Correspondances Calculées',
      'apply': 'Postuler',
      'saved': 'Sauvegardé',
      'bookmark_added': 'Offre ajoutée aux favoris',
      'match_percentage': '% de correspondance',
      'why_great_match': 'Pourquoi c\'est une excellente correspondance:',
      'skills_match': 'compétences correspondent',
      'location_match': 'Localisation',
      'contract_type': 'Type de contrat',
      'category': 'Catégorie',

      // Écrans d'Auth
      'first_name': 'Prénom',
      'last_name': 'Nom',
      'password': 'Mot de passe',
      'password_hint': 'Mot de passe (min 8 car.)',
      'create_user_email': 'Créer Utilisateur + Email',
      'user_created_success': '✅ UTILISATEUR CRÉÉ AVEC SUCCÈS!',
      'create_account': 'Créer Votre Compte',
      'already_have_account': 'Vous avez déjà un compte ?',
      'sign_in': 'Se Connecter',
      'sign_up': 'Sign in',
      'create_account_as_pro': 'Créer un compte en tant que',

      // Profil
      'my_profile': 'Mon Profil',
      'personal_information': 'Informations Personnelles',
      'professional_information': 'Informations Professionnelles',
      'full_name': 'Nom Complet',
      'email': 'Email',
      'phone': 'Téléphone',
      'date_of_birth': 'Date de Naissance',
      'city': 'Ville',
      'country': 'Pays',
      'current_occupation': 'Profession Actuelle',
      'job_position': 'Poste',
      'bio': 'Biographie',
      'edit_profile': 'Modifier le Profil',
      // 'job_preferences': 'Préférences d\'Emploi', // Removed

      // Emplois
      'position': 'Poste',
      'company': 'Entreprise',
      'salary': 'Salaire',
      'requirements': 'Exigences',
      'description': 'Description',
      'apply_now': 'Postuler Maintenant',
      'job_offers': 'Offres d\'Emploi',
      'job recommendation': 'Recommandation d\'emploi',

      // Messages d'erreur
      'connection_error': 'Erreur de connexion',
      'please_try_again': 'Veuillez réessayer',
      'invalid_email': 'Email invalide',
      'password_too_short': 'Mot de passe trop court',
      'please_enter_password': 'Veuillez saisir un mot de passe',

      // Termes & Accessibilité
      'terms_agreement': 'En créant un compte, vous acceptez nos',
      'terms_of_service': 'Conditions d\'Utilisation',
      'accessibility': 'Accessibilité',
      'help': 'Aide',
      'welcome': 'Bienvenue',
      'app_tagline': 'Combler le fossé avec un talent intemporel',

      // Thème & Apparence
      'appearance': 'Apparence',
      'dark_mode': 'Mode Sombre',
      'light_mode': 'Mode Clair',
      'language': 'Langue',
      'theme_switched': 'Thème modifié',
      'theme_switched_dark': 'Basculé vers le mode sombre',
      'theme_switched_light': 'Basculé vers le mode clair',

      // Processus de candidature
      'apply_screen_title': 'Postuler',
      'upload_cv': 'Télécharger votre CV *',
      'click_select_cv': 'Cliquez pour sélectionner votre CV',
      'accepted_formats': 'Formats acceptés: PDF, DOC, DOCX',
      'cv_selected': '✅ CV Sélectionné',
      'contact_info': 'Informations de contact',
      'cover_letter': 'Lettre de motivation (optionnel)',
      'cover_letter_placeholder': 'Expliquez pourquoi vous êtes intéressé par ce poste...',
      'send_application': 'Envoyer ma candidature',
      'application_sent': 'Candidature Envoyée!',
      'application_success': 'Votre candidature pour {title} a été soumise avec succès',
      'cv_required': '⚠️ CV Requis',
      'please_select_cv': 'Veuillez sélectionner votre CV',
      'email_required': '⚠️ Email Requis',
      'application_sent_message': 'Votre candidature a été envoyée avec succès',
      'confirmation_email_info': 'Un email de confirmation a été envoyé dans votre boîte de réception',
      'apply_button': 'Postuler',
      'cancel_button': 'Annuler',
      'confirm_application': 'Confirmer la candidature',
      'confirm_application_message': 'Êtes-vous sûr de vouloir postuler pour ce poste ?',
    },
    'es': {
      // Navegación y General
      'dashboard': 'Panel de Control',
      'profile': 'Perfil',
      'settings': 'Configuración',
      'logout': 'Cerrar Sesión',
      'back': 'Volver',
      'next': 'Siguiente',
      'continue': 'Continuar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'create': 'Crear',
      'search': 'Buscar',
      'loading': 'Cargando...',
      'error': 'Error',
      'cancel': 'Cancelar',
      'close': 'Cerrar',

      // Cambio de idioma
      'language_switched': 'Idioma cambiado',
      'switched_to': 'Cambiado a',
      'switched_to_french': 'Cambiado al francés',
      'switched_to_english': 'Cambiado al inglés',

      // Autenticación
      'first_name': 'Nombre',
      'last_name': 'Apellido',
      'password': 'Contraseña',
      'password_hint': 'Contraseña (min 8 caracteres)',
      'create_account': 'Crear Tu Cuenta',
      'sign_in': 'Iniciar Sesión',
      'sign_up': 'Registrarse',
      'create_account_as_pro': 'Crear cuenta como',

      // Profil
      'my_profile': 'Mi Perfil',
      'edit_profile': 'Editar Perfil',
      'full_name': 'Nombre Completo',
      'email': 'Email',
      'phone': 'Teléfono',
      'city': 'Ciudad',
      'country': 'País',

      // Empleos
      'apply': 'Aplicar',
      'job_offers': 'Ofertas de Trabajo',
      'apply_button': 'Aplicar',
      'cancel_button': 'Cancelar',
      'job recommendation': 'Recomendación de empleo',
    },
  };
}