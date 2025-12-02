// lib/service/translation_service.dart
import 'package:get/get.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/google_translation_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:flutter/foundation.dart';

class TranslationService extends GetxController {
  static TranslationService get instance => Get.find();

  var currentLanguage = 'en'.obs; // 'en' pour anglais, 'fr' pour français

  @override
  void onInit() {
    super.onInit();
    loadLanguageFromPreferences();
  }

  void loadLanguageFromPreferences() {
    currentLanguage.value =
        PreferencesService.getString(PrefKeys.currentLanguage).isEmpty
            ? 'en'
            : PreferencesService.getString(PrefKeys.currentLanguage);
  }

  void toggleLanguage() {
    currentLanguage.value = currentLanguage.value == 'en' ? 'fr' : 'en';
    PreferencesService.setValue(
        PrefKeys.currentLanguage, currentLanguage.value);
  }

  String getText(String key) {
    return translations[currentLanguage.value]?[key] ?? key;
  }

  // Traduit un texte dynamique via Google Translate
  // Utilisez cette méthode pour traduire du contenu utilisateur ou dynamique
  Future<String> translateDynamicText(String text, {String? targetLang}) async {
    try {
      final target = targetLang ?? currentLanguage.value;
      final translated = await GoogleTranslationService.translateText(
        text: text,
        targetLanguage: target,
      );
      return translated ??
          text; // Retourne le texte original si la traduction échoue
    } catch (e) {
      if (kDebugMode) {
        print('Erreur traduction dynamique: $e');
      }
      return text; // Retourne le texte original en cas d'erreur
    }
  }

  // Détecte automatiquement la langue d'un texte
  Future<String?> detectTextLanguage(String text) async {
    return await GoogleTranslationService.detectLanguage(text);
  }

  // Obtient les langues supportées par Google Translate
  Future<List<Language>?> getSupportedLanguages() async {
    return await GoogleTranslationService.getSupportedLanguages();
  }

