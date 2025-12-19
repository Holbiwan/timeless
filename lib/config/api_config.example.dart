// API configuration example file
// Copy this file to api_config.dart and add your real keys

class ApiConfig {
  // Google Cloud Translation API key
  // Get your key from: https://console.cloud.google.com/
  static const String googleTranslationApiKey =
      'YOUR_GOOGLE_TRANSLATION_API_KEY_HERE';

  // Other API keys (for future use)
  // static const String firebaseApiKey = 'YOUR_FIREBASE_KEY_HERE';
  // static const String mapApiKey = 'YOUR_MAP_KEY_HERE';

  // Base URL for Google Translation API
  static const String googleTranslationBaseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  // Debug options
  static const bool enableApiLogging = true;
  static const bool enableErrorLogging = true;
}
