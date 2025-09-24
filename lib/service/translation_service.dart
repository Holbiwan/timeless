// lib/service/translation_service.dart
import 'package:get/get.dart';

class TranslationService extends GetxController {
  static TranslationService get instance => Get.find();
  
  var currentLanguage = 'en'.obs; // 'en' pour anglais, 'fr' pour français
  
  void toggleLanguage() {
    currentLanguage.value = currentLanguage.value == 'en' ? 'fr' : 'en';
  }
  
  String getText(String key) {
    return translations[currentLanguage.value]?[key] ?? key;
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
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'create': 'Create',
      'search': 'Search',
      'loading': 'Loading...',
      
      // Smart Matching
      'smart_matching': 'Smart Job Matching',
      'intelligent_matching_system': 'Intelligent Matching System',
      'algorithm_description': 'Our algorithm analyzes your profile and skills to find the best matching jobs',
      'find_matches': '🔍 Find My Matches',
      'analyzing_profile': 'Analyzing Profile...',
      'processing_skills': 'Processing skills and preferences',
      'calculated_matches': '🎯 Your Calculated Matches',
      'apply': 'Apply',
      'saved': 'Saved',
      'bookmark_added': 'Job added to bookmarks',
      'match_percentage': '% Match',
      'why_great_match': 'Why this is a great match:',
      'skills_match': '📋 skills match',
      'location': '📍 Location',
      'contract_type': '💼 Contract type',
      'category': '🎯 Category',
      
      // Analytics Dashboard
      'analytics_dashboard': '📊 Analytics Dashboard',
      'job_offers': 'Job Offers',
      'users': 'Users',
      'applications': 'Applications',
      'success_rate': 'Success Rate',
      'live_activity_feed': '🔴 Live Activity Feed',
      'jobs_by_category': '📈 Jobs by Category',
      'ai_insights': '🎯 Smart Insights',
      
      // Apply Screen
      'apply_screen_title': '📝 Apply',
      'upload_cv': '📄 Upload your CV *',
      'click_select_cv': '📁 Click to select your CV',
      'accepted_formats': 'Accepted formats: PDF, DOC, DOCX',
      'cv_selected': '✅ CV Selected',
      'contact_info': '📧 Contact Information',
      'email': 'Email *',
      'phone': 'Phone',
      'cover_letter': '💬 Cover Letter (optional)',
      'cover_letter_placeholder': 'Explain why you are interested in this position...',
      'send_application': 'Send my application',
      'application_sent': '🎉 Application Sent!',
      'application_success': 'Your application for {title} has been successfully submitted',
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
      'create_account': 'Create account',
      'first_name': 'First name',
      'last_name': 'Last name',
      'password': 'Password',
      'password_hint': 'Password (min 8 chars)',
      'create_user_email': '🎯 Create User + Email',
      'user_created_success': '✅ USER CREATED SUCCESSFULLY!',
      'demo_credentials': '🎫 Demo Credentials:',
      
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
      'smart_matching': '🎯 Smart Job Matching',
      'intelligent_matching_system': 'Système de Matching Intelligent',
      'algorithm_description': 'Notre algorithme analyse votre profil et compétences pour trouver les meilleurs emplois correspondants',
      'find_matches': '🔍 Trouver mes correspondances',
      'analyzing_profile': 'Analyse en cours...',
      'processing_skills': 'Traitement des compétences et préférences',
      'calculated_matches': '🎯 Vos Correspondances Calculées',
      'apply': 'Postuler',
      'saved': 'Sauvegardé',
      'bookmark_added': 'Offre ajoutée aux favoris',
      'match_percentage': '% de correspondance',
      'why_great_match': 'Pourquoi c\'est une excellente correspondance:',
      'skills_match': '📋 compétences correspondent',
      'location': '📍 Localisation',
      'contract_type': '💼 Type de contrat',
      'category': '🎯 Catégorie',
      
      // Analytics Dashboard
      'analytics_dashboard': '📊 Tableau de Bord',
      'job_offers': 'Offres d\'Emploi',
      'users': 'Utilisateurs',
      'applications': 'Candidatures',
      'success_rate': 'Taux Réussite',
      'live_activity_feed': '🔴 Activité en Temps Réel',
      'jobs_by_category': '📈 Emplois par Catégorie',
      'ai_insights': '🎯 Analyses Intelligentes',
      
      // Apply Screen
      'apply_screen_title': '📝 Postuler',
      'upload_cv': '📄 Télécharger votre CV *',
      'click_select_cv': '📁 Cliquez pour sélectionner votre CV',
      'accepted_formats': 'Formats acceptés: PDF, DOC, DOCX',
      'cv_selected': '✅ CV Sélectionné',
      'contact_info': '📧 Informations de contact',
      'email': 'Email *',
      'phone': 'Téléphone',
      'cover_letter': '💬 Lettre de motivation (optionnel)',
      'cover_letter_placeholder': 'Expliquez pourquoi vous êtes intéressé par ce poste...',
      'send_application': 'Envoyer ma candidature',
      'application_sent': '🎉 Candidature Envoyée!',
      'application_success': 'Votre candidature pour {title} a été soumise avec succès',
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
      'create_account': 'Créer un compte',
      'first_name': 'Prénom',
      'last_name': 'Nom',
      'password': 'Mot de passe',
      'password_hint': 'Mot de passe (min 8 car.)',
      'create_user_email': '🎯 Créer Utilisateur + Email',
      'user_created_success': '✅ UTILISATEUR CRÉÉ AVEC SUCCÈS!',
      'demo_credentials': '🎫 Identifiants de Démo:',
      
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
    },
  };
}