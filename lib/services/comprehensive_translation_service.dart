// lib/services/comprehensive_translation_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/google_translation_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_theme.dart';

class ComprehensiveTranslationService extends GetxController {
  static ComprehensiveTranslationService get instance => Get.find();

  var currentLanguage = 'en'.obs;
  var isAutoTranslateEnabled = false.obs;
  var isTranslating = false.obs;

  // Supported languages ​​with their codes and names
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
    loadPreferences();
  }

  void loadPreferences() {
    try {
      // Load language from preferences
      final savedLang = PreferencesService.getString(PrefKeys.currentLanguage);
      if (savedLang.isNotEmpty && supportedLanguages.containsKey(savedLang)) {
        currentLanguage.value = savedLang;
        _setLanguageWithoutNotification(savedLang);
      } else {
        // Detect system language
        final systemLocale = Get.deviceLocale?.languageCode ?? 'en';
        currentLanguage.value =
            supportedLanguages.containsKey(systemLocale) ? systemLocale : 'en';
      }

      // Load automatic translation preferences
      isAutoTranslateEnabled.value =
          PreferencesService.getBool('auto_translate_enabled');
    } catch (e) {
      print('Erreur chargement préférences: $e');
      // Valeurs par défaut en cas d'erreur
      currentLanguage.value = 'en';
      isAutoTranslateEnabled.value = false;
    }
  }

  // Changes language without notification (for initial loading)
  void _setLanguageWithoutNotification(String langCode) {
    if (supportedLanguages.containsKey(langCode)) {
      currentLanguage.value = langCode;

      // Change locale with Easy Localization
      try {
        if (Get.context != null) {
          Get.context!.setLocale(Locale(langCode));
        }
      } catch (e) {
        print('Erreur changement locale: $e');
      }
    }
  }

  // Change the app language
  void setLanguage(String langCode) {
    if (supportedLanguages.containsKey(langCode)) {
      currentLanguage.value = langCode;

      // Change locale with Easy Localization if possible
      if (Get.context != null) {
        Get.context!.setLocale(Locale(langCode));
      }

      // Save preference
      try {
        PreferencesService.setValue(PrefKeys.currentLanguage, langCode);
      } catch (e) {
        print('Erreur sauvegarde langue: $e');
      }

      // Success notification
      AppTheme.showStandardSnackBar(
        title: "Language Changed",
        message: "Switched to ${supportedLanguages[langCode]}",
        isSuccess: true,
      );
    }
  }

  // Enables/Disables automatic translation
  void toggleAutoTranslate() {
    isAutoTranslateEnabled.value = !isAutoTranslateEnabled.value;
    try {
      PreferencesService.setValue(
          'auto_translate_enabled', isAutoTranslateEnabled.value);
    } catch (e) {
      print('Erreur sauvegarde auto-translate: $e');
    }

    AppTheme.showStandardSnackBar(
      title: "Auto Translation",
      message: isAutoTranslateEnabled.value ? "Enabled" : "Disabled",
      isSuccess: true,
    );
  }

  // Translates a text into the current language
  Future<String> translateText(String text, {String? targetLang}) async {
    if (text.isEmpty) return text;

    final target = targetLang ?? currentLanguage.value;

    // If it's the same language, no need to translate
    if (target == 'en' && await _isEnglishText(text)) {
      return text;
    }

    try {
      isTranslating.value = true;

      final translatedText = await GoogleTranslationService.translateText(
        text: text,
        targetLanguage: target,
      );

      if (translatedText != null && translatedText.isNotEmpty) {
        return translatedText;
      } else {
        print('Traduction vide ou nulle reçue');
        return text;
      }
    } catch (e) {
      print('Erreur de traduction: $e');
      _showTranslationError(
          'Translation failed. Check your internet connection.');
      return text;
    } finally {
      isTranslating.value = false;
    }
  }

  // Shows a translation error to the user
  void _showTranslationError(String message) {
    try {
      AppTheme.showStandardSnackBar(
        title: "Translation Error",
        message: message,
        isSuccess: false,
      );
    } catch (e) {
      print('Impossible d\'afficher l\'erreur: $e');
    }
  }

  // Automatically translates if the option is enabled
  Future<String> autoTranslateIfEnabled(String text,
      {String? targetLang}) async {
    if (isAutoTranslateEnabled.value) {
      return await translateText(text, targetLang: targetLang);
    }
    return text;
  }

  // Detects the language of a text
  Future<String?> detectLanguage(String text) async {
    if (text.trim().isEmpty) return null;

    try {
      final detectedLang = await GoogleTranslationService.detectLanguage(text);
      return detectedLang;
    } catch (e) {
      print('Erreur de détection de langue: $e');
      _showTranslationError(
          'Language detection failed. Check your internet connection.');
      return null;
    }
  }

  // Check if the translation service is available
  Future<bool> isTranslationServiceAvailable() async {
    try {
      final testResult = await GoogleTranslationService.translateText(
        text: 'test',
        targetLanguage: 'fr',
      );
      return testResult != null;
    } catch (e) {
      print('Translation service not available: $e');
      return false;
    }
  }

  // Check if a text is probably English (simple heuristic)
  Future<bool> _isEnglishText(String text) async {
    if (text.trim().isEmpty) return false;

    final commonEnglishWords = [
      'the',
      'and',
      'is',
      'in',
      'to',
      'of',
      'a',
      'that',
      'it',
      'with',
      'for',
      'you',
      'this',
      'are',
      'on',
      'as',
      'be',
      'or',
      'an',
      'by'
    ];

    final cleanText = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ');
    final wordsInText = cleanText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (wordsInText.isEmpty) return false;

    int englishWordsFound = 0;
    for (String word in wordsInText) {
      if (commonEnglishWords.contains(word)) {
        englishWordsFound++;
      }
    }

    // If more than 20% of words are common English words
    return englishWordsFound > wordsInText.length * 0.2;
  }

  // Cleans up the service resources
  @override
  void onClose() {
    // Clean up resources if necessary
    super.onClose();
  }

  // Resets the service to default values
  void resetToDefaults() {
    try {
      currentLanguage.value = 'en';
      isAutoTranslateEnabled.value = false;
      isTranslating.value = false;

      PreferencesService.setValue(PrefKeys.currentLanguage, 'en');
      PreferencesService.setValue('auto_translate_enabled', false);

      AppTheme.showStandardSnackBar(
        title: "Settings Reset",
        message: "Translation settings have been reset to defaults",
        isSuccess: true,
      );
    } catch (e) {
      print('Erreur lors de la réinitialisation: $e');
    }
  }

  // Convenience methods to change language
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

  // Toggle between main languages
  void toggleMainLanguages() {
    switch (currentLanguage.value) {
      case 'en':
        setFrench();
        break;
      case 'fr':
        setSpanish();
        break;
      case 'es':
        setArabic();
        break;
      case 'ar':
        setEnglish();
        break;
      default:
        setEnglish();
    }
  }

  // Getters pour l'UI
  String get currentLanguageName =>
      supportedLanguages[currentLanguage.value] ?? 'English';
  String get currentFlag => languageFlags[currentLanguage.value] ?? '🇺🇸';

  List<String> get availableLanguageCodes => supportedLanguages.keys.toList();

  String getLanguageName(String code) => supportedLanguages[code] ?? 'Unknown';
  String getLanguageFlag(String code) => languageFlags[code] ?? '🏳️';
}
