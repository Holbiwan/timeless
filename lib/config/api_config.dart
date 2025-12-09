// lib/config/api_config.dart
// Configuration des clés API - FICHIER SENSIBLE
// ⚠️ NE PAS COMMITTER CE FICHIER SUR GIT !

class ApiConfig {
  // Clé API Google Cloud Translation
  // Remplacez 'YOUR_REAL_API_KEY_HERE' par votre vraie clé API
  static const String googleTranslationApiKey = 'AIzaSyBLcuWuFnr8y6bMDi1xsQpOFzW_QN14Tvc';
  
  // Autres clés API (pour usage futur)
  // static const String firebaseApiKey = 'YOUR_FIREBASE_KEY';
  // static const String mapApiKey = 'YOUR_MAP_KEY';
  
  // URLs de base
  static const String googleTranslationBaseUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  // Configuration de debug
  static const bool enableApiLogging = true;
  static const bool enableErrorLogging = true;
}