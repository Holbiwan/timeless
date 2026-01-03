// API configuration file
// Add your real API keys here for production use

class ApiConfig {
  // Google Cloud Translation API key
  // Get your key from: https://console.cloud.google.com/
  static const String googleTranslationApiKey =
      'AIzaSyDummyKeyForDevelopment'; // Replace with real key

  // Base URL for Google Translation API
  static const String googleTranslationBaseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  // Debug options
  static const bool enableApiLogging = true;
  static const bool enableErrorLogging = true;
}