  // Traductions pour toute l'application
  static const Map<String, Map<String, String>> translations = {
    'en': {
      // Navigation et général
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

      // Smart Matching
      'smart_matching': 'Smart Job Matching',
      'intelligent_matching_system': 'Intelligent Matching System',
      'algorithm_description':
          'Our algorithm analyzes your profile and skills to find the best matching jobs',
      'find_matches': ' Find My Matches',
      'analyzing_profile': 'Analyzing Profile...',
      'processing_skills': 'Processing skills and preferences',
      'calculated_matches': ' Your Calculated Matches',
      'apply': 'Apply',
      'saved': 'Saved',
      'bookmark_added': 'Job added to bookmarks',
      'match_percentage': '% Match',
      'why_great_match': 'Why this is a great match:',
      'skills_match': ' skills match',
      'location_match': ' Location',
      'contract_type': ' Contract type',
      'category': ' Category',

      // Analytics Dashboard
      'analytics_dashboard': ' Analytics Dashboard',
      'job_offers': 'Job Offers',
      'users': 'Users',
      'applications': 'Applications',
      'success_rate': 'Success Rate',
      'live_activity_feed': ' Live Activity Feed',
      'jobs_by_category': ' Jobs by Category',
      'ai_insights': ' Smart Insights',

      // Apply Screen
      'apply_screen_title': ' Apply',
      'upload_cv': ' Upload your CV *',
      'click_select_cv': ' Click to select your CV',
      'accepted_formats': 'Accepted formats: PDF, DOC, DOCX',
      'cv_selected': '✅ CV Selected',
      'contact_info': ' Contact Information',
      'cover_letter': ' Cover Letter (optional)',
      'cover_letter_placeholder':
          'Explain why you are interested in this position...',
      'send_application': 'Send my application',
      'application_sent': ' Application Sent!',
      'application_success':
          'Your application for {title} has been successfully submitted',
      'cv_required': '⚠️ CV Required',
      'please_select_cv': 'Please select your CV',
      'email_required': '⚠️ Email Required',
      'please_enter_email': 'Please enter your email',
      'correspondence': 'correspondence',

      // Home Screen
      'see_jobs': 'See Jobs',
      'smart_matching_btn': 'Smart Matching',
      'analytics_btn': 'Analytics',
      'job_recommendation': 'Job Recommendations',
      'see_all': 'See All',

      // Auth Screens
      'first_name': 'First name',
      'last_name': 'Last name',
      'password': 'Password',
      'password_hint': 'Password (min 8 chars)',
      'create_user_email': ' Create User + Email',
      'user_created_success': '✅ USER CREATED SUCCESSFULLY!',
      'demo_credentials': ' Demo Credentials:',

      // Job Categories
      'software_development': 'Software Development',
      'data_science': 'Data Science',
      'design': 'Design',
      'product_management': 'Product Management',
      'cybersecurity': 'Cybersecurity',

      // Common Job Fields
      'position': 'Position',
      'company': 'Company',
      'salary': 'Salary',
      'requirements': 'Requirements',
      'description': 'Description',
      'posted_date': 'Posted Date',
      'apply_now': 'Apply Now',

      // Error Messages
      'error': 'Error',
      'connection_error': 'Connection error',
      'please_try_again': 'Please try again',
      'invalid_email': 'Invalid email',
      'password_too_short': 'Password too short',
      'please_enter_password': 'Please enter password',

      // Profile Completion Screen
      'welcome_user': 'Welcome {name}!',
      'complete_profile_description':
          'Complete your profile to personalize your Timeless experience',
      'professional_profile': 'Professional Profile',
      'first_name_label': 'First Name',
      'last_name_label': 'Last Name',
      'phone_label': 'Phone',
      'position_wanted': 'Position Wanted',
      'position_placeholder': 'Ex: Flutter Developer, UX Designer...',
      'experience_level': 'Experience Level',
      'city_label': 'City',
      'city_placeholder': 'Ex: Paris, London, Remote...',
      'bio_optional': 'Bio (optional)',
      'bio_placeholder': 'Describe yourself in a few words...',
      'skip_for_now': 'Skip for now',
      'finish': 'Finish',
      'switch_account': 'Switch Account',
      'sign_out': 'Sign Out',
      'account_switched': 'Account Switched',
      'connected_with': 'Connected with {email}',
      'account_switch_cancelled': 'Account switch cancelled',
      'logout_confirmation': 'Logout',
      'logout_message': 'Are you sure you want to logout?',
      'logout_description':
          'You will need to sign in again to access your account.',
      'logout_success': 'Logout Successful',
      'see_you_soon': 'See you soon on Timeless!',
      'missing_information': 'Missing Information',
      'first_last_name_required': 'First name and last name are required',
      'profile_completed': 'Profile Completed!',
      'welcome_to_timeless': 'Welcome to Timeless',
      'profile_save_error': 'Unable to save profile',

      // Experience Levels
      'experience_internship': 'Internship / Apprenticeship',
      'experience_junior': 'Junior (0-2 years)',
      'experience_mid': 'Experienced (3-5 years)',
      'experience_senior': 'Senior (5-10 years)',
      'experience_expert': 'Expert (10+ years)',

      // First Screen / Welcome Screen
      'app_tagline': 'Bridging the gap with timeless talent',
      'create_account': 'Create Your Account',
      'already_have_account': 'Already have an account?',
      'sign_in': 'Sign In',
      'employer_access': 'Pro Access',
      'continue_as_guest': 'Tour as Guest',
      'terms_agreement': 'By creating an account, you are agreeing to our',
      'terms_of_service': 'Terms of Service',
      'welcome': 'Welcome',
      'accessibility': 'Accessibility',
      'language_switched': 'Language switched',
      'switched_to_french': 'Switched to French',
      'switched_to_english': 'Switched to English',

      // Help Dialog
      'help': 'Help',
      'help_welcome': 'Welcome to Timeless!',
      'help_profile_desc': '• Profile: View and edit your personal information',
      'help_settings_desc':
          '• Settings: Configure the app according to your preferences',
      'help_accessibility_desc':
          '• Accessibility: Adjust accessibility settings',
      'help_help_desc': '• Help: View this help',
      'help_contact': 'For more help, contact our support.',
      'close': 'Close',

      // Settings
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'theme_switched': 'Theme switched',
      'theme_switched_dark': 'Switched to dark mode',
      'theme_switched_light': 'Switched to light mode',

      // Profile Screen
      'my_profile': 'My Profile',
      'personal_information': 'Personal Information',
      'location': 'Location',
      'professional_information': 'Professional Information',
      'full_name': 'Full Name',
      'email': 'Email',
      'phone': 'Phone',
      'date_of_birth': 'Date of Birth',
      'city': 'City',
      'state': 'State',
      'country': 'Country',
      'current_occupation': 'Current Occupation',
      'job_position': 'Job Position',
      'bio': 'Bio',
      'not_specified': 'Not specified',
      'your_name': 'Your Name',
      'edit_profile': 'Edit Profile',
      'job_preferences': 'Job Preferences',
      'clear_profile_data': 'Clear Profile Data (Reset)',
      'clear_profile_title': 'Clear Profile Data',
      'clear_profile_message':
          'This will clear all your profile and preference data. Are you sure?',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'clearing_data': 'Clearing data...',
      'profile_cleared': 'Profile Cleared',
      'profile_cleared_message':
          'All profile and preference data has been cleared. You can now enter your own information.',

      // Guest Tour
      'guest_browser_title': 'Browse as Guest',
      'guest_browser_welcome': 'Browse as a guest',
      'guest_browser_description':
          'You can view tips and see job offers. To apply, you\'ll need to sign in or create an account.',
      'tips_for_you': 'Tips for You',
      'tips_for_you_subtitle': 'Advice for your job search',
      'see_job_offers': 'See Job Offers',
      'see_job_offers_subtitle': 'Browse available positions',
      'ready_to_apply': 'Ready to apply?',
      'ready_to_apply_description': 'Create your account to apply for jobs',
      'create_account_cta': 'Create Account',
      'sign_in_cta': 'Sign In',
      'job_offers_title': 'Job Offers',
      'login_required': 'Login Required',
      'login_required_message':
          'To apply for this position, you must sign in or create an account.',
      'sign_up': 'Sign Up',
      'sign_in_as': 'Sign in as',
      'candidate_already_account':
          'You are a candidate and\nalready have an account',

      // Employer Screens
      'employer_signin_title': 'Sign In as PRO',
      'employer_signin_subtitle': 'Choose your connection method',
      'signin_with_siret': 'Sign in with your SIRET code',
      'signin_with_siret_description':
          'Use your SIRET number to quickly access your employer account',
      'fast_access': 'Fast access',
      'signin_with_ape_email_password': 'Sign in with APE + Email + Password',
      'signin_with_ape_description':
          'Use your APE code, professional email and password to access your account',
      'secure_connection': 'Secure connection',
      'first_connection_note':
          'First connection? Your account must be created beforehand with your company information.',
      'or': 'OR',
      'siret_signin_title': 'SIRET Connection',
      'siret_signin_subtitle':
          'Enter your SIRET number to access your employer space',
      'siret_code': 'SIRET Code',
      'siret_placeholder': 'Ex: 12345678901234',
      'siret_info':
          'SIRET is a unique 14-digit identifier assigned to each business establishment in France.',
      'signin': 'Sign In',
      'use_other_method': 'Use another connection method',
      'ape_signin_title': 'Secure Connection',
      'ape_signin_subtitle': 'APE Code + Email + Password',
      'ape_code': 'APE Code',
      'ape_placeholder': 'Ex: 6201Z',
      'professional_email': 'Professional email',
      'professional_email_placeholder': 'contact@your-company.com',
      'your_password': 'Your password',
      'ape_verification_info':
          'We verify that your APE code and email match a registered employer account.',
      'Create pro Account': 'Create PRO Account',

      // Accessibility
      'accessibility_settings': 'Accessibility Settings',
      'accessibility_features': 'Accessibility Features',
      'accessibility_description':
          'Configure features for better accessibility',
      'visual_accessibility': 'Visual Accessibility',
      'hearing_accessibility': 'Hearing Accessibility',
      'high_contrast_mode': 'High Contrast Mode',
      'high_contrast_description':
          'Improves visibility with high contrast colors',
      'dark_mode_description': 'Reduces eye strain with dark theme',
      'large_text': 'Large Text',
      'large_text_description': 'Increases text size for better readability',
      'vibration_feedback': 'Vibration Feedback',
      'vibration_feedback_description': 'Feel vibrations for audio cues',
      'visual_feedback': 'Visual Feedback',
      'visual_feedback_description':
          'See visual notifications instead of audio',
      'voice_descriptions': 'Voice Descriptions',
      'voice_descriptions_description': 'Enable detailed voice descriptions',
      'font_size_control': 'Font Size Control',
      'font_size_description': 'Adjust text size for better readability',
      'test_settings': 'Test Your Settings',
      'test_settings_description':
          'This is a sample text to test your accessibility settings. You can see how the contrast, font size, and other features affect readability.',
      'test_button': 'Test Button',
      'reset_to_default': 'Reset to Default',
      'reset_dialog_title': 'Reset Accessibility Settings',
      'reset_dialog_message':
          'This will reset all accessibility settings to their default values. Continue?',
      'reset': 'Reset',
    },
    'fr': {
      // Navigation et général
      'dashboard': 'Tableau de Bord',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'logout': 'Déconnexion',
      'back': 'Retour',
      'next': 'Suivant',
      'continue': 'Continuer',
      'cancel': 'Annuler',
      'save': 'Sauvegarder',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'create': 'Créer',
      'search': 'Rechercher',
      'loading': 'Chargement...',

      // Smart Matching
      'smart_matching': ' Smart Job Matching',
      'intelligent_matching_system': 'Système de Matching Intelligent',
      'algorithm_description':
          'Notre algorithme analyse votre profil et compétences pour trouver les meilleurs emplois correspondants',
      'find_matches': ' Trouver mes correspondances',
      'analyzing_profile': 'Analyse en cours...',
      'processing_skills': 'Traitement des compétences et préférences',
      'calculated_matches': ' Vos Correspondances Calculées',
      'apply': 'Postuler',
      'saved': 'Sauvegardé',
      'bookmark_added': 'Offre ajoutée aux favoris',
      'match_percentage': '% de correspondance',
      'why_great_match': 'Pourquoi c\'est une excellente correspondance:',
      'skills_match': ' compétences correspondent',
      'location_match': ' Localisation',
      'contract_type': ' Type de contrat',
      'category': ' Catégorie',

      // Analytics Dashboard
      'analytics_dashboard': ' Tableau de Bord',
      'job_offers': 'Offres d\'Emploi',
      'users': 'Utilisateurs',
      'applications': 'Candidatures',
      'success_rate': 'Taux Réussite',
      'live_activity_feed': ' Activité en Temps Réel',
      'jobs_by_category': ' Emplois par Catégorie',
      'ai_insights': ' Analyses Intelligentes',

      // Apply Screen
      'apply_screen_title': ' Postuler',
      'upload_cv': ' Télécharger votre CV *',
      'click_select_cv': ' Cliquez pour sélectionner votre CV',
      'accepted_formats': 'Formats acceptés: PDF, DOC, DOCX',
      'cv_selected': '✅ CV Sélectionné',
      'contact_info': ' Informations de contact',
      'cover_letter': ' Lettre de motivation (optionnel)',
      'cover_letter_placeholder':
          'Expliquez pourquoi vous êtes intéressé par ce poste...',
      'send_application': 'Envoyer ma candidature',
      'application_sent': ' Candidature Envoyée!',
      'application_success':
          'Votre candidature pour {title} a été soumise avec succès',
      'cv_required': '⚠️ CV Requis',
      'please_select_cv': 'Veuillez sélectionner votre CV',
      'email_required': '⚠️ Email Requis',
      'correspondence': 'correspondance',

      // Home Screen
      'see_jobs': 'Voir les Emplois',
      'smart_matching_btn': 'Smart Matching',
      'analytics_btn': 'Analytics',
      'job_recommendation': 'Recommandations d\'Emplois',
      'see_all': 'Voir Tout',

      // Auth Screens
      'first_name': 'Prénom',
      'last_name': 'Nom',
      'password': 'Mot de passe',
      'password_hint': 'Mot de passe (min 8 car.)',
      'create_user_email': ' Créer Utilisateur + Email',
      'user_created_success': '✅ UTILISATEUR CRÉÉ AVEC SUCCÈS!',
      'demo_credentials': ' Identifiants de Démo:',

      // Job Categories
      'software_development': 'Développement Logiciel',
      'data_science': 'Science des Données',
      'design': 'Design',
      'product_management': 'Gestion de Produit',
      'cybersecurity': 'Cybersécurité',

      // Common Job Fields
      'position': 'Poste',
      'company': 'Entreprise',
      'salary': 'Salaire',
      'requirements': 'Exigences',
      'description': 'Description',
      'posted_date': 'Date de Publication',
      'apply_now': 'Postuler Maintenant',

      // Error Messages
      'error': 'Erreur',
      'connection_error': 'Erreur de connexion',
      'please_try_again': 'Veuillez réessayer',
      'invalid_email': 'Email invalide',
      'password_too_short': 'Mot de passe trop court',
      'please_enter_password': 'Veuillez saisir un mot de passe',

      // Profile Completion Screen
      'welcome_user': 'Bienvenue {name} !',
      'complete_profile_description':
          'Complétez votre profil pour personnaliser votre expérience Timeless',
      'personal_information': 'Informations Personnelles',
      'professional_profile': 'Profil professionnel',
      'first_name_label': 'Prénom',
      'last_name_label': 'Nom',
      'phone_label': 'Téléphone',
      'position_wanted': 'Poste recherché',
      'position_placeholder': 'Ex: Développeur Flutter, Designer UX...',
      'experience_level': 'Niveau d\'expérience',
      'city_label': 'Ville',
      'city_placeholder': 'Ex: Paris, Lyon, Remote...',
      'bio_optional': 'Bio (optionnel)',
      'bio_placeholder': 'Décrivez-vous en quelques mots...',
      'skip_for_now': 'Ignorer pour le moment',
      'finish': 'Terminer',
      'switch_account': 'Changer de compte',
      'sign_out': 'Se déconnecter',
      'account_switched': 'Compte changé',
      'connected_with': 'Connecté avec {email}',
      'account_switch_cancelled': 'Changement de compte annulé',
      'logout_confirmation': 'Déconnexion',
      'logout_message': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'logout_description':
          'Vous devrez vous reconnecter pour accéder à votre compte.',
      'logout_success': 'Déconnexion réussie',
      'see_you_soon': 'À bientôt sur Timeless !',
      'missing_information': 'Informations manquantes',
      'first_last_name_required': 'Prénom et nom sont requis',
      'profile_completed': 'Profil complété !',
      'welcome_to_timeless': 'Bienvenue sur Timeless',
      'profile_save_error': 'Impossible de sauvegarder le profil',

      // Experience Levels
      'experience_internship': 'Stage / Alternance',
      'experience_junior': 'Junior (0-2 ans)',
      'experience_mid': 'Confirmé (3-5 ans)',
      'experience_senior': 'Senior (5-10 ans)',
      'experience_expert': 'Expert (10+ ans)',

      // First Screen / Welcome Screen
      'app_tagline': 'Combler le fossé avec un talent intemporel',
      'create_account': 'Créer Votre Compte',
      'already_have_account': 'Vous avez déjà un compte ?',
      'sign_in': 'Se Connecter',
      'employer_access': 'Accès Employeur',
      'continue_as_guest': 'Continuer en Invité',
      'terms_agreement': 'En créant un compte, vous acceptez nos',
      'terms_of_service': 'Conditions d\'Utilisation',
      'welcome': 'Bienvenue',
      'accessibility': 'Accessibilité',
      'language_switched': 'Langue modifiée',
      'switched_to_french': 'Basculé vers le français',
      'switched_to_english': 'Basculé vers l\'anglais',

      // Help Dialog
      'help': 'Aide',
      'help_welcome': 'Bienvenue dans Timeless !',
      'help_profile_desc':
          '• Profile: Consultez et modifiez vos informations personnelles',
      'help_settings_desc':
          '• Settings: Configurez l\'application selon vos préférences',
      'help_accessibility_desc':
          '• Accessibility: Ajustez les paramètres d\'accessibilité',
      'help_help_desc': '• Help: Consultez cette aide',
      'help_contact': 'Pour plus d\'aide, contactez notre support.',
      'close': 'Fermer',

      // Settings
      'appearance': 'Apparence',
      'dark_mode': 'Mode Sombre',
      'light_mode': 'Mode Clair',
      'language': 'Langue',
      'theme_switched': 'Thème modifié',
      'theme_switched_dark': 'Basculé vers le mode sombre',
      'theme_switched_light': 'Basculé vers le mode clair',

      // Profile Screen
      'my_profile': 'Mon Profil',
      'location': 'Localisation',
      'professional_information': 'Informations Professionnelles',
      'full_name': 'Nom Complet',
      'email': 'Email',
      'date_of_birth': 'Date de Naissance',
      'city': 'Ville',
      'state': 'État/Région',
      'country': 'Pays',
      'current_occupation': 'Profession Actuelle',
      'job_position': 'Poste',
      'bio': 'Biographie',
      'not_specified': 'Non spécifié',
      'your_name': 'Votre Nom',
      'edit_profile': 'Modifier le Profil',
      'job_preferences': 'Préférences d\'Emploi',
      'clear_profile_data': 'Effacer les Données (Reset)',
      'clear_profile_title': 'Effacer les Données',
      'clear_profile_message':
          'Ceci effacera toutes vos données de profil et préférences. Êtes-vous sûr ?',
      'clear': 'Effacer',
      'clearing_data': 'Effacement des données...',
      'profile_cleared': 'Profil Effacé',
      'profile_cleared_message':
          'Toutes les données de profil et préférences ont été effacées. Vous pouvez maintenant saisir vos propres informations.',

      // Guest Tour
      'guest_browser_title': 'Parcourir en tant qu\'invité',
      'guest_browser_welcome': 'Parcourez en tant qu\'invité',
      'guest_browser_description':
          'Vous pouvez consulter les conseils et voir les offres d\'emploi. Pour postuler, vous devrez vous connecter ou créer un compte.',
      'tips_for_you': 'Conseils pour vous',
      'tips_for_you_subtitle': 'Conseils pour votre recherche d\'emploi',
      'see_job_offers': 'Voir les offres d\'emploi',
      'see_job_offers_subtitle': 'Parcourir les postes disponibles',
      'ready_to_apply': 'Prêt à postuler ?',
      'ready_to_apply_description':
          'Créez votre compte pour postuler aux offres',
      'create_account_cta': 'Créer un compte',
      'sign_in_cta': 'Se connecter',
      'job_offers_title': 'Offres d\'emploi',
      'login_required': 'Connexion requise',
      'login_required_message':
          'Pour postuler à cette offre, vous devez vous connecter ou créer un compte.',
      'sign_up': 'S\'inscrire',
      'sign_in_as': 'Se connecter en tant que',
      'candidate_already_account': 'Tu es candidat et\na déjà un compte',

      // Employer Screens
      'employer_signin_title': 'Se connecter en tant que PRO',
      'employer_signin_subtitle': 'Choisissez votre méthode de connexion',
      'signin_with_siret': 'Se connecter avec votre code SIRET',
      'signin_with_siret_description':
          'Utilisez votre numéro SIRET pour accéder rapidement à votre compte employeur',
      'fast_access': 'Accès rapide',
      'signin_with_ape_email_password':
          'Se connecter avec APE + Email + Mot de passe',
      'signin_with_ape_description':
          'Utilisez votre code APE, email professionnel et mot de passe pour accéder à votre compte',
      'secure_connection': 'Connexion sécurisée',
      'first_connection_note':
          'Première connexion ? Votre compte doit être créé au préalable avec vos informations d\'entreprise.',
      'or': 'OU',
      'siret_signin_title': 'Connexion par SIRET',
      'siret_signin_subtitle':
          'Saisissez votre numéro SIRET pour accéder à votre espace employeur',
      'siret_code': 'Code SIRET',
      'siret_placeholder': 'Ex: 12345678901234',
      'siret_info':
          'Le SIRET est un identifiant unique de 14 chiffres attribué à chaque établissement d\'entreprise en France.',
      'signin': 'Se connecter',
      'use_other_method': 'Utiliser une autre méthode de connexion',
      'ape_signin_title': 'Connexion sécurisée',
      'ape_signin_subtitle': 'Code APE + Email + Mot de passe',
      'ape_code': 'Code APE',
      'ape_placeholder': 'Ex: 6201Z',
      'professional_email': 'Email professionnel',
      'professional_email_placeholder': 'contact@votre-entreprise.com',
      'your_password': 'Votre mot de passe',
      'ape_verification_info':
          'Nous vérifions que votre code APE et votre email correspondent à un compte employeur enregistré.',
      'Create pro Account': 'Créer un compte PRO',

      // Accessibility
      'accessibility_settings': 'Paramètres d\'Accessibilité',
      'accessibility_features': 'Fonctions d\'Accessibilité',
      'accessibility_description':
          'Configurer les fonctions pour une meilleure accessibilité',
      'visual_accessibility': 'Accessibilité Visuelle',
      'hearing_accessibility': 'Accessibilité Auditive',
      'high_contrast_mode': 'Mode Contraste Élevé',
      'high_contrast_description':
          'Améliore la visibilité avec des couleurs à fort contraste',
      'dark_mode_description':
          'Réduit la fatigue oculaire avec un thème sombre',
      'large_text': 'Texte Agrandi',
      'large_text_description':
          'Augmente la taille du texte pour une meilleure lisibilité',
      'vibration_feedback': 'Retour Vibration',
      'vibration_feedback_description':
          'Ressentir les vibrations pour les signaux audio',
      'visual_feedback': 'Retour Visuel',
      'visual_feedback_description':
          'Voir les notifications visuelles au lieu d\'audio',
      'voice_descriptions': 'Descriptions Vocales',
      'voice_descriptions_description':
          'Activer les descriptions vocales détaillées',
      'font_size_control': 'Contrôle de la Taille de Police',
      'font_size_description':
          'Ajuster la taille du texte pour une meilleure lisibilité',
      'test_settings': 'Tester Vos Paramètres',
      'test_settings_description':
          'Ceci est un exemple de texte pour tester vos paramètres d\'accessibilité. Vous pouvez voir comment le contraste, la taille de police et autres fonctions affectent la lisibilité.',
      'test_button': 'Bouton Test',
      'reset_to_default': 'Réinitialiser par Défaut',
      'reset_dialog_title': 'Réinitialiser les Paramètres d\'Accessibilité',
      'reset_dialog_message':
          'Ceci réinitialisera tous les paramètres d\'accessibilité à leurs valeurs par défaut. Continuer ?',
      'reset': 'Réinitialiser',
    },
  };
}
