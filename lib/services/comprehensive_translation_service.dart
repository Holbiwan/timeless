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

  // Langues supportées avec leurs codes et noms
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

  // Drapeaux emoji pour chaque langue
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
      // Charger la langue depuis les préférences
      final savedLang = PreferencesService.getString(PrefKeys.currentLanguage);
      if (savedLang.isNotEmpty && supportedLanguages.containsKey(savedLang)) {
        currentLanguage.value = savedLang;
        _setLanguageWithoutNotification(savedLang);
      } else {
        // Détecter la langue du système
        final systemLocale = Get.deviceLocale?.languageCode ?? 'en';
        currentLanguage.value =
            supportedLanguages.containsKey(systemLocale) ? systemLocale : 'en';
      }

      // Charger les préférences de traduction automatique
      isAutoTranslateEnabled.value =
          PreferencesService.getBool('auto_translate_enabled');
    } catch (e) {
      print('Erreur chargement préférences: $e');
      // Valeurs par défaut en cas d'erreur
      currentLanguage.value = 'en';
      isAutoTranslateEnabled.value = false;
    }
  }

  // Change la langue sans notification (pour le chargement initial)
  void _setLanguageWithoutNotification(String langCode) {
    if (supportedLanguages.containsKey(langCode)) {
      currentLanguage.value = langCode;

      // Changer la locale avec Easy Localization si possible
      try {
        if (Get.context != null) {
          Get.context!.setLocale(Locale(langCode));
        }
      } catch (e) {
        print('Erreur changement locale: $e');
      }
    }
  }

  // Change la langue de l'application
  void setLanguage(String langCode) {
    if (supportedLanguages.containsKey(langCode)) {
      currentLanguage.value = langCode;

      // Changer la locale avec Easy Localization si possible
      if (Get.context != null) {
        Get.context!.setLocale(Locale(langCode));
      }

      // Sauvegarder la préférence
      try {
        PreferencesService.setValue(PrefKeys.currentLanguage, langCode);
      } catch (e) {
        print('Erreur sauvegarde langue: $e');
      }

      // Notification de succès
      AppTheme.showStandardSnackBar(
        title: "Language Changed",
        message: "Switched to ${supportedLanguages[langCode]}",
        isSuccess: true,
      );
    }
  }

  // Active/Désactive la traduction automatique
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

  // Traduit un texte vers la langue actuelle
  Future<String> translateText(String text, {String? targetLang}) async {
    if (text.isEmpty) return text;

    final target = targetLang ?? currentLanguage.value;

    // Si c'est la même langue, pas besoin de traduire
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

  // Affiche une erreur de traduction à l'utilisateur
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

  // Traduit automatiquement si l'option est activée
  Future<String> autoTranslateIfEnabled(String text,
      {String? targetLang}) async {
    if (isAutoTranslateEnabled.value) {
      return await translateText(text, targetLang: targetLang);
    }
    return text;
  }

  // Détecte la langue d'un texte
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

  // Vérifie si le service de traduction est disponible
  Future<bool> isTranslationServiceAvailable() async {
    try {
      final testResult = await GoogleTranslationService.translateText(
        text: 'test',
        targetLanguage: 'fr',
      );
      return testResult != null;
    } catch (e) {
      print('Service de traduction non disponible: $e');
      return false;
    }
  }

  // Vérifie si un texte est probablement en anglais (simple heuristique)
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

    // Si plus de 20% des mots sont des mots anglais courants
    return englishWordsFound > wordsInText.length * 0.2;
  }

  // Nettoie les ressources du service
  @override
  void onClose() {
    // Nettoyer les ressources si nécessaire
    super.onClose();
  }

  // Réinitialise le service aux valeurs par défaut
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

  // Méthodes de commodité pour changer de langue
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

  // Toggle entre les langues principales
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
