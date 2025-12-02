// lib/config/api_config.example.dart
// Fichier exemple pour la configuration des clés API
// COPIEZ CE FICHIER VERS api_config.dart ET AJOUTEZ VOS VRAIES CLÉS

class ApiConfig {
  // Clé API Google Cloud Translation
  // Obtenez votre clé sur: https://console.cloud.google.com/
  static const String googleTranslationApiKey = 'YOUR_GOOGLE_TRANSLATION_API_KEY_HERE';
  
  // Autres clés API (pour usage futur)
  // static const String firebaseApiKey = 'YOUR_FIREBASE_KEY_HERE';
  // static const String mapApiKey = 'YOUR_MAP_KEY_HERE';
  
  // URLs de base
  static const String googleTranslationBaseUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  // Configuration de debug
  static const bool enableApiLogging = true;
  static const bool enableErrorLogging = true;
}